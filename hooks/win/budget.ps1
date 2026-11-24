# devsys UserPromptSubmit: inject budget guidance only when the level changes. Silent otherwise.
. "$PSScriptRoot\common.ps1"

$in = Read-HookInput
$proj = Get-ProjectDir $in
if (-not (Test-DevsysProject $proj)) { exit 0 }
$lvl = Get-UsageLevel (Get-DevsysConfig $proj)
if ($null -eq $lvl) { exit 0 }

$sid = if ($in -and $in.session_id) { [string]$in.session_id } else { 'nosession' }
$f = Join-Path (Get-DevsysStateDir) "level-$sid.txt"
$prev = if (Test-Path $f) { (Get-Content -Raw $f).Trim() } else { '' }
if ($prev -eq $lvl.Level) { exit 0 }
Set-Content -Path $f -Value $lvl.Level -Encoding ASCII

$msg = (Get-BudgetGuidance $lvl.Level) + " (5h " + $lvl.FiveHour + "%, 7d " + $lvl.SevenDay + "%)"
$out = @{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $msg } }
if ($lvl.Level -ne 'NORMAL') { $out.systemMessage = "devsys budget is now $($lvl.Level) (5h $($lvl.FiveHour)%, 7d $($lvl.SevenDay)%)" }
Write-HookJson $out
exit 0
