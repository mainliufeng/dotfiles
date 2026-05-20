# Verification: hermes

After any Hermes install or update:

1. Confirm the installed path exists under `~/.hermes/skills/<category>/<name>`
2. Confirm `SKILL.md` exists
3. For local/private skills, confirm the installed path itself is **not** a whole-directory symlink
4. Run `hermes skills list` and confirm the skill appears in the catalog
5. Load the skill directly (for example `skill_view(<name>)`) and confirm it resolves to the intended installed path
6. Also load at least one linked file (for example `skill_view(<name>, file_path=...)`) when the skill ships references/assets/templates/scripts, to catch symlink-path escapes
7. Confirm the category is reasonable and not duplicated strangely
8. Report whether the skill should be added to a better category later
