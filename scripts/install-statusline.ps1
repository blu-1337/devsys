# devsys: install the statusline into USER settings (%USERPROFILE%\.claude\settings.json).
# Copies scripts to %USERPROFILE%\.claude\devsys\ (stable path, survives plugin updates).
# Only run with the user's explicit consent. Use -Check to report status without changing anything.
param([switch]$Check, [switch]$Force)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$claudeDir = Join-Path $env:USERPROFILE '.claude'
$destDir = Join-Path $claudeDir 'devsys'
$settings = Join-Path $claudeDir 'settings.json'

$cfg = $null
if (Test-Path $settings) { $cfg = Get-Content -Raw -Encoding UTF8 $settings | ConvertFrom-Json }
$existing = if ($cfg -and $cfg.statusLine) { [string]$cfg.statusLine.command } else { '' }

if ($Check) {
    [pscustomobject]@{ settings = $settings; statusLine = $existing; isDevsys = ($existing -like '*devsys*statusline.ps1*') } | ConvertTo-Json
    exit 0
}
if ($existing -and $existing -notlike '*devsys*statusline.ps1*' -and -not $Force) {
    Write-Output "A different statusLine is already configured: $existing. Re-run with -Force to replace it (ask the user first)."
    exit 1
}

if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force $destDir | Out-Null }
Copy-Item (Join-Path $root 'hooks\win\common.ps1') $destDir -Force
Copy-Item (Join-Path $root 'hooks\win\statusline.ps1') $destDir -Force

if (Test-Path $settings) { Copy-Item $settings "$settings.devsys-backup" -Force }
if ($null -eq $cfg) { $cfg = New-Object psobject }
$cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $destDir 'statusline.ps1') + '"'
$sl = [pscustomobject]@{ type = 'command'; command = $cmd; padding = 0 }
if ($cfg.PSObject.Properties.Name -contains 'statusLine') { $cfg.statusLine = $sl } else { $cfg | Add-Member -NotePropertyName statusLine -NotePropertyValue $sl }
$json = $cfg | ConvertTo-Json -Depth 20
[IO.File]::WriteAllText($settings, $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "Installed devsys statusline. Backup: $settings.devsys-backup. Shows in the terminal CLI; the desktop Code tab may not display statuslines."
