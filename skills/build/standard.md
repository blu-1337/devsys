# Standard lane

## S1. Clarify (one round, only if needed)
Ask *all* blocking questions in one message, numbered, each with a suggested default; "defaults" is a valid answer. Ask nothing you can infer from the repo or decide sensibly yourself. After this round: no more interruptions until handover (except a guardian heads-up).

## S2. Spec + plan (Opus via `devsys:architect`)
**Always** delegate to `devsys:architect` (NORMAL/unknown budget; SAVER only for Deep) with a planning brief: the request, the clarified answers, the budget level, and the formats below (copy them). Do not write the spec/plan yourself unless the budget forbids Opus. Then show the architect's preview (S3) without rewriting it.
`docs/spec.md` (<= 60 lines): Goal; Non-goals; Users and how they run it; Acceptance checks (numbered, each testable, each mapped to a test or a manual step); Constraints (stack, Windows 11, high-risk rules).
`docs/plan.md`:
- `## Contracts` first: one block per module - responsibility, public functions/CLI/API with signatures, what it must not depend on. Logic stays testable without UI or host app.
- `## Tasks`: <= 8 tasks for a small app, each a checkbox line: `- [ ] T<n> <what> | files: <...> | check: <command> | model: sonnet`. Order so each task leaves the build green. First task fills `commands.*` in `devsys.json` if they are still placeholders (verify by running).
- If the stack is new, decide it here (prefer what is already installed: check before choosing) and record a one-line ADR via the librarian.

## S3. Plan preview (planPreview: on, or deep-only and this is Deep)
Send this block verbatim inside a code fence (<= 20 lines, no prose around it except one line pointing to the spec) and wait for "go" or changes (skip if planPreview is off or the user said "no preview"):
```
PLAN: <name>                         lane: Standard · est. usage: low|med|high
Build:   <2-3 lines: what they get>
How:     <stack + architecture, 1-2 lines>
Tasks:   1. ... 2. ... (one line each)
Test it: <how they will check it works>
Assumed: <defaults you chose>
Risks:   <only if any>
→ "go", or tell me what to change
```
No fluff, <= 20 lines. After "go", suggest `/clear` only if context is above ~40%; the files carry the state.

## S4. Build loop (one task at a time, sequential)
For each `- [ ]` task in order:
1. Delegate to `devsys:implementer` with: the task line, the contract block(s) it touches, the check command. (Small tasks in an already-loaded context may be done inline on Sonnet.) Never run two writers in parallel.
2. Read its <= 20-line reply. Verify yourself: run the check command and look at the decisive lines.
3. Green -> tick the box in `docs/plan.md` (`- [x]`), commit (`feat: T<n> <what>`).
4. Blocked after the implementer's two attempts -> one escalation: `devsys:architect` (Opus, fresh context) with an escalation brief (task line, error output, contract, files). It fixes or returns a precise fix for the implementer. Still failing -> mark `- [!] T<n> blocked: <reason>` and continue with tasks that don't depend on it.
5. Above ~40% context: checkpoint plan.md, then `/compact` focused on the remaining tasks.

## S5. Review (fresh context)
Run `devsys:reviewer` with the base commit of this request. Fix blocker/major findings through S4 (one round; a second review only if a blocker was fixed). Minor findings go to HANDOFF "Known limitations" unless trivial.

## S6. Handover
Rewrite `docs/HANDOFF.md` (<= 40 lines): What it is; How to run it (exact PowerShell commands from a fresh terminal); What to test (3-7 concrete steps, with expected results); Acceptance checks with result (pass/fail + evidence); Known limitations; How to report problems ("tell me what happened, or run /devsys:feedback").
Commit. Tell the user in <= 8 lines: what was built, the run command, what to try first. Their turn: test it.

## S7. Compound (cheap, after handover)
Send `devsys:librarian` a brief (<= 10 lines) only if there is something worth keeping: surprises -> gotchas; decisions -> ADRs. Append one line to `docs/usage-log.csv` (create with header `date,lane,request,tasks,blocked,model_main,budget_level` if missing).
