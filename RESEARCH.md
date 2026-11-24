# Research notes (2026-11-24)

## A. Video: https://youtu.be/KK-j8JQzqMQ

Speaker: a software engineer with about 15 years' experience (12 at ARM, then director of AI). What matters for this system:

| Point in video | How the plan uses it |
|----------------|----------------------|
| **Context rot.** Big projects overwhelm the model, small changes start breaking other parts. | P1, P2: small contexts, phase files, `/clear` |
| **Targeted, focused changes** plus a lot of context from a **knowledge base** (tickets, meetings, past agent findings) | P4: `docs/kb/`, librarian keeps it current |
| **Scout agent** fetches only the knowledge a task needs | `scout` agent (Haiku) |
| **Small services with simple contracts.** Each agent owns one part, and agents don't touch each other's code. | P3: contracts first, one owner module per task, `guard-scope` hook |
| An LLM takes the shortest path ("put something in the middle") and calls it good once tests pass | Fresh-context adversarial reviewer, spec-based acceptance checks |
| Pipeline per epic: browser testing, kick back errors, iterate until shippable | `build` loop: implement → verify → review → fix |
| **Confidence building.** Start by reading all output, then trust the pipeline once proven. | P8, rollout phases |
| Plan the big picture first. Features get **bolted on, not squished in**. If it doesn't fit, go back to the design. | Spec/plan phases, ADRs |
| Learn the primitives: prompts, context, skills, tools, MCP | The system uses all of them deliberately |
| **Personal benchmarks** beat public leaderboards | §8 evals |
| Prefers open-source harnesses over Claude Code (lock-in concern) | Noted. You chose Claude-first. Hedge: P9 portable markdown plus `AGENTS.md`. |

What the video does *not* give: concrete file layouts, configs or model routing. Those come from the sources below.

## B. Official Anthropic guidance (verified against docs today)

- CLAUDE.md under 200 lines, loaded every session. Path-specific guidance goes in `.claude/rules/*.md` with `paths:` globs, which load only when matching files are touched.
- Skills: only name and description are always in context. The body loads on use. Keep SKILL.md under 500 lines. Fields: `description`, `allowed-tools`, `model`, `effort`, `context: fork`, `disable-model-invocation`, `paths`.
- Subagents: `model` (haiku/sonnet/opus/inherit/ID), `effort`, `tools`/`disallowedTools`, `skills`, `memory`, `isolation: worktree`, `maxTurns`, `omitClaudeMd`. Without `model:` they inherit the parent model (cost leak).
- Hooks: PreToolUse is the only true gate (exit 2 blocks). Stop with exit 2 is a verification gate. SessionStart injects context. PreCompact steers summaries.
- Rule of thumb: "every time X" goes in a hook, "never X" in a deny rule or hook, a procedure in a skill, an API-only rule in a `paths:` rule.
- Workflow advice: give Claude a runnable pass/fail check, interview first and write SPEC.md, then a fresh session. Stop after two failed corrections and `/clear`. Use `/code-review` and `/verify`. For unattended runs, use `--max-turns` and `--max-budget-usd`.
- Plugins plus marketplaces are the supported way to share a personal system across projects.
- Model aliases: `opus`, `sonnet`, `haiku`, `opusplan`. Effort: low/medium/high/xhigh/max (default medium on 5.5 models).
- Agent teams: experimental and token-heavy, so not part of the default design.

## C. Community practice

- **Research → Plan → Implement plus frequent intentional compaction** (HumanLayer / Dex Horthy): keep context at ~40–60% and compact into structured artifacts.
- **Spec-driven development** (GitHub Spec Kit: Constitution → Specify → Plan → Tasks → Implement). Thoughtworks warns that bloated specs hurt, so keep them lean, with human review.
- **Model routing:** reported savings of 30–50%. Haiku for search, Sonnet for code, Opus for hard reasoning.
- **Learning loops:** a learnings file plus a wrap-up skill, then promotion of stable lessons into rules (Warp, MindStudio, compound-agent). Adversarial reviewers: false positives are cheap.
- **Gap in the community:** few people measure their setups. Our `evals/` fills that gap.

## D. ATAS

