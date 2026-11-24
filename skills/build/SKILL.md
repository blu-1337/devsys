---
description: devsys build router - turns "build me X / add feature Y / make a plugin for Z" into working, tested software. Picks the Quick, Standard or Deep lane, checks the request against the project's design first, shows a short plan preview, then builds hands-off. Use whenever the user asks to build, create, implement or add something non-trivial in a devsys project.
---

# devsys build (router)

The user describes and tests; you do everything in between. Keep the main thread lean: state lives in `docs/`, heavy reading goes to subagents.

## 0. Load state (cheap)
- `devsys.json` (planPreview, highRisk, commands, stack). If missing: offer `/devsys:init` first (one line) and stop.
- If `docs/plan.md` has unchecked tasks for *this* request, resume at the first `- [ ]` (skip to the lane's build loop).
- Budget line from session context (NORMAL / SAVER / CONSERVE / unknown). CONSERVE: Sonnet only, no subagents except `devsys:scout`; finish or checkpoint, then tell the user to continue later. SAVER: no parallel agents, helpers at low effort, `devsys:architect` (Opus) only for Deep. NORMAL or unknown: `devsys:architect` plans every Standard/Deep build (a short Opus burst is worth it); unknown also means no parallel agents.

## 1. Guardian check (before any planning)
Compare the request with `docs/spec.md`, accepted ADRs (`docs/decisions/`, status `accepted`), module contracts in `docs/plan.md`, and `CLAUDE.md` rules. Skip ADRs with status `accepted-risk` on the same topic (the user already chose).
Warn only for real impact: contradicts spec/ADR/contract; couples modules; skips or weakens verification; hack where structure is needed (or overkill); second tool doing the same job; security, data-loss or (high-risk) money risk; scope that destabilizes what works. Style and taste never qualify.
If it qualifies: change nothing, send exactly this, and end your turn (never assume an answer, even in non-interactive runs):
```
⚠ Heads-up: <what was asked, one line>
Risk:   <what breaks or gets worse, and when>
Better: <the best-practice way to get the same result>
→ 1) Do it the better way (recommended)  2) Do it my way anyway  3) Let's discuss
```
Only on an explicit 2) from the user: build it properly their way and record an ADR with status `accepted-risk` (via `devsys:librarian`). Low-impact concerns: one line in the handover instead of a stop.

## 2. Pick the lane (say it in one line: "Lane: Standard - because ...")
- **Quick**: a change to existing behaviour or a small standalone script; touches <= 2 source files; no new user-facing surface (UI, server, command group, file format, external API) -> invoke the `devsys:quick` skill and stop here.
- **Standard**: a feature or small app, or anything adding a new user-facing surface or module; known stack and APIs.
- **Deep**: large app, several modules, plugin inside other software (host-app), unfamiliar SDK/API, or `highRisk: true`.
The user can force a lane ("lane: deep", "quick is fine"). Between Standard and Deep, take the cheaper one; escalate if it turns out bigger.

## 3. Run the lane
Read only the file you need, then follow it:
- Standard: `${CLAUDE_PLUGIN_ROOT}/skills/build/standard.md`
- Deep: `${CLAUDE_PLUGIN_ROOT}/skills/build/deep.md` (it extends standard.md)

## Always
- Windows 11 + PowerShell for every command shown to the user.
- Never read/write secrets; high-risk projects: simulation/sandbox only, no live credentials or orders without explicit user approval.
- Evidence over claims: never say "done" without the check output.
