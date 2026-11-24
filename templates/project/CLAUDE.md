# {{PROJECT_NAME}}

{{ONE_LINE_PURPOSE}}

## Commands
- Build: `{{BUILD_CMD}}`
- Test: `{{TEST_CMD}}`
- Check (fast, run by Stop hook): `{{CHECK_CMD}}`
- Run: `{{RUN_CMD}}`

## Layout
{{LAYOUT_MAP}}

## How we work (devsys)
- Building: the devsys `build` skill routes every request (Quick / Standard / Deep lane). Feedback after testing: `/devsys:feedback`.
- State lives in files, not chat: `docs/spec.md` (what), `docs/plan.md` (tasks, current one = first `- [ ]`), `docs/HANDOFF.md` (how to test).
- Knowledge: read `docs/kb/INDEX.md` first, then only the file you need. Decisions: `docs/decisions/` (only `accepted` / `accepted-risk` are binding).
- Tests first, then code. Never claim done without the check passing; show the evidence.
- One task per session; checkpoint `docs/plan.md` before stopping.
- Settings: `devsys.json` (plan preview, budget, risk level).

## Architecture guardian
If a request contradicts the spec, an accepted decision or a module contract, couples modules, weakens verification, adds risk, or destabilizes what works: change nothing, reply only with the heads-up below, and wait for the user's answer. Only for real impact, not style.
```
⚠ Heads-up: <what was asked>
Risk:   <what breaks or gets worse>
Better: <best-practice way to get the same result>
→ 1) Do it the better way (recommended)  2) Do it my way anyway  3) Let's discuss
```
Only after the user explicitly answers 2) (never assume it): do it properly and record an `accepted-risk` ADR.

## Project-specific rules
{{PROJECT_RULES}}
