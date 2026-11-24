# devsys Stop hook: runs the project's fast check before Claude may finish.
# Skips when nothing changed since the last passing check. Max 3 consecutive blocks per session.
. "$PSScriptRoot\common.ps1"

$in = Read-HookInput
$proj = Get-ProjectDir $in
$cfg = Get-DevsysConfig $proj
if ($null -eq $cfg -or $null -eq $cfg.commands) { exit 0 }
$check = [string]$cfg.commands.check
if (Test-Placeholder $check) { exit 0 }

$state = Get-DevsysStateDir
$projKey = ([BitConverter]::ToString((New-Object Security.Cryptography.MD5CryptoServiceProvider).ComputeHash([Text.Encoding]::UTF8.GetBytes($proj.ToLower())))).Replace('-', '').Substring(0, 12)
$passFile = Join-Path $state "lastpass-$projKey.txt"
$sid = if ($in -and $in.session_id) { [string]$in.session_id } else { 'nosession' }
$blockFile = Join-Path $state "stopblocks-$sid.txt"

# Fingerprint of the working tree (git only); if unchanged since last pass, skip.
$fp = $null
Push-Location $proj
try {
    $null = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -eq 0) {
        $status = (git status --porcelain 2>$null) -join "`n"
        $diff = (git diff HEAD 2>$null) -join "`n"
        $head = (git rev-parse HEAD 2>$null)
        $bytes = [Text.Encoding]::UTF8.GetBytes("$head`n$status`n$diff")
        $fp = [BitConverter]::ToString((New-Object Security.Cryptography.SHA1CryptoServiceProvider).ComputeHash($bytes)).Replace('-', '')
    }
} catch {} finally { Pop-Location }

if ($fp -and (Test-Path $passFile) -and ((Get-Content -Raw $passFile).Trim() -eq $fp)) { exit 0 }

# Run the check in the project directory.
Push-Location $proj
try {
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $check 2>&1 | Out-String
    $code = $LASTEXITCODE
} finally { Pop-Location }

if ($code -eq 0) {
    if ($fp) { Set-Content -Path $passFile -Value $fp -Encoding ASCII }
    if (Test-Path $blockFile) { Remove-Item $blockFile -Force }
    exit 0
}

$blocks = 0
if (Test-Path $blockFile) { $blocks = [int](Get-Content -Raw $blockFile) }
$blocks++
Set-Content -Path $blockFile -Value $blocks -Encoding ASCII

$tail = ($out -split "`r?`n" | Where-Object { $_ -ne '' } | Select-Object -Last 40) -join "`n"
if ($blocks -gt 3) {
    Remove-Item $blockFile -Force
    Write-HookJson @{ systemMessage = "devsys: check '$check' still failing after 3 attempts. Stopping; see docs/plan.md blocked notes." }
    exit 0
}
Exit-Block "devsys check failed (attempt $blocks/3): '$check' exited $code. Fix before finishing; if you can't, mark the task blocked in docs/plan.md and explain.`n--- last output ---`n$tail"
