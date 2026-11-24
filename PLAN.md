# Claude Development System ("devsys"): Blueprint v2

> Status: **PLAN ONLY, nothing implemented yet.** v2 written 2026-11-24 on Claude Opus 5.5, after your answers and a 70+ source review.
> Evidence and source comparison: [RESEARCH.md](RESEARCH.md).

---

## 0. Your decisions (recorded)

| # | Decision |
|---|----------|
| D1 | Local git now, GitHub later (it is then installable as a plugin from GitHub). |
| D2 | **Claude Pro plan.** Usage limits are tight, so token efficiency is a hard requirement, not a nice-to-have. |
| D3 | **Stack-agnostic.** The system stays generic and adapts to a language/stack when a real project starts. |
| D4 | **Hands-off for you.** Claude builds, verifies and delivers. You test the finished software and give feedback. |
| D5 | Parallel agents **only where they match single-agent quality**. Cheap models (Haiku, low effort) for parallel work. Tokens are managed. |
| D6 | Updates are **suggest-only**. Claude reminds you, and you answer yes or no. |
| D7 | Domain projects (ATAS, trading) are **separate projects** that use this system. Nothing domain-specific lives here. |
| D8 | **Push back on me.** If I ask for something that goes against best practice or could destabilize the architecture, warn me, explain the better way, and ask me to confirm (§3b). |
| D9 | **Plan preview on by default.** Show a short, no-fluff plan before building and wait for "go". It can be switched off (§3c). |
| D10 | **Adapt to usage dynamically.** Limits aren't published, so watch usage as it builds up and scale model, effort and parallelism down as it rises (§4b). |
| D11 | **Windows 11 only for now.** PowerShell hooks and Windows paths. A macOS port is a later, separate job, so OS-specific parts are kept isolated (§2b). |

## 1. What 70+ sources agree on (the foundation)

These points recur across Anthropic's docs, the AI Engineer and Anthropic team talks, HumanLayer, Spec Kit, Kiro, Aider, Willison, Osmani, Cognition, academic benchmarks and practitioner videos:

1. **Verification is the biggest lever.** Claude must have a runnable pass/fail check: build, tests, types, a screenshot or a demo run. Tests are written *before* the code, otherwise Claude writes tests that simply confirm its own code.
2. **Context is the scarce resource.** Quality drops as the window fills, with a "dumb zone" past roughly 40%. Use one task per session, carry state in small files instead of long chats, and `/clear` between tasks.
3. **Write the plan or spec to a file before coding, but scale the ceremony to the task size.** Heavy pipelines like BMAD or Spec Kit are bloat for small work.
4. **Keep CLAUDE.md tiny and human-written.** Include only what Claude can't infer. A 2026 study found LLM-generated context files *lowered* success and raised cost by more than 20%.
5. **Hooks and deny rules give guarantees; prompts are only requests.**
6. **Use subagents for context isolation, not role-play personas.** "Frontend agent" or "QA agent" personas add tokens with no proven gain.
7. **Parallel *writers* make worse code.** CooperBench measured about 30% lower success when two agents split features. Parallel *readers* and *reviewers* work well.
8. **Skills must be earned.** Write one only for something Claude actually got wrong. In one 450-run test, 7 of 9 popular skill packs did no better than a dummy file of the same length.
9. **A fresh-context reviewer catches what the author misses.**
10. **Prune the harness with each model generation.** Old workarounds become dead weight, so re-test and delete.
11. **Measure with personal evals drawn from your real failures**, not with public benchmarks.
12. The video's specific contributions: a **knowledge base plus scout**, **small modules with contracts** where features are bolted on rather than squished in, and gradual **confidence building**.

## 2. Architecture

