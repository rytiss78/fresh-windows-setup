# Windows Po Installo

This folder is the authoritative shared workspace for Codex and the user's local Hermes agent. The user asked Codex to take over the existing project and make it available to Hermes.

## Existing application

- `FreshWindowsSetup.ps1`: Fresh Windows Setup v1.2.0, PowerShell 5.1 Windows Forms application, by Emocinis Taikinys. Keep the Lithuanian UI and author credit.
- `FreshWindowsSetup.exe`: existing executable. Its build recipe and correspondence to the current source have not yet been verified.
- Features include selectable software installation, bundled app removal, Windows settings, privacy settings, and logging.

## Working together

Work directly in this folder. Read current files before editing and preserve the other agent's changes. Record significant changes and validation in `PROJECT-NOTES.md`.

Sharing the project does not itself request application changes or execution of Windows setup actions. Wait for a concrete development task before changing application behavior.

## Validation

Start with a PowerShell parser check. The script exposes `-ValidateOnly`, which constructs the UI and exits before showing it; inspect the current code before using it. Normal launch requests elevation and the interface can apply system changes. Do not run normal setup merely to test code.

Do not claim the EXE is updated after changing the script unless it has actually been rebuilt and verified.
