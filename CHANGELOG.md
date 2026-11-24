# Changelog

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
