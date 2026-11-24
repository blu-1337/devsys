---
description: Create, apply or save back a devsys stack adapter (build/test/check/format commands, rules, Windows setup for one language or toolchain). Use when a project starts on a stack that has no adapter yet, or to save lessons from a finished project back into devsys.
disable-model-invocation: true
argument-hint: "new <stack> | save [<stack>]"
---

# devsys stack-new

Args: $ARGUMENTS. Adapters live in the devsys **source repo** (not the installed plugin copy, which is replaced on update): path in `%USERPROFILE%\.claude\devsys\config.json` key `sourceRepo`. If missing, ask once for the folder of the devsys git repo and write that file. Read-only fallback for lookups: `${CLAUDE_PLUGIN_ROOT}/stacks/`.

## new <stack>
1. If `<sourceRepo>/stacks/<stack>/adapter.md` exists: apply it (step 4) and stop.
2. Research only what you don't reliably know: current recommended test runner, linter/formatter and project layout for this stack on Windows 11. Use `devsys:researcher` only for unfamiliar toolchains. Prefer tools already installed (`Get-Command`, `winget list`); never install anything without asking (give the `winget` id).
3. Verify in a scratch folder (scratchpad or `%TEMP%\devsys-stack-<stack>`): create the smallest project, one passing test and one failing test; run build, test, check and format; confirm the check fails on the failing test and passes after removing it. Record the exact commands that worked.
4. Write (or apply) the adapter, all short:
   - `adapter.md` (<= 60 lines): versions verified, commands (build/test/check/run/format with `{file}`), test framework + where tests live, layout, how to run one test.
   - `rules.md`: frontmatter `paths:` globs for the stack's files, then <= 15 lines of rules a strong model would otherwise get wrong here.
   - `win.md`: winget ids, PATH/encoding/quoting quirks seen during verification.
   Apply to the current project: fill `devsys.json` commands and stack, copy `rules.md` to `.claude/rules/<stack>.md`.
5. Commit the adapter in the source repo (`stack: add <stack> adapter`), not pushed.

## save [<stack>]
After a project: compare the project's `devsys.json` commands, `.claude/rules/<stack>.md` and `docs/kb/gotchas.md` with the adapter. Propose only lessons that are about the **stack** (not this project), as a diff. On yes: update the adapter files, add `Verified:` date, commit in the source repo (`stack: update <stack> from <project>`).
