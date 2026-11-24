# devsys PreToolUse guard: blocks secret access, asks before destructive commands.
# Matcher: Read|Edit|Write|MultiEdit|Bash|PowerShell
. "$PSScriptRoot\common.ps1"

$in = Read-HookInput
if ($null -eq $in) { exit 0 }

$tool = [string]$in.tool_name
$ti = $in.tool_input
$target = ''
if ($ti.file_path) { $target = [string]$ti.file_path }
elseif ($ti.command) { $target = [string]$ti.command }
if ([string]::IsNullOrWhiteSpace($target)) { exit 0 }

function Out-Decision([string]$Decision, [string]$Reason) {
    Write-HookJson @{ hookSpecificOutput = @{
        hookEventName = 'PreToolUse'; permissionDecision = $Decision; permissionDecisionReason = $Reason } }
    exit 0
}

# --- Secrets (deny) ---------------------------------------------------------
# Allowed examples: .env.example, .env.sample, .env.template
$secretPatterns = @(
    '(^|[\\/\s"''=])\.env(?!\.(example|sample|template))(\.[\w-]+)?($|[\s"''|;&>)])',
    '\.(pem|pfx|p12|key)($|[\s"''|;&>)])',
    '(^|[\\/\s"''])id_(rsa|ed25519|ecdsa)($|[\s"''.])',
    '[\\/]secrets[\\/]',
    '(^|[\\/\s"''])credentials\.json($|[\s"''])'
)
foreach ($p in $secretPatterns) {
    if ($target -match $p) {
        Out-Decision 'deny' "devsys guard: '$tool' touches a secret file (matched $p). Secrets are never read or written by Claude. Ask the user to handle this file themselves, or use a placeholder/example file."
    }
}

# --- Destructive commands (ask the user) -----------------------------------
if ($tool -eq 'Bash' -or $tool -eq 'PowerShell') {
    $destructive = @(
        @{ p = 'rm\s+-[a-zA-Z]*r[a-zA-Z]*\s+(-[a-zA-Z]+\s+)*(/|~|\$HOME|\*|[A-Za-z]:[\\/]?)(\s|$)'; d = 'recursive delete of a root/home/wildcard path' },
        @{ p = 'Remove-Item\b.*-Recurse.*\s(([A-Za-z]:\\?)|\$env:USERPROFILE|~|\*)(\s|$|")'; d = 'recursive delete of a drive/home/wildcard path' },
        @{ p = '\b(rd|rmdir)\s+/s\b'; d = 'recursive directory delete' },
        @{ p = '\bdel\s+(/[a-zA-Z]\s+)*/s\b'; d = 'recursive file delete' },
        @{ p = '\bformat(\.com)?\s+[A-Za-z]:'; d = 'disk format' },
        @{ p = 'git\s+push\b.*(--force\b|--force-with-lease\b|\s-f\b)'; d = 'force push' },
        @{ p = 'git\s+reset\s+--hard'; d = 'hard reset (discards uncommitted work)' },
        @{ p = 'git\s+clean\s+-[a-zA-Z]*f'; d = 'git clean (deletes untracked files)' },
        @{ p = 'git\s+branch\s+-D\b'; d = 'force branch delete' }
    )
    foreach ($x in $destructive) {
        if ($target -match $x.p) {
            Out-Decision 'ask' ("devsys guard: this command looks destructive (" + $x.d + "). Confirm only if intended.")
        }
    }
}

exit 0
