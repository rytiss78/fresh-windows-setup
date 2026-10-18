#Requires -Version 5.1
<#
Fresh Windows Setup
A single-file, first-boot Windows configuration utility.
All system changes are selectable in the interface and logged.

Made by Emocinis Taikinys
#>

[CmdletBinding()]
param(
    [switch]$ValidateOnly,
    [switch]$DryRun,
    [string]$ExportConfig,
    [string]$ImportConfig,
    [switch]$Uninstall
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$AppName = 'Fresh Windows Setup'
$AppVersion = '1.4.0'
$AppAuthor = 'Emocinis Taikinys'

$ProgramCatalog = @(
    [pscustomobject]@{ Name = '🎮 AMD tvarkyklių aptikimas (oficialus puslapis)'; InstallType = 'OfficialPage'; Url = 'https://www.amd.com/en/support/download/drivers.html'; Default = $true }
    [pscustomobject]@{ Name = '🤖 ChatGPT (oficialus atsisiuntimo puslapis)'; InstallType = 'OfficialPage'; Url = 'https://chatgpt.com/download/'; Default = $true }
    [pscustomobject]@{ Name = '🖼️ Icaros'; InstallType = 'WinGet'; Id = 'Xanashi.Icaros'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '📝 Notepad++'; InstallType = 'WinGet'; Id = 'Notepad++.Notepad++'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '💡 OpenRGB'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGB'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🌈 Smart HDR Manager (beta; AMD palaikymas nepatvirtintas)'; InstallType = 'GitHubReleaseZip'; Repository = 'VantaCode420/SmartHdrManager'; AssetPattern = 'win-x64-standalone\.zip    [pscustomobject]@{ Name = '✨ OpenRGB Effects Plugin'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGBEffectsPlugin'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🎬 PotPlayer 64 bitų'; InstallType = 'WinGet'; Id = 'Daum.PotPlayer'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🐍 Python 3.14'; InstallType = 'WinGet'; Id = 'Python.Python.3.14'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🧲 qBittorrent'; InstallType = 'WinGet'; Id = 'qBittorrent.qBittorrent'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🎮 Steam'; InstallType = 'WinGet'; Id = 'Valve.Steam'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🍿 Stremio'; InstallType = 'WinGet'; Id = 'Stremio.Stremio'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '📡 TP-Link Archer TBE550E Wi-Fi ir Bluetooth tvarkyklės (oficialus puslapis)'; InstallType = 'OfficialPage'; Url = 'https://www.tp-link.com/en/support/download/archer-tbe550e/'; Default = $true }
    [pscustomobject]@{ Name = '🌐 Vivaldi naršyklė'; InstallType = 'WinGet'; Id = 'Vivaldi.Vivaldi'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🌈 Windows HDR Calibration (Microsoft Store)'; InstallType = 'WinGet'; Id = '9N7F2SM5D1LR'; Source = 'msstore'; Default = $true }
    [pscustomobject]@{ Name = '⬇️ yt-dlp'; InstallType = 'WinGet'; Id = 'yt-dlp.yt-dlp'; Source = 'winget'; Default = $true }
)

$VivaldiExtensionCatalog = @(
    [pscustomobject]@{ Name = 'Bitwarden slaptažodžių tvarkyklė'; Id = 'nngceckbapebfimnlniiiahkandclblb'; Default = $true }
    [pscustomobject]@{ Name = 'Hide Scrollbar'; Id = 'gngenlhkmpneoiicndbjghjhpogdcncl'; Default = $true }
    [pscustomobject]@{ Name = 'Imagus Reborn'; Id = 'fcjmgeodgobggcppooncdagfkogfffdm'; Default = $true }
    [pscustomobject]@{ Name = 'SponsorBlock for YouTube'; Id = 'mnjggcdmjocbbbhaepdhchncahnbgone'; Default = $true }
    [pscustomobject]@{ Name = 'YouTube Inline Fullscreen'; Id = 'mfpkbigjnlcgngkdbmnchfnenfmibkig'; Default = $true }
)

# This is intentionally conservative. Core components and frameworks are excluded.
$BundledAppCatalog = @(
    [pscustomobject]@{ Name = 'Clipchamp'; Package = 'Clipchamp.Clipchamp'; Default = $true }
    [pscustomobject]@{ Name = 'Dev Home'; Package = 'Microsoft.Windows.DevHome'; Default = $true }
    [pscustomobject]@{ Name = 'Atsiliepimų telkinys (Feedback Hub)'; Package = 'Microsoft.WindowsFeedbackHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft 365 (Office) programėlė'; Package = 'Microsoft.MicrosoftOfficeHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft naujienos'; Package = 'Microsoft.BingNews'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Solitaire Collection'; Package = 'Microsoft.MicrosoftSolitaireCollection'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft orai'; Package = 'Microsoft.BingWeather'; Default = $true }
    [pscustomobject]@{ Name = 'Žmonės (People)'; Package = 'Microsoft.People'; Default = $true }
    [pscustomobject]@{ Name = 'Užrašinė (Notepad)'; Package = 'Microsoft.WindowsNotepad'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox programėlė'; Package = 'Microsoft.GamingApp'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Game Bar'; Package = 'Microsoft.XboxGamingOverlay'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Identity Provider'; Package = 'Microsoft.XboxIdentityProvider'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Speech-to-Text Overlay'; Package = 'Microsoft.XboxSpeechToTextOverlay'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox TCUI'; Package = 'Microsoft.Xbox.TCUI'; Default = $true }
    [pscustomobject]@{ Name = 'OneDrive'; Package = 'OneDriveDesktop'; Kind = 'OneDrive'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Office darbalaukio paketas'; Package = 'Microsoft.Office.Desktop'; Default = $true }
    [pscustomobject]@{ Name = 'Windows atsarginis kopijavimas (išjungti, bet palikti bendrą Windows apvalkalo paketą)'; Package = 'WindowsBackup'; Kind = 'WindowsBackup'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Edge naršyklė ir jos naršyklės naujinimo komponentai'; Package = 'MicrosoftEdge'; Kind = 'Edge'; Default = $true }
)

$PrivacyCatalog = @(
    [pscustomobject]@{ Name = 'Sumažinti diagnostikos duomenis iki mažiausio palaikomo lygio'; Key = 'DiagnosticData'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti reklamos ID ir suasmenintas reklamas'; Key = 'Advertising'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti pagal diagnostikos duomenis pritaikytas funkcijas'; Key = 'TailoredExperiences'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti Windows pasiūlymus ir reklaminį turinį'; Key = 'Suggestions'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti atsiliepimų prašymus'; Key = 'Feedback'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti veiklos istorijos skelbimą ir siuntimą'; Key = 'ActivityHistory'; Default = $true }
    [pscustomobject]@{ Name = 'Sumažinti rašymo ir braižymo suasmeninimo duomenų rinkimą'; Key = 'InputPersonalization'; Default = $true }
)

$WindowsSettingsGroups = [ordered]@{
    'Užduočių juosta ir Start meniu' = @(
        [pscustomobject]@{ Name = 'Lygiuoti užduočių juostą kairėje'; Key = 'TaskbarLeft'; Default = $true }
        [pscustomobject]@{ Name = 'Slėpti paiešką užduočių juostoje'; Key = 'HideSearch'; Default = $true }
        [pscustomobject]@{ Name = 'Slėpti valdiklius užduočių juostoje'; Key = 'HideWidgets'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Start meniu rekomendacijas'; Key = 'DisableStartRecommendations'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti neseniai atidarytų elementų rodymą'; Key = 'DisableRecentItems'; Default = $true }
        [pscustomobject]@{ Name = 'Automatiškai slėpti užduočių juostą'; Key = 'TaskbarAutoHide'; Default = $true }
    )
    'Failų naršyklė' = @(
        [pscustomobject]@{ Name = 'Rodyti failų plėtinius'; Key = 'ShowFileExtensions'; Default = $true }
        [pscustomobject]@{ Name = 'Rodyti paslėptus failus'; Key = 'ShowHiddenFiles'; Default = $false }
        [pscustomobject]@{ Name = 'Failų naršyklę atverti ties „Šis kompiuteris“'; Key = 'ExplorerThisPC'; Default = $true }
        [pscustomobject]@{ Name = 'Naudoti kompaktišką rodinį'; Key = 'CompactView'; Default = $true }
        [pscustomobject]@{ Name = 'Grąžinti klasikinį dešiniojo pelės mygtuko meniu'; Key = 'ClassicContextMenu'; Default = $true }
        [pscustomobject]@{ Name = 'Pašalinti „Galeriją“ iš failų naršyklės'; Key = 'RemoveGallery'; Default = $true }
        [pscustomobject]@{ Name = 'Pašalinti „Pagrindinį“ iš failų naršyklės'; Key = 'RemoveHome'; Default = $true }
    )
    'Išvaizda ir naudojimas' = @(
        [pscustomobject]@{ Name = 'Išjungti Bing ir interneto rezultatus Start paieškoje'; Key = 'DisableWebSearch'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Windows patarimus ir pasiūlymus'; Key = 'DisableTips'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti programų paleidimo delsą'; Key = 'DisableStartupDelay'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti pelės pagreitį'; Key = 'DisableMouseAcceleration'; Default = $true }
        [pscustomobject]@{ Name = 'Įjungti Windows tamsųjį režimą'; Key = 'DarkMode'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti užrakinimo ekrano pasiūlymus'; Key = 'DisableLockScreenSuggestions'; Default = $true }
    )
    'Privatumas' = $PrivacyCatalog
    'Sistema ir maitinimas' = @(
        [pscustomobject]@{ Name = 'Išjungti greitąjį paleidimą'; Key = 'DisableFastStartup'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti sistemos atkūrimą'; Key = 'DisableSystemRestore'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Windows atsarginį kopijavimą ir nustatymų sinchronizavimą'; Key = 'DisableWindowsBackup'; Default = $true }
    )
    'Tinklas ir žaidimai' = @(
        [pscustomobject]@{ Name = 'Nustatyti prijungtus tinklus kaip privačius'; Key = 'PrivateNetwork'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Xbox Game Bar įrašymą'; Key = 'DisableGameBarRecording'; Default = $true }
    )
    'Regionas' = @(
        [pscustomobject]@{ Name = 'Nustatyti Lietuvos regioną ir Vilniaus laiko juostą'; Key = 'LithuaniaRegion'; Default = $true }
    )
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $ValidateOnly -and -not (Test-IsAdministrator)) {
    if (-not $PSCommandPath) { throw 'Prieš paleisdami įrašykite šį scenarijų į failą.' }
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        ('"{0}"' -f $PSCommandPath)
    )
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:LogPath = Join-Path $env:TEMP ('FreshWindowsSetup-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
$script:LogBox = $null

function Write-SetupLog {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Message,
        [ValidateSet('INFO', 'OK', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    $line = '[{0:HH:mm:ss}] [{1}] {2}' -f (Get-Date), $Level, $Message
    Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    if ($null -ne $script:LogBox) {
        $start = $script:LogBox.TextLength
        $script:LogBox.AppendText($line + [Environment]::NewLine)
        $script:LogBox.Select($start, $line.Length)
        $script:LogBox.SelectionColor = [Drawing.Color]::FromArgb(235, 235, 235)
        if ($Level -eq 'ERROR') {
            $script:LogBox.SelectionBackColor = [Drawing.Color]::FromArgb(128, 28, 38)
        } else {
            $script:LogBox.SelectionBackColor = $script:LogBox.BackColor
        }
        $script:LogBox.SelectionStart = $script:LogBox.TextLength
        $script:LogBox.SelectionLength = 0
        $script:LogBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet('DWord', 'QWord', 'String', 'ExpandString', 'MultiString', 'Binary')][string]$Type = 'DWord'
    )
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null

    $actual = Get-ItemPropertyValue -LiteralPath $Path -Name $Name -ErrorAction Stop
    if ($Value -is [array]) {
        $expectedText = ($Value | ForEach-Object { [string]$_ }) -join '|'
        $actualText = ($actual | ForEach-Object { [string]$_ }) -join '|'
        $matches = $expectedText -ceq $actualText
    } else {
        $matches = ([string]$Value) -ceq ([string]$actual)
    }
    if (-not $matches) {
        throw "Nepavyko patikrinti $Path\$Name. Tikėtasi '$Value', rasta '$actual'."
    }
    Write-SetupLog "Patikrinta: $Path\$Name = $actual."
}

function Set-RegistryDefaultValue {
    param([Parameter(Mandatory)][string]$Path, [AllowEmptyString()][string]$Value)
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-Item -LiteralPath $Path -Value $Value -Force
    $actual = (Get-Item -LiteralPath $Path -ErrorAction Stop).GetValue('')
    if ([string]$actual -cne [string]$Value) {
        throw "Nepavyko patikrinti numatytosios registro reikšmės ties $Path."
    }
    Write-SetupLog "Patikrinta numatytoji registro reikšmė: $Path."
}

function Remove-RegistryValue {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name)
    if (Test-Path -LiteralPath $Path) {
        Remove-ItemProperty -LiteralPath $Path -Name $Name -Force -ErrorAction SilentlyContinue
    }
    $remaining = Get-ItemPropertyValue -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $remaining) { throw "Nepavyko patikrinti registro reikšmės pašalinimo: $Path\$Name." }
    Write-SetupLog "Patikrinta, kad registro reikšmės nėra: $Path\$Name."
}

function Invoke-LoggedAction {
    param([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][scriptblock]$Action)
    Write-SetupLog "$Description..."
    try {
        & $Action
    Write-SetupLog "$Description – atlikta." 'OK'
    } catch {
        $errorMsg = if ($_.Exception.Message) { $_.Exception.Message } else { 'Nežinoma klaida' }
        Write-SetupLog "$Description – nepavyko: $errorMsg" 'ERROR'
    }
}

function Invoke-NativeCommand {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments 2>&1 | ForEach-Object { Write-SetupLog ([string]$_) }
    if ($LASTEXITCODE -ne 0) { throw "$FilePath baigė darbą su kodu $LASTEXITCODE." }
}

function Invoke-NativeCommandSafe {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$Arguments,
        [string[]]$TransientErrorCodes = @(1605, 1612, 1618, 1619, 1641, 3010),
        [int]$MaxRetries = 2
    )
    $exitCode = -1
    for ($i = 0; $i -lt $MaxRetries + 1; $i++) {
        & $FilePath @Arguments 2>&1 | ForEach-Object { Write-SetupLog ([string]$_) }
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) { return $true }
        if ($TransientErrorCodes -contains $exitCode) {
            Write-SetupLog "Perėjusi klaida ($exitCode). Bandoma iš naujo ($($i+1)/$MaxRetries)..." 'WARN'
            Start-Sleep -Seconds (3 * ($i + 1))
            continue
        }
        if ($i -lt $MaxRetries) {
            Write-SetupLog "Klaida ($exitCode). Bandoma iš naujo ($($i+1)/$MaxRetries)..." 'WARN'
            Start-Sleep -Seconds (3 * ($i + 1))
            continue
        }
        throw "$FilePath baigė darbą su kodu $exitCode."
    }
    return $true
}

function Test-WinGetPackageInstalled {
    param([string]$Id, [string]$Source = 'winget', [switch]$MsStore)
    $sourceArg = if ($MsStore) { 'msstore' } else { $Source }
    try {
        $listOutput = & winget.exe list --id $Id --exact --source $sourceArg --accept-source-agreements --disable-interactivity 2>&1
        return ($listOutput -join "`n") -match [regex]::Escape($Id)
    } catch {
        return $false
    }
}

function Install-GitHubReleaseZip {
    param(
        [Parameter(Mandatory)][string]$Repository,
        [Parameter(Mandatory)][string]$AssetPattern,
        [Parameter(Mandatory)][string]$ApplicationName
    )

    $previousProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    $stagingPath = Join-Path $env:TEMP ($ApplicationName + '-' + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $env:TEMP ($ApplicationName + '-' + [guid]::NewGuid().ToString('N') + '.zip')
    $installPath = Join-Path $env:LOCALAPPDATA ('Programs\' + $ApplicationName)

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $headers = @{
            'User-Agent' = 'FreshWindowsSetup'
            'Accept' = 'application/vnd.github+json'
        }
        $releasesUri = 'https://api.github.com/repos/{0}/releases?per_page=20' -f $Repository
        $releases = @(Invoke-RestMethod -Uri $releasesUri -Headers $headers -Method Get)
        $asset = $null
        foreach ($release in $releases) {
            $asset = @($release.assets | Where-Object { $_.name -match $AssetPattern } | Select-Object -First 1) | Select-Object -First 1
            if ($null -ne $asset) { break }
        }
        if ($null -eq $asset -or [string]::IsNullOrWhiteSpace([string]$asset.browser_download_url)) {
            throw "GitHub leidimuose nerastas tinkamas failas ($AssetPattern)."
        }

        Write-SetupLog ("Atsisiunčiama {0} iš leidimo {1}..." -f $ApplicationName, $release.tag_name)
        Invoke-WebRequest -Uri $asset.browser_download_url -Headers @{ 'User-Agent' = 'FreshWindowsSetup' } -OutFile $zipPath -UseBasicParsing
        if (-not (Test-Path -LiteralPath $zipPath) -or (Get-Item -LiteralPath $zipPath).Length -lt 1MB) {
            throw 'Atsisiųstas archyvas neegzistuoja arba yra netikėtai mažas.'
        }

        New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null
        Expand-Archive -LiteralPath $zipPath -DestinationPath $stagingPath -Force
        $applicationExe = Get-ChildItem -LiteralPath $stagingPath -Filter 'SmartHdrManager.exe' -File -Recurse | Select-Object -First 1
        if ($null -eq $applicationExe) {
            throw 'Archyve nerastas SmartHdrManager.exe; diegimas nutrauktas.'
        }

        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        Copy-Item -Path (Join-Path $stagingPath '*') -Destination $installPath -Recurse -Force
        $installedExe = Get-ChildItem -LiteralPath $installPath -Filter 'SmartHdrManager.exe' -File -Recurse | Select-Object -First 1
        if ($null -eq $installedExe) {
            throw 'Įdiegtoje vietoje nerastas SmartHdrManager.exe.'
        }

        $startMenuPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
        New-Item -ItemType Directory -Path $startMenuPath -Force | Out-Null
        $shortcutPath = Join-Path $startMenuPath ($ApplicationName + '.lnk')
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $installedExe.FullName
        $shortcut.WorkingDirectory = $installedExe.DirectoryName
        $shortcut.Save()

        Write-SetupLog ("Įdiegta {0} ({1}) į {2}. AMD / Intel GPU suderinamumas kūrėjo dar nepatvirtintas." -f $ApplicationName, $release.tag_name, $installPath) 'OK'
    } finally {
        if (Test-Path -LiteralPath $stagingPath) { Remove-Item -LiteralPath $stagingPath -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue }
        $ProgressPreference = $previousProgressPreference
    }
}

function Install-Programs {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Programos: niekas nepasirinkta.' 'WARN'; return }
    $winget = Get-Command 'winget.exe' -ErrorAction SilentlyContinue
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Diegti: $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Start-Process -FilePath $item.Url
                Write-SetupLog "Atvertas patikrintas leidėjo puslapis: $($item.Url). Šį įrangai ar programai būdingą diegimą užbaikite rankiniu būdu." 'WARN'
                return
            }

            if ($item.InstallType -eq 'GitHubReleaseZip') {
                Install-GitHubReleaseZip -Repository $item.Repository -AssetPattern $item.AssetPattern -ApplicationName 'SmartHdrManager'
                return
            }
            if (-not $winget) { throw 'WinGet nepasiekiamas. Įdiekite arba atnaujinkite Microsoft App Installer ir bandykite dar kartą.' }

            # Skip if already installed (Item 4)
            $isInstalled = Test-WinGetPackageInstalled -Id $item.Id -Source $item.Source
            # Use safe command with retries for transient errors (Item 8)
            $arguments = @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
            try {
                Invoke-NativeCommandSafe -FilePath $winget.Source -Arguments $arguments
                # Verify installation succeeded
                $listOutput = @(& $winget.Source list --id $item.Id --exact --source $item.Source --accept-source-agreements --disable-interactivity 2>&1)
                if ($LASTEXITCODE -ne 0 -or -not (($listOutput -join "`n") -match [regex]::Escape($item.Id))) {
                    Write-SetupLog "WinGet patikra nerado $($item.Id). Paketas gali būti iš dalies įdiegtas." 'WARN'
                } else {
                    Write-SetupLog "Patikrintas įdiegtas paketas: $($item.Id)." 'OK'
                }
            } catch {
                $errorMsg = if ($null -ne $_.Exception.Message -and $_.Exception.Message.Trim()) { $_.Exception.Message } else { 'Nežinoma klaida.' }
                Write-SetupLog "WinGet diegimas nepavyko: $errorMsg" 'ERROR'
            }
        }
    }
}

function Configure-VivaldiExtensions {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Vivaldi plėtiniai: niekas nepasirinkta.' 'WARN'; return }
    $policyPath = 'HKLM:\SOFTWARE\Policies\Vivaldi\ExtensionInstallForcelist'
    if (-not (Test-Path -LiteralPath $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
    $index = 1
    foreach ($item in $Items) {
        $policyValue = '{0};https://clients2.google.com/service/update2/crx' -f $item.Id
        Set-RegistryValue -Path $policyPath -Name ([string]$index) -Value $policyValue -Type String
        Write-SetupLog "Pridėta Vivaldi plėtinio politika: $($item.Name)." 'OK'
        $index++
    }
    Write-SetupLog 'Vivaldi politikos diegimas yra eksperimentinis. Paleidę Vivaldi patikrinkite plėtinius.' 'WARN'
}

function Set-PrivacyOption {
    param([Parameter(Mandatory)][string]$Key)
    switch ($Key) {
        'DiagnosticData' {
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDiagnosticLogCollection' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDumpCollection' 1
            Write-SetupLog 'Diagnostikos duomenys nustatyti į mažiausią įprastai palaikomą lygį; vis tiek galioja Windows leidimo apribojimai.' 'WARN'
        }
        'Advertising' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
        }
        'TailoredExperiences' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' 1
        }
        'Suggestions' {
            $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            foreach ($name in @('ContentDeliveryAllowed', 'FeatureManagementEnabled', 'OemPreInstalledAppsEnabled', 'PreInstalledAppsEnabled', 'PreInstalledAppsEverEnabled', 'SilentInstalledAppsEnabled', 'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled', 'SystemPaneSuggestionsEnabled')) {
                Set-RegistryValue $contentPath $name 0
            }
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
        }
        'Feedback' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
        }
        'ActivityHistory' {
            $activityPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
            Set-RegistryValue $activityPath 'EnableActivityFeed' 0
            Set-RegistryValue $activityPath 'PublishUserActivities' 0
            Set-RegistryValue $activityPath 'UploadUserActivities' 0
        }
        'InputPersonalization' {
            $inputPath = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
            Set-RegistryValue $inputPath 'AllowInputPersonalization' 0
            Set-RegistryValue $inputPath 'RestrictImplicitInkCollection' 1
            Set-RegistryValue $inputPath 'RestrictImplicitTextCollection' 1
            Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
            Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
        }
        default { throw "Neatpažinta privatumo parinktis: $Key" }
    }
}

function Get-CurrentConfig {
    param(
        [System.Windows.Forms.CheckedListBox]$ProgramList,
        [System.Windows.Forms.CheckedListBox]$ExtensionList,
        [System.Collections.ArrayList]$SettingsLists,
        [System.Windows.Forms.CheckedListBox]$AppsList
    )
    $config = [ordered]@{
        'Programos' = @($ProgramList.CheckedItems | ForEach-Object { $_.Id })
        'VivaldiPlėtiniai' = @($ExtensionList.CheckedItems | ForEach-Object { $_.Id })
        'IntegruotosProgramėlės' = @($AppsList.CheckedItems | ForEach-Object { $_.Package })
        'Nustatymai' = @{}
    }
    foreach ($list in $SettingsLists) {
        foreach ($item in $list.CheckedItems) {
            if ($item.Key) {
                $config.Nustatymai[$item.Key] = $true
            }
        }
    }
    return $config
}

function Set-UninstallMode {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Naudoti: niekas nepasirinkta.' 'WARN'; return }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Atstatyti (nešalinti): $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Write-SetupLog "Oficialus puslapis atidarytas rankiniam įdiegimui: $($item.Url)." 'WARN'
                Start-Process -FilePath $item.Url
                return
            }
            # Reinstall via winget
            $arguments = @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
            Invoke-NativeCommandSafe -FilePath 'winget.exe' -Arguments $arguments
            Write-SetupLog "Atstatytas paketas: $($item.Id)." 'OK'
        }
    }
}

function Remove-BundledApps {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Integruotos programėlės: niekas nepasirinkta.' 'WARN'; return }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Pašalinti: $($item.Name)" -Action {
            $kindProperty = $item.PSObject.Properties['Kind']
            $kind = if ($null -ne $kindProperty) { [string]$kindProperty.Value } else { 'Appx' }

            if ($kind -eq 'OneDrive') {
                try {
                    $setupCandidates = @(
                        (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
                        (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
                    )
                    $setup = $setupCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
                    if ($setup) {
                        # Stop OneDrive process first — it blocks uninstall and causes 0x80070005
                        Get-Process -Name 'OneDrive' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 2
                        $process = Start-Process -FilePath $setup -ArgumentList @('/uninstall') -Wait -PassThru -ErrorAction Stop
                        # Exit code 19 = already uninstalled (expected on fresh systems)
                        if ($process.ExitCode -notin @(0, 19)) { throw "OneDrive šalinimo programa baigė darbą su kodu $($process.ExitCode)." }
                    }
                    $oneDriveExecutables = @(
                        (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe')
                        (Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe')
                    )
                    if ($oneDriveExecutables | Where-Object { Test-Path -LiteralPath $_ }) {
                        throw 'OneDrive patikra vis dar aptiko įdiegtą vykdomąjį failą.'
                    }
                    Write-SetupLog 'Patikrinta: OneDrive vykdomojo failo nėra.'
                } catch {
                    Write-SetupLog "OneDrive šalinimas praleistas: $($_.Exception.Message)" 'WARN'
                }
                return
            }

            if ($kind -eq 'WindowsBackup') {
                Set-WindowsOption -Key 'DisableWindowsBackup'
                Write-SetupLog 'Windows atsarginio kopijavimo programa yra bendro Windows apvalkalo paketo dalis, todėl pats paketas paliktas.' 'WARN'
                return
            }

            if ($kind -eq 'Edge') {
                $edgeGuid = '{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
                $webViewGuid = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                $edgePolicy = 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate'
                Set-RegistryValue $edgePolicy ("Install$edgeGuid") 0
                Set-RegistryValue $edgePolicy ("Update$edgeGuid") 0
                Set-RegistryValue $edgePolicy ("Uninstall$($edgeGuid.ToLowerInvariant())") 1
                Set-RegistryValue $edgePolicy ("Install$webViewGuid") 1
                Set-RegistryValue $edgePolicy ("Update$webViewGuid") 1

                Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                $edgeRoot = Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application'
                $setup = Get-ChildItem -LiteralPath $edgeRoot -Filter 'setup.exe' -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $_.FullName -match '\\Installer\\setup\.exe$' } |
                    Sort-Object FullName -Descending |
                    Select-Object -First 1
                if ($setup) {
                    $process = Start-Process -FilePath $setup.FullName -ArgumentList @('--uninstall', '--system-level', '--verbose-logging', '--force-uninstall') -Wait -PassThru
                    if ($process.ExitCode -ne 0) { throw "Microsoft Edge šalinimo programa baigė darbą su kodu $($process.ExitCode)." }
                }

                foreach ($runPath in @(
                    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
                    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
                    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
                )) {
                    try { Remove-RegistryValue $runPath 'MicrosoftEdgeAutoLaunch' } catch {}
                }

                foreach ($shortcut in @(
                    (Join-Path $env:PUBLIC 'Desktop\Microsoft Edge.lnk'),
                    (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk'),
                    (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk')
                )) {
                    if (Test-Path -LiteralPath $shortcut) { Remove-Item -LiteralPath $shortcut -Force }
                    if (Test-Path -LiteralPath $shortcut) { throw "Nepavyko pašalinti nuorodos: $shortcut" }
                }

                $edgeExecutable = Join-Path $edgeRoot 'msedge.exe'
                $versionedEdge = @(Get-ChildItem -LiteralPath $edgeRoot -Filter 'msedge.exe' -Recurse -ErrorAction SilentlyContinue)
                if ((Test-Path -LiteralPath $edgeExecutable) -or $versionedEdge.Count -gt 0) {
                    throw 'Microsoft Edge pašalinimo patikra vis dar aptiko msedge.exe.'
                }
                Write-SetupLog 'Patikrinta: Edge naršyklė pašalinta, jos diegimas ir naujinimai užblokuoti; WebView2 ir jo naujinimai palikti.'
                return
            }

            foreach ($package in @(Get-AppxPackage -AllUsers -Name $item.Package -ErrorAction SilentlyContinue)) {
                Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
            }
            $provisioned = @(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $item.Package })
            foreach ($package in $provisioned) {
                Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -AllUsers -ErrorAction Stop | Out-Null
            }

            $remainingInstalled = @(Get-AppxPackage -AllUsers -Name $item.Package -ErrorAction SilentlyContinue)
            $remainingProvisioned = @(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $item.Package })
            if ($remainingInstalled.Count -gt 0 -or $remainingProvisioned.Count -gt 0) {
                throw "Programėlės pašalinimo patikra vis dar aptiko $($item.Package)."
            }
            Write-SetupLog "Patikrinta, kad pašalinta arba nebuvo įdiegta: $($item.Package)."
        }
    }
}

function Set-TaskbarAutoHide {
    $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = [byte[]](Get-ItemPropertyValue -LiteralPath $path -Name 'Settings' -ErrorAction Stop)
    if ($settings.Length -lt 9) { throw 'Užduočių juostos nustatymo reikšmės formatas neatpažintas.' }
    $settings[8] = 3
    Set-RegistryValue $path 'Settings' $settings 'Binary'
    Write-SetupLog 'Automatinis užduočių juostos slėpimas visiškai įsigalios iš naujo paleidus Explorer arba kitą kartą prisijungus.' 'WARN'
}

function Set-LithuaniaRegion {
    Set-Culture -CultureInfo 'lt-LT'
    Set-WinHomeLocation -GeoId 140
    Set-WinSystemLocale -SystemLocale 'lt-LT'
    Set-TimeZone -Id 'FLE Standard Time'
    if ((Get-TimeZone).Id -ne 'FLE Standard Time') { throw 'Nepavyko patikrinti laiko juostos.' }
    if ((Get-WinSystemLocale).Name -ne 'lt-LT') { throw 'Nepavyko patikrinti sistemos lokalės.' }
    if ((Get-WinHomeLocation).GeoId -ne 140) { throw 'Nepavyko patikrinti namų regiono.' }
    if ((Get-Culture).Name -ne 'lt-LT') { throw 'Nepavyko patikrinti regioninio formato.' }
    Write-SetupLog 'Patikrintas Lietuvos regionas, lietuviška sistemos lokalė ir Vilniaus laiko juosta.'
    Write-SetupLog 'Kai kuriems lietuviškos lokalės pakeitimams gali reikėti atsijungti arba paleisti Windows iš naujo.' 'WARN'
}

function Set-ConnectedNetworksPrivate {
    $profiles = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected' })
    if ($profiles.Count -eq 0) { throw 'Nerastas nė vienas prijungtas tinklo profilis.' }
    foreach ($profile in $profiles) {
        Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
    }
    $remaining = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { ($_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected') -and $_.NetworkCategory -ne 'Private' })
    if ($remaining.Count -gt 0) { throw 'Tinklo kategorijos patikra aptiko prijungtą profilį, kuris nėra privatus.' }
    Write-SetupLog 'Patikrinta: visi prijungti tinklo profiliai yra privatūs.'
}

function Set-WindowsOption {
    param([Parameter(Mandatory)][string]$Key)
    if ($Key -in @($PrivacyCatalog.Key)) {
        Set-PrivacyOption -Key $Key
        return
    }
    switch ($Key) {
        'TaskbarLeft' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0 }
        'HideSearch' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0 }
        'HideWidgets' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
            try { Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0 } catch { Write-SetupLog 'Dsh politika nepasiekiama (galbūt reikalingos teisės).' 'WARN' }
        }
        'DisableStartRecommendations' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_AccountNotifications' 0
        }
        'DisableRecentItems' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoRecentDocsHistory' 1
        }
        'ShowFileExtensions' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0 }
        'ShowHiddenFiles' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' 1 }
        'CompactView' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'UseCompactMode' 1 }
        'ClassicContextMenu' {
            Set-RegistryDefaultValue 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' ''
        }
        'RemoveGallery' {
            Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0
        }
        'RemoveHome' {
            Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' 'System.IsPinnedToNameSpaceTree' 0
        }
        'DisableWebSearch' {
            Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
        }
        'DisableTips' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
        }
        'DisableStartupDelay' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0 }
        'ExplorerThisPC' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1 }
        'DisableMouseAcceleration' {
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseSpeed' '0' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' '0' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' '0' 'String'
        }
        'DarkMode' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0
        }
        'DisableLockScreenSuggestions' {
            $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            Set-RegistryValue $contentPath 'RotatingLockScreenEnabled' 0
            Set-RegistryValue $contentPath 'RotatingLockScreenOverlayEnabled' 0
            Set-RegistryValue $contentPath 'SubscribedContent-338387Enabled' 0
        }
        'DisableFastStartup' {
            Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
        }
        'DisableSystemRestore' {
            $systemDrive = [Environment]::GetEnvironmentVariable('SystemDrive') + '\'
            Disable-ComputerRestore -Drive $systemDrive -ErrorAction SilentlyContinue
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' 'DisableSR' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' 'DisableConfig' 1
        }
        'DisableWindowsBackup' {
            $syncPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
            Set-RegistryValue $syncPath 'EnableWindowsBackup' 0
            foreach ($name in @('DisableSettingSync', 'DisableApplicationSettingSync', 'DisableCredentialsSettingSync', 'DisablePersonalizationSettingSync', 'DisableWindowsSettingSync')) {
                Set-RegistryValue $syncPath $name 2
                Set-RegistryValue $syncPath ($name + 'UserOverride') 1
            }
            Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup' 'DisableMonitoring' 1
        }
        'PrivateNetwork' { Set-ConnectedNetworksPrivate }
        'DisableGameBarRecording' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
            Set-RegistryValue 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
        }
        'TaskbarAutoHide' { Set-TaskbarAutoHide }
        'LithuaniaRegion' { Set-LithuaniaRegion }
        default { throw "Neatpažintas Windows nustatymas: $Key" }
    }
}

