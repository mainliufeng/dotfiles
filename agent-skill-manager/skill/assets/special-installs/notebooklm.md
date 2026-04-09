# Special install: notebooklm

`notebooklm` now comes from `teng-lin/notebooklm-py`.

This install has two parts:

1. Install the global `notebooklm` CLI.
2. Link the locally managed skill from `~/dotfiles/agent-skill-manager/public_skills/notebooklm`.

## Notes

- Prefer the released package, not `main`.
- The CLI stores auth and runtime state under `~/.notebooklm` by default.
- This tool supports features the old skill did not expose cleanly, including artifact export and source fulltext access.
- Browser support requires Playwright's Chromium binary.

## CLI

Install:
```bash
pipx install --force 'notebooklm-py[browser]'
/home/liufeng/.local/share/pipx/venvs/notebooklm-py/bin/playwright install chromium
```

Update:
```bash
pipx upgrade notebooklm-py
/home/liufeng/.local/share/pipx/venvs/notebooklm-py/bin/playwright install chromium
```

## codex

Preferred install path:
- `~/.codex/skills/notebooklm`

Install:
```bash
ln -sfn ~/dotfiles/agent-skill-manager/public_skills/notebooklm ~/.codex/skills/notebooklm
```

## hermes

Preferred category:
- `research`

Preferred install path:
- `~/.hermes/skills/research/notebooklm`

Install:
```bash
ln -sfn ~/dotfiles/agent-skill-manager/public_skills/notebooklm ~/.hermes/skills/research/notebooklm
```

## Verification

- `notebooklm --version` succeeds.
- `notebooklm status` runs.
- `~/.codex/skills/notebooklm/SKILL.md` exists.
- `~/.hermes/skills/research/notebooklm/SKILL.md` exists.
