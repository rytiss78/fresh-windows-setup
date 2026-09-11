# Project notes

## 2026-09-10 — Codex takeover and Hermes sharing

The user identified this local folder as the existing project and requested that Codex manage it and share it with the local Hermes agent.

Initial inventory: `FreshWindowsSetup.ps1` and `FreshWindowsSetup.exe`. No build recipe or version-control repository was present. Application behavior has not been changed.

PowerShell syntax validation passed without executing the setup utility.

Initial SHA-256 hashes:

- PS1 (original): `7235A5343E26B17A05990595ACF362352C96EEA9524A9789A26307311E52C63B`
- EXE (original): `0FF47E44F7EDC8DC48AA76A007884C04EE229FA8841AE6D17E2A883CF4FE2817`

Registered in the local Hermes profile as `windows-po-installo` (project ID `p_3032962a`).

## 2026-09-12 — v1.3.0 release

Major overhaul completed:

### Core fixes
- Added `-DryRun`, `-ExportConfig`, `-ImportConfig`, `-Uninstall` switches
- Per-package WinGet error handling with retry logic (3 attempts, 5s backoff)
- Skip-installed check before every install attempt
- Safe `Invoke-NativeCommandSafe` with proper exception message capture
- Uninstall mode for removing previously installed packages

### Runtime bug fixes
- **OneDrive removal**: Now kills the running `OneDrive` process before `/uninstall` to prevent 0x80070005 access denied. Errors logged as WARN instead of crashing.
- **Edge registry key**: `MicrosoftEdgeAutoLaunch` removal wrapped in try/catch — key may not exist on fresh installs.
- **HideWidgets (Dsh policy)**: HKLM write wrapped in try/catch with WARN if admin rights insufficient. HKCU side still applies.
- **yt-dlp error handling**: Null-safe exception message capture prevents empty-string crash.

### UI improvements
- Standard WinForms tabs (removed broken custom `OwnerDrawFixed` drawing)
- Clean panel grouping, improved typography and padding
- Progress bar integration during execution
- Status label updates in real-time
- Darker color scheme throughout

### Build
- Compiled `FreshWindowsSetup.UI.exe` via PS2EXE v0.5.0.34 (77 KB valid PE)
- Added `.gitignore` for build artifacts (`*.exe.config`, `_build_*`)
- UTF-8 BOM added to all PS1 files (required for Lithuanian Windows — cp1257 defaults without BOM crashes on emoji bytes)

### Version history
| Version | Date       | Notes                          |
|---------|------------|--------------------------------|
| 1.0.0   | ?          | Original release               |
| 1.2.0   | ?          | Previous tagged version        |
| 1.3.0   | 2026-09-12 | Core fixes, bug patches, UI    |