function Get-StartupEntries {
    foreach ($hive in @([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryHive]::LocalMachine)) {
        foreach ($view in @([Microsoft.Win32.RegistryView]::Registry64, [Microsoft.Win32.RegistryView]::Registry32)) {
            if (-not [Environment]::Is64BitOperatingSystem -and $view -eq [Microsoft.Win32.RegistryView]::Registry64) { continue }
            $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, $view)
            try {
                foreach ($suffix in @('Run', 'RunOnce')) {
                    $path = 'Software\Microsoft\Windows\CurrentVersion\' + $suffix
                    $key = $base.OpenSubKey($path)
                    if ($null -eq $key) { continue }
                    try {
                        foreach ($valueName in $key.GetValueNames()) {
                            $value = $key.GetValue($valueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                            [pscustomobject]@{
                                Name = "$valueName [$hive / $view / $suffix] — $value"
                                Kind = 'Registry'; Hive = $hive; View = $view; Path = $path
                                ValueName = $valueName; Value = $value; ValueKind = $key.GetValueKind($valueName)
                                Default = $false
                            }
                        }
                    } finally { $key.Dispose() }
                }
            } finally { $base.Dispose() }
        }
    }
    foreach ($folder in @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))) {
        if (-not $folder -or -not (Test-Path -LiteralPath $folder)) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $folder -File -Force -ErrorAction Stop)) {
            if ($file.Name -eq 'desktop.ini') { continue }
            [pscustomobject]@{
                Name = "$($file.Name) [$folder]"; Kind = 'File'; Path = $file.FullName
                Hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash; Default = $false
            }
        }
    }
}

