---
paths: ["**/*.ps1", "**/*.psm1", "**/*.psd1"]
---
- Must run on Windows PowerShell 5.1: no `??`, `?.`, ternary, `&&`/`||`, `-Parallel`, or `ConvertFrom-Json -AsHashtable`.
- Encoding: read with `Get-Content -Encoding UTF8`; write JSON/text consumed by other tools with `[IO.File]::WriteAllText($p, $s, (New-Object Text.UTF8Encoding($false)))` (5.1 `-Encoding UTF8` adds a BOM). Keep .ps1 files ASCII or UTF-8 with BOM.
- Native commands (git, python) under `$ErrorActionPreference='Stop'`: stderr becomes a terminating error; set `Continue` around them and check `$LASTEXITCODE`.
- Approved verbs (`Get-Verb`); never name a function like a built-in alias (rd, rm, sc, del...).
- Tests use `$env:TEMP` folders; never touch real user data. Destructive cmdlets get `-WhatIf` support (`[CmdletBinding(SupportsShouldProcess)]`).
- Give the user commands with `-ExecutionPolicy Bypass`; execution policy is Restricted by default.
