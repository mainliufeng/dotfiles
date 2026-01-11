---
name: mobius-workflow
description: Fetch dependency node results for Workflow Desktop nodes and update workflow/node metadata. Use when you need to read upstream node outputs, build prompts with dependency context, or patch workflow.json/nodes/<nodeId>.json (title, prompt, dependsOn, status, mode).
---

# Workflow Node Deps

## Overview

Read dependency node results and update workflow/node metadata for Workflow Desktop without touching output files. Use the bundled scripts to fetch upstream messages and to modify workflow.json + nodes/<nodeId>.json safely.

## Quick start

1. Locate the workflow root (default `~/.workflow_desktop/`).
2. Fetch dependency results for the current node.
3. Merge dependency outputs into the current node prompt if needed.
4. Update workflow or node metadata via script when edits are required.

## Get dependency node results

Use `scripts/get_node_deps_results.py`.

Examples:

```bash
python scripts/get_node_deps_results.py \
  --workflow-id <workflowId> \
  --node-id <nodeId>
```

Return only the last assistant message for each dependency:

```bash
python scripts/get_node_deps_results.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --mode last-assistant
```

Return the last N messages for each dependency:

```bash
python scripts/get_node_deps_results.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --mode tail \
  --tail 4
```

## Build prompts with dependency context

Use this pattern when you need to inform the model about upstream results:

1. Read dependency outputs with `get_node_deps_results.py`.
2. Concatenate dependency summaries into the current node prompt, for example:

```
[Dependency Results]
- node-a: <last assistant output>
- node-b: <last assistant output>

[Current Node Task]
<original prompt>
```

Do not attempt to read or write any external output files; only use the JSON files under the workflow root.

## Update workflow/node metadata

Use `scripts/update_workflow_node.py` to patch workflow.json and nodes/<nodeId>.json.

Examples:

Update node title and prompt:

```bash
python scripts/update_workflow_node.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --title "New title" \
  --prompt "New prompt"
```

Set dependencies:

```bash
python scripts/update_workflow_node.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --set-depends node-a,node-b
```

Add/remove dependencies:

```bash
python scripts/update_workflow_node.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --add-dep node-c \
  --remove-dep node-b
```

Update status or mode:

```bash
python scripts/update_workflow_node.py \
  --workflow-id <workflowId> \
  --node-id <nodeId> \
  --status awaiting_input \
  --mode interactive
```

## References

- Storage layout and fields: `references/storage.md`
