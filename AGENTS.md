# Windows Po Installo

This folder is the authoritative shared workspace for Codex and the user's local Hermes agent. The user asked Codex to take over the existing project and make it available to Hermes.

## Application

- `FreshWindowsSetup.ps1`: Fresh Windows Setup v1.3.0, PowerShell 5.1 WinForms app by Emocinis Taikinys. Lithuanian UI preserved.
- `FreshWindowsSetup.UI.ps1`: Improved UI version — cleaner layout, standard tabs, progress bar, status label. Same functionality.
- `FreshWindowsSetup.UI.exe`: Compiled from UI source via PS2EXE (v0.5.0.34). Valid PE, 77 KB. Requires admin.
- Features: selectable software installation, bundled app removal, Windows settings, privacy tweaks, logging.

## Build recipe

```powershell
Import-Module ps2exe
Invoke-ps2exe `
    -InputFile 'FreshWindowsSetup.UI.ps1' `
    -OutputFile 'FreshWindowsSetup.UI.exe' `
    -supportOS -DPIAware -winFormsDPIAware -requireAdmin
```

## Working together

Work directly in this folder. Preserve the other agent's changes. Record significant changes in `PROJECT-NOTES.md`.

Do not claim the EXE is updated after changing the script unless it has actually been rebuilt and verified.
