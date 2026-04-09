# Special install: gstack

`gstack` is not a plain skill copy. It has upstream setup flows and may generate additional skills.

## codex
Current known approach:
1. Ensure repo exists at `~/gstack`
2. Run:
   ```bash
   cd ~/gstack && ./setup --host codex
   ```
3. Verify generated Codex-facing skills exist under `~/.codex/skills`

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
- After install/update, verify representative subskills such as `browse`, `qa`, `review`, or `office-hours`.
