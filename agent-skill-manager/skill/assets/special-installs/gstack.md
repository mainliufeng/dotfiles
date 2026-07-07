# Special install: gstack

`gstack` is not a plain skill copy. It has upstream setup flows and may generate additional skills.

## codex
Do not install gstack into Codex by default.

Current policy:
1. Keep the upstream checkout at `~/gstack` for manual/reference use.
2. Do not run `cd ~/gstack && ./setup --host codex` during normal skill sync.
3. Do not leave generated `gstack*` entries under `~/.codex/skills`.
4. If the user explicitly asks to re-enable gstack as Codex skills, run the upstream setup and document that it reintroduces broad auto-discovery.

## library

Current policy:
1. Keep the upstream checkout at `~/gstack`.
2. Link it into the cold library as `~/.local/share/agent-skill-manager/skills/gstack`.
3. Do not expose generated `gstack*` skills to Codex unless the user explicitly asks to re-enable broad auto-discovery.

## Notes
- Do not replace this with a naive symlink unless upstream behavior is understood.
- For Codex, the expected default verification is absence from `~/.codex/skills`, not presence.
- If temporarily using gstack, read the specific upstream skill from `~/gstack/.agents/skills/<skill>/SKILL.md`.
