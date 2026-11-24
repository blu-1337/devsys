# Stack adapters

Adapters are made on demand: `/devsys:stack-new new <stack>` generates one the first time a project uses a stack (commands verified by running them), and `/devsys:stack-new save` brings stack lessons back here after a project.

Available: `python`, `powershell`. Planned when first needed: `dotnet` (C#; needs the .NET SDK - only the runtime is installed on this machine as of 2026-11-24).

Each adapter is a folder `stacks/<stack>/` with:
- `adapter.md`: build / test / lint / format commands, test framework, project layout conventions
- `rules.md`: path-scoped rule copied to the project's `.claude/rules/` (with `paths:` frontmatter)
- `win.md`: Windows-specific install and setup notes (`winget` ids, PATH quirks)
- `check.ps1` (optional): the fast check run by the Stop hook
