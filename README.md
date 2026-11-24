# devsys: Claude Code development system

A reusable, token-efficient way to build scripts, applications and plugins for other software with Claude Code. You describe what you want and test the result. Claude does the rest: it clarifies once, shows a short plan, builds with tests first, verifies its own work, gets a fresh-context review, and hands over test instructions.

**Status:** v0.3.3. All phases (0–6) are built and live-verified. The repo is at https://github.com/blu-1337/devsys (private). The full design is in [PLAN.md](PLAN.md), the evidence behind it in [RESEARCH.md](RESEARCH.md), and the release history in [CHANGELOG.md](CHANGELOG.md).

**Platform:** Windows 11 with Windows PowerShell 5.1 (PowerShell 7 also works), on the Claude Pro plan.

## Install

From a local folder:
```powershell
& "$env:USERPROFILE\.local\bin\claude.exe" plugin marketplace add "H:\projects\19-software-development-system"
& "$env:USERPROFILE\.local\bin\claude.exe" plugin install devsys@devsys-local
```
From GitHub: `claude plugin marketplace add blu-1337/devsys`, then `claude plugin install devsys@devsys-local`.

For the status bar (once per machine): `/devsys:init` offers it. To install it directly:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "H:\projects\19-software-development-system\scripts\install-statusline.ps1"
```

## Use

1. Open Claude Code in an empty project folder and run `/devsys:init`.
2. Describe what you want ("build me ..."). The build router picks a lane:
   - **Quick:** small changes.
   - **Standard:** features and small apps. You see a plan first and reply "go".
   - **Deep:** large apps, plugins for other software, and high-risk work.
3. Test what you get, following `docs/HANDOFF.md`. Report problems in plain words or with `/devsys:feedback`.

| Command | What it does |
|---------|--------------|
| `/devsys:init` | Set up a project folder |
| `/devsys:build` | Build router. Usually it starts automatically |
| `/devsys:quick` | Force the Quick lane |
| `/devsys:feedback <text>` | Turn test feedback into fixes |
| `/devsys:review [base] [fix]` | Fresh-context review of the current changes |
| `/devsys:compound` | Save lessons (gotchas, decisions, rules) |
| `/devsys:stack-new new <stack>` · `save` | Create or improve a language adapter |
| `/devsys:update [dry-run]` | Check for Claude updates and propose devsys changes (suggest-only) |

**Models:** Opus plans through the `architect` agent. Sonnet builds and reviews. Haiku handles searching and bookkeeping. The status bar shows your 5-hour and 7-day usage, and devsys saves usage as it rises.

## Install on another machine
```powershell
claude plugin marketplace add blu-1337/devsys
```
```powershell
claude plugin install devsys@devsys-local
```
The repo is private, so git on that machine must be signed in to GitHub (Git Credential Manager prompts on first use). On this PC, devsys is installed from the local folder, so local changes go live after `claude plugin update devsys@devsys-local`. Push them with `git push`.

## Layout
| Folder | Purpose |
|--------|---------|
| `.claude-plugin/` | Plugin and local marketplace manifests, icon |
| `skills/` | `init`, `build` (with `standard.md` and `deep.md`), `quick`, `feedback`, `review`, `compound`, `stack-new`, `update` |
| `agents/` | `architect` (Opus), `implementer`, `reviewer`, `researcher` (Sonnet), `scout`, `librarian` (Haiku) |
| `hooks/win/` | PowerShell hooks (secret and destructive-command guard, Stop check, format, session start, budget), status bar, 41 unit tests |
| `templates/project/` | Files `/devsys:init` creates |
| `stacks/` | Language adapters: `python`, `powershell` |
| `evals/` | Behaviour suite (`claude plugin eval`), headless build-to-green runner, baselines |
| `update/` | Capabilities manifest, sources, meta-prompt, update proposals |

## Updating the system
devsys reminds you every 30 days. Run `/devsys:update` and approve each proposal. To have any future Claude audit the whole system, paste [update/META-PROMPT.md](update/META-PROMPT.md).
