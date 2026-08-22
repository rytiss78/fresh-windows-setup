#Requires -Version 5.1
<#
Fresh Windows Setup
A single-file, first-boot Windows configuration utility.
All system changes are selectable in the interface and logged.

Made by Emocinis Taikinys
#>

[CmdletBinding()]
param([switch]$ValidateOnly)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$AppName = 'Fresh Windows Setup'
$AppVersion = '1.1.0'
$AppAuthor = 'Emocinis Taikinys'

$ProgramCatalog = @(
    [pscustomobject]@{ Name = 'Vivaldi web browser'; InstallType = 'WinGet'; Id = 'Vivaldi.Vivaldi'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'ChatGPT (official download page)'; InstallType = 'OfficialPage'; Url = 'https://chatgpt.com/download/'; Default = $true }
    [pscustomobject]@{ Name = 'yt-dlp'; InstallType = 'WinGet'; Id = 'yt-dlp.yt-dlp'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'qBittorrent'; InstallType = 'WinGet'; Id = 'qBittorrent.qBittorrent'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'Steam'; InstallType = 'WinGet'; Id = 'Valve.Steam'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'Notepad++'; InstallType = 'WinGet'; Id = 'Notepad++.Notepad++'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'Python 3.14'; InstallType = 'WinGet'; Id = 'Python.Python.3.14'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'AMD driver auto-detect (official page)'; InstallType = 'OfficialPage'; Url = 'https://www.amd.com/en/support/download/drivers.html'; Default = $true }
    [pscustomobject]@{ Name = 'Windows HDR Calibration (Microsoft Store)'; InstallType = 'WinGet'; Id = '9N7F2SM5D1LR'; Source = 'msstore'; Default = $true }
    [pscustomobject]@{ Name = 'PotPlayer 64-bit'; InstallType = 'WinGet'; Id = 'Daum.PotPlayer'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'OpenRGB'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGB'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'OpenRGB Effects Plugin'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGBEffectsPlugin'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'TP-Link Archer TBE550E Wi-Fi/Bluetooth drivers (official page)'; InstallType = 'OfficialPage'; Url = 'https://www.tp-link.com/en/support/download/archer-tbe550e/'; Default = $true }
    [pscustomobject]@{ Name = 'Stremio'; InstallType = 'WinGet'; Id = 'Stremio.Stremio'; Source = 'winget'; Default = $true }
    [pscustomobject]@{ Name = 'Icaros'; InstallType = 'WinGet'; Id = 'Xanashi.Icaros'; Source = 'winget'; Default = $true }
)

$VivaldiExtensionCatalog = @(
    [pscustomobject]@{ Name = 'Bitwarden Password Manager'; Id = 'nngceckbapebfimnlniiiahkandclblb'; Default = $true }
    [pscustomobject]@{ Name = 'Hide Scrollbar'; Id = 'gngenlhkmpneoiicndbjghjhpogdcncl'; Default = $true }
    [pscustomobject]@{ Name = 'Imagus Reborn'; Id = 'fcjmgeodgobggcppooncdagfkogfffdm'; Default = $true }
    [pscustomobject]@{ Name = 'SponsorBlock for YouTube'; Id = 'mnjggcdmjocbbbhaepdhchncahnbgone'; Default = $true }
    [pscustomobject]@{ Name = 'YouTube Inline Fullscreen'; Id = 'mfpkbigjnlcgngkdbmnchfnenfmibkig'; Default = $true }
)

