---
name: mobius-workflow
description: Read/update workflow.json and fetch node result files for Workflow Desktop. Use when you need to inspect or modify workflow metadata or read node results.
---

# Workflow Split and Node Results

## Overview

Workflow Desktop nodes run with isolated context. Information should flow only via `workflow.json` dependencies and node result files. This skill provides scripts to read/update `workflow.json` and to fetch node results, plus common split patterns.

## Quick start

1. Locate the workflow root (default `~/.mobius-workflow/`).
2. Read `workflow.json` or a node result with the scripts.
3. Only update `workflow.json` (do not edit session/result files).

## Read workflow.json

Use `scripts/get_workflow.py`:

```bash
python scripts/get_workflow.py --workflow-id <workflowId>
```

## Update workflow.json

Use `scripts/update_workflow.py` (only reads/writes `workflow.json`):

Update workflow metadata:

```bash
python scripts/update_workflow.py \
  --workflow-id <workflowId> \
  --name "New workflow name" \
  --root-prompt "New root prompt" \
  --status running
```

Update node fields (still only `workflow.json`):

```bash
python scripts/update_workflow.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --title "New title" \
  --prompt "New prompt" \
  --mode automatic
```

Dependencies:

```bash
python scripts/update_workflow.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --set-depends node-a,node-b
```

## Fetch a single node result

Use `scripts/get_node_result.py`:

```bash
python scripts/get_node_result.py \
  --workflow-id <workflowId> \
  --node-id <nodeId>
```

Text output (result only):

```bash
python scripts/get_node_result.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --format text
```

## How to split a workflow (context isolation)

- Each node should have one clear objective and a reusable output (`nodes/<nodeId>.result.json`).
- Make dependencies explicit: use `dependsOn` whenever upstream results are required.
- Pass information only via result files or agreed shared files, not implicit context.
- Use interactive nodes for human confirmation or missing details; use automatic nodes for deterministic outputs.
- Each node prompt must declare inputs (upstream results / files) and expected output format.

## Common patterns

Single-node workflow (simple tasks):
- nodes: 1 automatic node that produces the final deliverable.

Requirements -> Design -> Implementation:
- node-req (interactive/automatic): clarify constraints and produce a requirement brief.
- node-design (automatic): derive the design and task split from the brief.
- node-impl (automatic): implement and output changes/results.

Parallel research -> Synthesis (fan-out / fan-in):
- node-research-a/b/c: research subtopics in parallel.
- node-synthesis: dependsOn all research nodes, consolidate into one result.

Design -> Implementation -> Verification:
- node-design: define solution and acceptance criteria.
- node-impl: implement and output change notes.
- node-verify: validate against acceptance criteria and return verdict.

Multi-stage interactive flow:
- node-discovery (interactive): iterative clarification.
- node-plan (automatic): produce execution plan.
- node-exec (automatic): execute and deliver final result.

## References

- Storage layout and fields: `references/storage.md`
