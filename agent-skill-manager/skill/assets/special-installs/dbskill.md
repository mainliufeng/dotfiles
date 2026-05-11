# Special install: dbskill

Upstream:
- `https://github.com/dontbesilent2025/dbskill`

This upstream repo contains a bundle of independent skills under `skills/`.
Install every direct child directory that contains `SKILL.md`.

## Source checkout

Preferred source path:
- `~/Code/source/dbskill`

Install or update source:

```bash
if [ -d ~/Code/source/dbskill/.git ]; then
  git -C ~/Code/source/dbskill pull --ff-only
else
  git clone https://github.com/dontbesilent2025/dbskill.git ~/Code/source/dbskill
fi
```

## codex

Preferred install shape:
- `~/.codex/skills/<skill-name>` symlinked to `~/Code/source/dbskill/skills/<skill-name>`

Install all skills:

```bash
mkdir -p ~/.codex/skills
for skill_dir in ~/Code/source/dbskill/skills/*; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  ln -sfn "$skill_dir" ~/.codex/skills/"$(basename "$skill_dir")"
done
```

## hermes

Hermes should use marketplace categories from `.claude-plugin/marketplace.json`.
Create real installed directories and link the files inside; do not symlink the whole skill directory.

Category mapping:
- `dbs`, `dbs-diagnosis`, `dbs-benchmark`, `dbs-action`, `dbs-slowisfast`, `dbs-goal` -> `business-diagnostics`
- `dbs-content`, `dbs-hook`, `dbs-xhs-title`, `dbs-ai-check` -> `content-creation`
- `dbs-deconstruct`, `dbs-chatroom-austrian`, `dbs-chatroom` -> `thinking-tools`
- `dbs-agent-migration` -> `workflow-infrastructure`
- `dbs-save`, `dbs-restore`, `dbs-report` -> `state-management`

Preferred install shape:

```text
~/.hermes/skills/<category>/<skill-name>/
  SKILL.md -> ~/Code/source/dbskill/skills/<skill-name>/SKILL.md
```

Create `DESCRIPTION.md` for any new category.

## Verify

- `~/.codex/skills/dbs/SKILL.md` exists.
- All 17 Codex skill links point into `~/Code/source/dbskill/skills/`.
- All 17 Hermes installed directories contain a directly readable `SKILL.md`.
- Hermes installed skill directories are not whole-directory symlinks.
- `hermes skills list` includes representative skills such as `dbs`, `dbs-diagnosis`, and `dbs-goal`.
