# Run in Windows PowerShell 5.1; reads catalogs and functions through the AST without starting setup.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$source = Join-Path (Split-Path $PSScriptRoot) 'FreshWindowsSetup.UI.ps1'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($source, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
function Assert { param($Condition, $Message) if (-not $Condition) { throw $Message } }

foreach ($name in @('ProgramCatalog', 'VivaldiExtensionCatalog', 'BundledAppCatalog', 'PrivacyCatalog', 'WindowsSettingsSections')) {
    $node = $ast.Find({ param($n) $n -is [Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq "`$$name" }, $false)
    Assert ($null -ne $node) "Catalog $name not found."
    . ([scriptblock]::Create($node.Extent.Text))
}
foreach ($name in @('Get-OptionalProperty', 'Get-CatalogKey', 'Invoke-WinGet')) {
    $node = $ast.Find({ param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name }, $true)
    . ([scriptblock]::Create($node.Extent.Text))
}
$script:logged = [System.Collections.Generic.List[string]]::new()
function Write-SetupLog { param($Message, $Level) $script:logged.Add([string]$Message) }

$settings = @($WindowsSettingsSections | ForEach-Object { $_.Items })
$catalogs = [ordered]@{ Program = $ProgramCatalog; Extension = $VivaldiExtensionCatalog; App = $BundledAppCatalog; Setting = $settings }
foreach ($kind in $catalogs.Keys) {
    $keys = @($catalogs[$kind] | ForEach-Object { Get-CatalogKey $_ })
    $duplicates = @($keys | Group-Object | Where-Object Count -gt 1 | ForEach-Object Name)
    Assert ($duplicates.Count -eq 0) "Duplicate $kind keys: $($duplicates -join ', ')"
    foreach ($item in $catalogs[$kind]) {
        Assert (-not [string]::IsNullOrWhiteSpace([string](Get-OptionalProperty $item 'Description'))) "$kind '$($item.Name)' has no description."
        Assert ($item.Default -is [bool]) "$kind '$($item.Name)' needs a boolean Default."
        $risk = Get-OptionalProperty $item 'Risk'
        Assert ($null -eq $risk -or $risk -in @('Caution', 'High')) "$kind '$($item.Name)' has unknown Risk '$risk'."
        $effect = Get-OptionalProperty $item 'Effect'
        Assert ($null -eq $effect -or $effect -in @('Explorer', 'SignOut', 'Reboot')) "$kind '$($item.Name)' has unknown Effect '$effect'."
    }
}

foreach ($item in $ProgramCatalog) {
    switch ($item.InstallType) {
        'WinGet' { Assert ($item.Id -and $item.Source -in @('winget', 'msstore')) "Program '$($item.Name)' needs a WinGet Id and source." }
        'OfficialPage' { Assert ($item.Url -match '^https://') "Program '$($item.Name)' needs an https URL." }
        'GitHubReleaseZip' { Assert ($item.Repository -match '^[\w.-]+/[\w.-]+$' -and $item.AssetPattern -match '\{arch\}' -and $item.Executable -and $item.InstallFolder) "Program '$($item.Name)' has an incomplete GitHub definition." }
        default { throw "Program '$($item.Name)' has unknown InstallType '$($item.InstallType)'." }
    }
}
foreach ($item in $VivaldiExtensionCatalog) {
    Assert ($item.Id -cmatch '^[a-p]{32}$') "Extension '$($item.Name)' has an invalid Chrome Web Store ID."
}
Assert (@($VivaldiExtensionCatalog | Where-Object Id -eq 'dhdgffkkebhmkfjojejmpbldmpobfkfo').Count -eq 1) 'Tampermonkey must be in the Vivaldi catalog.'
Assert (@($ProgramCatalog | Where-Object { (Get-OptionalProperty $_ 'Repository') -eq 'VantaCode420/SmartHdrManager' }).Count -eq 1) 'Smart HDR Manager must be in the program catalog.'

# Every setting key needs a branch in Set-WindowsOption or Set-PrivacyOption, or it fails only at run time.
$handled = @()
foreach ($name in @('Set-WindowsOption', 'Set-PrivacyOption')) {
    $function = $ast.Find({ param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name }, $true)
    $switch = $function.Find({ param($n) $n -is [Management.Automation.Language.SwitchStatementAst] }, $true)
    $handled += @($switch.Clauses | ForEach-Object { $_.Item1.Value })
}
foreach ($item in $settings) { Assert ($handled -contains $item.Key) "Setting key '$($item.Key)' has no handler." }
foreach ($item in $PrivacyCatalog) { Assert ($settings -contains $item) "Privacy item '$($item.Key)' is not shown in any settings section." }

# PowerShell treats „ “ ” as double quotes, so one inside a "..." string silently ends it early.
$quoteChars = @([char]'"', [char]0x201C, [char]0x201D, [char]0x201E)
$broken = @($tokens | Where-Object { $_.Kind -in @('StringExpandable', 'StringLiteral') -and $_.Text.Length -ge 2 -and $quoteChars -contains $_.Text[0] -and $_.Text[0] -ne $_.Text[-1] })
Assert ($broken.Count -eq 0) "Strings closed by a Lithuanian quote: $(($broken | ForEach-Object { 'line ' + $_.Extent.StartLineNumber }) -join ', ')"

# WinGet exit codes: success variants return, hard failures throw without retrying.
Assert ((Invoke-WinGet -WinGet 'cmd.exe' -Arguments @('/c', 'exit 0')) -eq 0) 'Exit code 0 must succeed.'
Assert ((Invoke-WinGet -WinGet 'cmd.exe' -Arguments @('/c', 'exit 3010')) -eq 3010) 'Reboot-required (3010) must count as success.'
Assert ((Invoke-WinGet -WinGet 'cmd.exe' -Arguments @('/c', 'exit -1978335135')) -eq -1978335135) 'PACKAGE_ALREADY_INSTALLED must count as success.'
$watch = [Diagnostics.Stopwatch]::StartNew()
try { [void](Invoke-WinGet -WinGet 'cmd.exe' -Arguments @('/c', 'exit 1')); throw 'Expected failure.' }
catch { Assert ($_.Exception.Message -match '0x00000001') "Unexpected failure text: $($_.Exception.Message)" }
Assert ($watch.Elapsed.TotalSeconds -lt 3) 'A non-transient failure must not be retried.'
try { [void](Invoke-WinGet -WinGet 'cmd.exe' -Arguments @('/c', 'exit 1618') -MaxAttempts 1); throw 'Expected failure.' }
catch { Assert ($_.Exception.Message -match '0x00000652') "Unexpected failure text: $($_.Exception.Message)" }
# Output is read as UTF-8 whatever the console code page, and progress bars are dropped.
$script:logged.Clear()
$probe = "[Console]::OutputEncoding = [Text.UTF8Encoding]::new(`$false); [string][char]0x104 + 'zuolas' + [char]0x2019 + 's'; ([string][char]0x2588 * 3) + [char]0x2592 + ' 50%'"
[void](Invoke-WinGet -WinGet 'powershell.exe' -Arguments @('-NoProfile', '-Command', $probe))
Assert ($script:logged -ccontains ([string][char]0x104 + 'zuolas' + [char]0x2019 + 's')) "WinGet output was not decoded as UTF-8: $($script:logged -join ' | ')"
Assert ($script:logged.Count -eq 1) "Progress bar lines must be dropped: $($script:logged -join ' | ')"

# The whole interface must build (no window is shown and nothing is changed).
$output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File $source -ValidateOnly 2>&1 | Out-String
Assert ($LASTEXITCODE -eq 0 -and $output -match 'patikros įkėlimas baigtas') "UI validation failed: $output"

Write-Output ('PASS: {0} programs, {1} extensions, {2} apps, {3} settings; descriptions, unique keys, handlers, IDs, WinGet exit codes, UI load.' -f $ProgramCatalog.Count, $VivaldiExtensionCatalog.Count, $BundledAppCatalog.Count, $settings.Count)
