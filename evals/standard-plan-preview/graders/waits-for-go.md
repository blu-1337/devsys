---
type: llm
weight: 1
---
Pass if the agent stops BEFORE writing implementation code and asks for confirmation: either a short plan preview (what will be built, how, numbered tasks, how to test) ending with a request to say "go", or one batch of clarifying questions with suggested defaults. Fail if it reports the expense tracker as already built or written.
