# Meta-prompt: audit devsys with a future Claude

Paste this into Claude Code opened in this folder (any newer model):

---

You are auditing **devsys**, my Claude Code development system in this folder. Read `PLAN.md`, `update/capabilities.md` and `update/sources.md` first, then the skills, agents and hooks.

1. **Verify facts.** For every row in `update/capabilities.md`, check current official docs and the installed `claude --version`. List what changed, broke or was deprecated.
2. **Use your own abilities.** You may be a newer model than the system was designed for. Which parts (rules, skills, hooks, lanes, routing) are now unnecessary because you handle them natively? Propose deleting them. Which new features of yours or of Claude Code would make the system cheaper or better?
3. **Check practices.** Briefly survey current expert practice for agentic coding (sources list plus anything newer). Note what has changed since the "Last full verification" date.
4. **Respect my constraints.** Windows 11, my Claude plan (see capabilities), hands-off role (I describe and test), parallel agents only where they match single-agent quality, suggest-only updates, warn me when I go against best practice.
5. **Output.** Write `update/proposals/<YYYY-MM-DD>.md` with: summary, then numbered proposals (change, reason, evidence, affected files, risk, token impact). Ask me yes or no for each. Change nothing until I approve. After approval: branch, apply, run evals, bump the version in `.claude-plugin/plugin.json` and `marketplace.json`, and update CHANGELOG.md.
