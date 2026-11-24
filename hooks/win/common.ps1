# devsys shared helpers for hook scripts (Windows PowerShell 5.1 compatible, ASCII only).

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

function Read-HookInput {
    # Hook payload arrives as JSON on stdin.
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    return $raw | ConvertFrom-Json
}

function Get-DevsysStateDir {
    # Per-user, stable across plugin updates. Fixed path (not CLAUDE_PLUGIN_DATA) because the
    # statusline script runs outside the plugin and must share usage.json with the hooks.
    $base = $env:DEVSYS_STATE_DIR
    if ([string]::IsNullOrWhiteSpace($base)) { $base = Join-Path $env:USERPROFILE '.claude\devsys' }
    if (-not (Test-Path $base)) { New-Item -ItemType Directory -Force $base | Out-Null }
    return $base
}

function Test-DevsysProject([string]$ProjectDir) {
    # Hooks act only in devsys projects (or the devsys repo itself), never elsewhere.
    if ([string]::IsNullOrWhiteSpace($ProjectDir)) { return $false }
    if (Test-Path (Join-Path $ProjectDir '.claude\devsys.json')) { return $true }
    $pj = Join-Path $ProjectDir '.claude-plugin\plugin.json'
    if (Test-Path $pj) {
        try { return ((Get-Content -Raw $pj | ConvertFrom-Json).name -eq 'devsys') } catch { return $false }
    }
    return $false
}

function Get-UsageLevel($Config) {
    # Reads usage.json written by the statusline. Returns $null when missing or stale (>30 min).
    $f = Join-Path (Get-DevsysStateDir) 'usage.json'
    if (-not (Test-Path $f)) { return $null }
    try { $u = Get-Content -Raw $f | ConvertFrom-Json } catch { return $null }
    $age = ([DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) - [int64]$u.ts
    if ($age -gt 1800) { return $null }
    $saver = 50; $conserve = 80
    if ($Config -and $Config.budget) {
        if ($Config.budget.saverAt) { $saver = [int]$Config.budget.saverAt }
        if ($Config.budget.conserveAt) { $conserve = [int]$Config.budget.conserveAt }
    }
    $vals = @()
    if ($null -ne $u.five_hour) { $vals += [double]$u.five_hour }
    if ($null -ne $u.seven_day) { $vals += [double]$u.seven_day }
    if ($vals.Count -eq 0) { return $null }
    $max = ($vals | Measure-Object -Maximum).Maximum
    $level = 'NORMAL'
    if ($max -ge $conserve) { $level = 'CONSERVE' } elseif ($max -ge $saver) { $level = 'SAVER' }
    return [pscustomobject]@{ Level = $level; FiveHour = $u.five_hour; SevenDay = $u.seven_day; Max = $max }
}

function Get-BudgetGuidance([string]$Level) {
    switch ($Level) {
        'SAVER'    { return 'devsys budget SAVER: Opus only for Deep-lane planning; helpers at low effort; no parallel agents; keep reviews short.' }
        'CONSERVE' { return 'devsys budget CONSERVE: Sonnet only; no subagents except scout; finish or checkpoint the current task in docs/plan.md, then tell the user to pause or continue later.' }
        default    { return 'devsys budget NORMAL: full routing.' }
    }
}

function Get-DevsysConfig([string]$ProjectDir) {
    # Returns the project's .claude/devsys.json as an object, or $null if absent/invalid.
    if ([string]::IsNullOrWhiteSpace($ProjectDir)) { return $null }
    $p = Join-Path $ProjectDir '.claude\devsys.json'
    if (-not (Test-Path $p)) { return $null }
    try { return (Get-Content -Raw -Encoding UTF8 -Path $p | ConvertFrom-Json) } catch { return $null }
}

function Get-ProjectDir($HookInput) {
    if ($env:CLAUDE_PROJECT_DIR) { return $env:CLAUDE_PROJECT_DIR }
    if ($HookInput -and $HookInput.cwd) { return $HookInput.cwd }
    return (Get-Location).Path
}

function Test-Placeholder([string]$Value) {
    # True when a config value is empty or still a {{TEMPLATE}} placeholder.
    return ([string]::IsNullOrWhiteSpace($Value) -or $Value -match '^\{\{.*\}\}$')
}

function Write-HookJson($Object) {
    $Object | ConvertTo-Json -Depth 6 -Compress | Write-Output
}

function Exit-Block([string]$Reason) {
    # Exit code 2 = block; stderr is fed back to Claude.
    [Console]::Error.WriteLine($Reason)
    exit 2
}
