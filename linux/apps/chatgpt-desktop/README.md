# Official ChatGPT/Codex Desktop for Linux

This module records the official Linux desktop app distributed by OpenAI. On
Arch-like systems, dotfiles installs the packaged official binary as
`chatgpt-desktop-bin`; it provides both the ChatGPT desktop shell and Codex.

Install or verify it with:

```bash
~/dotfiles/linux/apps/chatgpt-desktop/setup.sh
```

Preview a missing-package installation without changing the machine:

```bash
~/dotfiles/linux/apps/chatgpt-desktop/setup.sh --dry-run
```

The package's `/usr/bin/chatgpt` launcher reads `chatgpt-flags.conf` from
`XDG_CONFIG_HOME` (or `~/.config`). Setup links the supplied native Wayland flags
when this file is absent, and preserves existing flags. Native Wayland follows
the monitor scale; fixed scale factors must not be multiplied on top of it.
Restart the app after changing launch flags. Remove the created symlink to undo.

The retired `ilysenko/codex-desktop-linux` wrapper and its
`codex-update-manager` are intentionally not installed by dotfiles anymore.

Personal plugins, active skills, and generated `AGENTS.md` are applied by the
private orchestrator:

```bash
~/dotfiles-private/codex/setup-linux-desktop.sh
```

Do not commit credentials, `~/.codex` runtime state, plugin caches, packages,
or task/session data into dotfiles.
