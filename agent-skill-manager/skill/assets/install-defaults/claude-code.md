# Default install: claude-code

Use this when a skill has no special install doc.

## Runtime path
- Install into `~/.claude/skills/<skill-name>`

## Default behavior
1. Prefer symlinks for local skills.
2. For upstream repo skills, clone/copy the runtime skill directory into Claude's skills dir.
3. Keep Claude-specific naming if upstream docs require it.
4. Skip already-correct installs unless the user asked for reinstall or update.

## Verify
- Directory exists at the expected path
- If symlinked, the symlink points to the intended source
- `SKILL.md` or the runtime entry file exists
