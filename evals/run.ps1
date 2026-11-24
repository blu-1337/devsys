# Headless build-to-green evals (needs a shell, which `claude plugin eval` can't grant on Windows).
# Each task: evals/headless/<name>/task.json (+ hidden test copied in AFTER the run, so Claude never sees it).
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File evals\run.ps1 [-Task <name>] [-Runs 1] [-NoPlugin]
param([string]$Task = '*', [int]$Runs = 1, [switch]$NoPlugin)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$claude = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claude) { $claude = "$env:USERPROFILE\.local\bin\claude.exe" }
$csv = Join-Path $PSScriptRoot 'baselines\headless.csv'
if (-not (Test-Path $csv)) { 'date,task,arm,run,passed,turns,cost_usd,seconds,model,claude' | Set-Content $csv -Encoding ASCII }
$ver = (& $claude --version) -replace ' .*', ''
foreach ($dir in Get-ChildItem (Join-Path $PSScriptRoot 'headless') -Directory -Filter $Task) {
    $t = Get-Content -Raw -Encoding UTF8 (Join-Path $dir.FullName 'task.json') | ConvertFrom-Json
    for ($i = 1; $i -le $Runs; $i++) {
        $work = Join-Path $env:TEMP ("devsys-eval-" + $dir.Name + "-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
        New-Item -ItemType Directory -Force $work | Out-Null
        $arm = 'with'
        if ($NoPlugin) { $arm = 'without' }
        else {
            & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'scripts\init-project.ps1') -Target $work -Name $dir.Name -Purpose 'eval task' -Stack $t.stack | Out-Null
        }
        Push-Location $work
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        $null = & git init -q 2>&1; $null = & git config user.name eval 2>&1; $null = & git config user.email eval@example.invalid 2>&1
        $a = @('-p', $t.prompt, '--model', $t.model, '--max-turns', [string]$t.maxTurns, '--permission-mode', 'acceptEdits',
               '--allowedTools', 'Read,Write,Edit,Glob,Grep,PowerShell,Bash,Agent,Skill', '--output-format', 'json')
        if (-not $NoPlugin) { $a += @('--plugin-dir', $repo) }
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $raw = & $claude @a 2>$null | Out-String
        $sec = [int]$sw.Elapsed.TotalSeconds
        try { $r = $raw | ConvertFrom-Json } catch { $r = $null }
        Copy-Item (Join-Path $dir.FullName $t.hiddenTest) $work -Force
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -Command $t.check 2>&1 | Out-String
        $passed = ($LASTEXITCODE -eq 0)
        $ErrorActionPreference = $prev
        Pop-Location
        $row = '{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}' -f (Get-Date -Format 'yyyy-MM-dd'), $dir.Name, $arm, $i, $passed, $r.num_turns, [math]::Round([double]$r.total_cost_usd, 3), $sec, $t.model, $ver
        Add-Content $csv $row -Encoding ASCII
        $row
        if (-not $passed) { "  hidden test output: " + ($out.Trim() -split "`n" | Select-Object -Last 6) -join ' | ' }
        Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    }
}
