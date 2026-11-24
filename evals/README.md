# Evals

Personal benchmark for the system. Built in Phase 4.

- Claude Code ships a built-in runner: `claude plugin eval` (reads `evals/**/case.yaml` or `prompt.md` + `graders/*.md`, and adds a no-plugin baseline arm). Phase 4 checks it first and only builds a custom `run.ps1` if it doesn't cover what we need.
- Tasks come from real failures in your projects. Each has a deterministic check. Run only when the system, the model or an update changes.
- `baselines/`: recorded results (pass rate, tokens, time) to compare against.
