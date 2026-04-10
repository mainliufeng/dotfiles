# Default install: hermes

Use this when a skill has no special install doc.

## Runtime path
- Install into `~/.hermes/skills/<category>/<skill-name>` when a category is known
- If category is unknown, stop and ask whether to create one or use a temporary holding category such as `meta` or `local`

## Default behavior
1. Preserve category/name layout.
2. For local skills, do **not** symlink the whole skill directory into `~/.hermes/skills/...` because Hermes currently indexes skills with `os.walk(..., followlinks=False)` and will miss symlinked directories.
3. Instead, create a real installed directory and symlink or copy the files inside it (at minimum `SKILL.md`).
4. Ensure `SKILL.md` remains in the installed directory.
5. Create `DESCRIPTION.md` for a new category if needed.
6. Do not flatten category structure unless the user explicitly wants that.

## Verify
- Installed path exists
- `SKILL.md` exists
- Category directory is sensible and not duplicated awkwardly