```
THIS REPO (devsys)  = Claude Code plugin + local marketplace, versioned with git
  ├─ skills/      on-demand procedures (most are user-invoked → zero idle token cost)
  ├─ agents/      few, model-pinned, tool-restricted
  ├─ hooks/       deterministic guards and checks (PowerShell)
  ├─ templates/   project scaffolding (CLAUDE.md, settings, docs/)
  ├─ stacks/      stack adapters, GENERATED ON DEMAND and saved back here (D3)
  ├─ evals/       personal benchmark
  └─ update/      capabilities manifest + self-update

        │  /plugin install devsys  →  /devsys:init in a new project folder
        ▼
ANY PROJECT
  CLAUDE.md (≤80 lines, index-style)     AGENTS.md → "see CLAUDE.md" (portability)
  .claude/settings.json  (permissions, hooks, statusline)
  .claude/rules/<stack>.md  (path-scoped, copied from stacks/)
  docs/
    spec.md            what we're building + acceptance checks
    plan.md            task checklist (the live state file)
    kb/INDEX.md        one line per KB doc: path · answers what · verified date
    kb/architecture.md, kb/gotchas.md, kb/runbooks/
    decisions/NNNN-*.md  short ADRs (status: accepted | superseded)
    HANDOFF.md         "how to test this" for you + known limitations
```

## 2b. Platform: Windows 11 only (D11)