- C# class library referencing `ATAS.Indicators.dll` from the install folder. Override the Indicator class. Strategies are also C#.
- Community example repo: alpha-vector-trade/atas-indicators (install paths, project setup).
- Unconfirmed: multi-timeframe access from custom indicators. Research this in phase 5.

## Sources

- [Video transcript](https://youtu.be/KK-j8JQzqMQ)
- [Anthropic: Steering Claude Code](https://claude.com/resources/articles/steering-claude-code-skills-hooks-rules-subagents-and-more)
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- [Subagents](https://code.claude.com/docs/en/sub-agents.md) · [Skills](https://code.claude.com/docs/en/skills.md) · [Memory/rules](https://code.claude.com/docs/en/memory.md) · [Hooks](https://code.claude.com/docs/en/hooks.md) · [Plugins](https://code.claude.com/docs/en/plugins/overview.md) · [Model config](https://code.claude.com/docs/en/model-config.md) · [Agent teams](https://code.claude.com/docs/en/agent-teams.md)
- [HumanLayer: Advanced Context Engineering](https://www.humanlayer.com/blog/advanced-context-engineering) · [Pragmatic Engineer w/ Dex Horthy](https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy)
- [Spec-driven development (Microsoft Learn / Spec Kit)](https://learn.microsoft.com/en-us/training/modules/spec-driven-development-github-spec-kit-enterprise-developers/2-review-spec-driven-development-approach)
- [Model routing for subagents](https://weihaoqu.github.io/learnAIDoc/wiki/claude-code-route-to-cheaper-models/) · [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) · [alexop.dev guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [Warp self-improving agents](https://claude.com/es/resources/articles/how-warp-builds-self-improving-agents-on-claude) · [Learnings loop](https://www.mindstudio.ai/blog/how-to-build-learnings-loop-claude-code-skills)
- [ATAS: custom indicators & bots](https://help.atas.net/en/support/solutions/articles/72000649737-creating-custom-indicators-and-trading-bots-in-atas) · [ATAS developing](https://atas.net/developing/) · [atas-indicators repo](https://github.com/alpha-vector-trade/atas-indicators)

---

# Round 2: broad review (2026-11-24), 70+ sources

Four parallel research passes (Sonnet), plus a docs check of the Pro plan. Evidence ratings: **H** = official docs or peer-reviewed, **M** = practitioner with production experience, **L** = anecdote or marketing.

## E. Methodology frameworks compared

| Framework | Workflow | Verdict for devsys |
|-----------|----------|--------------------|
| [GitHub Spec Kit](https://github.com/github/spec-kit) | constitution → specify → plan → tasks → implement | Steal the gates; too heavy for small work |
| [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) | Persona agents (PM, architect, dev, QA) | Skip: persona and token bloat |
| [Agent OS](https://buildermethods.com/agent-os) | Standards files + spec → tasks | Steal standards → stack adapters |
| [SuperClaude](https://github.com/SuperClaude-Org/SuperClaude_Framework) | Many commands and personas | Skip: always-loaded bloat |
| [claude-flow](https://github.com/ruvnet/claude-flow) | Swarms | Skip: token multiplier, weak evidence |
| [Kiro specs](https://kiro.dev/docs/specs/) | requirements → design → tasks, waves | Steal the 3-file artifact idea |
| [HumanLayer ACE-FCA](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents) / [12-factor agents](https://github.com/humanlayer/12-factor-agents) | Research → Plan → Implement, compaction, <40% context | **Core of devsys** |
| [Aider repo map](https://aider.chat/docs/repomap.html) / [conventions](https://aider.chat/docs/usage/conventions.html) | Token-budgeted map, architect/editor split | Steal the architect/editor split (= Opus/Sonnet) |
| [Cline memory bank](https://docs.cline.bot/prompting/cline-memory-bank) | Re-read memory files each session | Partial: pull on demand instead |
| [AGENTS.md](https://agents.md) | One small cross-tool file | Adopt as a pointer |
| [Anthropic: Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) | Simplest thing first | **Principle** |
| [Simon Willison: vibe engineering](https://simonwillison.net/2025/Oct/7/vibe-engineering/) | Tests, plans, small steps, sandboxes | Principle |
| [Harper Reed workflow](https://harper.blog/2025/02/16/my-llm-codegen-workflow-atm/) | Q&A → spec → prompt plan → TDD | Steal one-round clarification |
| [Addy Osmani workflow](https://addyo.substack.com/p/my-llm-coding-workflow-going-into) | spec, small chunks, second-model review | Principle |
| [Kent Beck: augmented coding](https://tidyfirst.substack.com/) | TDD, watch for test-cheating | Tests-first rule |
| [obra/superpowers](https://github.com/obra/superpowers) | brainstorm → worktree → plan → subagent per task | Steal discipline; skip mandatory subagent per task |
| [Every: compound engineering](https://every.to/p/compound-engineering) | plan → work → review → compound | Steal the compound step |

## F. Single vs. parallel agents

| Source | Finding | Ev. |
|--------|---------|-----|
| [CooperBench (arXiv 2601.13295)](https://arxiv.org/abs/2601.13295) | Two agents splitting features scored about 30% lower than one agent | H |
| [MAST (arXiv 2503.13657)](https://arxiv.org/pdf/2503.13657) | 14 multi-agent failure modes; gains are often minimal | H |
| [CAID (arXiv 2603.21489)](https://arxiv.org/pdf/2603.21489) | Parallel patches pass alone, then break after merge | M |
| [Agyn (arXiv 2602.01465)](https://arxiv.org/pdf/2602.01465v2) | Sequential role pipeline beats single agent on SWE-bench | M |
| [arXiv 2511.00872](https://arxiv.org/html/2511.00872v1) | Multi-agent cost is dominated by planning and reflection | M |
| [Cognition: Don't build multi-agents](https://cognition.ai/blog/dont-build-multi-agents) | Parallel writers diverge on implicit decisions | M |
| [Cognition: multi-agents working (2026)](https://cognition.com/blog/multi-agents-working) | Read-only subagents and a fresh reviewer work; weak models fail at escalation | M |
| [Anthropic multi-agent research](https://www.anthropic.com/engineering/multi-agent-research-system) | +90% on research tasks, but about 15× tokens | M-H |
| [Claude Code agent teams](https://code.claude.com/docs/en/agent-teams) | Good for review, research and independent modules; token-heavy | H |
| [Willison: parallel agents](https://simonwillison.net/2025/Oct/5/parallel-coding-agents/) | Review becomes the bottleneck | M |
| [incident.io worktrees](https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees) | 4–5 agents on separate features | L-M |
| [trigger.dev](https://trigger.dev/blog/parallel-agents-gitbutler) | Worktree environment overhead | L-M |
| [LangChain multi-agent](https://www.langchain.com/blog/how-and-when-to-build-multi-agent-systems) | Read-heavy systems are easy, write-heavy are hard | M |
| [Opus orchestrator experiment](https://dev.to/shimo4228/i-tried-an-opus-orchestrator-and-killed-it-the-roi-of-multi-agent-systems-1f7g) | +6–8% quality at high cost | L |
| [Haiku cost share](https://dev.to/constmirin/36-of-your-claude-code-subagents-are-running-on-haiku-16f6) | 36% of calls, 2% of spend | L |
| [Quesma multi-model](https://quesma.com/blog/multi-model-claude-code-refusal-terminal-bench/) | Model routing can backfire | L-M |

**Conclusion → PLAN §5:** parallelize reads and reviews; keep one writer for shared code.

## G. Knowledge base, memory, evals

| Source | Takeaway | Ev. |
|--------|----------|-----|
| [Anthropic: context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | Just-in-time loading, notes outside context, condensed subagent returns | H |
| [Manus: context engineering](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) | Stable prefix for cache hits; file system as memory | M-H |
| [Anthropic: demystifying evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) | 20–50 tasks from real failures, deterministic graders, pass^k | H |
| [Evaluating AGENTS.md (arXiv 2602.11988)](https://arxiv.org/abs/2602.11988) | LLM-generated context files lowered success and raised cost by more than 20% | M-H |
| [Claude Code memory docs](https://code.claude.com/docs/en/memory) | CLAUDE.md, rules, auto memory | H |
| [Claude Code headless](https://code.claude.com/docs/en/headless) | `claude -p`, stream-json for eval runs | H |
| [Aider repo map blog](https://aider.chat/2023/10/22/repomap.html) | ~1k-token symbol map | M |
| [Serena](https://github.com/oraios/serena) | LSP symbol retrieval; unproven savings | L-M |
| [Agentic search vs. RAG](https://smartscope.blog/en/ai-development/practices/rag-debate-agentic-search-code-exploration/) | Claude Code uses grep, not vectors | L-M |
| [O'Reilly: ADRs for agents](https://oreilly.com/radar/coding-agents-love-decision-records/) | ADRs in the repo; stale ADRs mislead | M |
| [llms.txt](https://llmstxt.org/) | LLM-readable doc index | M |
| [Context7](https://github.com/upstash/context7) | Version-specific library docs via MCP | M |
| [Compound engineering plugin](https://github.com/EveryInc/compound-engineering-plugin) | Write each solved problem back as knowledge | L-M |
| [Hamel: evals FAQ](https://hamel.dev/blog/posts/evals-faq/) / [field guide](https://hamel.dev/blog/posts/field-guide/) | Error analysis first; read traces | M-H |

## H. Expert videos (8 transcripts read, 16 total)

| Video | Key practice |
|-------|--------------|
| [Lydia Hallie: Rethinking Claude Code best practices](https://www.youtube.com/watch?v=vlfCjWuv4es) | Model steers; deny rules, hooks and CI enforce; trim CLAUDE.md |
| [Dex Horthy: No Vibes Allowed](https://www.youtube.com/watch?v=rmvDxxNubIg) | RPI and compaction; stay under 40% |
| [Dex Horthy: Why agents make codebases worse](https://www.youtube.com/watch?v=vKT59uoByXc) | Expect 2–4×; fewer parallel tasks |
| [How the Claude Code team uses Claude Code](https://www.youtube.com/watch?v=S-sYlFiGFv8) | Goals not tasks; delete harness as models improve |
| [Boris Cherny: delete your CLAUDE.md (analysis)](https://www.youtube.com/watch?v=HWEy91kb-8w) | Task + guardrails + exit criteria |
| [John Kim: 50 tips](https://www.youtube.com/watch?v=mZzhfPle9QU) | Plan first, validation loop, few MCPs |
| [Simon Scrapes: Top 1%](https://www.youtube.com/watch?v=J9NQTYUP6k0) | Skills only for observed failures (450-run test) |
| [Coding Sloth: 1000+ hours](https://www.youtube.com/watch?v=YAsxyoTWFDA) | $20-plan habits: one session per task, Opus plans and Sonnet builds |
| [Cal Rueb: best practices](https://www.youtube.com/watch?v=gv0WHhKelSE) · [Mastering Claude Code](https://www.youtube.com/watch?v=6eBSHbLKuN0) · [Boris Cherny: evolution](https://www.youtube.com/watch?v=Lue8K2jqfKk) · [Cat Wu & Boris (Every)](https://www.youtube.com/watch?v=IDSAMqip6ms) · [Pragmatic Engineer w/ Horthy](https://www.youtube.com/watch?v=Usufn8IQJgw) · [John Lindquist](https://www.youtube.com/watch?v=LvLdNkgO-N0) · [Cole Medin](https://www.youtube.com/watch?v=ttdWPDmBN_4) · [Maddy Zhang](https://www.youtube.com/watch?v=MzhIr7BfpI0) | Listed but not read in full |

**Contrarian views noted:**
- "Plan mode is obsolete" (Cherny). devsys keeps planning only for Standard and Deep work.
- "Don't set effort." devsys uses the default medium and raises it only for Deep.
- "Delete the harness every ~6 months." Built into `/devsys:update` as harness pruning.

## I. Pro plan facts (docs, 2026-11-24)

- The Claude Code default model on Pro is Opus 5.5. `sonnet`, `haiku` and `opusplan` are available ([model config](https://code.claude.com/docs/en/model-config.md)).
- There are session (5-hour) and weekly limits, plus model-specific limit messages ([errors](https://code.claude.com/docs/en/errors.md)). Exact numbers are not published in the docs.
- `/usage` shows a breakdown by skill, subagent, plugin and MCP. The statusline exposes `rate_limits.five_hour` and `seven_day` percentages ([costs](https://code.claude.com/docs/en/costs.md), [statusline](https://code.claude.com/docs/en/statusline.md)).
- Changelog: https://code.claude.com/docs/en/changelog
