---
description: Set up a new or existing project folder for the devsys workflow (CLAUDE.md, docs/, devsys.json, checks). Use when the user starts a new project or asks to "init devsys" / "set up this project".
disable-model-invocation: false
---

# devsys init

Goal: a project folder ready for devsys in as few tokens as possible. The script does the file work; you decide the values.

## 1. Pre-check
- Target = current working directory unless the user names another.
- Git identity: if `git config user.email` is empty, add to the step-2 questions: "Name and email for git commits (stored in this repo only)?" and set them with `git config user.name/user.email` (repo-local) after scaffolding.
- If `devsys.json` already exists: say so and stop (offer to update only `devsysVersion` if older than the plugin).

## 2. Ask once (single message, with defaults)
Ask only what you can't infer from the folder (existing files reveal the stack):
1. Project name (default: folder name)
2. One-line purpose
3. Stack/language, or "decide later" (default: infer from files; if empty folder, "decide later")
4. High-risk? (money, trading, production data, credentials) default: no
Accept "defaults" as an answer.

## 3. Stack commands
- If stack is known: check `${CLAUDE_PLUGIN_ROOT}/stacks/<stack>/adapter.md`. If it exists, use its commands. Otherwise determine build / test / check (fast: typecheck or lint or quick tests) / run / format commands yourself from current docs, preferring tools already installed. Verify each by running it once where possible (install nothing without asking; on Windows suggest `winget` ids).
- `format` may contain `{file}` (replaced with the edited file path by the hook). Leave a command empty-placeholder if not applicable.
- If "decide later": keep placeholders; the first build task fills them.

## 4. Scaffold
Run (PowerShell tool):
```
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/init-project.ps1" -Target "<dir>" -Name "<name>" -Purpose "<purpose>" -Stack "<stack>" -Build "<cmd>" -Test "<cmd>" -Check "<cmd>" -Run "<cmd>" -Format "<cmd>" [-HighRisk]
```
Omit parameters you don't have (placeholders stay). Read its JSON result; report skipped files instead of overwriting them.

Then edit `CLAUDE.md`: replace `{{LAYOUT_MAP}}` with a 2-6 line map (or "TBD") and `{{PROJECT_RULES}}` with "None yet." Keep CLAUDE.md under 80 lines.

If high-risk: add to `.claude/settings.json` deny rules for live-credential files the user names, and add a "simulation/sandbox by default; live actions need explicit user approval" line to CLAUDE.md project rules.

## 5. Statusline (once per machine)
Run `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-statusline.ps1" -Check`.
If it is not the devsys statusline, ask the user: "Install the devsys status bar (model, context %, 5h/7d usage) into your user settings? It shows in the terminal CLI; the desktop app may not display it." Only on yes, run the script without `-Check` (add `-Force` only if they agree to replace an existing one).

## 6. Finish
Commit the scaffold (`chore: devsys init`) if the repo was just created or the user agrees. Report in <= 6 lines: what was created, commands set (or pending), next step ("tell me what to build").
