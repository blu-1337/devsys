---
description: Turn the user's test feedback (bugs, wrong behaviour, change requests) into failing tests or plan tasks, fix them, and hand over again.
disable-model-invocation: true
argument-hint: "<what happened / what you want changed>"
---

# devsys feedback

Feedback: $ARGUMENTS

1. **Understand:** restate each point in one line as observed vs expected. If a point is ambiguous in a way that changes the fix, ask once (all questions together, with defaults). Read `docs/HANDOFF.md`, `docs/spec.md` and the relevant plan section only.
2. **Classify each point:**
   - bug (spec says X, app does Y) -> reproduce it with a failing test first (or a scripted repro if UI-only).
   - change request (spec didn't cover it / user changed mind) -> run the guardian check from the `build` skill (heads-up only for real impact), update `docs/spec.md` acceptance checks.
   - environment/usage problem (wrong command, missing install) -> fix HANDOFF instructions, no code change.
3. **Plan:** append tasks to `docs/plan.md` under `## Feedback <date>` as `- [ ] F<n> ... | files | check`.
4. **Fix:** run the build loop and the review exactly as in `${CLAUDE_PLUGIN_ROOT}/skills/build/standard.md` (S4-S6). Larger new features: switch to the `build` router instead.
5. **Compound:** if the bug was something the tests should have caught, tell the librarian to add a gotcha, and note "eval candidate" in it (real failures become devsys evals).
6. Report in <= 8 lines: each point -> fixed (with evidence) | changed | needs your input. Then: "please re-test: <steps>".
