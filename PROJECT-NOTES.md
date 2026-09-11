# Project notes

## 2026-09-10 — Codex takeover and Hermes sharing

The user identified this local folder as the existing project and requested that Codex manage it and share it with the local Hermes agent.

Initial inventory: `FreshWindowsSetup.ps1` and `FreshWindowsSetup.exe`. No build recipe or version-control repository was present. Application behavior has not been changed.

PowerShell syntax validation passed without executing the setup utility.

Initial SHA-256 hashes:

- PS1: `7235A5343E26B17A05990595ACF362352C96EEA9524A9789A26307311E52C63B`
- EXE: `0FF47E44F7EDC8DC48AA76A007884C04EE229FA8841AE6D17E2A883CF4FE2817`

See `AGENTS.md` for shared working context.

Registered in the local Hermes profile as `windows-po-installo` (project ID `p_3032962a`), pointing directly to `C:\Users\rytis\Windows Po Installo`. Both agents use the same files; no separate copy was created.