# This is intentionally conservative. Core components and frameworks are excluded.
$BundledAppCatalog = @(
    [pscustomobject]@{ Name = 'Clipchamp'; Package = 'Clipchamp.Clipchamp'; Default = $true }
    [pscustomobject]@{ Name = 'Dev Home'; Package = 'Microsoft.Windows.DevHome'; Default = $true }
    [pscustomobject]@{ Name = 'Feedback Hub'; Package = 'Microsoft.WindowsFeedbackHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft 365 (Office)'; Package = 'Microsoft.MicrosoftOfficeHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft News'; Package = 'Microsoft.BingNews'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Solitaire Collection'; Package = 'Microsoft.MicrosoftSolitaireCollection'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Weather'; Package = 'Microsoft.BingWeather'; Default = $true }
    [pscustomobject]@{ Name = 'People'; Package = 'Microsoft.People'; Default = $true }
    [pscustomobject]@{ Name = 'Notepad'; Package = 'Microsoft.WindowsNotepad'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox app'; Package = 'Microsoft.GamingApp'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Game Bar'; Package = 'Microsoft.XboxGamingOverlay'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Identity Provider'; Package = 'Microsoft.XboxIdentityProvider'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox Speech-to-Text Overlay'; Package = 'Microsoft.XboxSpeechToTextOverlay'; Default = $true }
    [pscustomobject]@{ Name = 'Xbox TCUI'; Package = 'Microsoft.Xbox.TCUI'; Default = $true }
    [pscustomobject]@{ Name = 'OneDrive'; Package = 'OneDriveDesktop'; Kind = 'OneDrive'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Office hub'; Package = 'Microsoft.MicrosoftOfficeHub'; Default = $true }
    [pscustomobject]@{ Name = 'Microsoft Office Desktop package'; Package = 'Microsoft.Office.Desktop'; Default = $true }
    [pscustomobject]@{ Name = 'Windows Backup app (disable; retain shared Windows shell package)'; Package = 'WindowsBackup'; Kind = 'WindowsBackup'; Default = $true }
)

$PrivacyCatalog = @(
    [pscustomobject]@{ Name = 'Reduce diagnostic data to the lowest supported level'; Key = 'DiagnosticData'; Default = $true }
    [pscustomobject]@{ Name = 'Disable advertising ID and personalized ads'; Key = 'Advertising'; Default = $true }
    [pscustomobject]@{ Name = 'Disable tailored experiences using diagnostic data'; Key = 'TailoredExperiences'; Default = $true }
    [pscustomobject]@{ Name = 'Disable Windows suggestions and consumer content'; Key = 'Suggestions'; Default = $true }
    [pscustomobject]@{ Name = 'Disable feedback prompts'; Key = 'Feedback'; Default = $true }
    [pscustomobject]@{ Name = 'Disable activity history publishing and upload'; Key = 'ActivityHistory'; Default = $true }
    [pscustomobject]@{ Name = 'Reduce typing and inking personalization collection'; Key = 'InputPersonalization'; Default = $true }
)

$WindowsSettingsGroups = [ordered]@{
    'Taskbar and Start' = @(
        [pscustomobject]@{ Name = 'Align taskbar to the left'; Key = 'TaskbarLeft'; Default = $true }
        [pscustomobject]@{ Name = 'Hide Search from the taskbar'; Key = 'HideSearch'; Default = $true }
        [pscustomobject]@{ Name = 'Hide Widgets from the taskbar'; Key = 'HideWidgets'; Default = $true }
        [pscustomobject]@{ Name = 'Disable Start-menu recommendations'; Key = 'DisableStartRecommendations'; Default = $true }
        [pscustomobject]@{ Name = 'Disable recently opened items'; Key = 'DisableRecentItems'; Default = $true }
        [pscustomobject]@{ Name = 'Automatically hide the taskbar'; Key = 'TaskbarAutoHide'; Default = $true }
    )
    'File Explorer' = @(
        [pscustomobject]@{ Name = 'Show file extensions'; Key = 'ShowFileExtensions'; Default = $true }
        [pscustomobject]@{ Name = 'Show hidden files'; Key = 'ShowHiddenFiles'; Default = $false }
        [pscustomobject]@{ Name = 'Open File Explorer to This PC'; Key = 'ExplorerThisPC'; Default = $true }
        [pscustomobject]@{ Name = 'Use compact view'; Key = 'CompactView'; Default = $true }
        [pscustomobject]@{ Name = 'Restore the classic right-click menu'; Key = 'ClassicContextMenu'; Default = $true }
        [pscustomobject]@{ Name = 'Remove Gallery from Explorer'; Key = 'RemoveGallery'; Default = $true }
        [pscustomobject]@{ Name = 'Remove Home from Explorer'; Key = 'RemoveHome'; Default = $true }
    )
    'Privacy and appearance' = @(
        [pscustomobject]@{ Name = 'Disable Bing/web results in Start search'; Key = 'DisableWebSearch'; Default = $true }
        [pscustomobject]@{ Name = 'Disable Windows tips and suggestions'; Key = 'DisableTips'; Default = $true }
        [pscustomobject]@{ Name = 'Disable startup delay'; Key = 'DisableStartupDelay'; Default = $true }
        [pscustomobject]@{ Name = 'Disable mouse acceleration'; Key = 'DisableMouseAcceleration'; Default = $true }
        [pscustomobject]@{ Name = 'Enable dark mode'; Key = 'DarkMode'; Default = $true }
        [pscustomobject]@{ Name = 'Disable lock-screen suggestions'; Key = 'DisableLockScreenSuggestions'; Default = $true }
    )
    'System and power' = @(
        [pscustomobject]@{ Name = 'Disable Fast Startup'; Key = 'DisableFastStartup'; Default = $true }
        [pscustomobject]@{ Name = 'Disable System Restore'; Key = 'DisableSystemRestore'; Default = $true }
        [pscustomobject]@{ Name = 'Disable Windows Backup and settings sync'; Key = 'DisableWindowsBackup'; Default = $true }
    )
    'Network and gaming' = @(
        [pscustomobject]@{ Name = 'Set connected networks to Private'; Key = 'PrivateNetwork'; Default = $true }
        [pscustomobject]@{ Name = 'Disable Xbox Game Bar recording'; Key = 'DisableGameBarRecording'; Default = $true }
    )
    'Region' = @(
        [pscustomobject]@{ Name = 'Set region and time zone to Lithuania / Vilnius'; Key = 'LithuaniaRegion'; Default = $true }
    )
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $ValidateOnly -and -not (Test-IsAdministrator)) {
    if (-not $PSCommandPath) { throw 'Save this script before running it.' }
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
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO', 'OK', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    $line = '[{0:HH:mm:ss}] [{1}] {2}' -f (Get-Date), $Level, $Message
    Add-Content -LiteralPath $script:LogPath -Value $line -Encoding UTF8
    if ($null -ne $script:LogBox) {
        $script:LogBox.AppendText($line + [Environment]::NewLine)
        $script:LogBox.SelectionStart = $script:LogBox.TextLength
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
        throw "Read-back verification failed for $Path\$Name. Expected '$Value', found '$actual'."
    }
    Write-SetupLog "Verified: $Path\$Name = $actual."
}

function Set-RegistryDefaultValue {
    param([Parameter(Mandatory)][string]$Path, [AllowEmptyString()][string]$Value)
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-Item -LiteralPath $Path -Value $Value -Force
    $actual = (Get-Item -LiteralPath $Path -ErrorAction Stop).GetValue('')
    if ([string]$actual -cne [string]$Value) {
        throw "Read-back verification failed for the default value at $Path."
    }
    Write-SetupLog "Verified default registry value: $Path."
}

function Invoke-LoggedAction {
    param([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][scriptblock]$Action)
    Write-SetupLog "$Description..."
    try {
        & $Action
        Write-SetupLog "$Description completed." 'OK'
    } catch {
        Write-SetupLog "$Description failed: $($_.Exception.Message)" 'ERROR'
    }
}

function Invoke-NativeCommand {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments 2>&1 | ForEach-Object { Write-SetupLog ([string]$_) }
    if ($LASTEXITCODE -ne 0) { throw "$FilePath exited with code $LASTEXITCODE." }
}

function Install-Programs {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Programs: nothing selected.' 'WARN'; return }
    $winget = Get-Command 'winget.exe' -ErrorAction SilentlyContinue
    if (-not $winget) { throw 'WinGet is unavailable. Install or update Microsoft App Installer and try again.' }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Install $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Start-Process -FilePath $item.Url
                Write-SetupLog "Opened the verified publisher page: $($item.Url). Complete this hardware/app-specific install manually." 'WARN'
                return
            }

            $arguments = @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
            Invoke-NativeCommand -FilePath $winget.Source -Arguments $arguments

            $listOutput = @(& $winget.Source list --id $item.Id --exact --source $item.Source --accept-source-agreements --disable-interactivity 2>&1)
            if ($LASTEXITCODE -ne 0 -or -not (($listOutput -join "`n") -match [regex]::Escape($item.Id))) {
                throw "WinGet read-back verification could not find $($item.Id) after installation."
            }
            Write-SetupLog "Verified installed package: $($item.Id)."
        }
    }
}

