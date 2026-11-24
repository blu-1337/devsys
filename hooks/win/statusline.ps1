# devsys statusline: shows model, context %, 5h/7d usage and budget level.
# Also caches usage to %USERPROFILE%\.claude\devsys\usage.json for the budget hooks.
# Installed by /devsys:init into user settings (statusLine), with the user's consent.
. "$PSScriptRoot\common.ps1"
$ErrorActionPreference = 'SilentlyContinue'

$in = Read-HookInput
if ($null -eq $in) { Write-Output 'devsys'; exit 0 }

$model = if ($in.model.display_name) { [string]$in.model.display_name } else { '?' }
$ctx = $in.context_window.used_percentage
$fh = $in.rate_limits.five_hour.used_percentage
$sd = $in.rate_limits.seven_day.used_percentage

if ($null -ne $fh -or $null -ne $sd) {
    $obj = @{ ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds(); five_hour = $fh; seven_day = $sd
              five_hour_resets_at = $in.rate_limits.five_hour.resets_at; seven_day_resets_at = $in.rate_limits.seven_day.resets_at }
    $obj | ConvertTo-Json -Compress | Set-Content -Path (Join-Path (Get-DevsysStateDir) 'usage.json') -Encoding ASCII
}

$parts = @($model)
if ($null -ne $ctx) {
    $c = [math]::Round([double]$ctx)
    $warn = if ($c -ge 40) { ' (compact/clear soon)' } else { '' }
    $parts += "ctx $c%$warn"
}
if ($null -ne $fh) { $parts += ('5h ' + [math]::Round([double]$fh) + '%') }
if ($null -ne $sd) { $parts += ('7d ' + [math]::Round([double]$sd) + '%') }
$lvl = Get-UsageLevel (Get-DevsysConfig ([string]$in.workspace.current_dir))
if ($lvl) { $parts += $lvl.Level }
Write-Output ($parts -join ' | ')
