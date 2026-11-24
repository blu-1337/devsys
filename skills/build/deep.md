# Deep lane = Standard lane + these additions

Read `standard.md` (same folder) and follow it, with these changes:

## D1. Research before the spec (after S1)
- Up to 3 read-only helpers in parallel, only when they search different things: `devsys:scout` (Haiku) for repo facts; `devsys:researcher` (Sonnet) per unfamiliar SDK/API, which writes `docs/kb/<topic>.md`. In SAVER/unknown budget: one at a time.
- Read only their briefs and the KB files the plan needs.

## D2. Architecture (in S2)
- Tell the architect this is Deep (it plans more carefully; high effort is fine here).
- **Host-app plugin** (code that runs inside other software): split into `core` (pure logic, no host references, fully unit-tested on its own) and a thin `adapter` (host API calls only). Add `docs/kb/runbook.md`: how to build, deploy into the host, attach a debugger/logs, and roll back. Tests for core run without the host.
- **High-risk** (`highRisk: true`: money, trading, production data): simulation/paper mode is the default and the only mode built unless the user explicitly approves live; live mode needs a separate config switch plus a confirmation step; no credentials in code or repo; add replay/backtest or fixture-based tests for every decision path; acceptance checks include "cannot place a live order/write production data by default".
- One ADR per significant choice (architecture, framework, data format).
- Tasks may number up to ~15; group them in milestones that each end in a runnable state.

## D3. Review (in S5)
- Reviewer runs on Opus for high-risk or host-app work: spawn `devsys:reviewer` with the Agent tool's `model: opus` override.
- Optional on NORMAL budget: up to 3 parallel reviewers, each with one angle (correctness, security/risk, tests/acceptance). Never parallel writers.

## D4. Handover
Add to HANDOFF: deployment steps into the host app (if any), how to switch modes (high-risk: and why live is off), and a rollback.
