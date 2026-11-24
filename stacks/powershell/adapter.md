# Stack adapter: powershell
Verified: 2026-11-24 on Windows 11 - Windows PowerShell 5.1 (built in), Pester 3.4.0 (built in). PowerShell 7 not installed. Also used for devsys's own hooks (37 tests) and the Phase 1 Quick-lane run.

## Defaults (zero install)
- Target Windows PowerShell 5.1 unless the user has PowerShell 7 (`Get-Command pwsh`). Keep scripts 7-compatible.
- Tests: built-in Pester 3.4 syntax (`Should Be`, not Pester 5's `Should -Be`). Files `tests/*.Tests.ps1`, each dot-sources the script under test: `. "$PSScriptRoot\..\Script.ps1"`.
- If Pester 5 is wanted: ask first, then `Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck`, and switch to `-Be` syntax everywhere.
- Layout: `<Name>.ps1` (functions, plus a guarded entry point) or a module `<Name>/<Name>.psm1` + `.psd1`; `tests/`.

## Commands (devsys.json)
| key | command |
|-----|---------|
| test | `powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests -EnableExit"` |
| check | `powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path tests -EnableExit -Quiet"` |
| format | (none built in; leave empty) |
| run | `powershell -NoProfile -ExecutionPolicy Bypass -File .\<Name>.ps1 <args>` |
| one test | `Invoke-Pester -Path tests\X.Tests.ps1 -TestName '<Describe name>'` |

`-EnableExit` sets the exit code to the number of failed tests (0 = pass). Verified: 1 on failure, 0 on pass.