function Get-TaskEntries {
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    foreach ($task in @(Get-ScheduledTask -ErrorAction Stop | Sort-Object TaskPath, TaskName)) {
        try {
            $registered = $service.GetFolder($task.TaskPath).GetTask($task.TaskName)
            $actions = @($task.Actions | ForEach-Object {
                if ($_.PSObject.Properties['Execute']) { "$($_.Execute) $($_.Arguments)" } else { $_.CimClass.CimClassName }
            }) -join '; '
            [pscustomobject]@{
                Name = "$($task.TaskPath)$($task.TaskName) [$($task.State)] — $actions"
                Kind = 'Task'; TaskPath = $task.TaskPath; TaskName = $task.TaskName
                Xml = [string]$registered.Xml; Default = $false
            }
        } catch { Write-SetupLog "Užduoties nuskaitymo klaida: $($task.TaskPath)$($task.TaskName): $($_.Exception.Message)" 'WARN' }
    }
}

function New-RemovalBackupDirectory {
    $path = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) ('FreshWindowsSetup\RemovalBackups\' + [guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($path)
    return $path
}

function Remove-StartupEntry {
    param([Parameter(Mandatory)]$Item)
    if ($Item.Kind -eq 'Registry') {
        $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Item.Hive, $Item.View)
        try {
            $key = $base.OpenSubKey($Item.Path, $true)
            if ($null -eq $key) { throw 'Įrašas pasikeitė. Atnaujinkite sąrašą.' }
            try {
                $value = $key.GetValue($Item.ValueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                if ($key.GetValueNames() -cnotcontains $Item.ValueName -or $key.GetValueKind($Item.ValueName) -ne $Item.ValueKind -or (ConvertTo-Json -InputObject $value -Compress) -cne (ConvertTo-Json -InputObject $Item.Value -Compress)) {
                    throw 'Įrašas pasikeitė. Atnaujinkite sąrašą.'
                }
                $backup = New-RemovalBackupDirectory
                $Item | Export-Clixml -LiteralPath (Join-Path $backup 'startup.xml') -Depth 5
                Write-SetupLog "Atsarginė kopija: $backup"
                $key.DeleteValue($Item.ValueName, $true)
                if ($key.GetValueNames() -ccontains $Item.ValueName) { throw 'Registro įrašas nepašalintas.' }
            } finally { $key.Dispose() }
        } finally { $base.Dispose() }
    } elseif ($Item.Kind -eq 'File') {
        $allowed = @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))
        $parent = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($Item.Path))
        if ($allowed -notcontains $parent) { throw 'Failas nėra paleisties aplanke.' }
        if ((Get-FileHash -LiteralPath $Item.Path -Algorithm SHA256).Hash -cne $Item.Hash) { throw 'Failas pasikeitė. Atnaujinkite sąrašą.' }
        $backup = New-RemovalBackupDirectory
        Copy-Item -LiteralPath $Item.Path -Destination (Join-Path $backup ([IO.Path]::GetFileName($Item.Path))) -ErrorAction Stop
        $Item | Export-Clixml -LiteralPath (Join-Path $backup 'startup.xml') -Depth 5
        if ((Get-FileHash -LiteralPath (Join-Path $backup ([IO.Path]::GetFileName($Item.Path))) -Algorithm SHA256).Hash -cne $Item.Hash) { throw 'Atsarginės kopijos patikra nepavyko.' }
        Write-SetupLog "Atsarginė kopija: $backup"
        Remove-Item -LiteralPath $Item.Path -Force -ErrorAction Stop
        if (Test-Path -LiteralPath $Item.Path) { throw 'Paleisties failas nepašalintas.' }
    } else { throw 'Neatpažintas paleisties įrašo tipas.' }
}

function Remove-TaskEntry {
    param([Parameter(Mandatory)]$Item)
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    $folder = $service.GetFolder($Item.TaskPath)
    $task = $folder.GetTask($Item.TaskName)
    if ([string]$task.Xml -cne $Item.Xml) { throw 'Užduotis pasikeitė. Atnaujinkite sąrašą.' }
    if ([int]$task.State -eq 4) { throw 'Užduotis vykdoma. Sustabdykite ją užduočių planuoklyje ir bandykite dar kartą.' }
    $backup = New-RemovalBackupDirectory
    [IO.File]::WriteAllText((Join-Path $backup 'task.xml'), $Item.Xml, [Text.Encoding]::Unicode)
    $Item | Select-Object TaskPath, TaskName | Export-Clixml -LiteralPath (Join-Path $backup 'task-location.xml')
    Write-SetupLog "Atsarginė kopija: $backup"
    $folder.DeleteTask($Item.TaskName, 0)
    $remaining = @($folder.GetTasks(1) | Where-Object { $_.Name -ceq $Item.TaskName })
    if ($remaining.Count -gt 0) { throw 'Užduotis nepašalinta.' }
}

function Update-RemovalList {
    param([System.Windows.Forms.CheckedListBox]$List, [ValidateSet('Startup', 'Task')][string]$Kind)
    $List.Items.Clear()
    try {
        $items = if ($Kind -eq 'Startup') { @(Get-StartupEntries) } else { @(Get-TaskEntries) }
        foreach ($entry in $items) { [void]$List.Items.Add($entry, $false) }
        Write-SetupLog "Sąrašas atnaujintas ($Kind): $($items.Count) įrašų."
    } catch { Write-SetupLog "Sąrašo nuskaitymo klaida ($Kind): $($_.Exception.Message)" 'ERROR' }
}

function Invoke-SelectedRemoval {
    param([System.Windows.Forms.CheckedListBox]$List, [ValidateSet('Startup', 'Task')][string]$Kind)
    $selected = @($List.CheckedItems | ForEach-Object { $_ })
    if ($selected.Count -eq 0) {
        [void][System.Windows.Forms.MessageBox]::Show('Pirmiausia pažymėkite norimus pašalinti įrašus.', $AppName, 'OK', 'Information')
        return
    }
    if ($DryRun) {
        foreach ($entry in $selected) { Write-SetupLog "DRY RUN: Pašalinti (planuota): $($entry.Name)" }
        return
    }
    $summary = ($selected | ForEach-Object { $_.Name }) -join [Environment]::NewLine
    $answer = [System.Windows.Forms.MessageBox]::Show("Pašalinti $($selected.Count) pažymėtus įrašus? Sisteminės užduotys gali būti būtinos Windows veikimui. Prieš šalinimą bus išsaugotos atsarginės kopijos.`r`n`r`n$summary", 'Patvirtinkite šalinimą', 'YesNo', 'Warning')
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    $tabs.Enabled = $false
    $runButton.Enabled = $false
    try {
        foreach ($entry in $selected) {
            Invoke-LoggedAction -Description "Pašalinti: $($entry.Name)" -Action {
                if ($Kind -eq 'Startup') { Remove-StartupEntry $entry } else { Remove-TaskEntry $entry }
            }
        }
        Update-RemovalList -List $List -Kind $Kind
        [void][System.Windows.Forms.MessageBox]::Show('Šalinimas baigtas. Peržiūrėkite žurnalą ir atsarginių kopijų vietas.', $AppName, 'OK', 'Information')
    } finally { $tabs.Enabled = $true; $runButton.Enabled = $true }
}

function Add-RemovalTab {
    param([System.Windows.Forms.TabControl]$Tabs, [string]$Title, [string]$Description, [System.Windows.Forms.CheckedListBox]$List, [System.Windows.Forms.Button]$Refresh, [System.Windows.Forms.Button]$Remove)
    $tab = [System.Windows.Forms.TabPage]::new($Title)
    $layout = [System.Windows.Forms.TableLayoutPanel]::new()
    $layout.Dock = 'Fill'; $layout.Padding = [System.Windows.Forms.Padding]::new(10)
    $layout.ColumnCount = 1; $layout.RowCount = 3
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
    $label = [System.Windows.Forms.Label]::new()
    $label.AutoSize = $true; $label.MaximumSize = [Drawing.Size]::new(850, 0)
    $label.Text = $Description; $label.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 10)
    $buttons = [System.Windows.Forms.FlowLayoutPanel]::new()
    $buttons.AutoSize = $true; $buttons.Dock = 'Fill'
    $Refresh.Text = 'Atnaujinti sąrašą'; $Refresh.AutoSize = $true
    $Remove.Text = 'Pašalinti pažymėtus'; $Remove.AutoSize = $true
    $buttons.Controls.AddRange(@($Refresh, $Remove))
    $layout.Controls.Add($label, 0, 0); $layout.Controls.Add($List, 0, 1); $layout.Controls.Add($buttons, 0, 2)
    $tab.Controls.Add($layout); [void]$Tabs.TabPages.Add($tab)
}


function New-CatalogList {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Catalog, [string]$EmptyMessage = 'No items have been supplied yet.')
    $list = [System.Windows.Forms.CheckedListBox]::new()
    $list.Dock = 'Fill'
    $list.CheckOnClick = $true
    $list.IntegralHeight = $false
    $list.DisplayMember = 'Name'
    foreach ($item in $Catalog) {
        $index = $list.Items.Add($item)
        $list.SetItemChecked($index, [bool]$item.Default)
    }
    if ($Catalog.Count -eq 0) {
        [void]$list.Items.Add($EmptyMessage)
        $list.Enabled = $false
    }
    return $list
}

