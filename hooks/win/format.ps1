# devsys PostToolUse: run the project's formatter on the edited file. Silent; never blocks.
. "$PSScriptRoot\common.ps1"

$in = Read-HookInput
if ($null -eq $in -or -not $in.tool_input.file_path) { exit 0 }
$proj = Get-ProjectDir $in
$cfg = Get-DevsysConfig $proj
if ($null -eq $cfg -or $null -eq $cfg.commands) { exit 0 }
$fmt = [string]$cfg.commands.format
if (Test-Placeholder $fmt) { exit 0 }

$file = [string]$in.tool_input.file_path
$cmd = $fmt.Replace('{file}', ('"' + $file + '"'))
Push-Location $proj
try { & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd *> $null } catch {} finally { Pop-Location }
exit 0
