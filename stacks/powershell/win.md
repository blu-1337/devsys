# Windows notes: powershell
- Default execution policy is Restricted: `running scripts is disabled on this system`. Always invoke with `powershell -NoProfile -ExecutionPolicy Bypass -File ...` (do not change the machine policy without asking).
- PowerShell 7 (optional): `winget install Microsoft.PowerShell` -> `pwsh`.
- Built-in Pester 3.4 is signed by Microsoft; upgrading needs `-SkipPublisherCheck`.
- `.ps1` files with non-ASCII characters and no BOM are read as ANSI by 5.1.