function Get-CheckedCatalogItems {
    param([Parameter(Mandatory)][System.Windows.Forms.CheckedListBox]$List)
    if (-not $List.Enabled) { return @() }
    return @($List.CheckedItems | ForEach-Object { $_ })
}

function Add-TabWithList {
    param([Parameter(Mandatory)][System.Windows.Forms.TabControl]$Tabs, [Parameter(Mandatory)][string]$Title, [Parameter(Mandatory)][System.Windows.Forms.CheckedListBox]$List, [string]$Description = '')
    $tab = [System.Windows.Forms.TabPage]::new($Title)
    $layout = [System.Windows.Forms.TableLayoutPanel]::new()
    $layout.Dock = 'Fill'
    $layout.Padding = [System.Windows.Forms.Padding]::new(10)
    $layout.ColumnCount = 1
    $layout.RowCount = 2
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
    $label = [System.Windows.Forms.Label]::new()
    $label.AutoSize = $true
    $label.MaximumSize = [Drawing.Size]::new(850, 0)
    $label.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 10)
    $label.Text = $Description
    $layout.Controls.Add($label, 0, 0)
    $layout.Controls.Add($List, 0, 1)
    $tab.Controls.Add($layout)
    [void]$Tabs.TabPages.Add($tab)
}

$darkBackground = [Drawing.Color]::FromArgb(30, 30, 30)
$darkPanel = [Drawing.Color]::FromArgb(38, 38, 38)
$darkInput = [Drawing.Color]::FromArgb(24, 24, 24)
$darkButton = [Drawing.Color]::FromArgb(55, 55, 55)
$lightText = [Drawing.Color]::FromArgb(235, 235, 235)
$mutedText = [Drawing.Color]::FromArgb(180, 180, 180)

function Set-DarkControl {
    param([System.Windows.Forms.Control]$Control)
    $Control.ForeColor = $lightText
    if ($Control -is [System.Windows.Forms.Form] -or $Control -is [System.Windows.Forms.TabPage]) {
        $Control.BackColor = $darkBackground
    } elseif ($Control -is [System.Windows.Forms.CheckedListBox] -or $Control -is [System.Windows.Forms.RichTextBox]) {
        $Control.BackColor = $darkInput
        $Control.BorderStyle = 'FixedSingle'
    } elseif ($Control -is [System.Windows.Forms.Button]) {
        $Control.BackColor = $darkButton
        $Control.FlatStyle = 'Flat'
        $Control.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(85, 85, 85)
    } else {
        $Control.BackColor = $darkPanel
    }
    foreach ($child in $Control.Controls) { Set-DarkControl $child }
}

$form = [System.Windows.Forms.Form]::new()
$form.Text = $AppName
$form.StartPosition = 'CenterScreen'
$form.Size = [Drawing.Size]::new(1000, 780)
$form.MinimumSize = [Drawing.Size]::new(820, 640)
$form.Font = [Drawing.Font]::new('Segoe UI', 10.5)

$root = [System.Windows.Forms.TableLayoutPanel]::new()
$root.Dock = 'Fill'
$root.Padding = [System.Windows.Forms.Padding]::new(14)
$root.ColumnCount = 1
$root.RowCount = 4
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
$form.Controls.Add($root)

$heading = [System.Windows.Forms.Label]::new()
$heading.AutoSize = $true
$heading.Font = [Drawing.Font]::new('Segoe UI Semibold', 16)
$heading.Text = $AppName
$heading.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 10)
$root.Controls.Add($heading, 0, 0)

$tabs = [System.Windows.Forms.TabControl]::new()
$tabs.Dock = 'Fill'
$tabs.Multiline = $true
$tabs.DrawMode = 'OwnerDrawFixed'
$tabs.ItemSize = [Drawing.Size]::new(150, 34)
$tabs.SizeMode = 'Fixed'
$tabs.Add_DrawItem({
    param($sender, $eventArgs)
    $selected = ($eventArgs.Index -eq $sender.SelectedIndex)
    $background = if ($selected) { [Drawing.Color]::FromArgb(60, 60, 60) } else { $darkPanel }
    $eventArgs.Graphics.FillRectangle([Drawing.SolidBrush]::new($background), $eventArgs.Bounds)
    $text = $sender.TabPages[$eventArgs.Index].Text
    [System.Windows.Forms.TextRenderer]::DrawText($eventArgs.Graphics, $text, $form.Font, $eventArgs.Bounds, $lightText, 'HorizontalCenter,VerticalCenter')
})
$root.Controls.Add($tabs, 0, 1)

$programList = New-CatalogList -Catalog $ProgramCatalog
$programList.Font = [Drawing.Font]::new('Segoe UI Emoji', 10.5)
Add-TabWithList -Tabs $tabs -Title 'Programos' -List $programList -Description 'Pažymėtos programos diegiamos naudojant tikslius WinGet paketų ID. Įrangai priklausantys įrašai atveria oficialų gamintojo puslapį.'

$extensionList = New-CatalogList -Catalog $VivaldiExtensionCatalog
Add-TabWithList -Tabs $tabs -Title 'Vivaldi plėtiniai' -List $extensionList -Description 'Pažymėti Chrome Web Store plėtiniai pridedami per Vivaldi valdomą registro politiką. Po paleidimo patikrinkite, ar plėtiniai atsirado.'

$appsList = New-CatalogList -Catalog $BundledAppCatalog
Add-TabWithList -Tabs $tabs -Title 'Integruotos programėlės' -List $appsList -Description 'Pašalinamos tik pažymėtos programėlės. WebView2, Microsoft Store, WinGet ir sisteminės bibliotekos nešalinamos.'

$settingsTab = [System.Windows.Forms.TabPage]::new('Windows nustatymai')
$settingsFlow = [System.Windows.Forms.FlowLayoutPanel]::new()
$settingsFlow.Dock = 'Fill'
$settingsFlow.AutoScroll = $true
$settingsFlow.FlowDirection = 'TopDown'
$settingsFlow.WrapContents = $false
$settingsFlow.Padding = [System.Windows.Forms.Padding]::new(12)
$settingsLists = [System.Collections.ArrayList]::new()
foreach ($groupName in $WindowsSettingsGroups.Keys) {
    $groupItems = @($WindowsSettingsGroups[$groupName])
    $groupContainer = [System.Windows.Forms.Panel]::new()
    $groupContainer.Width = 900
    $groupContainer.Height = 42 + (30 * $groupItems.Count)
    $groupContainer.Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 14)

    $groupTitle = [System.Windows.Forms.Label]::new()
    $groupTitle.Text = $groupName
    $groupTitle.Font = [Drawing.Font]::new('Segoe UI Semibold', 11.5)
    $groupTitle.AutoSize = $true
    $groupTitle.Location = [Drawing.Point]::new(3, 2)

    $groupList = New-CatalogList -Catalog $groupItems
    $groupList.Location = [Drawing.Point]::new(0, 30)
    $groupList.Width = 880
    $groupList.Height = 8 + (30 * $groupItems.Count)
    $groupList.Anchor = 'Top,Left,Right'
    [void]$settingsLists.Add($groupList)
    $groupContainer.Controls.AddRange(@($groupTitle, $groupList))
    [void]$settingsFlow.Controls.Add($groupContainer)
}
$settingsFlow.Add_SizeChanged({
    foreach ($groupControl in $settingsFlow.Controls) {
        $groupControl.Width = [Math]::Max(500, $settingsFlow.ClientSize.Width - 35)
    }
})
$settingsTab.Controls.Add($settingsFlow)
[void]$tabs.TabPages.Add($settingsTab)

$startupList = New-CatalogList -Catalog @()
$startupList.Items.Clear(); $startupList.Enabled = $true; $startupList.HorizontalScrollbar = $true
$taskList = New-CatalogList -Catalog @()
$taskList.Items.Clear(); $taskList.Enabled = $true; $taskList.HorizontalScrollbar = $true
$startupRefresh = [System.Windows.Forms.Button]::new()
$startupRemove = [System.Windows.Forms.Button]::new()
$taskRefresh = [System.Windows.Forms.Button]::new()
$taskRemove = [System.Windows.Forms.Button]::new()
Add-RemovalTab -Tabs $tabs -Title 'Paleisties programos' -Description 'Registro Run / RunOnce įrašai ir dabartinio naudotojo bei visų naudotojų paleisties failai. Šalinamas tik automatinis paleidimas. Sąrašą įkelkite mygtuku „Atnaujinti sąrašą“. Šalinimas vykdomas atskiru mygtuku.' -List $startupList -Refresh $startupRefresh -Remove $startupRemove
Add-RemovalTab -Tabs $tabs -Title 'Suplanuotos užduotys' -Description 'Visos prieinamos užduotys, įskaitant paslėptas ir Windows sistemines užduotis. Sąrašą įkelkite mygtuku „Atnaujinti sąrašą“. Pažymėkite tik atpažįstamas užduotis. Šalinimas vykdomas atskiru mygtuku; vykdomos užduotys nešalinamos.' -List $taskList -Refresh $taskRefresh -Remove $taskRemove
$startupRefresh.Add_Click({ Update-RemovalList -List $startupList -Kind Startup })
$taskRefresh.Add_Click({ Update-RemovalList -List $taskList -Kind Task })
$startupRemove.Add_Click({ Invoke-SelectedRemoval -List $startupList -Kind Startup })
$taskRemove.Add_Click({ Invoke-SelectedRemoval -List $taskList -Kind Task })

$logTab = [System.Windows.Forms.TabPage]::new('Žurnalas')
$script:LogBox = [System.Windows.Forms.RichTextBox]::new()
$script:LogBox.Dock = 'Fill'
$script:LogBox.ReadOnly = $true
$script:LogBox.WordWrap = $false
$script:LogBox.Font = [Drawing.Font]::new('Consolas', 10)
$logTab.Controls.Add($script:LogBox)
[void]$tabs.TabPages.Add($logTab)

$authorLabel = [System.Windows.Forms.Label]::new()
$authorLabel.AutoSize = $true
$authorLabel.Text = "By $AppAuthor  •  v$AppVersion"
$authorLabel.ForeColor = $mutedText
$authorLabel.Padding = [System.Windows.Forms.Padding]::new(0, 8, 0, 5)
$root.Controls.Add($authorLabel, 0, 2)

$buttonPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$buttonPanel.AutoSize = $true
$buttonPanel.Dock = 'Fill'
$buttonPanel.FlowDirection = 'RightToLeft'
$runButton = [System.Windows.Forms.Button]::new()
$runButton.Text = 'VYKDYTI NUSTATYMĄ'
$runButton.AutoSize = $true
$runButton.Padding = [System.Windows.Forms.Padding]::new(20, 7, 20, 7)
$openLogButton = [System.Windows.Forms.Button]::new()
$openLogButton.Text = 'Atverti žurnalą'
$openLogButton.AutoSize = $true
$openLogButton.Padding = [System.Windows.Forms.Padding]::new(10, 7, 10, 7)
$buttonPanel.Controls.AddRange(@($runButton, $openLogButton))
$root.Controls.Add($buttonPanel, 0, 3)

Set-DarkControl $form
$authorLabel.ForeColor = $mutedText
$script:LogBox.BackColor = $darkInput
$tabs.BackColor = $darkBackground

$openLogButton.Add_Click({
    if (Test-Path -LiteralPath $script:LogPath) { Start-Process -FilePath 'notepad.exe' -ArgumentList @($script:LogPath) }
})

