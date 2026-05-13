---
name: spark
description: Use when the user invokes spark, asks to use the Spark model, wants a fast subagent, or wants quick low-risk side work such as code search, lightweight investigation, summarization, or fact-finding. This skill treats the invocation as an explicit request to spawn a GPT-5.3 Codex Spark subagent and summarize its findings.
---

# Spark

Use this skill as a thin trigger for a fast subagent.

## Workflow

1. Spawn one `spark` subagent for the requested task.
2. Pass the user's exact request, current working directory, and any named files, symbols, URLs, or constraints.
3. Keep the delegated scope low-risk and bounded. Good fits include code search, file discovery, call-site tracing, lightweight investigation, summarization, and comparison.
4. Wait for the result, then summarize the answer with file and line references when relevant.

For multiple independent quick questions, spawn up to three `spark` agents in parallel and merge their results.

## Constraints

- Do not ask the subagent to make broad implementation changes.
- For code edits, migrations, commits, deployments, or destructive operations, use the normal parent-agent workflow or a dedicated worker instead.
- If the custom `spark` agent is unavailable, spawn a default subagent with `model: gpt-5.3-codex-spark` and `reasoning_effort: low`.
- If subagents are unavailable, say so and perform the task locally.
