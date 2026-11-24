---
description: Run a fresh-context adversarial review of the current changes against the spec, and optionally fix what it finds.
disable-model-invocation: true
argument-hint: "[base commit or branch] [fix]"
---

# devsys review

Args: $ARGUMENTS

1. Base = first arg if given, else the merge-base with main, else `HEAD~1`. Show `git diff --stat <base>` (one line per file).
2. Spawn `devsys:reviewer` with the base and the paths of spec, plan and decisions. Opus reviewer (agent model override) if `highRisk` is true or the diff touches a host-app adapter.
3. Show the findings as returned (do not pad them).
4. If args contain "fix": fix blocker and major findings one at a time (test first where it is a behaviour bug), run the check, commit. Otherwise ask: "Fix the blocker/major findings?".