$runButton.Add_Click({
    if ($DryRun) {
        $config = Get-CurrentConfig -ProgramList $programList -ExtensionList $extensionList -SettingsLists $settingsLists -AppsList $appsList
        Write-SetupLog '=== DRY RUN: Kas būtų padaryta ===' 'OK'
        foreach ($id in $config.Programos) { Write-SetupLog "Įdiegti (planuota): $id" 'INFO' }
        foreach ($id in $config.VivaldiPlėtiniai) { Write-SetupLog "Nustatyti plėtinį (planuota): $id" 'INFO' }
        foreach ($pkg in $config.IntegruotosProgramėlės) { Write-SetupLog "Pašalinti (planuota): $pkg" 'INFO' }
        foreach ($key in $config.Nustatymai.Keys) { Write-SetupLog "Nustatyti (planuota): $key" 'INFO' }
        [void][System.Windows.Forms.MessageBox]::Show("Dry Run baigtas. Žurnale matote, kas būtų padaryta.", $AppName, 'OK', 'Information')
        return
    }

    if ($ExportConfig) {
        $config = Get-CurrentConfig -ProgramList $programList -ExtensionList $extensionList -SettingsLists $settingsLists -AppsList $appsList
        $json = $config | ConvertTo-Json -Depth 4
        [System.IO.File]::WriteAllText($ExportConfig, $json, [System.Text.Encoding]::UTF8)
        Write-SetupLog "Konfigūracija išsaugota: $ExportConfig" 'OK'
        [void][System.Windows.Forms.MessageBox]::Show("Konfigūracija išsaugota:\n$ExportConfig", $AppName, 'OK', 'Information')
        return
    }

    if ($ImportConfig) {
        try {
            $json = [System.IO.File]::ReadAllText($ImportConfig, [System.Text.Encoding]::UTF8)
            $config = $json | ConvertFrom-Json
            # Restore program selections
            foreach ($id in $config.Programos) {
                for ($i = 0; $i -lt $programList.Items.Count; $i++) {
                    if ([string]$programList.Items[$i].Id -eq $id) { $programList.SetItemChecked($i, $true) }
                }
            }
            # Restore extension selections
            foreach ($id in $config.VivaldiPlėtiniai) {
                for ($i = 0; $i -lt $extensionList.Items.Count; $i++) {
                    if ([string]$extensionList.Items[$i].Id -eq $id) { $extensionList.SetItemChecked($i, $true) }
                }
            }
            # Restore app removal selections
            foreach ($pkg in $config.IntegruotosProgramėlės) {
                for ($i = 0; $i -lt $appsList.Items.Count; $i++) {
                    if ([string]$appsList.Items[$i].Package -eq $pkg) { $appsList.SetItemChecked($i, $true) }
                }
            }
            # Restore settings selections
            foreach ($key in $config.Nustatymai.Keys) {
                foreach ($list in $settingsLists) {
                    for ($i = 0; $i -lt $list.Items.Count; $i++) {
                        if ([string]$list.Items[$i].Key -eq $key) { $list.SetItemChecked($i, $true) }
                    }
                }
            }
            Write-SetupLog "Konfigūracija importuota iš: $ImportConfig" 'OK'
            [void][System.Windows.Forms.MessageBox]::Show("Konfigūracija įkelta. Spauskite VYKDYTI.", $AppName, 'OK', 'Information')
        } catch {
            Write-SetupLog "Nepavyko importuoti konfigūracijos: $($_.Exception.Message)" 'ERROR'
        }
        return
    }

    if ($Uninstall) {
        $answer = [System.Windows.Forms.MessageBox]::Show('Ar tikrai norite atstatyti visas pasirinktas programas? Šis veiksmas įdiegs jas iš naujo.', 'Patvirtinkite atkūrimą', 'YesNo', 'Warning')
        if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
        $runButton.Enabled = $false
        $tabs.SelectedTab = $logTab
        try {
            Write-SetupLog "$AppName v$AppVersion atkūrimo režimas pradėtas." 'OK'
            try { Set-UninstallMode -Items @(Get-CheckedCatalogItems $programList) }
            catch { Write-SetupLog "Atkūrimo dalies klaida: $($_.Exception.Message)" 'ERROR' }
            [void][System.Windows.Forms.MessageBox]::Show("Atkūrimas baigtas.", $AppName, 'OK', 'Information')
        } finally {
            $runButton.Enabled = $true
        }
        return
    }

    $answer = [System.Windows.Forms.MessageBox]::Show('Ar dabar pritaikyti visas pažymėtas parinktis? Kai kuriems pakeitimams reikės atsijungti arba paleisti Windows iš naujo.', 'Patvirtinkite vykdymą', 'YesNo', 'Warning')
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    $runButton.Enabled = $false
    $tabs.SelectedTab = $logTab
    try {
        Write-SetupLog "$AppName v$AppVersion pradėta. Žurnalo failas: $script:LogPath"
        try { Install-Programs -Items @(Get-CheckedCatalogItems $programList) }
        catch { Write-SetupLog "Programų diegimo dalies klaida: $($_.Exception.Message)" 'ERROR' }
        try { Configure-VivaldiExtensions -Items @(Get-CheckedCatalogItems $extensionList) }
        catch { Write-SetupLog "Vivaldi plėtinių dalies klaida: $($_.Exception.Message)" 'ERROR' }
        Remove-BundledApps -Items @(Get-CheckedCatalogItems $appsList)
        foreach ($settingsList in $settingsLists) {
            foreach ($item in @(Get-CheckedCatalogItems $settingsList)) {
                Invoke-LoggedAction -Description $item.Name -Action { Set-WindowsOption -Key $item.Key }
            }
        }
        Write-SetupLog 'Vykdymas baigtas. Peržiūrėkite įspėjimus bei klaidas ir paleiskite Windows iš naujo.' 'OK'
        [void][System.Windows.Forms.MessageBox]::Show('Vykdymas baigtas. Peržiūrėkite žurnalą ir paleiskite Windows iš naujo.', $AppName, 'OK', 'Information')
    } catch {
        Write-SetupLog "Netikėta klaida: $($_.Exception.Message)" 'ERROR'
        [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Vykdymas sustabdytas', 'OK', 'Error')
    } finally {
        $runButton.Enabled = $true
    }
})

if ($ValidateOnly) {
    Write-Output "$AppName v$AppVersion patikros įkėlimas baigtas."
    exit 0
}

Write-SetupLog 'Paruošta. Pakeitimų dar neatlikta.'
[void]$form.ShowDialog()

; Default = $false }
    [pscustomobject]@{ Name = '✨ OpenRGB Effects Plugin'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGBEffectsPlugin'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🎬 PotPlayer 64 bitų'; InstallType = 'WinGet'; Id = 'Daum.PotPlayer'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🐍 Python 3.14'; InstallType = 'WinGet'; Id = 'Python.Python.3.14'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🧲 qBittorrent'; InstallType = 'WinGet'; Id = 'qBittorrent.qBittorrent'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🎮 Steam'; InstallType = 'WinGet'; Id = 'Valve.Steam'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🍿 Stremio'; InstallType = 'WinGet'; Id = 'Stremio.Stremio'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '📡 TP-Link Archer TBE550E Wi-Fi ir Bluetooth tvarkyklės (oficialus puslapis)'; InstallType = 'OfficialPage'; Url = 'https://www.tp-link.com/en/support/download/archer-tbe550e/'; Default = $true }
    [pscustomobject]@{ Name = '🌐 Vivaldi naršyklė'; InstallType = 'WinGet'; Id = 'Vivaldi.Vivaldi'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = '🌈 Windows HDR Calibration (Microsoft Store)'; InstallType = 'WinGet'; Id = '9N7F2SM5D1LR'; Source = 'msstore'; Default = $true }
    [pscustomobject]@{ Name = '⬇️ yt-dlp'; InstallType = 'WinGet'; Id = 'yt-dlp.yt-dlp'; Source = 'winget'; Default = $true }
)

$VivaldiExtensionCatalog = @(
    [pscustomobject]@{ Name = 'Bitwarden slaptažodžių tvarkyklė'; Id = 'nngceckbapebfimnlniiiahkandclblb'; Default = $true }
    [pscustomobject]@{ Name = 'Hide Scrollbar'; Id = 'gngenlhkmpneoiicndbjghjhpogdcncl'; Default = $true }
    [pscustomobject]@{ Name = 'Imagus Reborn'; Id = 'fcjmgeodgobggcppooncdagfkogfffdm'; Default = $true }
    [pscustomobject]@{ Name = 'SponsorBlock for YouTube'; Id = 'mnjggcdmjocbbbhaepdhchncahnbgone'; Default = $true }
    [pscustomobject]@{ Name = 'YouTube Inline Fullscreen'; Id = 'mfpkbigjnlcgngkdbmnchfnenfmibkig'; Default = $true }
)

# This is intentionally conservative. Core components and frameworks are excluded.
$BundledAppCatalog = @(
    [pscustomobject]@{ Name = 'Clipchamp'; Package = 'Clipchamp.Clipchamp'; Default = $true }
    [pscustomobject]@{ Name = 'Dev Home'; Package = 'Microsoft.Windows.DevHome'; Default = $true }
    [pscustomobject]@{ Name = 'Atsiliepimų telkinys (Feedback Hub)'; Package = 'Microsoft.WindowsFeedbackHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft 365 (Office) programėlė'; Package = 'Microsoft.MicrosoftOfficeHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft naujienos'; Package = 'Microsoft.BingNews'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Solitaire Collection'; Package = 'Microsoft.MicrosoftSolitaireCollection'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft orai'; Package = 'Microsoft.BingWeather'; Default = $true }
    [pscustomobject]@{ Name = 'Žmonės (People)'; Package = 'Microsoft.People'; Default = $true }
    [pscustomobject]@{ Name = 'Užrašinė (Notepad)'; Package = 'Microsoft.WindowsNotepad'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox programėlė'; Package = 'Microsoft.GamingApp'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Game Bar'; Package = 'Microsoft.XboxGamingOverlay'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Identity Provider'; Package = 'Microsoft.XboxIdentityProvider'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Speech-to-Text Overlay'; Package = 'Microsoft.XboxSpeechToTextOverlay'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox TCUI'; Package = 'Microsoft.Xbox.TCUI'; Default = $true }
    [pscustomobject]@{ Name = 'OneDrive'; Package = 'OneDriveDesktop'; Kind = 'OneDrive'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Office darbalaukio paketas'; Package = 'Microsoft.Office.Desktop'; Default = $true }
    [pscustomobject]@{ Name = 'Windows atsarginis kopijavimas (išjungti, bet palikti bendrą Windows apvalkalo paketą)'; Package = 'WindowsBackup'; Kind = 'WindowsBackup'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Edge naršyklė ir jos naršyklės naujinimo komponentai'; Package = 'MicrosoftEdge'; Kind = 'Edge'; Default = $true }
)

$PrivacyCatalog = @(
    [pscustomobject]@{ Name = 'Sumažinti diagnostikos duomenis iki mažiausio palaikomo lygio'; Key = 'DiagnosticData'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti reklamos ID ir suasmenintas reklamas'; Key = 'Advertising'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti pagal diagnostikos duomenis pritaikytas funkcijas'; Key = 'TailoredExperiences'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti Windows pasiūlymus ir reklaminį turinį'; Key = 'Suggestions'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti atsiliepimų prašymus'; Key = 'Feedback'; Default = $true }
    [pscustomobject]@{ Name = 'Išjungti veiklos istorijos skelbimą ir siuntimą'; Key = 'ActivityHistory'; Default = $true }
    [pscustomobject]@{ Name = 'Sumažinti rašymo ir braižymo suasmeninimo duomenų rinkimą'; Key = 'InputPersonalization'; Default = $true }
)

$WindowsSettingsGroups = [ordered]@{
    'Užduočių juosta ir Start meniu' = @(
        [pscustomobject]@{ Name = 'Lygiuoti užduočių juostą kairėje'; Key = 'TaskbarLeft'; Default = $true }
        [pscustomobject]@{ Name = 'Slėpti paiešką užduočių juostoje'; Key = 'HideSearch'; Default = $true }
        [pscustomobject]@{ Name = 'Slėpti valdiklius užduočių juostoje'; Key = 'HideWidgets'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Start meniu rekomendacijas'; Key = 'DisableStartRecommendations'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti neseniai atidarytų elementų rodymą'; Key = 'DisableRecentItems'; Default = $true }
        [pscustomobject]@{ Name = 'Automatiškai slėpti užduočių juostą'; Key = 'TaskbarAutoHide'; Default = $true }
    )
    'Failų naršyklė' = @(
        [pscustomobject]@{ Name = 'Rodyti failų plėtinius'; Key = 'ShowFileExtensions'; Default = $true }
        [pscustomobject]@{ Name = 'Rodyti paslėptus failus'; Key = 'ShowHiddenFiles'; Default = $false }
        [pscustomobject]@{ Name = 'Failų naršyklę atverti ties „Šis kompiuteris“'; Key = 'ExplorerThisPC'; Default = $true }
        [pscustomobject]@{ Name = 'Naudoti kompaktišką rodinį'; Key = 'CompactView'; Default = $true }
        [pscustomobject]@{ Name = 'Grąžinti klasikinį dešiniojo pelės mygtuko meniu'; Key = 'ClassicContextMenu'; Default = $true }
        [pscustomobject]@{ Name = 'Pašalinti „Galeriją“ iš failų naršyklės'; Key = 'RemoveGallery'; Default = $true }
        [pscustomobject]@{ Name = 'Pašalinti „Pagrindinį“ iš failų naršyklės'; Key = 'RemoveHome'; Default = $true }
    )
    'Išvaizda ir naudojimas' = @(
        [pscustomobject]@{ Name = 'Išjungti Bing ir interneto rezultatus Start paieškoje'; Key = 'DisableWebSearch'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Windows patarimus ir pasiūlymus'; Key = 'DisableTips'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti programų paleidimo delsą'; Key = 'DisableStartupDelay'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti pelės pagreitį'; Key = 'DisableMouseAcceleration'; Default = $true }
        [pscustomobject]@{ Name = 'Įjungti Windows tamsųjį režimą'; Key = 'DarkMode'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti užrakinimo ekrano pasiūlymus'; Key = 'DisableLockScreenSuggestions'; Default = $true }
    )
    'Privatumas' = $PrivacyCatalog
    'Sistema ir maitinimas' = @(
        [pscustomobject]@{ Name = 'Išjungti greitąjį paleidimą'; Key = 'DisableFastStartup'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti sistemos atkūrimą'; Key = 'DisableSystemRestore'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Windows atsarginį kopijavimą ir nustatymų sinchronizavimą'; Key = 'DisableWindowsBackup'; Default = $true }
    )
    'Tinklas ir žaidimai' = @(
        [pscustomobject]@{ Name = 'Nustatyti prijungtus tinklus kaip privačius'; Key = 'PrivateNetwork'; Default = $true }
        [pscustomobject]@{ Name = 'Išjungti Xbox Game Bar įrašymą'; Key = 'DisableGameBarRecording'; Default = $true }
    )
    'Regionas' = @(
        [pscustomobject]@{ Name = 'Nustatyti Lietuvos regioną ir Vilniaus laiko juostą'; Key = 'LithuaniaRegion'; Default = $true }
    )
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $ValidateOnly -and -not (Test-IsAdministrator)) {
    if (-not $PSCommandPath) { throw 'Prieš paleisdami įrašykite šį scenarijų į failą.' }
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
        '-NoProfile'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        ('"{0}"' -f $PSCommandPath)
    )
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:LogPath = Join-Path $env:TEMP ('FreshWindowsSetup-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
$script:LogBox = $null

function Write-SetupLog {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Message,
        [ValidateSet('INFO', 'OK', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    $line = '[{0:HH:mm:ss}] [{1}] {2}' -f (Get-Date), $Level, $Message
    Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    if ($null -ne $script:LogBox) {
        $start = $script:LogBox.TextLength
        $script:LogBox.AppendText($line + [Environment]::NewLine)
        $script:LogBox.Select($start, $line.Length)
        $script:LogBox.SelectionColor = [Drawing.Color]::FromArgb(235, 235, 235)
        if ($Level -eq 'ERROR') {
            $script:LogBox.SelectionBackColor = [Drawing.Color]::FromArgb(128, 28, 38)
        } else {
            $script:LogBox.SelectionBackColor = $script:LogBox.BackColor
        }
        $script:LogBox.SelectionStart = $script:LogBox.TextLength
        $script:LogBox.SelectionLength = 0
        $script:LogBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet('DWord', 'QWord', 'String', 'ExpandString', 'MultiString', 'Binary')][string]$Type = 'DWord'
    )
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null

    $actual = Get-ItemPropertyValue -LiteralPath $Path -Name $Name -ErrorAction Stop
    if ($Value -is [array]) {
        $expectedText = ($Value | ForEach-Object { [string]$_ }) -join '|'
        $actualText = ($actual | ForEach-Object { [string]$_ }) -join '|'
        $matches = $expectedText -ceq $actualText
    } else {
        $matches = ([string]$Value) -ceq ([string]$actual)
    }
    if (-not $matches) {
        throw "Nepavyko patikrinti $Path\$Name. Tikėtasi '$Value', rasta '$actual'."
    }
    Write-SetupLog "Patikrinta: $Path\$Name = $actual."
}

function Set-RegistryDefaultValue {
    param([Parameter(Mandatory)][string]$Path, [AllowEmptyString()][string]$Value)
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-Item -LiteralPath $Path -Value $Value -Force
    $actual = (Get-Item -LiteralPath $Path -ErrorAction Stop).GetValue('')
    if ([string]$actual -cne [string]$Value) {
        throw "Nepavyko patikrinti numatytosios registro reikšmės ties $Path."
    }
    Write-SetupLog "Patikrinta numatytoji registro reikšmė: $Path."
}

function Remove-RegistryValue {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name)
    if (Test-Path -LiteralPath $Path) {
        Remove-ItemProperty -LiteralPath $Path -Name $Name -Force -ErrorAction SilentlyContinue
    }
    $remaining = Get-ItemPropertyValue -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $remaining) { throw "Nepavyko patikrinti registro reikšmės pašalinimo: $Path\$Name." }
    Write-SetupLog "Patikrinta, kad registro reikšmės nėra: $Path\$Name."
}

function Invoke-LoggedAction {
    param([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][scriptblock]$Action)
    Write-SetupLog "$Description..."
    try {
        & $Action
    Write-SetupLog "$Description – atlikta." 'OK'
    } catch {
        $errorMsg = if ($_.Exception.Message) { $_.Exception.Message } else { 'Nežinoma klaida' }
        Write-SetupLog "$Description – nepavyko: $errorMsg" 'ERROR'
    }
}

function Invoke-NativeCommand {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments 2>&1 | ForEach-Object { Write-SetupLog ([string]$_) }
    if ($LASTEXITCODE -ne 0) { throw "$FilePath baigė darbą su kodu $LASTEXITCODE." }
}

function Invoke-NativeCommandSafe {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$Arguments,
        [string[]]$TransientErrorCodes = @(1605, 1612, 1618, 1619, 1641, 3010),
        [int]$MaxRetries = 2
    )
    $exitCode = -1
    for ($i = 0; $i -lt $MaxRetries + 1; $i++) {
        & $FilePath @Arguments 2>&1 | ForEach-Object { Write-SetupLog ([string]$_) }
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) { return $true }
        if ($TransientErrorCodes -contains $exitCode) {
            Write-SetupLog "Perėjusi klaida ($exitCode). Bandoma iš naujo ($($i+1)/$MaxRetries)..." 'WARN'
            Start-Sleep -Seconds (3 * ($i + 1))
            continue
        }
        if ($i -lt $MaxRetries) {
            Write-SetupLog "Klaida ($exitCode). Bandoma iš naujo ($($i+1)/$MaxRetries)..." 'WARN'
            Start-Sleep -Seconds (3 * ($i + 1))
            continue
        }
        throw "$FilePath baigė darbą su kodu $exitCode."
    }
    return $true
}

function Test-WinGetPackageInstalled {
    param([string]$Id, [string]$Source = 'winget', [switch]$MsStore)
    $sourceArg = if ($MsStore) { 'msstore' } else { $Source }
    try {
        $listOutput = & winget.exe list --id $Id --exact --source $sourceArg --accept-source-agreements --disable-interactivity 2>&1
        return ($listOutput -join "`n") -match [regex]::Escape($Id)
    } catch {
        return $false
    }
}

function Install-Programs {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Programos: niekas nepasirinkta.' 'WARN'; return }
    $winget = Get-Command 'winget.exe' -ErrorAction SilentlyContinue
    if (-not $winget) { throw 'WinGet nepasiekiamas. Įdiekite arba atnaujinkite Microsoft App Installer ir bandykite dar kartą.' }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Diegti: $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Start-Process -FilePath $item.Url
                Write-SetupLog "Atvertas patikrintas leidėjo puslapis: $($item.Url). Šį įrangai ar programai būdingą diegimą užbaikite rankiniu būdu." 'WARN'
                return
            }

            # Skip if already installed (Item 4)
            $isInstalled = Test-WinGetPackageInstalled -Id $item.Id -Source $item.Source
            # Use safe command with retries for transient errors (Item 8)
            $arguments = @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
            try {
                Invoke-NativeCommandSafe -FilePath $winget.Source -Arguments $arguments
                # Verify installation succeeded
                $listOutput = @(& $winget.Source list --id $item.Id --exact --source $item.Source --accept-source-agreements --disable-interactivity 2>&1)
                if ($LASTEXITCODE -ne 0 -or -not (($listOutput -join "`n") -match [regex]::Escape($item.Id))) {
                    Write-SetupLog "WinGet patikra nerado $($item.Id). Paketas gali būti iš dalies įdiegtas." 'WARN'
                } else {
                    Write-SetupLog "Patikrintas įdiegtas paketas: $($item.Id)." 'OK'
                }
            } catch {
                $errorMsg = if ($null -ne $_.Exception.Message -and $_.Exception.Message.Trim()) { $_.Exception.Message } else { 'Nežinoma klaida.' }
                Write-SetupLog "WinGet diegimas nepavyko: $errorMsg" 'ERROR'
            }
        }
    }
}

