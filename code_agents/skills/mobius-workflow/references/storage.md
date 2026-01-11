# Workflow Desktop storage reference

## Root

Default root directory:

- `~/.workflow_desktop/`

Structure:

```
~/.workflow_desktop/
  workflows/
    <workflowId>/
      workflow.json
      nodes/
        <nodeId>.json
```

## workflow.json

Fields used by this skill:

- `id`, `name`, `rootPrompt`, `status`, `createdAt`, `updatedAt`
- `nodes[]`: `id`, `title`, `prompt`, `mode`, `status`, `dependsOn`, `createdAt`, `updatedAt`

## nodes/<nodeId>.json

Fields used by this skill:

- `workflowId`, `nodeId`, `mode`, `status`, `sessionId`, `updatedAt`
- `messages[]`: `{ role, content, createdAt }`

## Notes

- Dependency data is determined by `workflow.json` (`dependsOn`).
- Node messages live in `nodes/<nodeId>.json`.
- This skill only reads/writes `workflow.json` and `nodes/<nodeId>.json`.
