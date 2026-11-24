# devsys: scaffold a project from templates/project. Never overwrites existing files.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File init-project.ps1 -Target <dir> -Name <name> [-Purpose ..] [-Stack ..]
#        [-Build ..] [-Test ..] [-Check ..] [-Run ..] [-Format ..] [-HighRisk]
param(
    [Parameter(Mandatory)] [string]$Target,
    [Parameter(Mandatory)] [string]$Name,
    [string]$Purpose = '{{ONE_LINE_PURPOSE}}',
    [string]$Stack = '{{STACK}}',
    [string]$Build = '{{BUILD_CMD}}',
    [string]$Test = '{{TEST_CMD}}',
    [string]$Check = '{{CHECK_CMD}}',
    [string]$Run = '{{RUN_CMD}}',
    [string]$Format = '{{FORMAT_CMD}}',
    [switch]$HighRisk
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$src = Join-Path $root 'templates\project'
$version = (Get-Content -Raw -Encoding UTF8 (Join-Path $root '.claude-plugin\plugin.json') | ConvertFrom-Json).version
if (-not (Test-Path $Target)) { New-Item -ItemType Directory -Force $Target | Out-Null }
$Target = (Resolve-Path $Target).Path

# JSON-escape values that go into devsys.json
function ConvertTo-JsonText([string]$s) { return ($s | ConvertTo-Json).Trim('"') }

$map = [ordered]@{
    '{{PROJECT_NAME}}'     = $Name
    '{{ONE_LINE_PURPOSE}}' = $Purpose
    '{{STACK}}'            = $Stack
    '{{BUILD_CMD}}'        = $Build
    '{{TEST_CMD}}'         = $Test
    '{{CHECK_CMD}}'        = $Check
    '{{RUN_CMD}}'          = $Run
    '{{FORMAT_CMD}}'       = $Format
    '{{DATE}}'             = (Get-Date -Format 'yyyy-MM-dd')
    '{{LANE}}'             = 'TBD'
}

$created = @(); $skipped = @()
$utf8 = New-Object System.Text.UTF8Encoding($false)
Get-ChildItem -Path $src -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($src.Length).TrimStart('\')
    $dest = Join-Path $Target $rel
    if (Test-Path $dest) { $skipped += $rel; return }
    $dir = Split-Path $dest -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    $text = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8)
    $isJson = $rel -like '*.json'
    foreach ($k in $map.Keys) {
        $v = [string]$map[$k]
        if ($isJson -and $v -notmatch '^\{\{.*\}\}$') { $v = ConvertTo-JsonText $v }
        $text = $text.Replace($k, $v)
    }
    if ($rel -eq '.claude\devsys.json') {
        $text = $text.Replace('"devsysVersion": "0.1.0"', ('"devsysVersion": "' + $version + '"'))
        if ($HighRisk) { $text = $text.Replace('"highRisk": false', '"highRisk": true') }
    }
    [IO.File]::WriteAllText($dest, $text, $utf8)
    $created += $rel
}

# git repo
$gitNew = $false
Push-Location $Target
$prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'   # PS 5.1 turns native stderr into errors
try {
    $null = & git rev-parse --is-inside-work-tree 2>&1
    if ($LASTEXITCODE -ne 0) { $null = & git init -q -b main 2>&1; $gitNew = $true }
} finally { $ErrorActionPreference = $prevEap; Pop-Location }

# .gitignore entries for local state
$gi = Join-Path $Target '.gitignore'
$want = @('.claude/settings.local.json', '.env', '.env.*', '!.env.example')
$have = if (Test-Path $gi) { Get-Content $gi } else { @() }
$add = $want | Where-Object { $have -notcontains $_ }
if ($add) { Add-Content -Path $gi -Value $add -Encoding UTF8 }

[pscustomobject]@{ target = $Target; created = $created; skipped_existing = $skipped; git_initialized = $gitNew } | ConvertTo-Json -Depth 4