function Configure-VivaldiExtensions {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Vivaldi plėtiniai: niekas nepasirinkta.' 'WARN'; return }
    $policyPath = 'HKLM:\SOFTWARE\Policies\Vivaldi\ExtensionInstallForcelist'
    if (-not (Test-Path -LiteralPath $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
    $index = 1
    foreach ($item in $Items) {
        $policyValue = '{0};https://clients2.google.com/service/update2/crx' -f $item.Id
        Set-RegistryValue -Path $policyPath -Name ([string]$index) -Value $policyValue -Type String
        Write-SetupLog "Pridėta Vivaldi plėtinio politika: $($item.Name)." 'OK'
        $index++
    }
    Write-SetupLog 'Vivaldi politikos diegimas yra eksperimentinis. Paleidę Vivaldi patikrinkite plėtinius.' 'WARN'
}

function Set-PrivacyOption {
    param([Parameter(Mandatory)][string]$Key)
    switch ($Key) {
        'DiagnosticData' {
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDiagnosticLogCollection' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDumpCollection' 1
            Write-SetupLog 'Diagnostikos duomenys nustatyti į mažiausią įprastai palaikomą lygį; vis tiek galioja Windows leidimo apribojimai.' 'WARN'
        }
        'Advertising' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
        }
        'TailoredExperiences' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' 1
        }
        'Suggestions' {
            $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            foreach ($name in @('ContentDeliveryAllowed', 'FeatureManagementEnabled', 'OemPreInstalledAppsEnabled', 'PreInstalledAppsEnabled', 'PreInstalledAppsEverEnabled', 'SilentInstalledAppsEnabled', 'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled', 'SystemPaneSuggestionsEnabled')) {
                Set-RegistryValue $contentPath $name 0
            }
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
        }
        'Feedback' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
        }
        'ActivityHistory' {
            $activityPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
            Set-RegistryValue $activityPath 'EnableActivityFeed' 0
            Set-RegistryValue $activityPath 'PublishUserActivities' 0
            Set-RegistryValue $activityPath 'UploadUserActivities' 0
        }
        'InputPersonalization' {
            $inputPath = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
            Set-RegistryValue $inputPath 'AllowInputPersonalization' 0
            Set-RegistryValue $inputPath 'RestrictImplicitInkCollection' 1
            Set-RegistryValue $inputPath 'RestrictImplicitTextCollection' 1
            Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
            Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
        }
        default { throw "Neatpažinta privatumo parinktis: $Key" }
    }
}

function Get-CurrentConfig {
    param(
        [System.Windows.Forms.CheckedListBox]$ProgramList,
        [System.Windows.Forms.CheckedListBox]$ExtensionList,
        [System.Collections.ArrayList]$SettingsLists,
        [System.Windows.Forms.CheckedListBox]$AppsList
    )
    $config = [ordered]@{
        'Programos' = @($ProgramList.CheckedItems | ForEach-Object { $_.Id })
        'VivaldiPlėtiniai' = @($ExtensionList.CheckedItems | ForEach-Object { $_.Id })
        'IntegruotosProgramėlės' = @($AppsList.CheckedItems | ForEach-Object { $_.Package })
        'Nustatymai' = @{}
    }
    foreach ($list in $SettingsLists) {
        foreach ($item in $list.CheckedItems) {
            if ($item.Key) {
                $config.Nustatymai[$item.Key] = $true
            }
        }
    }
    return $config
}

function Set-UninstallMode {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Naudoti: niekas nepasirinkta.' 'WARN'; return }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Atstatyti (nešalinti): $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Write-SetupLog "Oficialus puslapis atidarytas rankiniam įdiegimui: $($item.Url)." 'WARN'
                Start-Process -FilePath $item.Url
                return
            }
            # Reinstall via winget
            $arguments = @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
            Invoke-NativeCommandSafe -FilePath 'winget.exe' -Arguments $arguments
            Write-SetupLog "Atstatytas paketas: $($item.Id)." 'OK'
        }
    }
}

function Remove-BundledApps {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Integruotos programėlės: niekas nepasirinkta.' 'WARN'; return }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Pašalinti: $($item.Name)" -Action {
            $kindProperty = $item.PSObject.Properties['Kind']
            $kind = if ($null -ne $kindProperty) { [string]$kindProperty.Value } else { 'Appx' }

            if ($kind -eq 'OneDrive') {
                try {
                    $setupCandidates = @(
                        (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
                        (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
                    )
                    $setup = $setupCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
                    if ($setup) {
                        # Stop OneDrive process first — it blocks uninstall and causes 0x80070005
                        Get-Process -Name 'OneDrive' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 2
                        $process = Start-Process -FilePath $setup -ArgumentList @('/uninstall') -Wait -PassThru -ErrorAction Stop
                        # Exit code 19 = already uninstalled (expected on fresh systems)
                        if ($process.ExitCode -notin @(0, 19)) { throw "OneDrive šalinimo programa baigė darbą su kodu $($process.ExitCode)." }
                    }
                    $oneDriveExecutables = @(
                        (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe')
                        (Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe')
                    )
                    if ($oneDriveExecutables | Where-Object { Test-Path -LiteralPath $_ }) {
                        throw 'OneDrive patikra vis dar aptiko įdiegtą vykdomąjį failą.'
                    }
                    Write-SetupLog 'Patikrinta: OneDrive vykdomojo failo nėra.'
                } catch {
                    Write-SetupLog "OneDrive šalinimas praleistas: $($_.Exception.Message)" 'WARN'
                }
                return
            }

            if ($kind -eq 'WindowsBackup') {
                Set-WindowsOption -Key 'DisableWindowsBackup'
                Write-SetupLog 'Windows atsarginio kopijavimo programa yra bendro Windows apvalkalo paketo dalis, todėl pats paketas paliktas.' 'WARN'
                return
            }

            if ($kind -eq 'Edge') {
                $edgeGuid = '{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
                $webViewGuid = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
                $edgePolicy = 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate'
                Set-RegistryValue $edgePolicy ("Install$edgeGuid") 0
                Set-RegistryValue $edgePolicy ("Update$edgeGuid") 0
                Set-RegistryValue $edgePolicy ("Uninstall$($edgeGuid.ToLowerInvariant())") 1
                Set-RegistryValue $edgePolicy ("Install$webViewGuid") 1
                Set-RegistryValue $edgePolicy ("Update$webViewGuid") 1

                Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                $edgeRoot = Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application'
                $setup = Get-ChildItem -LiteralPath $edgeRoot -Filter 'setup.exe' -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $_.FullName -match '\\Installer\\setup\.exe$' } |
                    Sort-Object FullName -Descending |
                    Select-Object -First 1
                if ($setup) {
                    $process = Start-Process -FilePath $setup.FullName -ArgumentList @('--uninstall', '--system-level', '--verbose-logging', '--force-uninstall') -Wait -PassThru
                    if ($process.ExitCode -ne 0) { throw "Microsoft Edge šalinimo programa baigė darbą su kodu $($process.ExitCode)." }
                }

                foreach ($runPath in @(
                    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
                    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
                    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
                )) {
                    try { Remove-RegistryValue $runPath 'MicrosoftEdgeAutoLaunch' } catch {}
                }

                foreach ($shortcut in @(
                    (Join-Path $env:PUBLIC 'Desktop\Microsoft Edge.lnk'),
                    (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk'),
                    (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk')
                )) {
                    if (Test-Path -LiteralPath $shortcut) { Remove-Item -LiteralPath $shortcut -Force }
                    if (Test-Path -LiteralPath $shortcut) { throw "Nepavyko pašalinti nuorodos: $shortcut" }
                }

                $edgeExecutable = Join-Path $edgeRoot 'msedge.exe'
                $versionedEdge = @(Get-ChildItem -LiteralPath $edgeRoot -Filter 'msedge.exe' -Recurse -ErrorAction SilentlyContinue)
                if ((Test-Path -LiteralPath $edgeExecutable) -or $versionedEdge.Count -gt 0) {
                    throw 'Microsoft Edge pašalinimo patikra vis dar aptiko msedge.exe.'
                }
                Write-SetupLog 'Patikrinta: Edge naršyklė pašalinta, jos diegimas ir naujinimai užblokuoti; WebView2 ir jo naujinimai palikti.'
                return
            }

            foreach ($package in @(Get-AppxPackage -AllUsers -Name $item.Package -ErrorAction SilentlyContinue)) {
                Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
            }
            $provisioned = @(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $item.Package })
            foreach ($package in $provisioned) {
                Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -AllUsers -ErrorAction Stop | Out-Null
            }

            $remainingInstalled = @(Get-AppxPackage -AllUsers -Name $item.Package -ErrorAction SilentlyContinue)
            $remainingProvisioned = @(Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $item.Package })
            if ($remainingInstalled.Count -gt 0 -or $remainingProvisioned.Count -gt 0) {
                throw "Programėlės pašalinimo patikra vis dar aptiko $($item.Package)."
            }
            Write-SetupLog "Patikrinta, kad pašalinta arba nebuvo įdiegta: $($item.Package)."
        }
    }
}

function Set-TaskbarAutoHide {
    $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = [byte[]](Get-ItemPropertyValue -LiteralPath $path -Name 'Settings' -ErrorAction Stop)
    if ($settings.Length -lt 9) { throw 'Užduočių juostos nustatymo reikšmės formatas neatpažintas.' }
    $settings[8] = 3
    Set-RegistryValue $path 'Settings' $settings 'Binary'
    Write-SetupLog 'Automatinis užduočių juostos slėpimas visiškai įsigalios iš naujo paleidus Explorer arba kitą kartą prisijungus.' 'WARN'
}

function Set-LithuaniaRegion {
    Set-Culture -CultureInfo 'lt-LT'
    Set-WinHomeLocation -GeoId 140
    Set-WinSystemLocale -SystemLocale 'lt-LT'
    Set-TimeZone -Id 'FLE Standard Time'
    if ((Get-TimeZone).Id -ne 'FLE Standard Time') { throw 'Nepavyko patikrinti laiko juostos.' }
    if ((Get-WinSystemLocale).Name -ne 'lt-LT') { throw 'Nepavyko patikrinti sistemos lokalės.' }
    if ((Get-WinHomeLocation).GeoId -ne 140) { throw 'Nepavyko patikrinti namų regiono.' }
    if ((Get-Culture).Name -ne 'lt-LT') { throw 'Nepavyko patikrinti regioninio formato.' }
    Write-SetupLog 'Patikrintas Lietuvos regionas, lietuviška sistemos lokalė ir Vilniaus laiko juosta.'
    Write-SetupLog 'Kai kuriems lietuviškos lokalės pakeitimams gali reikėti atsijungti arba paleisti Windows iš naujo.' 'WARN'
}

function Set-ConnectedNetworksPrivate {
    $profiles = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected' })
    if ($profiles.Count -eq 0) { throw 'Nerastas nė vienas prijungtas tinklo profilis.' }
    foreach ($profile in $profiles) {
        Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
    }
    $remaining = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { ($_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected') -and $_.NetworkCategory -ne 'Private' })
    if ($remaining.Count -gt 0) { throw 'Tinklo kategorijos patikra aptiko prijungtą profilį, kuris nėra privatus.' }
    Write-SetupLog 'Patikrinta: visi prijungti tinklo profiliai yra privatūs.'
}

function Set-WindowsOption {
    param([Parameter(Mandatory)][string]$Key)
    if ($Key -in @($PrivacyCatalog.Key)) {
        Set-PrivacyOption -Key $Key
        return
    }
    switch ($Key) {
        'TaskbarLeft' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0 }
        'HideSearch' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0 }
        'HideWidgets' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
            try { Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0 } catch { Write-SetupLog 'Dsh politika nepasiekiama (galbūt reikalingos teisės).' 'WARN' }
        }
        'DisableStartRecommendations' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_AccountNotifications' 0
        }
        'DisableRecentItems' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoRecentDocsHistory' 1
        }
        'ShowFileExtensions' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0 }
        'ShowHiddenFiles' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' 1 }
        'CompactView' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'UseCompactMode' 1 }
        'ClassicContextMenu' {
            Set-RegistryDefaultValue 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' ''
        }
        'RemoveGallery' {
            Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0
        }
        'RemoveHome' {
            Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' 'System.IsPinnedToNameSpaceTree' 0
        }
        'DisableWebSearch' {
            Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
        }
        'DisableTips' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
        }
        'DisableStartupDelay' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0 }
        'ExplorerThisPC' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1 }
        'DisableMouseAcceleration' {
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseSpeed' '0' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' '0' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' '0' 'String'
        }
        'DarkMode' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0
        }
        'DisableLockScreenSuggestions' {
            $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            Set-RegistryValue $contentPath 'RotatingLockScreenEnabled' 0
            Set-RegistryValue $contentPath 'RotatingLockScreenOverlayEnabled' 0
            Set-RegistryValue $contentPath 'SubscribedContent-338387Enabled' 0
        }
        'DisableFastStartup' {
            Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
        }
        'DisableSystemRestore' {
            $systemDrive = [Environment]::GetEnvironmentVariable('SystemDrive') + '\'
            Disable-ComputerRestore -Drive $systemDrive -ErrorAction SilentlyContinue
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' 'DisableSR' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' 'DisableConfig' 1
        }
        'DisableWindowsBackup' {
            $syncPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
            Set-RegistryValue $syncPath 'EnableWindowsBackup' 0
            foreach ($name in @('DisableSettingSync', 'DisableApplicationSettingSync', 'DisableCredentialsSettingSync', 'DisablePersonalizationSettingSync', 'DisableWindowsSettingSync')) {
                Set-RegistryValue $syncPath $name 2
                Set-RegistryValue $syncPath ($name + 'UserOverride') 1
            }
            Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup' 'DisableMonitoring' 1
        }
        'PrivateNetwork' { Set-ConnectedNetworksPrivate }
        'DisableGameBarRecording' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
            Set-RegistryValue 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
        }
        'TaskbarAutoHide' { Set-TaskbarAutoHide }
        'LithuaniaRegion' { Set-LithuaniaRegion }
        default { throw "Neatpažintas Windows nustatymas: $Key" }
    }
}

