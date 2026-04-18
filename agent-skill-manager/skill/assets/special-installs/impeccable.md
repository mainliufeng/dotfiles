# Special install: impeccable

`impeccable` ships as a Codex skill bundle, not a single runtime skill directory.

## Why this is special

- The upstream repo contains multiple Codex skills under `.codex/skills/`.
- Installing only `~/.codex/skills/impeccable` would miss the companion commands such as `audit`, `polish`, and `layout`.
- The repo already includes a Codex-ready runtime layout, so no extra build step is required for installation.

## Source location

- Keep the upstream checkout under `~/Code/source/impeccable` on this machine.
- If the repo is missing, clone it first:
  ```bash
  git clone --depth 1 https://github.com/pbakaus/impeccable ~/Code/source/impeccable
  ```
- If it already exists, update it before reinstalling:
  ```bash
  git -C ~/Code/source/impeccable fetch --depth 1 origin
  git -C ~/Code/source/impeccable reset --hard origin/HEAD
  ```

## codex

Preferred approach:
1. Ensure `~/Code/source/impeccable/.codex/skills` exists.
2. Link each upstream skill directory into `~/.codex/skills/`:
   ```bash
   mkdir -p ~/.codex/skills
   for skill_dir in ~/Code/source/impeccable/.codex/skills/*; do
     ln -sfn "$skill_dir" ~/.codex/skills/"$(basename "$skill_dir")"
   done
   ```
3. Do not remove unrelated runtime skills while installing this bundle.

Installed Codex skills from this bundle:
- `adapt`
- `animate`
- `audit`
- `bolder`
- `clarify`
- `colorize`
- `critique`
- `delight`
- `distill`
- `harden`
- `impeccable`
- `layout`
- `optimize`
- `overdrive`
- `polish`
- `quieter`
- `shape`
- `typeset`

## Verification

- `~/.codex/skills/impeccable/SKILL.md` exists.
- Representative companion skills such as `~/.codex/skills/audit/SKILL.md` and `~/.codex/skills/polish/SKILL.md` also exist.
- If symlinked, each runtime skill points into `~/Code/source/impeccable/.codex/skills/`.