function Configure-VivaldiExtensions {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Vivaldi extensions: nothing selected.' 'WARN'; return }
    $policyPath = 'HKLM:\SOFTWARE\Policies\Vivaldi\ExtensionInstallForcelist'
    if (-not (Test-Path -LiteralPath $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
    $index = 1
    foreach ($item in $Items) {
        $policyValue = '{0};https://clients2.google.com/service/update2/crx' -f $item.Id
        Set-RegistryValue -Path $policyPath -Name ([string]$index) -Value $policyValue -Type String
        Write-SetupLog "Vivaldi extension policy added: $($item.Name)." 'OK'
        $index++
    }
    Write-SetupLog 'Vivaldi policy deployment is experimental. Verify the extensions after starting Vivaldi.' 'WARN'
}

function Set-PrivacyOption {
    param([Parameter(Mandatory)][string]$Key)
    switch ($Key) {
        'DiagnosticData' {
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDiagnosticLogCollection' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDumpCollection' 1
            Write-SetupLog 'Diagnostic data is set to the lowest generally supported level; Windows edition rules still apply.' 'WARN'
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
        default { throw "Unknown privacy option: $Key" }
    }
}

function Remove-BundledApps {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Bundled apps: nothing selected.' 'WARN'; return }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Remove $($item.Name)" -Action {
            $kindProperty = $item.PSObject.Properties['Kind']
            $kind = if ($null -ne $kindProperty) { [string]$kindProperty.Value } else { 'Appx' }

            if ($kind -eq 'OneDrive') {
                $setupCandidates = @(
                    (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
                    (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
                )
                $setup = $setupCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
                if ($setup) {
                    $process = Start-Process -FilePath $setup -ArgumentList @('/uninstall') -Wait -PassThru
                    if ($process.ExitCode -notin @(0, 19)) { throw "OneDrive uninstaller exited with code $($process.ExitCode)." }
                }
                $oneDriveExecutables = @(
                    (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe')
                    (Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe')
                )
                if ($oneDriveExecutables | Where-Object { Test-Path -LiteralPath $_ }) {
                    throw 'OneDrive read-back verification still found an installed executable.'
                }
                Write-SetupLog 'Verified: OneDrive executable is absent.'
                return
            }

            if ($kind -eq 'WindowsBackup') {
                Set-WindowsOption -Key 'DisableWindowsBackup'
                Write-SetupLog 'Windows Backup is part of a shared Windows shell package, so the package itself was retained.' 'WARN'
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
                throw "App-removal read-back verification still found $($item.Package)."
            }
            Write-SetupLog "Verified removed or absent: $($item.Package)."
        }
    }
}

function Set-TaskbarAutoHide {
    $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = [byte[]](Get-ItemPropertyValue -LiteralPath $path -Name 'Settings' -ErrorAction Stop)
    if ($settings.Length -lt 9) { throw 'The taskbar settings value has an unexpected format.' }
    $settings[8] = 3
    Set-RegistryValue $path 'Settings' $settings 'Binary'
    Write-SetupLog 'Taskbar auto-hide will fully apply after Explorer restarts or the next sign-in.' 'WARN'
}

function Set-LithuaniaRegion {
    Set-Culture -CultureInfo 'lt-LT'
    Set-WinHomeLocation -GeoId 140
    Set-WinSystemLocale -SystemLocale 'lt-LT'
    Set-TimeZone -Id 'FLE Standard Time'
    if ((Get-TimeZone).Id -ne 'FLE Standard Time') { throw 'Time-zone read-back verification failed.' }
    if ((Get-WinSystemLocale).Name -ne 'lt-LT') { throw 'System-locale read-back verification failed.' }
    if ((Get-WinHomeLocation).GeoId -ne 140) { throw 'Home-location read-back verification failed.' }
    if ((Get-Culture).Name -ne 'lt-LT') { throw 'Regional-format read-back verification failed.' }
    Write-SetupLog 'Verified Lithuanian home location, system locale, and FLE Standard Time.'
    Write-SetupLog 'Lithuanian system-locale changes may require signing out or restarting.' 'WARN'
}

function Set-ConnectedNetworksPrivate {
    $profiles = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected' })
    if ($profiles.Count -eq 0) { throw 'No connected network profile was found.' }
    foreach ($profile in $profiles) {
        Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
    }
    $remaining = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { ($_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected') -and $_.NetworkCategory -ne 'Private' })
    if ($remaining.Count -gt 0) { throw 'Network-category read-back verification found a connected profile that is not Private.' }
    Write-SetupLog 'Verified: every connected network profile is Private.'
}

function Set-WindowsOption {
    param([Parameter(Mandatory)][string]$Key)
    switch ($Key) {
        'TaskbarLeft' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 0 }
        'HideSearch' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0 }
        'HideWidgets' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
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
        default { throw "Unknown Windows setting: $Key" }
    }
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

$form = [System.Windows.Forms.Form]::new()
$form.Text = "$AppName v$AppVersion"
$form.StartPosition = 'CenterScreen'
$form.Size = [Drawing.Size]::new(900, 700)
$form.MinimumSize = [Drawing.Size]::new(760, 580)
$form.Font = [Drawing.Font]::new('Segoe UI', 9)

$root = [System.Windows.Forms.TableLayoutPanel]::new()
$root.Dock = 'Fill'
$root.Padding = [System.Windows.Forms.Padding]::new(12)
$root.ColumnCount = 1
$root.RowCount = 4
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$root.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
$form.Controls.Add($root)

$heading = [System.Windows.Forms.Label]::new()
$heading.AutoSize = $true
$heading.Font = [Drawing.Font]::new('Segoe UI Semibold', 14)
$heading.Text = "$AppName  v$AppVersion"
$heading.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 8)
$root.Controls.Add($heading, 0, 0)

$tabs = [System.Windows.Forms.TabControl]::new()
$tabs.Dock = 'Fill'
$root.Controls.Add($tabs, 0, 1)

$programList = New-CatalogList -Catalog $ProgramCatalog
Add-TabWithList -Tabs $tabs -Title 'Programs' -List $programList -Description 'Install exact WinGet packages. Hardware-dependent entries open their verified publisher pages instead of guessing a driver.'
$extensionList = New-CatalogList -Catalog $VivaldiExtensionCatalog
Add-TabWithList -Tabs $tabs -Title 'Vivaldi extensions' -List $extensionList -Description 'Deploy selected Chrome Web Store extensions through a Vivaldi managed policy. This remains experimental until verified on the target Vivaldi version.'
$privacyList = New-CatalogList -Catalog $PrivacyCatalog
Add-TabWithList -Tabs $tabs -Title 'Privacy' -List $privacyList -Description 'Reduce data collection and promotional content without disabling Windows Update, Defender, or the Store.'
$appsList = New-CatalogList -Catalog $BundledAppCatalog
Add-TabWithList -Tabs $tabs -Title 'Bundled apps' -List $appsList -Description 'Remove selected optional inbox apps for existing users and from provisioning for future users. Core Windows components are excluded.'
$settingsTab = [System.Windows.Forms.TabPage]::new('Windows settings')
$settingsLayout = [System.Windows.Forms.TableLayoutPanel]::new()
$settingsLayout.Dock = 'Fill'
$settingsLayout.Padding = [System.Windows.Forms.Padding]::new(8)
$settingsLayout.ColumnCount = 1
$settingsLayout.RowCount = 2
[void]$settingsLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('AutoSize'))
[void]$settingsLayout.RowStyles.Add([System.Windows.Forms.RowStyle]::new('Percent', 100))
$settingsDescription = [System.Windows.Forms.Label]::new()
$settingsDescription.AutoSize = $true
$settingsDescription.Text = 'Settings are grouped by purpose. Every write is read back and verified before it is reported as successful.'
$settingsDescription.Padding = [System.Windows.Forms.Padding]::new(0, 0, 0, 8)
$settingsTabs = [System.Windows.Forms.TabControl]::new()
$settingsTabs.Dock = 'Fill'
$settingsLists = [System.Collections.ArrayList]::new()
foreach ($groupName in $WindowsSettingsGroups.Keys) {
    $groupList = New-CatalogList -Catalog @($WindowsSettingsGroups[$groupName])
    [void]$settingsLists.Add($groupList)
    Add-TabWithList -Tabs $settingsTabs -Title $groupName -List $groupList
}
$settingsLayout.Controls.Add($settingsDescription, 0, 0)
$settingsLayout.Controls.Add($settingsTabs, 0, 1)
$settingsTab.Controls.Add($settingsLayout)
[void]$tabs.TabPages.Add($settingsTab)

$logTab = [System.Windows.Forms.TabPage]::new('Log')
$script:LogBox = [System.Windows.Forms.TextBox]::new()
$script:LogBox.Dock = 'Fill'
$script:LogBox.Multiline = $true
$script:LogBox.ReadOnly = $true
$script:LogBox.ScrollBars = 'Both'
$script:LogBox.WordWrap = $false
$script:LogBox.Font = [Drawing.Font]::new('Consolas', 9)
$logTab.Controls.Add($script:LogBox)
[void]$tabs.TabPages.Add($logTab)

$authorLabel = [System.Windows.Forms.Label]::new()
$authorLabel.AutoSize = $true
$authorLabel.Text = "Made by $AppAuthor"
$authorLabel.Padding = [System.Windows.Forms.Padding]::new(0, 7, 0, 4)
$root.Controls.Add($authorLabel, 0, 2)

$buttonPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$buttonPanel.AutoSize = $true
$buttonPanel.Dock = 'Fill'
$buttonPanel.FlowDirection = 'RightToLeft'
$runButton = [System.Windows.Forms.Button]::new()
$runButton.Text = 'RUN SETUP'
$runButton.AutoSize = $true
$runButton.Padding = [System.Windows.Forms.Padding]::new(18, 6, 18, 6)
$openLogButton = [System.Windows.Forms.Button]::new()
$openLogButton.Text = 'Open log'
$openLogButton.AutoSize = $true
$openLogButton.Padding = [System.Windows.Forms.Padding]::new(8, 6, 8, 6)
$buttonPanel.Controls.AddRange(@($runButton, $openLogButton))
$root.Controls.Add($buttonPanel, 0, 3)

$openLogButton.Add_Click({
    if (Test-Path -LiteralPath $script:LogPath) { Start-Process -FilePath 'notepad.exe' -ArgumentList @($script:LogPath) }
})

$runButton.Add_Click({
    $answer = [System.Windows.Forms.MessageBox]::Show('Apply every checked option now? Some changes require signing out or restarting.', 'Confirm Fresh Windows Setup', 'YesNo', 'Warning')
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    $runButton.Enabled = $false
    $tabs.SelectedTab = $logTab
    try {
        Write-SetupLog "$AppName v$AppVersion started. Log file: $script:LogPath"
        try { Install-Programs -Items @(Get-CheckedCatalogItems $programList) }
        catch { Write-SetupLog "Programs category failed: $($_.Exception.Message)" 'ERROR' }
        try { Configure-VivaldiExtensions -Items @(Get-CheckedCatalogItems $extensionList) }
        catch { Write-SetupLog "Vivaldi extensions category failed: $($_.Exception.Message)" 'ERROR' }
        foreach ($item in @(Get-CheckedCatalogItems $privacyList)) {
            Invoke-LoggedAction -Description $item.Name -Action { Set-PrivacyOption -Key $item.Key }
        }
        Remove-BundledApps -Items @(Get-CheckedCatalogItems $appsList)
        foreach ($settingsList in $settingsLists) {
            foreach ($item in @(Get-CheckedCatalogItems $settingsList)) {
                Invoke-LoggedAction -Description $item.Name -Action { Set-WindowsOption -Key $item.Key }
            }
        }
        Write-SetupLog 'Setup finished. Review warnings and errors, then restart Windows.' 'OK'
        [void][System.Windows.Forms.MessageBox]::Show('Setup finished. Review the log and restart Windows.', $AppName, 'OK', 'Information')
    } catch {
        Write-SetupLog "Unexpected failure: $($_.Exception.Message)" 'ERROR'
        [void][System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Setup stopped', 'OK', 'Error')
    } finally {
        $runButton.Enabled = $true
    }
})

if ($ValidateOnly) {
    Write-Output "$AppName v$AppVersion validation load completed."
    exit 0
}

Write-SetupLog 'Ready. No changes have been made.'
[void]$form.ShowDialog()