function Get-StartupEntries {
    foreach ($hive in @([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryHive]::LocalMachine)) {
        foreach ($view in @([Microsoft.Win32.RegistryView]::Registry64, [Microsoft.Win32.RegistryView]::Registry32)) {
            if (-not [Environment]::Is64BitOperatingSystem -and $view -eq [Microsoft.Win32.RegistryView]::Registry64) { continue }
            $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, $view)
            try {
                foreach ($suffix in @('Run', 'RunOnce')) {
                    $path = 'Software\Microsoft\Windows\CurrentVersion\' + $suffix
                    $key = $base.OpenSubKey($path)
                    if ($null -eq $key) { continue }
                    try {
                        foreach ($valueName in $key.GetValueNames()) {
                            $value = $key.GetValue($valueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                            [pscustomobject]@{
                                Name = "$valueName [$hive / $view / $suffix] — $value"
                                Kind = 'Registry'; Hive = $hive; View = $view; Path = $path
                                ValueName = $valueName; Value = $value; ValueKind = $key.GetValueKind($valueName)
                                Default = $false
                            }
                        }
                    } finally { $key.Dispose() }
                }
            } finally { $base.Dispose() }
        }
    }
    foreach ($folder in @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))) {
        if (-not $folder -or -not (Test-Path -LiteralPath $folder)) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $folder -File -Force -ErrorAction Stop)) {
            if ($file.Name -eq 'desktop.ini') { continue }
            [pscustomobject]@{
                Name = "$($file.Name) [$folder]"; Kind = 'File'; Path = $file.FullName
                Hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash; Default = $false
            }
        }
    }
}

function Get-TaskEntries {
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    foreach ($task in @(Get-ScheduledTask -ErrorAction Stop | Sort-Object TaskPath, TaskName)) {
        try {
            $registered = $service.GetFolder($task.TaskPath).GetTask($task.TaskName)
            $actions = @($task.Actions | ForEach-Object {
                if ($_.PSObject.Properties['Execute']) { "$($_.Execute) $($_.Arguments)" } else { $_.CimClass.CimClassName }
            }) -join '; '
            [pscustomobject]@{
                Name = "$($task.TaskPath)$($task.TaskName) [$($task.State)] — $actions"
                Kind = 'Task'; TaskPath = $task.TaskPath; TaskName = $task.TaskName
                Xml = [string]$registered.Xml; Default = $false
            }
        } catch { Write-SetupLog "Užduoties nuskaitymo klaida: $($task.TaskPath)$($task.TaskName): $($_.Exception.Message)" 'WARN' }
    }
}

function New-RemovalBackupDirectory {
    $path = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) ('FreshWindowsSetup\RemovalBackups\' + [guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($path)
    return $path
}

function Remove-StartupEntry {
    param([Parameter(Mandatory)]$Item)
    if ($Item.Kind -eq 'Registry') {
        $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Item.Hive, $Item.View)
        try {
            $key = $base.OpenSubKey($Item.Path, $true)
            if ($null -eq $key) { throw 'Įrašas pasikeitė. Atnaujinkite sąrašą.' }
            try {
                $value = $key.GetValue($Item.ValueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                if ($key.GetValueNames() -cnotcontains $Item.ValueName -or $key.GetValueKind($Item.ValueName) -ne $Item.ValueKind -or (ConvertTo-Json -InputObject $value -Compress) -cne (ConvertTo-Json -InputObject $Item.Value -Compress)) {
                    throw 'Įrašas pasikeitė. Atnaujinkite sąrašą.'
                }
                $backup = New-RemovalBackupDirectory
                $Item | Export-Clixml -LiteralPath (Join-Path $backup 'startup.xml') -Depth 5
                Write-SetupLog "Atsarginė kopija: $backup"
                $key.DeleteValue($Item.ValueName, $true)
                if ($key.GetValueNames() -ccontains $Item.ValueName) { throw 'Registro įrašas nepašalintas.' }
            } finally { $key.Dispose() }
        } finally { $base.Dispose() }
    } elseif ($Item.Kind -eq 'File') {
        $allowed = @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))
        $parent = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($Item.Path))
        if ($allowed -notcontains $parent) { throw 'Failas nėra paleisties aplanke.' }
        if ((Get-FileHash -LiteralPath $Item.Path -Algorithm SHA256).Hash -cne $Item.Hash) { throw 'Failas pasikeitė. Atnaujinkite sąrašą.' }
        $backup = New-RemovalBackupDirectory
        Copy-Item -LiteralPath $Item.Path -Destination (Join-Path $backup ([IO.Path]::GetFileName($Item.Path))) -ErrorAction Stop
        $Item | Export-Clixml -LiteralPath (Join-Path $backup 'startup.xml') -Depth 5
        if ((Get-FileHash -LiteralPath (Join-Path $backup ([IO.Path]::GetFileName($Item.Path))) -Algorithm SHA256).Hash -cne $Item.Hash) { throw 'Atsarginės kopijos patikra nepavyko.' }
        Write-SetupLog "Atsarginė kopija: $backup"
        Remove-Item -LiteralPath $Item.Path -Force -ErrorAction Stop
        if (Test-Path -LiteralPath $Item.Path) { throw 'Paleisties failas nepašalintas.' }
    } else { throw 'Neatpažintas paleisties įrašo tipas.' }
}

function Remove-TaskEntry {
    param([Parameter(Mandatory)]$Item)
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    $folder = $service.GetFolder($Item.TaskPath)
    $task = $folder.GetTask($Item.TaskName)
    if ([string]$task.Xml -cne $Item.Xml) { throw 'Užduotis pasikeitė. Atnaujinkite sąrašą.' }
    if ([int]$task.State -eq 4) { throw 'Užduotis vykdoma. Sustabdykite ją užduočių planuoklyje ir bandykite dar kartą.' }
    $backup = New-RemovalBackupDirectory
    [IO.File]::WriteAllText((Join-Path $backup 'task.xml'), $Item.Xml, [Text.Encoding]::Unicode)
    $Item | Select-Object TaskPath, TaskName | Export-Clixml -LiteralPath (Join-Path $backup 'task-location.xml')
    Write-SetupLog "Atsarginė kopija: $backup"
    $folder.DeleteTask($Item.TaskName, 0)
    $remaining = @($folder.GetTasks(1) | Where-Object { $_.Name -ceq $Item.TaskName })
    if ($remaining.Count -gt 0) { throw 'Užduotis nepašalinta.' }
}

function Update-RemovalList {
    param([System.Windows.Forms.CheckedListBox]$List, [ValidateSet('Startup', 'Task')][string]$Kind)
    $List.Items.Clear()
    try {
        $items = if ($Kind -eq 'Startup') { @(Get-StartupEntries) } else { @(Get-TaskEntries) }
        foreach ($entry in $items) { [void]$List.Items.Add($entry, $false) }
        Write-SetupLog "Sąrašas atnaujintas ($Kind): $($items.Count) įrašų."
    } catch { Write-SetupLog "Sąrašo nuskaitymo klaida ($Kind): $($_.Exception.Message)" 'ERROR' }
}

function Invoke-SelectedRemoval {
    param([System.Windows.Forms.CheckedListBox]$List, [ValidateSet('Startup', 'Task')][string]$Kind)
    $selected = @($List.CheckedItems | ForEach-Object { $_ })
    if ($selected.Count -eq 0) {
        [void][System.Windows.Forms.MessageBox]::Show('Pirmiausia pažymėkite norimus pašalinti įrašus.', $AppName, 'OK', 'Information')
        return
    }
    if ($DryRun) {
        foreach ($entry in $selected) { Write-SetupLog "DRY RUN: Pašalinti (planuota): $($entry.Name)" }
        return
    }
    $summary = ($selected | ForEach-Object { $_.Name }) -join [Environment]::NewLine
    $answer = [System.Windows.Forms.MessageBox]::Show("Pašalinti $($selected.Count) pažymėtus įrašus? Sisteminės užduotys gali būti būtinos Windows veikimui. Prieš šalinimą bus išsaugotos atsarginės kopijos.`r`n`r`n$summary", 'Patvirtinkite šalinimą', 'YesNo', 'Warning')
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    $tabs.Enabled = $false
    $runButton.Enabled = $false
    try {
        foreach ($entry in $selected) {
            Invoke-LoggedAction -Description "Pašalinti: $($entry.Name)" -Action {
                if ($Kind -eq 'Startup') { Remove-StartupEntry $entry } else { Remove-TaskEntry $entry }
            }
        }
        Update-RemovalList -List $List -Kind $Kind
        [void][System.Windows.Forms.MessageBox]::Show('Šalinimas baigtas. Peržiūrėkite žurnalą ir atsarginių kopijų vietas.', $AppName, 'OK', 'Information')
    } finally { $tabs.Enabled = $true; $runButton.Enabled = $true }
}

function Add-RemovalTab {
    param([System.Windows.Forms.TabControl]$Tabs, [string]$Title, [string]$Description, [System.Windows.Forms.CheckedListBox]$List, [System.Windows.Forms.Button]$Refresh, [System.Windows.Forms.Button]$Remove)
    $tab = [System.Windows.Forms.TabPage]::new($Title)
    $layout = [System.Windows.Forms.TableLayoutPanel]::new()
    $layout.Dock = 'Fill'; $layout.Padding = [System.Windows.Forms.Padding]::new(10)
    $layout.ColumnCount = 1; $layout.RowCount = 3
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
    $label = [System.Windows.Forms.Label]::new()
    $label.AutoSize = $true; $label.MaximumSize = [Drawing.Size]::new(850, 0)
    $label.Text = $Description; $label.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 10)
    $buttons = [System.Windows.Forms.FlowLayoutPanel]::new()
    $buttons.AutoSize = $true; $buttons.Dock = 'Fill'
    $Refresh.Text = 'Atnaujinti sąrašą'; $Refresh.AutoSize = $true
    $Remove.Text = 'Pašalinti pažymėtus'; $Remove.AutoSize = $true
    $buttons.Controls.AddRange(@($Refresh, $Remove))
    $layout.Controls.Add($label, 0, 0); $layout.Controls.Add($List, 0, 1); $layout.Controls.Add($buttons, 0, 2)
    $tab.Controls.Add($layout); [void]$Tabs.TabPages.Add($tab)
}


function New-CatalogList {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Catalog, [string]$EmptyMessage = 'No items have been supplied yet.')
    $list = [System.Windows.Forms.CheckedListBox]::new()
    $list.Dock = 'Fill'
    $list.CheckOnClick = $true
    $list.IntegralHeight = $false
    $list.DisplayMember = 'Name'
    foreach ($item in $Catalog) {
        $index = $list.Items.Add($item)
        $list.SetItemChecked($index, [bool]$item.Default)
    }
    if ($Catalog.Count -eq 0) {
        [void]$list.Items.Add($EmptyMessage)
        $list.Enabled = $false
    }
    return $list
}

function Get-CheckedCatalogItems {
    param([Parameter(Mandatory)][System.Windows.Forms.CheckedListBox]$List)
    if (-not $List.Enabled) { return @() }
    return @($List.CheckedItems | ForEach-Object { $_ })
}

function Add-TabWithList {
    param([Parameter(Mandatory)][System.Windows.Forms.TabControl]$Tabs, [Parameter(Mandatory)][string]$Title, [Parameter(Mandatory)][System.Windows.Forms.CheckedListBox]$List, [string]$Description = '')
    $tab = [System.Windows.Forms.TabPage]::new($Title)
    $layout = [System.Windows.Forms.TableLayoutPanel]::new()
    $layout.Dock = 'Fill'
    $layout.Padding = [System.Windows.Forms.Padding]::new(10)
    $layout.ColumnCount = 1
    $layout.RowCount = 2
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
    [void]$layout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
    $label = [System.Windows.Forms.Label]::new()
    $label.AutoSize = $true
    $label.MaximumSize = [Drawing.Size]::new(850, 0)
    $label.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 10)
    $label.Text = $Description
    $layout.Controls.Add($label, 0, 0)
    $layout.Controls.Add($List, 0, 1)
    $tab.Controls.Add($layout)
    [void]$Tabs.TabPages.Add($tab)
}

$darkBackground = [Drawing.Color]::FromArgb(30, 30, 30)
$darkPanel = [Drawing.Color]::FromArgb(38, 38, 38)
$darkInput = [Drawing.Color]::FromArgb(24, 24, 24)
$darkButton = [Drawing.Color]::FromArgb(55, 55, 55)
$lightText = [Drawing.Color]::FromArgb(235, 235, 235)
$mutedText = [Drawing.Color]::FromArgb(180, 180, 180)

function Set-DarkControl {
    param([System.Windows.Forms.Control]$Control)
    $Control.ForeColor = $lightText
    if ($Control -is [System.Windows.Forms.Form] -or $Control -is [System.Windows.Forms.TabPage]) {
        $Control.BackColor = $darkBackground
    } elseif ($Control -is [System.Windows.Forms.CheckedListBox] -or $Control -is [System.Windows.Forms.RichTextBox]) {
        $Control.BackColor = $darkInput
        $Control.BorderStyle = 'FixedSingle'
    } elseif ($Control -is [System.Windows.Forms.Button]) {
        $Control.BackColor = $darkButton
        $Control.FlatStyle = 'Flat'
        $Control.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(85, 85, 85)
    } else {
        $Control.BackColor = $darkPanel
    }
    foreach ($child in $Control.Controls) { Set-DarkControl $child }
}

