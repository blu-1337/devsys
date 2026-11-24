---
description: devsys Quick lane - build a small script, tool or single-file fix end-to-end with tests first and verified evidence. Use for small, well-defined tasks (one file or a few, obvious approach); not for multi-module features.
model: sonnet
effort: medium
---

# devsys Quick lane

For small work. No spec or plan files, no subagents unless a search would otherwise flood context (then one `Explore`/scout call).

## Steps
1. **Frame (1-3 lines to the user):** what you'll build, where, and any assumption. Ask only if something blocking is truly unknown (one question batch, with defaults). If the request goes against best practice or the project's design, use the devsys heads-up format from CLAUDE.md before proceeding.
2. **Test first:** write the smallest test that proves the behaviour, using the project's test command from `.claude/devsys.json` (`commands.test`). If no framework exists, create a minimal self-checking test script (for PowerShell: Pester if available - check with `Get-Module -ListAvailable Pester`; else a plain `tests/*.Tests.ps1` that throws on failure). Run it and confirm it fails for the right reason.
3. **Implement** the minimum to pass. Follow existing project conventions.
4. **Verify:** run the test and the check command. Paste the decisive output lines (not whole logs). Fix and re-run until green; after two failed fix attempts, stop and report what's wrong rather than guessing further.
5. **Hand over (<= 8 lines):** what was built, how to run it (exact PowerShell command), what you verified (evidence), any limitation. If the project uses `docs/HANDOFF.md`, update it.
6. **Compound (only if something surprised you):** add one entry to `docs/kb/gotchas.md`.

## Rules
- Windows 11 + PowerShell syntax for all commands you give the user.
- If `commands.check` / `commands.test` are placeholders and the stack is now clear, fill them in `.claude/devsys.json` (verified by running) so the Stop hook can guard future work.
- Don't widen scope. If the task turns out bigger than Quick, say so and suggest the Standard lane.
