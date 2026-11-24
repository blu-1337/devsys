# devsys: Claude Code development system

A reusable, token-efficient way to build scripts, applications and plugins for other software with Claude Code. You describe what you want and test the result; Claude clarifies once, shows a short plan, builds with tests first, verifies itself, gets a fresh-context review and hands over instructions for testing.

**Status:** v0.1.0, Phase 0 (skeleton). See [PLAN.md](PLAN.md) for the full design and [RESEARCH.md](RESEARCH.md) for the evidence behind it.

**Platform:** Windows 11, Windows PowerShell 5.1 (compatible with PowerShell 7). Claude Pro plan assumed.

## Install (local, before GitHub)

In Claude Code (terminal `claude`, or the app if `/plugin` is available):

```
/plugin marketplace add H:\projects\19-software-development-system
/plugin install devsys@devsys-local
```

Or from PowerShell:

```powershell
& "$env:USERPROFILE\.local\bin\claude.exe" plugin marketplace add "H:\projects\19-software-development-system"
& "$env:USERPROFILE\.local\bin\claude.exe" plugin install devsys@devsys-local
```

## Layout

| Folder | Purpose |
|--------|---------|
| `.claude-plugin/` | Plugin + local marketplace manifests |
| `skills/` | On-demand procedures (`/devsys:init`, `/devsys:build`, …), from Phase 1 |
| `agents/` | Model-pinned subagents (scout, implementer, reviewer, …), from Phase 2 |
| `hooks/win/` | PowerShell guards and checks, from Phase 1 |
| `templates/` | Project scaffolding (CLAUDE.md, settings, docs/) |
| `stacks/` | Stack adapters, generated on demand per language |
| `evals/` | Personal benchmark |
| `update/` | Capabilities manifest, update sources, self-update proposals |

## Updating the system

When reminded (or anytime), run `/devsys:update`. It only proposes changes; you approve each one. To have any future Claude audit the system, paste [update/META-PROMPT.md](update/META-PROMPT.md).
