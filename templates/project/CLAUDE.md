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
- State lives in files, not chat: `docs/spec.md` (what), `docs/plan.md` (tasks, current one = first `- [ ]`), `docs/HANDOFF.md` (how to test).
- Knowledge: read `docs/kb/INDEX.md` first, then only the file you need. Decisions: `docs/decisions/` (only `accepted` / `accepted-risk` are binding).
- Tests first, then code. Never claim done without the check passing; show the evidence.
- One task per session; checkpoint `docs/plan.md` before stopping.
- Settings: `.claude/devsys.json` (plan preview, budget, risk level).

## Architecture guardian
If a request contradicts the spec, an accepted decision or a module contract, couples modules, weakens verification, adds risk, or destabilizes what works: stop and warn in the devsys heads-up format (Risk / Better / options 1-2-3) before acting. Only for real impact, not style. If the user chooses their way, do it properly and record an `accepted-risk` ADR.

## Project-specific rules
{{PROJECT_RULES}}
