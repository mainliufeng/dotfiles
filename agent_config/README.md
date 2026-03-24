# agent_config

`agent_config/` is the single source of truth for agent setup in this repo.
Local skill source files live in repo; target skill directories are only a link layer.

It replaces app-driven config with fixed scripts and a static manifest.

## Directory layout

- `config/manifest.json`: base manifest for targets, agent_md_fragments, skills, and project overrides
- `agent_md_fragments/`: reusable agent.md fragments for AGENTS/CLAUDE
- `local_skills/`: repo-managed local skills (commit, hyprland, ...)
- `scripts/install-skills.sh`: install skills from manifest
- `scripts/build-agent-md.sh`: render AGENTS.md / CLAUDE.md / overrides
- `setup.sh`: one-shot entrypoint

## Usage

Install both Codex and Claude skills, and render all agent markdown files:

```bash
~/dotfiles/agent_config/setup.sh
```

Only Codex:

```bash
~/dotfiles/agent_config/setup.sh --target codex
```

Only regenerate markdown files:

```bash
~/dotfiles/agent_config/setup.sh --skip-skills
```

Only install skills:

```bash
~/dotfiles/agent_config/setup.sh --skip-md
```

## Overlay manifest

If `~/dotfiles-private/agent_config/config/manifest.json` exists, setup merges it automatically on top of the public manifest.

- Public skills stay in `~/dotfiles/agent_config/local_skills`
- Private skills stay in `~/dotfiles-private/agent_config/local_skills`
- Relative local paths are resolved relative to the manifest's own `agent_config/` root

## Skill sync behavior

- `kind=local` skills are linked into `~/.codex/skills` / `~/.claude/skills`, not copied
- Edit local skills in repo source only; do not hand-edit the linked runtime copies
- If an old copied skill already exists, setup moves it to `*.agent_config.bak.<timestamp>` and replaces it with a symlink

## Notes

- GitHub skills are installed through Codex built-in installer:
  `~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py`
- `gstack` follows upstream README now:
  Claude installs from `~/.claude/skills/gstack` via `./setup`,
  while Codex installs from `~/gstack` via `./setup --host codex`.
  The Codex setup command manages `~/.codex/skills/gstack` and the generated
  top-level skill links for you.
- `ui-ux-pro-max` needs both skill files and `~/src/ui-ux-pro-max` source files;
  this is handled by `scripts/install-skills.sh`.
