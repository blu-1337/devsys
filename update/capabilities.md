# Capabilities manifest

Every assumption devsys makes about Claude and Claude Code. `/devsys:update` re-verifies these. Change model routing **here** first, then in agent frontmatter.

Last full verification: **2026-11-24** (Claude Code 2.1.310, Opus 5.5).

## Environment
| Item | Value | Verified |
|------|-------|----------|
| OS | Windows 11 Pro | 2026-11-24 |
| Shell for hooks | Windows PowerShell 5.1 (`powershell.exe -NoProfile -ExecutionPolicy Bypass -File`). PowerShell 7 not installed. | 2026-11-24 |
| PS 5.1 gotchas | `Set-Content -Encoding UTF8` writes a BOM (use `[IO.File]::WriteAllText` with `UTF8Encoding($false)` for JSON); native-command stderr becomes a terminating error under `$ErrorActionPreference='Stop'` (wrap git calls); `Get-Content` defaults to ANSI (pass `-Encoding UTF8`) | 2026-11-24 |
| Claude CLI path | `%USERPROFILE%\.local\bin\claude.exe` (not on PATH) | 2026-11-24 |
| Claude Code version | 2.1.310 | 2026-11-24 |
| Plan | Claude Pro (limits not published; measured via statusline) | 2026-11-24 |

## Model routing (single source of truth)
| Role | Alias | Effort |
|------|-------|--------|
| Main session | `opusplan` | medium |
| Planning / architecture / escalation | `opus` (Opus 5.5) | medium; high on Deep |
| Implementation / review / research | `sonnet` (Sonnet 5.5) | medium |
| Scout / summarizer / librarian / parallel read-only | `haiku` (Haiku 5.5) | low |

## Claude Code features relied on
| Feature | Detail | Verified | Source |
|---------|--------|----------|--------|
| Subagent frontmatter | `name`, `description`, `model` (haiku/sonnet/opus/inherit/ID), `effort`, `tools`, `disallowedTools`, `skills`, `memory`, `isolation: worktree`, `maxTurns`, `omitClaudeMd` | 2026-11-24 | docs/sub-agents |
| Unpinned subagents inherit parent model | yes, so always pin `model` | 2026-11-24 | docs/sub-agents |
| Explore override | a user/project agent named `Explore` with `model: haiku` | 2026-11-24 | docs/sub-agents |
| Skill frontmatter | `description` (≤1,536 chars with when_to_use), `allowed-tools`, `model`, `effort`, `context: fork`, `disable-model-invocation`, `paths`, `shell: powershell` | 2026-11-24 | docs/skills |
| Skill size | SKILL.md < 500 lines; after compaction, 5k tokens per skill, 25k total | 2026-11-24 | docs/skills |
| Rules | `.claude/rules/*.md` with `paths:` globs; only `paths` frontmatter is read | 2026-11-24 | docs/memory |
| CLAUDE.md | < 200 lines; `@imports` max depth 4; root re-read after compaction | 2026-11-24 | docs/memory |
| Hooks: gate | PreToolUse, exit 2 or `permissionDecision: deny` blocks; `onFailure: "block"` | 2026-11-24 | docs/hooks |
| Hooks: verify | Stop, exit 2 keeps Claude working; cap of 8 consecutive blocks (`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`) | 2026-11-24 | docs/best-practices |
| Hooks: context | SessionStart stdout and `additionalContext` are injected; output cap 10,000 chars | 2026-11-24 | docs/hooks |
| Hook on Windows | exec form `"command": "powershell.exe", "args": [..., "-File", "${CLAUDE_PLUGIN_ROOT}/hooks/win/x.ps1"]` (no shell quoting); `timeout` in seconds; `hooks/hooks.json` needs top-level `"hooks"` wrapper | unit-tested 2026-11-24; **live firing not yet verified** | docs/hooks, docs/plugins/components |
| Hook outputs used | PreToolUse `hookSpecificOutput.permissionDecision` deny/ask; Stop exit 2 + stderr; SessionStart/UserPromptSubmit `additionalContext`; `systemMessage` for user | docs 2026-11-24 | docs/hooks |
| Statusline usage | `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage` (Pro/Max only, after first response); `context_window.used_percentage`. **Only source of usage %**: not in hook input or env. Statusline is user-settings only (not plugin) and **may not render in the desktop Code tab** (user reports) | docs 2026-11-24 | docs/statusline |
| Plugin env | `${CLAUDE_PLUGIN_ROOT}` (changes per update, never store state), `${CLAUDE_PLUGIN_DATA}` (per-plugin data dir), `CLAUDE_PROJECT_DIR`; substituted in skill text but not in Bash tool env | docs 2026-11-24 | docs/plugins/manifest-reference |
| Headless CLI | `claude.exe -p` needs its own login (`/login` in terminal); desktop app auth is separate | 2026-11-24 | observed |
| Plugin idle cost | ~112 tokens/session (2 skill descriptions); hooks cost no model context | 2026-11-24 | `claude plugin details` |
| Plugins | bundle skills, agents, hooks, MCP, output styles; rules/settings **not** confirmed as plugin parts, so `init` copies them | 2026-11-24 | docs/plugins |
| Plugin CLI | `validate`, `details` (shows projected token cost), `eval` (built-in eval runner), `tag` | 2026-11-24 | `claude plugin --help` |
| Effort levels | low, medium, high, xhigh, max; default medium on 5.5 models | 2026-11-24 | docs/model-config |
| Headless | `claude -p`, `--output-format stream-json`, `--max-turns`, `--max-budget-usd`, `--bare` | 2026-11-24 | docs/headless |
| Agent teams | experimental, token-heavy, **not used** | 2026-11-24 | docs/agent-teams |

## Research-based assumptions (re-test on each model generation)
- Context quality drops past about 40% usage. Compact or clear before then.
- Parallel writers underperform one sequential writer (CooperBench, about −30%). Parallelize reads and reviews only.
- LLM-generated CLAUDE.md content hurts. Keep it human-curated and minimal.
- Skills earn their place only when they beat no-skill (`claude plugin details` and evals).
