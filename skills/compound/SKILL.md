---
description: Capture lessons from the work just done - gotchas, decisions (ADRs), KB entries, and promotion of stable lessons into project rules or a stack adapter.
disable-model-invocation: true
argument-hint: "[what to remember]"
---

# devsys compound

Input: $ARGUMENTS (if empty, review this session's surprises, failed attempts and decisions).

1. Write a brief (<= 12 lines) of facts worth keeping. Drop anything the code or git history already shows, and anything generic that any model knows.
2. Send it to `devsys:librarian` (gotchas, ADRs, INDEX).
3. **Promotion** (only for lessons that held across 2+ tasks): propose a one-line rule for `CLAUDE.md` "Project-specific rules" or `.claude/rules/<area>.md` (path-scoped), or for the stack adapter (`stacks/<stack>/rules.md` in the devsys plugin repo, via `/devsys:stack-new save`). Show the exact line and ask yes/no; never promote silently. Keep CLAUDE.md under 80 lines.
4. Report the files touched in <= 5 lines.
