---
description: Check for Claude / Claude Code changes and new best practices since the last check, and propose devsys updates (suggest-only, yes/no per item).
disable-model-invocation: true
argument-hint: "[dry-run]"
model: opus
effort: medium
---

# devsys update

Args: $ARGUMENTS ("dry-run" = write the proposal only; never apply).
Work in the devsys **source repo**: `sourceRepo` from `%USERPROFILE%\.claude\devsys\config.json` (if missing, ask once for the folder and save it). Never edit the installed plugin copy.

## 1. Baseline (cheap, local)
- `update/capabilities.md` (assumptions + "Last full verification" date = D), `update/sources.md`, `CHANGELOG.md` top entry.
- Local facts: `claude --version` (CLI at `%USERPROFILE%\.local\bin\claude.exe` if not on PATH), `claude plugin --help`, `claude plugin details devsys` (token cost), current model names from your own system context.
- `docs/usage-log.csv` files in recent projects if the user names them (real costs per lane).

## 2. Research (parallel, read-only, max 3; one at a time if budget is SAVER/unknown)
Spawn `devsys:researcher`-style briefs but tell each to **reply only, not write files**, <= 30 lines with URLs:
1. Official changelog + docs since D: new/changed/deprecated features that touch any row of capabilities.md (hooks, skills, agents, plugins, statusline, models, effort, eval).
2. Models: new Claude models/aliases, pricing or plan-limit changes relevant to Pro routing.
3. Practice: what changed in expert agentic-coding practice since D (community list in sources.md; facts only from official sources).

## 3. Proposal
Write `update/proposals/<YYYY-MM-DD>.md`:
- Summary (<= 5 lines): what changed since D.
- Numbered proposals, each: **Change** | **Why** (evidence + URL) | **Files** | **Risk** | **Token impact** | **Kind**: adopt / fix (a capability row is now wrong) / prune (harness the current model no longer needs - ask yourself honestly which rules/skills you would follow anyway).
- Max ~10, highest value first. Nothing speculative; "no change needed" is a valid result.

## 4. Decide (skip in dry-run)
Ask yes/no per proposal (one question batch; AskUserQuestion with multiSelect where available). Apply nothing unasked.

## 5. Apply approved items
- Branch `update/<date>`; apply; run `powershell -NoProfile -ExecutionPolicy Bypass -File hooks/win/tests/run-tests.ps1` and `claude plugin validate .`.
- If skills/agents/routing changed: offer an eval run (`claude plugin eval . --runs 1`; it spends quota, so ask) and compare with `evals/baselines/`.
- Update capabilities.md rows + "Last full verification", bump version in `.claude-plugin/plugin.json` and `marketplace.json`, CHANGELOG entry, commit, and tell the user how to merge (`git merge update/<date>`) and reinstall/update the plugin.

## 6. Always (also in dry-run)
Write today's date (yyyy-MM-dd) to `%USERPROFILE%\.claude\devsys\last-check.txt` so the 30-day reminder resets. Report in <= 8 lines: proposal file, counts by kind, what was applied.
