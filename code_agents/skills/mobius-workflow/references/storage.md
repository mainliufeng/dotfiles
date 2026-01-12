# Workflow Desktop storage reference

## Root

Default root directory:

- `~/.mobius-workflow/`

Structure:

```
~/.mobius-workflow/
  workflows/
    <workflowId>/
      workflow.json
      nodes/
        <nodeId>.session.json
        <nodeId>.result.json
```

## workflow.json

Fields used by this skill:

- `id`, `name`, `rootPrompt`, `status`, `createdAt`, `updatedAt`
- `nodes[]`: `id`, `title`, `prompt`, `mode`, `status`, `dependsOn`, `createdAt`, `updatedAt`

## nodes/<nodeId>.session.json

Fields used by this skill:

- `workflowId`, `nodeId`, `mode`, `status`, `sessionId`, `updatedAt`
- `messages[]`: `{ role, content, createdAt }`

## Notes

- Dependency data is determined by `workflow.json` (`dependsOn`).
- Node messages live in `nodes/<nodeId>.session.json`.
- Node results live in `nodes/<nodeId>.result.json` (last assistant output per run).
- This skill only reads/writes `workflow.json` and reads `nodes/<nodeId>.result.json`.
