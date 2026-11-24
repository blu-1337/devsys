# devsys SessionStart: current task, budget level, update reminder. <= ~10 lines of context.
. "$PSScriptRoot\common.ps1"

$in = Read-HookInput
$proj = Get-ProjectDir $in
if (-not (Test-DevsysProject $proj)) { exit 0 }
$cfg = Get-DevsysConfig $proj
$lines = @()
$userMsg = @()

# Current task = first unchecked box in docs/plan.md
$plan = Join-Path $proj 'docs\plan.md'
if (Test-Path $plan) {
    $task = Get-Content -Encoding UTF8 $plan | Where-Object { $_ -match '^\s*-\s\[\s\]\s+\S' } | Select-Object -First 1
    if ($task) { $lines += "devsys current task: " + $task.Trim() }
}

# Budget
$lvl = Get-UsageLevel $cfg
if ($lvl) {
    $lines += (Get-BudgetGuidance $lvl.Level) + " (5h " + $lvl.FiveHour + "%, 7d " + $lvl.SevenDay + "%)"
    if ($in -and $in.session_id) { Set-Content -Path (Join-Path (Get-DevsysStateDir) ("level-" + $in.session_id + ".txt")) -Value $lvl.Level -Encoding ASCII }
} else {
    $lines += "devsys budget: unknown (no fresh statusline data). Prefer Sonnet for execution; suggest /usage if work is heavy."
}

# Update reminder (suggest-only), only on fresh startup
if (-not $in -or $in.source -eq 'startup') {
    $lc = Join-Path (Get-DevsysStateDir) 'last-check.txt'
    if (-not (Test-Path $lc)) {
        Set-Content -Path $lc -Value (Get-Date -Format 'yyyy-MM-dd') -Encoding ASCII
    } else {
        try {
            $last = [datetime]::ParseExact((Get-Content -Raw $lc).Trim(), 'yyyy-MM-dd', $null)
            $days = [int][math]::Floor(((Get-Date).Date - $last).TotalDays)
            if ($days -ge 30) {
                $msg = "devsys: last update check was $days days ago. Run /devsys:update? (suggest-only)"
                $userMsg += $msg
                $lines += "$msg Mention this to the user once; do not run it unless they say yes."
            }
        } catch {}
    }
}

$out = @{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = ($lines -join "`n") } }
if ($userMsg.Count -gt 0) { $out.systemMessage = ($userMsg -join ' ') }
Write-HookJson $out
exit 0
