# Stack adapters

Empty on purpose. `/devsys:init` generates an adapter the first time a project uses a stack, verifies its commands by running them, and saves the improved adapter back here after the project.

Each adapter is a folder `stacks/<stack>/` with:
- `adapter.md`: build / test / lint / format commands, test framework, project layout conventions
- `rules.md`: path-scoped rule copied to the project's `.claude/rules/` (with `paths:` frontmatter)
- `win.md`: Windows-specific install and setup notes (`winget` ids, PATH quirks)
- `check.ps1` (optional): the fast check run by the Stop hook
