# Special install: gstack

`gstack` is not a plain skill copy. It has upstream setup flows and may generate additional skills.

## codex
Do not install gstack into Codex by default.

Current policy:
1. Keep the upstream checkout at `~/gstack` for manual/reference use.
2. Do not run `cd ~/gstack && ./setup --host codex` during normal skill sync.
3. Do not leave generated `gstack*` entries under `~/.codex/skills`.
4. If the user explicitly asks to re-enable gstack as Codex skills, run the upstream setup and document that it reintroduces broad auto-discovery.

## claude-code
Current known approach:
1. Ensure source checkout exists at `~/.claude/skills/gstack` or another confirmed Claude-compatible source checkout
2. Run:
   ```bash
   cd <gstack-source> && ./setup
   ```
3. Verify Claude-facing skills appear under `~/.claude/skills`

## Notes
- Do not replace this with a naive symlink unless upstream behavior is understood.
- For Codex, the expected default verification is absence from `~/.codex/skills`, not presence.
- After Claude install/update, verify representative subskills such as `browse`, `qa`, `review`, or `office-hours`.
