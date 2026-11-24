---
name: standard-plan-preview
tags: [routing, preview]
runs: 1
max_turns: 30
model: sonnet
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Agent]
---

Build me a small expense tracker: record expenses with category and date, monthly totals per category, export to CSV, and a simple local web page to view it.
