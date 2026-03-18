# agent_config

`agent_config/` is the single source of truth for agent setup in this repo.

It replaces app-driven config with fixed scripts and a static manifest.

## Directory layout

- `config/manifest.json`: all targets, agent_md_fragments, skills, and project overrides
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

## Notes

- GitHub skills are installed through Codex built-in installer:
  `~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py`
- `gstack` is installed specially: the canonical checkout lives at
  `~/.claude/skills/gstack`, and Codex uses a compatibility symlink from
  `~/.codex/skills/gstack` because upstream hardcodes the Claude path.
- `ui-ux-pro-max` needs both skill files and `~/src/ui-ux-pro-max` source files;
  this is handled by `scripts/install-skills.sh`.
