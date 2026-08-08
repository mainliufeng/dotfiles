# Codex Desktop Linux

This module installs the unofficial Linux wrapper from
`https://github.com/ilysenko/codex-desktop-linux` on Arch-like systems.

The source checkout lives at:

```text
~/Code/source/codex-desktop-linux
```

First install:

```bash
~/dotfiles/linux/apps/codex-desktop/setup.sh
```

That runs the upstream recommended native command:

```bash
CODEX_SUDO_ALERT=1 make bootstrap-native
```

The module is idempotent: when the `codex-desktop` pacman package already
exists, it does not rebuild by default. To update/rebuild explicitly:

```bash
~/dotfiles/linux/apps/codex-desktop/setup.sh --update-source --rebuild
```

Preview without changing the machine:

```bash
~/dotfiles/linux/apps/codex-desktop/setup.sh --dry-run
```

Personal plugins, active skills, and generated `AGENTS.md` are applied by the
private orchestrator:

```bash
~/dotfiles-private/codex/setup-linux-desktop.sh
```

Do not commit `Codex.dmg`, generated `codex-app/`, packages, plugin caches,
credentials, or `~/.codex` runtime state into dotfiles.
