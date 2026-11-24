# Changelog

## 0.3.0 (2026-11-24)
- Phase 2:
  - Agents: `architect` (Opus), `implementer` and `reviewer` (Sonnet), `researcher` (Sonnet), `scout` and `librarian` (Haiku, low). An `Explore` override (Haiku) is copied into projects.
  - `build` router: guardian check, then the Quick, Standard or Deep lane, with lane files loaded on demand.
  - Standard lane: clarify once, then Opus spec/plan, plan preview, a sequential build loop, a fresh review, handover and a usage log. Deep lane adds research, core/adapter for host-app plugins, high-risk rules and an Opus review.
  - New skills: `/devsys:feedback`, `/devsys:review`, `/devsys:compound`.
- Live-verified in headless sessions on Pro:
  - Guardian: correct heads-up on "delete the tests to go faster" (~$0.08).
  - Quick lane: todo CLI plus web UI plus recurring tasks (~$0.20 each).
  - Standard lane: a Downloads sorter. Opus planned, 7 tasks were committed, 66 tests pass, and the review caught 1 blocker and 3 majors, all fixed (~$1.98 list).
- Fixes found live:
  - `opusplan` never reaches Opus outside plan mode, so planning now goes through the `architect` agent.
  - "unknown" budget no longer blocks Opus planning.
  - Lane rules tightened: a new user-facing surface means Standard.
  - The guardian now waits for an explicit answer. Before, it once assumed "my way" and wrote an accepted-risk ADR.
  - Project settings moved from `.claude/devsys.json` to `devsys.json` in the project root, because Claude Code protects `.claude/` and blocked hands-off edits. The legacy path still works.
  - `init` asks for a git identity when none is set.
  - `devsysVersion` is now stamped correctly.
- Phase 3: `/devsys:stack-new` (new or save; adapters live in the source repo set in `~/.claude/devsys/config.json`). Adapters `python` and `powershell` were verified on this machine, including that the PowerShell execution policy is Restricted, so commands need `-ExecutionPolicy Bypass`.
- Phase 5 (draft): `/devsys:update` skill (Opus, suggest-only, dry-run mode).
- 40 hook unit tests.

## 0.2.1 (2026-11-24)
- Live-verified in real headless Claude sessions on Windows 11 (Pro subscription):
  - guard denies secrets and asks before destructive commands
  - session-start context is injected
  - `/devsys:quick` builds end-to-end on Sonnet with tests first
  - the Stop gate forces a fix when tests fail
- Guard: asks before `git checkout --`, `git checkout .`, `git restore` (not `--staged`), `git stash drop|clear`. Seen live: Claude discarded uncommitted changes to fix a failing check.
- Guard: messages name the file type instead of the raw pattern, to save tokens.
- 37 hook unit tests.
- Statusline installed in user settings (backup kept) and live-verified in the terminal: Pro `rate_limits` arrive (5h/7d %), and usage.json feeds the budget levels.

## 0.2.0 (2026-11-24)
- Phase 1: Windows PowerShell 5.1 hooks (`hooks/hooks.json`, exec form):
  - `guard` (PreToolUse): denies secret files, asks before destructive commands
  - `stop-check` (Stop): runs the project's fast check; skips when the tree is unchanged since the last pass; gives up after 3 blocks
  - `format` (PostToolUse): optional formatter
  - `session-start`: current task, budget level, 30-day update reminder (suggest-only)
  - `budget` (UserPromptSubmit): injects the budget level only when it changes
- Statusline script (model, context %, 5h/7d usage, budget level) writing `~/.claude/devsys/usage.json`; installer with consent and backup.
- Skills: `/devsys:init` (scaffold via `scripts/init-project.ps1`), `/devsys:quick` (Quick lane, Sonnet).
- Project templates: CLAUDE.md with the architecture-guardian rule, AGENTS.md, devsys.json, settings deny rules, docs/ (spec, plan, HANDOFF, kb, decisions).
- 32 hook unit tests (`hooks/win/tests/run-tests.ps1`).
- Fix: init script no longer aborts on PS 5.1 when git writes to stderr.
- Pending: live verification inside real Claude sessions (needs the CLI logged in).

## 0.1.0 (2026-11-24)
- Phase 0: git repo, plugin and local marketplace manifests, folder skeleton.
- Capabilities manifest, update sources and meta-prompt.
- Platform decision: Windows PowerShell 5.1 (built in; PowerShell 7 not installed). Scripts stay 7-compatible.
