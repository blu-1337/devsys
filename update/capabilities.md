# Capabilities manifest

Every assumption devsys makes about Claude and Claude Code. `/devsys:update` re-verifies these. Change model routing **here** first, then in agent frontmatter.

Last full verification: **2026-11-24** (Claude Code 2.1.331, Opus 5.5). Last update dry run: 2026-11-24 (`update/proposals/2026-11-24-dry-run.md`, 6 proposals pending the user's yes/no).

## Environment
| Item | Value | Verified |
|------|-------|----------|
| OS | Windows 11 Pro | 2026-11-24 |
| Shell for hooks | Windows PowerShell 5.1 (`powershell.exe -NoProfile -ExecutionPolicy Bypass -File`). PowerShell 7 not installed. | 2026-11-24 |
| PS 5.1 gotchas | `Set-Content -Encoding UTF8` writes a BOM (use `[IO.File]::WriteAllText` with `UTF8Encoding($false)` for JSON); native-command stderr becomes a terminating error under `$ErrorActionPreference='Stop'` (wrap git calls); `Get-Content` defaults to ANSI (pass `-Encoding UTF8`) | 2026-11-24 |
| Claude CLI path | `%USERPROFILE%\.local\bin\claude.exe` (not on PATH) | 2026-11-24 |
| Claude Code version | 2.1.331 (auto-updates, channel "latest") | 2026-11-24 |
| Plan | Claude Pro (limits not published; measured via statusline) | 2026-11-24 |

## Model routing (single source of truth)
| Role | Alias | Effort |
|------|-------|--------|
| Main session | `opusplan` (= Sonnet outside plan mode; headless/build runs never reach Opus) | medium |
| Planning / architecture / escalation | `opus` (Opus 5.5) via the `architect` agent | medium; high on Deep |
| Implementation / review / research | `sonnet` (Sonnet 5.5) | medium |
| Scout / summarizer / librarian / parallel read-only | `haiku` (Haiku 5.5) | low |
| (none) | `fable` (Fable 5.2) **never used by devsys**: user decision 2026-11-24; outside Pro limits (paid credits) and 2x Opus price. No agent, skill or update proposal may route to it | - |

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
| Hook on Windows | exec form `"command": "powershell.exe", "args": [..., "-File", "${CLAUDE_PLUGIN_ROOT}/hooks/win/x.ps1"]` (no shell quoting); `timeout` in seconds; `hooks/hooks.json` needs top-level `"hooks"` wrapper | **live-verified 2026-11-24**: PreToolUse deny + ask, SessionStart context, Stop exit-2 gate (Claude fixed sabotaged code) | docs/hooks, docs/plugins/components |
| Hook outputs used | PreToolUse `hookSpecificOutput.permissionDecision` deny/ask; Stop exit 2 + stderr; SessionStart/UserPromptSubmit `additionalContext`; `systemMessage` for user | docs 2026-11-24 | docs/hooks |
| Statusline usage | `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage` (Pro/Max only, after first response); `context_window.used_percentage`. **Only source of usage %**: not in hook input or env. Statusline is user-settings only (not plugin) and **may not render in the desktop Code tab** (user reports) | docs 2026-11-24 | docs/statusline |
| Plugin env | `${CLAUDE_PLUGIN_ROOT}` (changes per update, never store state), `${CLAUDE_PLUGIN_DATA}` (per-plugin data dir), `CLAUDE_PROJECT_DIR`; substituted in skill text but not in Bash tool env | docs 2026-11-24 | docs/plugins/manifest-reference |
| Headless CLI | `claude.exe -p` needs its own login (`/login` in terminal, choose the **subscription** option, not Console/API billing); desktop app auth is separate. `claude auth status` shows `subscriptionType` | 2026-11-24 | observed |
| Skill `model:` override | `/devsys:quick` with `model: sonnet` ran entirely on Sonnet from an Opus-default session. Since 2.1.330 subagents spawned by such a skill stay on the **session** model unless pinned, so every devsys agent pins `model` | 2026-11-24 | observed (modelUsage) + changelog 2.1.330 |
| Protected `.claude/` dir | Claude Code asks before edits under `.claude/` even in acceptEdits (seen: `.claude/devsys.json` edit blocked in a hands-off build). devsys config therefore lives in `devsys.json` at the project root | 2026-11-24 | observed |
| Skill auto-trigger | Model-invocable skills do **not** reliably fire on plain requests ("build me X" skipped `devsys:build` in evals). A one-line SessionStart instruction fixed it (tests-first 0 -> 1.0) | 2026-11-24 | evals |
| `claude plugin eval` on Windows | Runner refuses Bash/PowerShell grants (no sandbox backend): behaviour-only cases there; build-to-green via `evals/run.ps1` (`claude -p`). `scaffold_script` = path inside the case dir (bash). Plugin hooks do run. Grader types used: regex, llm, file_exists, tool_used | 2026-11-24 | observed |
| Plugin always-on cost | ~936 tokens/session in v0.3.1 for 8 skills + 6 agents (was ~692 in v0.3.0); measure with `claude plugin details devsys`, or `claude --plugin-dir <repo> plugin details devsys` when not installed | 2026-11-24 | observed |
| Self-edit protection | Files of a plugin loaded in the session (e.g. via `--plugin-dir`) are "sensitive": edits need user approval even in acceptEdits. `/devsys:update` writing proposals therefore asks once | 2026-11-24 | observed |
| Plugin agents | `agents/*.md` in the plugin are namespaced `devsys:<name>`; an `Explore` override must be a project agent (`.claude/agents/Explore.md`, copied by init) | 2026-11-24 | observed |
| Permission deny vs hook | project `permissions.deny` fires before the PreToolUse hook (both layers useful) | 2026-11-24 | observed |
| `ask` in headless mode | a PreToolUse `ask` acts as a block in `-p` (no one to ask) | 2026-11-24 | observed |

## Observed costs (Pro plan, list-price equivalents from `-p` JSON)
| Task | Model | Turns | Output tok | Time | List $ |
|------|-------|-------|-----------|------|--------|
| Quick lane: PowerShell word counter + 3 Pester tests | Sonnet 5.5 | 6 | ~1.5k (208k cache reads) | 26 s | ~$0.11 |
| Stop-gate repair of sabotaged script | Haiku 5.5 | 8 | small | ~20 s | small |
| Guardian heads-up (no action) | Sonnet 5.5 | 2 | ~0.5k | 13 s | ~$0.08 |
| Standard lane: Downloads sorter, 7 tasks + review fixes, 66 tests | Opus plan + Sonnet build | 23 | ~60k | ~8 min | ~$2.40 |
| Eval suite, 6 cases x 2 runs x 2 arms | Sonnet | - | - | ~6 min | ~$1.35 |
| Statusline live | **verified 2026-11-24 in terminal CLI (Pro):** rendered `Haiku 5.5 \| ctx 4% \| 5h 17% \| 7d 18% \| NORMAL`; usage.json written with `resets_at`. Desktop Code tab display still unverified, so budget data is fresh only while/after a terminal session runs (30-min staleness limit) | 2026-11-24 | observed |
| Plugins | bundle skills, agents, hooks, MCP, output styles; rules/settings **not** confirmed as plugin parts, so `init` copies them | 2026-11-24 | docs/plugins |
| Plugin CLI | `validate [--strict]`, `details` (projected token cost), `eval`, `tag`, `configure`, `enable`/`disable`, `init`/`new`, `install`, `update`, `prune`, `restore-set-aside`, `test`. `--plugin-dir` is a global flag (goes before `plugin`) | 2026-11-24 (2.1.331) | `claude plugin --help` |
| Effort levels | low, medium, high, xhigh, max; default medium on 5.5 models | 2026-11-24 | docs/model-config |
| Headless | `claude -p`, `--output-format stream-json`, `--max-turns`, `--max-budget-usd`, `--bare` | 2026-11-24 | docs/headless |
| Agent teams | experimental, token-heavy, **not used** | 2026-11-24 | docs/agent-teams |

## Research-based assumptions (re-test on each model generation)
- Context quality drops past about 40% usage. Compact or clear before then.
- Parallel writers underperform one sequential writer (CooperBench, about −30%). Parallelize reads and reviews only.
- LLM-generated CLAUDE.md content hurts. Keep it human-curated and minimal.
- Skills earn their place only when they beat no-skill (`claude plugin details` and evals).
