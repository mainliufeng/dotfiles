# Default install: hermes

Use this when a skill has no special install doc.

## Runtime path
- Install into `~/.hermes/skills/<category>/<skill-name>` when a category is known
- If category is unknown, stop and ask whether to create one or use a temporary holding category such as `meta` or `local`

## Default behavior
1. Preserve category/name layout.
2. For local skills, do **not** symlink the whole skill directory into `~/.hermes/skills/...` because Hermes currently indexes skills with `os.walk(..., followlinks=False)` and will miss symlinked directories.
3. Instead, create a real installed directory and symlink or copy the files inside it (at minimum `SKILL.md`).
4. If the source skill has `references/`, `assets/`, `templates/`, or `scripts/`, symlink or copy those inside the installed directory too.
5. Ensure `SKILL.md` remains directly readable from the installed directory.
6. Create `DESCRIPTION.md` for a new category if needed.
7. Do not flatten category structure unless the user explicitly wants that.

## Safe install shape

Good:

```text
~/.hermes/skills/local/knowledge/
  SKILL.md -> ~/dotfiles-private/agent-skill-manager/private_skills/knowledge/SKILL.md
  references/ -> ~/dotfiles-private/agent-skill-manager/private_skills/knowledge/references
```

Bad:

```text
~/.hermes/skills/local/knowledge -> ~/dotfiles-private/agent-skill-manager/private_skills/knowledge
```

The same rule applies to private skills like `knowledge`.

## Verify
- Installed path exists
- `SKILL.md` exists
- Installed path is not a whole-directory symlink for local/private skills
- Category directory is sensible and not duplicated awkwardly
