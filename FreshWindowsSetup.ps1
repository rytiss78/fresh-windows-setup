#Requires -Version 5.1
<#
Fresh Windows Setup – compatibility launcher.
FreshWindowsSetup.UI.ps1 is the single source of the application; this file only forwards to it
so older links and shortcuts keep working. Keep both files in the same folder.

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

$application = Join-Path $PSScriptRoot 'FreshWindowsSetup.UI.ps1'
if (-not (Test-Path -LiteralPath $application)) {
    throw "Nerastas $application. Atsisiųskite FreshWindowsSetup.UI.ps1 į tą patį aplanką."
}
& $application @PSBoundParameters
exit $LASTEXITCODE