- Hooks, statusline and eval runners are **PowerShell** scripts. **Decided in Phase 0: Windows PowerShell 5.1** (built in; PowerShell 7 isn't installed). Scripts stay compatible with 7.
- Windows paths and conventions: `%USERPROFILE%\.claude`, CRLF-aware formatters, `winget` for installing tools a stack needs (always asked first).
- All OS-specific code is isolated in `hooks/win/` and `stacks/*/win.md`. A future macOS port means adding `hooks/mac/` and `mac.md` files (a self-contained job for a Claude on your MacBook) without touching the workflow, skills or agents.

## 3. The workflow, built around your role (D4)

You do two things: **describe what you want** and **test what you get**. Everything between is Claude's job, with built-in checks.

### Lanes: picked automatically by the `/devsys:build` router

| Lane | Typical work | What happens | Cost |
|------|--------------|--------------|------|
| **Quick** | Script, small tool, one-file fix | Write tests → code → verify → hand over | Lowest |
| **Standard** | Feature or small app | Clarify → short spec → plan → build task by task → verify → review → hand over | Medium |
| **Deep** | Large app, plugin for other software, unfamiliar SDK, risky domain | Standard, plus a research phase, architecture with module contracts, a stronger review, and ADRs | Highest, used only when needed |

"Deep lane" just means the extra-careful path for big or unfamiliar work. You don't choose it: the router does, and it tells you in one line ("treating this as Deep because…").

### Standard and Deep lanes, step by step

1. **Clarify (one round):** Claude asks *all* blocking questions in a single batch, with suggested defaults so you can just say "defaults". After that round, no more interruptions.
2. **Research (Deep only):** a scout and researcher on cheap models gather SDK docs and repo facts into `docs/kb/`, and only a summary returns.
3. **Spec + plan (Opus):** `docs/spec.md` holds the goals, non-goals and acceptance checks. `docs/plan.md` holds module contracts first, then tasks. Each task names its files, its check command and its model. Then `/clear`, and the build starts fresh from the files.
4. **Build loop (Sonnet):** one task at a time, *tests first*, then code, then the check. The Stop hook blocks "done" while checks fail. After two failed fixes, escalate to Opus with a fresh context. If that also fails, the task is marked blocked and Claude moves on, reporting it in the handover.
5. **Review (fresh context):** a reviewer sees only the spec and the diff. It is adversarial and ignores style. Findings go back to step 4.
6. **Handover:** `docs/HANDOFF.md` covers how to run it, what to test, the acceptance checks with their results, and known limitations. **Your turn: test it.**
7. **Feedback (`/devsys:feedback`):** paste or describe what's wrong. Claude turns it into failing tests or tasks and loops back to step 4.
8. **Compound (Haiku):** gotchas, ADRs and KB updates. A stable lesson can be promoted into a rule or the stack adapter. That promotion is shown in the diff, never silent.

## 3b. Against-the-grain warnings (D8)

You direct the project without writing code, so some of your ideas may unknowingly fight the design. Claude acts as the **architecture guardian**.

**It warns when a request would:**
- contradict the spec, an accepted ADR or a module contract
- couple modules that should stay separate (squishing in instead of bolting on)
- skip or weaken verification (no tests, disabled checks, "just make it work")
- add a quick hack where a structural change is needed, or the reverse (overkill)
- conflict with the chosen stack or architecture (wrong tool, a second framework doing the same job)
- create security, data-loss or (in high-risk projects) money risk
- grow scope enough to destabilize what already works

**Format (short, always the same):**
```
⚠ Heads-up: <one line: what you asked>
Risk:   <1–2 lines: what breaks or gets worse, and when>
Better: <1–2 lines: the best-practice way to get the same result>
→ 1) Do it the better way (recommended)  2) Do it my way anyway  3) Let's discuss
```

**Rules:**
- Warn only when the impact is real (architecture, correctness, security, maintainability). No nagging about style or taste.
- If you choose "my way anyway", Claude does it **properly** and records an ADR with status `accepted-risk`, so later sessions know it was deliberate and don't warn again.
- Severity sets the bar. Low-impact concerns become a one-line note in the handover instead of a stop.

**Where it lives:**
- A 4-line rule in the project CLAUDE.md template, so it always applies.
- A check in the `build` router: each new request is compared against `spec.md`, ADRs and contracts before planning.
- The fresh-context reviewer also flags architectural drift in the finished diff.

## 3c. Plan preview (D9)

Before building in the Standard and Deep lanes, Claude shows:

```
PLAN: <name>                         lane: Standard · est. usage: low/med/high
Build:   <2–3 lines: what you'll get>
How:     <stack, architecture in 1–2 lines>
Tasks:   1. … 2. … 3. …   (≤8, one line each)
Test it: <how you'll check it works>
Assumed: <defaults Claude chose for unanswered questions>
Risks:   <only if any>
→ "go", or tell me what to change
```

- Typically 10–20 lines, with no fluff.
- The Quick lane skips the preview unless you ask for it.
- The setting lives in `.claude/devsys.json`, with `"planPreview": "on" | "off" | "deep-only"` (default `on`). You can also flip it in conversation ("no preview this time").

## 4. Model and effort routing for the Pro plan (D2)

On Pro, Opus spends your limits fastest. The approach is **Opus thinks, Sonnet types, Haiku fetches.**

| Role | Model | Effort | Notes |
|------|-------|--------|-------|
| Main session | **`opusplan`** alias | medium (default) | Opus while planning, Sonnet while executing. The best fit for "Opus for planning" on Pro. |
| Spec, plan, architecture, escalated debugging | Opus 5.5 | medium; high for Deep | Short, high-value bursts |
| Implementation, review, research | Sonnet 5.5 | medium | The workhorse |
| scout (search/explore), log and test-output summarizer, librarian (KB upkeep) | **Haiku 5.5** | low | Read-only or mechanical work |
| Formatting, linting, build checks | none (hooks) | n/a | Zero tokens |

- Every agent pins `model:` and `effort:` in its frontmatter. Unpinned subagents silently inherit Opus.
- The built-in `Explore` is overridden with a Haiku-pinned `Explore`.
- **Statusline** shows context % plus your **5-hour and 7-day usage %**. These Pro fields are confirmed in the docs. You always see the budget.
- The model mapping lives in one file (`update/capabilities.md`), so changing it when new models ship is a one-line edit.

## 4b. Dynamic usage budgeting (D10)

The exact Pro limits are unknown, so the system measures instead of guessing.

- The statusline script receives `rate_limits.five_hour.used_percentage` and `seven_day.used_percentage`. It writes them to `.claude/devsys-usage.json` each time it refreshes.
- A `UserPromptSubmit` hook reads that file and injects **one line** of budget state when the level changes. Claude adapts as follows:

| Budget level | Trigger (higher of 5h / 7d) | Behavior |
|--------------|-----------------------------|----------|
| 🟢 Normal | < 50% | Full routing from §4 |
| 🟡 Saver | 50–80% | Opus only for Deep planning; helpers at low effort; no parallel agents; shorter reviews |
| 🔴 Conserve | > 80% | Sonnet only, no subagents except the scout; finish or checkpoint the current task into `plan.md`; tell you to pause or continue later |

- The thresholds are tunable in `devsys.json`.
- A small `docs/usage-log.csv` records each session's usage per task type (date, lane, model, % used). After a few projects it shows what things really cost on your plan, and `/devsys:update` can then suggest better thresholds.
- Phase 1 first checks that these statusline fields actually appear on your account.

## 5. Parallel agents policy (D5)

The evidence is clear. Parallel helps for **reading**, hurts for **writing the same code**, and costs about 4–15× tokens.

| Work type | Mode | Model |
|-----------|------|-------|
| Codebase search, docs lookup, log triage | **Parallel OK** (max 3 on Pro) | Haiku, low |
| Mechanical uniform edits (rename across files, add tests to N files) where each is checked by tests | Parallel OK | Haiku, low |
| Multi-angle review (bugs / security / tests) of a finished diff | Parallel OK on Deep only | Sonnet, medium |
| Feature implementation, refactors, anything sharing files or decisions | **Sequential, one writer** | Sonnet |
| Truly independent modules with contracts frozen first | Parallel *allowed* (worktrees), off by default on Pro | Sonnet |
| Planning, root-cause debugging, integration | Sequential, main thread | Opus |

Haiku is **not** used as a parallel *code writer* for real features. The research shows weaker models fail at knowing when to escalate, and the fix rounds cost more than the savings. That matches your rule: if single is better, use single.

Guardrails: subagents return **evidence briefs** (≤40 lines, file:line plus command output), never dumps. After any parallel write, the code is merged one branch at a time and the full checks run after each merge.

## 6. Token-efficiency rules

1. CLAUDE.md ≤ 80 lines, written as an index of pointers. No "IMPORTANT!!" shouting.
2. Most skills set `disable-model-invocation: true`, so they cost nothing until you type them. Only the router and build skills auto-trigger.
3. Few agents (about 5), short descriptions. No persona zoo.
4. KB retrieval works as INDEX.md → grep → read only the needed file. No vector DB and no default MCP servers. A docs MCP (for example Context7) is added only for third-party library APIs, per project.
5. One task per session, `/clear` between tasks, and `/compact <focus>` triggered by Claude before it hits the dumb zone.
6. Hooks print only failures, and test output is summarized by Haiku before it reaches the main thread.
7. Stable files at the top of context, so the prompt cache gets hits. Don't leave sessions idle beyond the cache window.
8. Specific prompts: name files and functions.
9. `/usage` review is part of the monthly update check.

## 7. Stack adapters: generic now, specific on demand (D3)

- `stacks/` starts **empty**, apart from a README and an adapter template.
- When `/devsys:init` runs in a new project, Claude detects or asks the stack, then:
  - if an adapter exists, it copies it in
  - if not, it **generates one**: build, test, lint and format commands, a test framework choice, path-scoped rules, and a Stop-hook check command. Generation uses current docs, verified by actually running the commands once.
- After the project, the adapter, improved by real lessons, is **saved back** to `stacks/`. The system gets better with every language you use and stays generic for the ones you don't.
- A special profile, **"host-app plugin"** (for plugins inside other software such as trading platforms, DAWs or IDEs), adds three things: an SDK research step into the KB, a build-and-deploy runbook, and a **core logic / thin adapter** architecture, so logic is testable outside the host app.
- A **"high-risk" flag** (money, trading, production data) adds deny rules (no live credentials, no live orders, simulation by default) and mandatory replay or backtest checks.

## 8. Personal evals

- `evals/tasks/`: start with 8–10 small tasks with deterministic checks. Grow to 20–30, taken from **real failures** in your projects. Include "must not change X" tasks.
- **Found in Phase 0:** Claude Code has a built-in `claude plugin eval` runner (it includes a no-plugin baseline) and `claude plugin details` (projected token cost). Phase 4 uses these first.
- Fallback: `evals/run.ps1` runs each task headless (`claude -p`, fresh worktree, `--max-turns`, stream-json) and logs pass/fail, tokens, time and model to CSV.
- Run each task k=2 (to save Pro quota). Treat differences under about 10 points as noise.
- Run evals **only when something changes** (system edit, new model, update applied), never on a schedule. Each run costs quota.

## 9. Self-update (D6: suggest-only)

- `update/capabilities.md` lists every assumption (models, fields, hook events, limits), each with a "verified on" date.
- `update/sources.md` lists the Claude Code changelog, the docs index, the Anthropic engineering blog and selected community sources.
- A **SessionStart hook** checks `update/last-check.txt`. If it is older than 30 days, it shows one line: *"devsys: last update check was N days ago. Run /devsys:update?"* Nothing else happens.
- `/devsys:update` (Opus, user-invoked only) works in four steps:
  1. Researches changes since the last check with cheap subagents.
  2. Writes `update/proposals/<date>.md`, with new features to adopt, deprecated practices to drop, and **harness pruning** (rules or skills the new model no longer needs).
  3. Asks you yes or no for each item.
  4. Applies the approved items on a branch, runs evals, bumps the version and the CHANGELOG.
- `update/META-PROMPT.md` is a paste-able prompt for any future Claude: *audit this system against current best practices and your own abilities, and propose changes*.

## 10. Planned contents (small on purpose)

**Skills:** `init` (auto) · `build` (auto, the router) · `feedback` · `review` · `compound` · `kb` (add or refresh knowledge) · `bench` · `update` · `stack-new`

**Agents:** `scout` (Haiku low, read-only) · `researcher` (Sonnet, web plus docs, writes KB) · `implementer` (Sonnet) · `reviewer` (Sonnet; Opus on Deep; read-only, fresh) · `librarian` (Haiku low) · `Explore` override (Haiku)

**Hooks:**
- `guard-secrets` (PreToolUse deny)
- `guard-destructive` (rm -rf, force-push, etc.)
- `check-on-stop` (Stop: stack check command, exit 2 on failure)
- `format-on-edit` (PostToolUse)
- `session-start` (shows the current plan task, plus the update reminder)
- `budget` (UserPromptSubmit: injects the usage level from §4b when it changes)

**Project settings:** `.claude/devsys.json` holds `planPreview`, the budget thresholds, `highRisk` and the stack.

**Settings template:** permissions allowlist for stack commands, deny list, statusline with context and usage %.

## 11. Rollout (when you say "go")

| Phase | Deliverable | Done when |
|-------|-------------|-----------|
| 0 | `git init`, plugin + marketplace skeleton, capabilities.md | `/plugin install` works from this folder |
| 1 | Verify that PowerShell hooks fire on Windows 11 and that statusline usage fields appear. Then templates, `init`, hooks, statusline + budget, Quick lane | Hooks block and pass correctly; the budget level changes in a test; a scratch script is built end-to-end in the Quick lane |
| 2 | Agents, `build` router with Standard and Deep lanes, plan preview, architecture guardian, `feedback`, `review`, `compound` | A small sample app is built hands-off; one deliberately bad request triggers a correct warning; you test the app, and the feedback loop works |
| 3 | `stack-new` + adapter save-back | Two different stacks are generated and saved |
| 4 | Evals + baseline | Baseline CSV recorded |
| 5 | Update mechanism + META-PROMPT | One dry-run proposal is produced |
| 6 | Push to GitHub, install from GitHub in a fresh project | Works from a clean machine path |

Then the ATAS project starts as its own project, using `/devsys:init` with the host-app plugin and high-risk profiles.

## 12. Risks

- **Over-engineering.** Default to the Quick lane. Every addition must beat "no addition" in evals.
- **Pro limits hit mid-task.** `plan.md` is the resumable state file, so work resumes in a new session or window without losing progress.
- **Hands-off means less human review.** This is compensated by tests-first, the Stop-hook gate, a fresh reviewer and your acceptance testing. Trust grows as evals prove out.
- **Claude Code changes.** Capabilities manifest, update skill and evals.
- **The guardian becomes a nag.** It only warns on real impact, and `accepted-risk` ADRs stop repeat warnings. An eval task checks that harmless requests trigger no warning.
- **Usage data unavailable or delayed.** If the statusline fields are missing, fall back to Sonnet-default routing and manual `/usage` checks.
