# Default install: hermes

Use this when a skill has no special install doc.

## Runtime path
- Install into `~/.hermes/skills/<category>/<skill-name>` when a category is known
- If category is unknown, stop and ask whether to create one or use a temporary holding category such as `meta` or `local`

## Default behavior
1. Preserve category/name layout.
2. Prefer symlinks for local skills.
3. Ensure `SKILL.md` remains in the installed directory.
4. Create `DESCRIPTION.md` for a new category if needed.
5. Do not flatten category structure unless the user explicitly wants that.

## Verify
- Installed path exists
- `SKILL.md` exists
- Category directory is sensible and not duplicated awkwardly