$form = [System.Windows.Forms.Form]::new()
$form.Text = $AppName
$form.StartPosition = 'CenterScreen'
$form.Size = [Drawing.Size]::new(1000, 780)
$form.MinimumSize = [Drawing.Size]::new(820, 640)
$form.Font = [Drawing.Font]::new('Segoe UI', 10.5)

$root = [System.Windows.Forms.TableLayoutPanel]::new()
$root.Dock = 'Fill'
$root.Padding = [System.Windows.Forms.Padding]::new(14)
$root.ColumnCount = 1
$root.RowCount = 4
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
$form.Controls.Add($root)

$heading = [System.Windows.Forms.Label]::new()
$heading.AutoSize = $true
$heading.Font = [Drawing.Font]::new('Segoe UI Semibold', 16)
$heading.Text = $AppName
$heading.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 10)
$root.Controls.Add($heading, 0, 0)

$tabs = [System.Windows.Forms.TabControl]::new()
$tabs.Dock = 'Fill'
$tabs.Multiline = $true
$tabs.DrawMode = 'OwnerDrawFixed'
$tabs.ItemSize = [Drawing.Size]::new(150, 34)
$tabs.SizeMode = 'Fixed'
$tabs.Add_DrawItem({
    param($sender, $eventArgs)
    $selected = ($eventArgs.Index -eq $sender.SelectedIndex)
    $background = if ($selected) { [Drawing.Color]::FromArgb(60, 60, 60) } else { $darkPanel }
    $eventArgs.Graphics.FillRectangle([Drawing.SolidBrush]::new($background), $eventArgs.Bounds)
    $text = $sender.TabPages[$eventArgs.Index].Text
    [System.Windows.Forms.TextRenderer]::DrawText($eventArgs.Graphics, $text, $form.Font, $eventArgs.Bounds, $lightText, 'HorizontalCenter,VerticalCenter')
})
$root.Controls.Add($tabs, 0, 1)

$programList = New-CatalogList -Catalog $ProgramCatalog
$programList.Font = [Drawing.Font]::new('Segoe UI Emoji', 10.5)
Add-TabWithList -Tabs $tabs -Title 'Programos' -List $programList -Description 'Pažymėtos programos diegiamos naudojant tikslius WinGet paketų ID. Įrangai priklausantys įrašai atveria oficialų gamintojo puslapį.'

$extensionList = New-CatalogList -Catalog $VivaldiExtensionCatalog
Add-TabWithList -Tabs $tabs -Title 'Vivaldi plėtiniai' -List $extensionList -Description 'Pažymėti Chrome Web Store plėtiniai pridedami per Vivaldi valdomą registro politiką. Po paleidimo patikrinkite, ar plėtiniai atsirado.'

$appsList = New-CatalogList -Catalog $BundledAppCatalog
Add-TabWithList -Tabs $tabs -Title 'Integruotos programėlės' -List $appsList -Description 'Pašalinamos tik pažymėtos programėlės. WebView2, Microsoft Store, WinGet ir sisteminės bibliotekos nešalinamos.'

$settingsTab = [System.Windows.Forms.TabPage]::new('Windows nustatymai')
$settingsFlow = [System.Windows.Forms.FlowLayoutPanel]::new()
$settingsFlow.Dock = 'Fill'
$settingsFlow.AutoScroll = $true
$settingsFlow.FlowDirection = 'TopDown'
$settingsFlow.WrapContents = $false
$settingsFlow.Padding = [System.Windows.Forms.Padding]::new(12)
$settingsLists = [System.Collections.ArrayList]::new()
foreach ($groupName in $WindowsSettingsGroups.Keys) {
    $groupItems = @($WindowsSettingsGroups[$groupName])
    $groupContainer = [System.Windows.Forms.Panel]::new()
    $groupContainer.Width = 900
    $groupContainer.Height = 42 + (30 * $groupItems.Count)
    $groupContainer.Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 14)

    $groupTitle = [System.Windows.Forms.Label]::new()
    $groupTitle.Text = $groupName
    $groupTitle.Font = [Drawing.Font]::new('Segoe UI Semibold', 11.5)
    $groupTitle.AutoSize = $true
    $groupTitle.Location = [Drawing.Point]::new(3, 2)

    $groupList = New-CatalogList -Catalog $groupItems
    $groupList.Location = [Drawing.Point]::new(0, 30)
    $groupList.Width = 880
    $groupList.Height = 8 + (30 * $groupItems.Count)
    $groupList.Anchor = 'Top,Left,Right'
    [void]$settingsLists.Add($groupList)
    $groupContainer.Controls.AddRange(@($groupTitle, $groupList))
    [void]$settingsFlow.Controls.Add($groupContainer)
}
$settingsFlow.Add_SizeChanged({
    foreach ($groupControl in $settingsFlow.Controls) {
        $groupControl.Width = [Math]::Max(500, $settingsFlow.ClientSize.Width - 35)
    }
})
$settingsTab.Controls.Add($settingsFlow)
[void]$tabs.TabPages.Add($settingsTab)

$startupList = New-CatalogList -Catalog @()
$startupList.Items.Clear(); $startupList.Enabled = $true; $startupList.HorizontalScrollbar = $true
$taskList = New-CatalogList -Catalog @()
$taskList.Items.Clear(); $taskList.Enabled = $true; $taskList.HorizontalScrollbar = $true
$startupRefresh = [System.Windows.Forms.Button]::new()
$startupRemove = [System.Windows.Forms.Button]::new()
$taskRefresh = [System.Windows.Forms.Button]::new()
$taskRemove = [System.Windows.Forms.Button]::new()
Add-RemovalTab -Tabs $tabs -Title 'Paleisties programos' -Description 'Registro Run / RunOnce įrašai ir dabartinio naudotojo bei visų naudotojų paleisties failai. Šalinamas tik automatinis paleidimas. Sąrašą įkelkite mygtuku „Atnaujinti sąrašą“. Šalinimas vykdomas atskiru mygtuku.' -List $startupList -Refresh $startupRefresh -Remove $startupRemove
Add-RemovalTab -Tabs $tabs -Title 'Suplanuotos užduotys' -Description 'Visos prieinamos užduotys, įskaitant paslėptas ir Windows sistemines užduotis. Sąrašą įkelkite mygtuku „Atnaujinti sąrašą“. Pažymėkite tik atpažįstamas užduotis. Šalinimas vykdomas atskiru mygtuku; vykdomos užduotys nešalinamos.' -List $taskList -Refresh $taskRefresh -Remove $taskRemove
$startupRefresh.Add_Click({ Update-RemovalList -List $startupList -Kind Startup })
$taskRefresh.Add_Click({ Update-RemovalList -List $taskList -Kind Task })
$startupRemove.Add_Click({ Invoke-SelectedRemoval -List $startupList -Kind Startup })
$taskRemove.Add_Click({ Invoke-SelectedRemoval -List $taskList -Kind Task })

$logTab = [System.Windows.Forms.TabPage]::new('Žurnalas')
$script:LogBox = [System.Windows.Forms.RichTextBox]::new()
$script:LogBox.Dock = 'Fill'
$script:LogBox.ReadOnly = $true
$script:LogBox.WordWrap = $false
$script:LogBox.Font = [Drawing.Font]::new('Consolas', 10)
$logTab.Controls.Add($script:LogBox)
[void]$tabs.TabPages.Add($logTab)

$authorLabel = [System.Windows.Forms.Label]::new()
$authorLabel.AutoSize = $true
$authorLabel.Text = "By $AppAuthor  •  v$AppVersion"
$authorLabel.ForeColor = $mutedText
$authorLabel.Padding = [System.Windows.Forms.Padding]::new(0, 8, 0, 5)
$root.Controls.Add($authorLabel, 0, 2)

$buttonPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$buttonPanel.AutoSize = $true
$buttonPanel.Dock = 'Fill'
$buttonPanel.FlowDirection = 'RightToLeft'
$runButton = [System.Windows.Forms.Button]::new()
$runButton.Text = 'VYKDYTI NUSTATYMĄ'
$runButton.AutoSize = $true
$runButton.Padding = [System.Windows.Forms.Padding]::new(20, 7, 20, 7)
$openLogButton = [System.Windows.Forms.Button]::new()
$openLogButton.Text = 'Atverti žurnalą'
$openLogButton.AutoSize = $true
$openLogButton.Padding = [System.Windows.Forms.Padding]::new(10, 7, 10, 7)
$buttonPanel.Controls.AddRange(@($runButton, $openLogButton))
$root.Controls.Add($buttonPanel, 0, 3)

Set-DarkControl $form
$authorLabel.ForeColor = $mutedText
$script:LogBox.BackColor = $darkInput
$tabs.BackColor = $darkBackground

$openLogButton.Add_Click({
    if (Test-Path -LiteralPath $script:LogPath) { Start-Process -FilePath 'notepad.exe' -ArgumentList @($script:LogPath) }
})

$runButton.Add_Click({
    if ($DryRun) {
        $config = Get-CurrentConfig -ProgramList $programList -ExtensionList $extensionList -SettingsLists $settingsLists -AppsList $appsList
        Write-SetupLog '=== DRY RUN: Kas būtų padaryta ===' 'OK'
        foreach ($id in $config.Programos) { Write-SetupLog "Įdiegti (planuota): $id" 'INFO' }
        foreach ($id in $config.VivaldiPlėtiniai) { Write-SetupLog "Nustatyti plėtinį (planuota): $id" 'INFO' }
        foreach ($pkg in $config.IntegruotosProgramėlės) { Write-SetupLog "Pašalinti (planuota): $pkg" 'INFO' }
        foreach ($key in $config.Nustatymai.Keys) { Write-SetupLog "Nustatyti (planuota): $key" 'INFO' }
        [void][System.Windows.Forms.MessageBox]::Show("Dry Run baigtas. Žurnale matote, kas būtų padaryta.", $AppName, 'OK', 'Information')
        return
    }

    if ($ExportConfig) {
        $config = Get-CurrentConfig -ProgramList $programList -ExtensionList $extensionList -SettingsLists $settingsLists -AppsList $appsList
        $json = $config | ConvertTo-Json -Depth 4
        [System.IO.File]::WriteAllText($ExportConfig, $json, [System.Text.Encoding]::UTF8)
        Write-SetupLog "Konfigūracija išsaugota: $ExportConfig" 'OK'
        [void][System.Windows.Forms.MessageBox]::Show("Konfigūracija išsaugota:\n$ExportConfig", $AppName, 'OK', 'Information')
        return
    }

    if ($ImportConfig) {
        try {
            $json = [System.IO.File]::ReadAllText($ImportConfig, [System.Text.Encoding]::UTF8)
            $config = $json | ConvertFrom-Json
            # Restore program selections
            foreach ($id in $config.Programos) {
                for ($i = 0; $i -lt $programList.Items.Count; $i++) {
                    if ([string]$programList.Items[$i].Id -eq $id) { $programList.SetItemChecked($i, $true) }
                }
            }
            # Restore extension selections
            foreach ($id in $config.VivaldiPlėtiniai) {
                for ($i = 0; $i -lt $extensionList.Items.Count; $i++) {
                    if ([string]$extensionList.Items[$i].Id -eq $id) { $extensionList.SetItemChecked($i, $true) }
                }
            }
            # Restore app removal selections
            foreach ($pkg in $config.IntegruotosProgramėlės) {
                for ($i = 0; $i -lt $appsList.Items.Count; $i++) {
                    if ([string]$appsList.Items[$i].Package -eq $pkg) { $appsList.SetItemChecked($i, $true) }
                }
            }
            # Restore settings selections
            foreach ($key in $config.Nustatymai.Keys) {
                foreach ($list in $settingsLists) {
                    for ($i = 0; $i -lt $list.Items.Count; $i++) {
                        if ([string]$list.Items[$i].Key -eq $key) { $list.SetItemChecked($i, $true) }
                    }
                }
            }
            Write-SetupLog "Konfigūracija importuota iš: $ImportConfig" 'OK'
            [void][System.Windows.Forms.MessageBox]::Show("Konfigūracija įkelta. Spauskite VYKDYTI.", $AppName, 'OK', 'Information')
        } catch {
            Write-SetupLog "Nepavyko importuoti konfigūracijos: $($_.Exception.Message)" 'ERROR'
        }
        return
    }

    if ($Uninstall) {
        $answer = [System.Windows.Forms.MessageBox]::Show('Ar tikrai norite atstatyti visas pasirinktas programas? Šis veiksmas įdiegs jas iš naujo.', 'Patvirtinkite atkūrimą', 'YesNo', 'Warning')
        if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
        $runButton.Enabled = $false
        $tabs.SelectedTab = $logTab
        try {
            Write-SetupLog "$AppName v$AppVersion atkūrimo režimas pradėtas." 'OK'
            try { Set-UninstallMode -Items @(Get-CheckedCatalogItems $programList) }
            catch { Write-SetupLog "Atkūrimo dalies klaida: $($_.Exception.Message)" 'ERROR' }
            [void][System.Windows.Forms.MessageBox]::Show("Atkūrimas baigtas.", $AppName, 'OK', 'Information')
        } finally {
            $runButton.Enabled = $true
        }
        return
    }

    $answer = [System.Windows.Forms.MessageBox]::Show('Ar dabar pritaikyti visas pažymėtas parinktis? Kai kuriems pakeitimams reikės atsijungti arba paleisti Windows iš naujo.', 'Patvirtinkite vykdymą', 'YesNo', 'Warning')
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    $runButton.Enabled = $false
    $tabs.SelectedTab = $logTab
    try {
        Write-SetupLog "$AppName v$AppVersion pradėta. Žurnalo failas: $script:LogPath"
        try { Install-Programs -Items @(Get-CheckedCatalogItems $programList) }
        catch { Write-SetupLog "Programų diegimo dalies klaida: $($_.Exception.Message)" 'ERROR' }
        try { Configure-VivaldiExtensions -Items @(Get-CheckedCatalogItems $extensionList) }
        catch { Write-SetupLog "Vivaldi plėtinių dalies klaida: $($_.Exception.Message)" 'ERROR' }
        Remove-BundledApps -Items @(Get-CheckedCatalogItems $appsList)
        foreach ($settingsList in $settingsLists) {
            foreach ($item in @(Get-CheckedCatalogItems $settingsList)) {
                Invoke-LoggedAction -Description $item.Name -Action { Set-WindowsOption -Key $item.Key }
            }
        }
        Write-SetupLog 'Vykdymas baigtas. Peržiūrėkite įspėjimus bei klaidas ir paleiskite Windows iš naujo.' 'OK'
        [void][System.Windows.Forms.MessageBox]::Show('Vykdymas baigtas. Peržiūrėkite žurnalą ir paleiskite Windows iš naujo.', $AppName, 'OK', 'Information')
    } catch {
        Write-SetupLog "Netikėta klaida: $($_.Exception.Message)" 'ERROR'
        [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Vykdymas sustabdytas', 'OK', 'Error')
    } finally {
        $runButton.Enabled = $true
    }
})

if ($ValidateOnly) {
    Write-Output "$AppName v$AppVersion patikros įkėlimas baigtas."
    exit 0
}

Write-SetupLog 'Paruošta. Pakeitimų dar neatlikta.'
[void]$form.ShowDialog()

