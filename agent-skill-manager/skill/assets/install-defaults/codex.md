# Default install: codex

Use this when a skill has no special install doc.

## Runtime path
- Install into `~/.codex/skills/<skill-name>`

## Default behavior
1. If the source is a local directory, prefer a symlink.
2. If the source is a GitHub/upstream repo and a Codex-native installer is clearly available, prefer that.
3. Otherwise clone/copy into the Codex skills directory.
4. Do not overwrite an existing install blindly; inspect first.
5. For install requests, skip already-correct installs unless the user requested reinstall.

## Verify
- Directory exists at the expected path
- If symlinked, the symlink points to the expected source
- `SKILL.md` or equivalent runtime files are present
