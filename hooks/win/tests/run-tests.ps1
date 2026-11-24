# Unit tests for devsys hooks: pipes sample hook JSON into each script and checks the result.
# Run:  powershell -NoProfile -ExecutionPolicy Bypass -File hooks\win\tests\run-tests.ps1
$ErrorActionPreference = 'Stop'
$hookDir = Split-Path $PSScriptRoot -Parent
$tmp = Join-Path $env:TEMP ("devsys-test-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
$state = Join-Path $tmp 'state'
$proj = Join-Path $tmp 'proj'
New-Item -ItemType Directory -Force $state, (Join-Path $proj '.claude'), (Join-Path $proj 'docs') | Out-Null
$env:DEVSYS_STATE_DIR = $state
$env:CLAUDE_PROJECT_DIR = $proj

$script:pass = 0; $script:fail = 0
function Invoke-Hook([string]$Name, $Payload) {
    $json = $Payload | ConvertTo-Json -Depth 6 -Compress
    $psi = New-Object Diagnostics.ProcessStartInfo 'powershell.exe', ("-NoProfile -ExecutionPolicy Bypass -File `"" + (Join-Path $hookDir $Name) + "`"")
    $psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $p = [Diagnostics.Process]::Start($psi)
    $p.StandardInput.Write($json); $p.StandardInput.Close()
    $o = $p.StandardOutput.ReadToEnd(); $e = $p.StandardError.ReadToEnd(); $p.WaitForExit()
    return [pscustomobject]@{ Code = $p.ExitCode; Out = $o; Err = $e }
}
function Assert([string]$Name, [bool]$Cond, $R) {
    if ($Cond) { $script:pass++; Write-Output "PASS  $Name" }
    else { $script:fail++; Write-Output "FAIL  $Name`n      code=$($R.Code) out=$($R.Out.Trim()) err=$($R.Err.Trim())" }
}
function Pre($tool, $inputObj) { Invoke-Hook 'guard.ps1' @{ hook_event_name = 'PreToolUse'; tool_name = $tool; tool_input = $inputObj; cwd = $proj } }

# ---- guard.ps1 -------------------------------------------------------------
$r = Pre 'Read' @{ file_path = "$proj\.env" };                       Assert 'guard denies Read .env' ($r.Out -match '"deny"') $r
$r = Pre 'Read' @{ file_path = "$proj\.env.local" };                 Assert 'guard denies Read .env.local' ($r.Out -match '"deny"') $r
$r = Pre 'Read' @{ file_path = "$proj\.env.example" };               Assert 'guard allows .env.example' ($r.Code -eq 0 -and $r.Out.Trim() -eq '') $r
$r = Pre 'Write' @{ file_path = "$proj\certs\server.pem" };          Assert 'guard denies Write .pem' ($r.Out -match '"deny"') $r
$r = Pre 'Bash' @{ command = 'cat .env' };                           Assert 'guard denies bash cat .env' ($r.Out -match '"deny"') $r
$r = Pre 'PowerShell' @{ command = 'Get-Content .\secrets\api.txt' }; Assert 'guard denies secrets dir' ($r.Out -match '"deny"') $r
$r = Pre 'Read' @{ file_path = "$proj\src\environment.ts" };          Assert 'guard allows environment.ts' ($r.Out.Trim() -eq '') $r
$r = Pre 'Read' @{ file_path = "$proj\src\keyboard.ts" };             Assert 'guard allows keyboard.ts' ($r.Out.Trim() -eq '') $r
$r = Pre 'Bash' @{ command = 'rm -rf /' };                            Assert 'guard asks rm -rf /' ($r.Out -match '"ask"') $r
$r = Pre 'Bash' @{ command = 'rm -rf ./build' };                      Assert 'guard allows rm -rf ./build' ($r.Out.Trim() -eq '') $r
$r = Pre 'PowerShell' @{ command = 'Remove-Item -Recurse -Force C:\' }; Assert 'guard asks Remove-Item C:\' ($r.Out -match '"ask"') $r
$r = Pre 'PowerShell' @{ command = 'Remove-Item -Recurse -Force .\dist' }; Assert 'guard allows Remove-Item .\dist' ($r.Out.Trim() -eq '') $r
$r = Pre 'Bash' @{ command = 'git push --force origin main' };        Assert 'guard asks force push' ($r.Out -match '"ask"') $r
$r = Pre 'Bash' @{ command = 'git reset --hard HEAD~1' };             Assert 'guard asks reset --hard' ($r.Out -match '"ask"') $r
$r = Pre 'Bash' @{ command = 'git status' };                          Assert 'guard allows git status' ($r.Out.Trim() -eq '') $r
$r = Pre 'Bash' @{ command = 'git checkout -- wordcount.ps1' };       Assert 'guard asks checkout --' ($r.Out -match '"ask"') $r
$r = Pre 'Bash' @{ command = 'git restore src/a.ps1' };               Assert 'guard asks git restore' ($r.Out -match '"ask"') $r
$r = Pre 'Bash' @{ command = 'git restore --staged src/a.ps1' };      Assert 'guard allows restore --staged' ($r.Out.Trim() -eq '') $r
$r = Pre 'Bash' @{ command = 'git checkout -b feature/x' };           Assert 'guard allows checkout -b' ($r.Out.Trim() -eq '') $r
$r = Pre 'Read' @{ file_path = "$proj\.env" };                        Assert 'guard message has no raw regex' ($r.Out -match '\.env file' -and $r.Out -notmatch '\(\?!') $r

# ---- session-start / budget (non-devsys project = silent) ------------------
$r = Invoke-Hook 'session-start.ps1' @{ hook_event_name = 'SessionStart'; source = 'startup'; session_id = 's1'; cwd = $proj }
Assert 'session-start silent outside devsys project' ($r.Out.Trim() -eq '' -and $r.Code -eq 0) $r

# Make it a devsys project with a plan
@'
{ "stack": "test", "planPreview": "on", "highRisk": false,
  "commands": { "check": "exit 0", "test": "", "format": "" },
  "budget": { "saverAt": 50, "conserveAt": 80 } }
'@ | Set-Content (Join-Path $proj '.claude\devsys.json') -Encoding ASCII
"# Plan`n- [x] done task`n- [ ] write the parser - src/parse.ps1" | Set-Content (Join-Path $proj 'docs\plan.md') -Encoding ASCII

$r = Invoke-Hook 'session-start.ps1' @{ hook_event_name = 'SessionStart'; source = 'startup'; session_id = 's1'; cwd = $proj }
Assert 'session-start shows current task' ($r.Out -match 'write the parser') $r
Assert 'session-start budget unknown without data' ($r.Out -match 'budget: unknown') $r
Assert 'session-start creates last-check' (Test-Path (Join-Path $state 'last-check.txt')) $r

(Get-Date).AddDays(-40).ToString('yyyy-MM-dd') | Set-Content (Join-Path $state 'last-check.txt') -Encoding ASCII
$r = Invoke-Hook 'session-start.ps1' @{ hook_event_name = 'SessionStart'; source = 'startup'; session_id = 's1'; cwd = $proj }
Assert 'session-start update reminder after 30 days' ($r.Out -match 'systemMessage' -and $r.Out -match '40 days') $r
$r = Invoke-Hook 'session-start.ps1' @{ hook_event_name = 'SessionStart'; source = 'compact'; session_id = 's1'; cwd = $proj }
Assert 'no update reminder on compact' ($r.Out -notmatch 'systemMessage') $r

# ---- statusline -> usage.json -> budget ------------------------------------
$r = Invoke-Hook 'statusline.ps1' @{ model = @{ display_name = 'Opus 5.5' }; context_window = @{ used_percentage = 23.4 };
    rate_limits = @{ five_hour = @{ used_percentage = 30 }; seven_day = @{ used_percentage = 10 } }; workspace = @{ current_dir = $proj } }
Assert 'statusline renders' ($r.Out -match 'Opus 5.5 \| ctx 23% \| 5h 30% \| 7d 10% \| NORMAL') $r
Assert 'statusline writes usage.json' (Test-Path (Join-Path $state 'usage.json')) $r

$r = Invoke-Hook 'budget.ps1' @{ hook_event_name = 'UserPromptSubmit'; session_id = 'b1'; prompt = 'hi'; cwd = $proj }
Assert 'budget injects NORMAL first time' ($r.Out -match 'NORMAL') $r
$r = Invoke-Hook 'budget.ps1' @{ hook_event_name = 'UserPromptSubmit'; session_id = 'b1'; prompt = 'hi'; cwd = $proj }
Assert 'budget silent when unchanged' ($r.Out.Trim() -eq '') $r

$null = Invoke-Hook 'statusline.ps1' @{ model = @{ display_name = 'Opus 5.5' }; rate_limits = @{ five_hour = @{ used_percentage = 65 }; seven_day = @{ used_percentage = 20 } }; workspace = @{ current_dir = $proj } }
$r = Invoke-Hook 'budget.ps1' @{ hook_event_name = 'UserPromptSubmit'; session_id = 'b1'; prompt = 'hi'; cwd = $proj }
Assert 'budget switches to SAVER at 65%' ($r.Out -match 'SAVER' -and $r.Out -match 'systemMessage') $r

$null = Invoke-Hook 'statusline.ps1' @{ model = @{ display_name = 'Opus 5.5' }; rate_limits = @{ five_hour = @{ used_percentage = 50 }; seven_day = @{ used_percentage = 85 } }; workspace = @{ current_dir = $proj } }
$r = Invoke-Hook 'budget.ps1' @{ hook_event_name = 'UserPromptSubmit'; session_id = 'b1'; prompt = 'hi'; cwd = $proj }
Assert 'budget switches to CONSERVE when 7d at 85%' ($r.Out -match 'CONSERVE') $r

# ---- stop-check ------------------------------------------------------------
Push-Location $proj; git init -q; git -c user.name=t -c user.email=t@t add -A; git -c user.name=t -c user.email=t@t commit -qm init; Pop-Location
$r = Invoke-Hook 'stop-check.ps1' @{ hook_event_name = 'Stop'; session_id = 'c1'; cwd = $proj }
Assert 'stop passes when check passes' ($r.Code -eq 0) $r

(Get-Content -Raw (Join-Path $proj '.claude\devsys.json')).Replace('"check": "exit 0"', '"check": "Write-Output boom-failure; exit 3"') | Set-Content (Join-Path $proj '.claude\devsys.json') -Encoding ASCII
$r = Invoke-Hook 'stop-check.ps1' @{ hook_event_name = 'Stop'; session_id = 'c1'; cwd = $proj }
Assert 'stop blocks (exit 2) when check fails' ($r.Code -eq 2 -and $r.Err -match 'boom-failure' -and $r.Err -match 'attempt 1/3') $r
$null = Invoke-Hook 'stop-check.ps1' @{ hook_event_name = 'Stop'; session_id = 'c1'; cwd = $proj }
$null = Invoke-Hook 'stop-check.ps1' @{ hook_event_name = 'Stop'; session_id = 'c1'; cwd = $proj }
$r = Invoke-Hook 'stop-check.ps1' @{ hook_event_name = 'Stop'; session_id = 'c1'; cwd = $proj }
Assert 'stop gives up after 3 blocks' ($r.Code -eq 0 -and $r.Out -match 'still failing') $r

(Get-Content -Raw (Join-Path $proj '.claude\devsys.json')).Replace('"check": "Write-Output boom-failure; exit 3"', '"check": "{{CHECK_CMD}}"') | Set-Content (Join-Path $proj '.claude\devsys.json') -Encoding ASCII
$r = Invoke-Hook 'stop-check.ps1' @{ hook_event_name = 'Stop'; session_id = 'c2'; cwd = $proj }
Assert 'stop skips placeholder check' ($r.Code -eq 0 -and $r.Err.Trim() -eq '') $r

# ---- format ----------------------------------------------------------------
$r = Invoke-Hook 'format.ps1' @{ hook_event_name = 'PostToolUse'; tool_name = 'Write'; tool_input = @{ file_path = "$proj\a.txt" }; cwd = $proj }
Assert 'format silent with no formatter' ($r.Code -eq 0 -and $r.Out.Trim() -eq '') $r

Remove-Item -Recurse -Force $tmp
Write-Output "`n$script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
