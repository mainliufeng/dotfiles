# macOS

This directory contains macOS-only setup.

Observed on this Mac when the layout was created:

- Homebrew: `/opt/homebrew/bin/brew`
- Homebrew version: `5.1.10`
- Installed casks: `alfred`, `clash-verge-rev`, `codex-app`, `font-hack-nerd-font`, `ghostty`, `hammerspoon`, `neovide-app`
- Applications present: `Alfred 5.app`, `Clash Verge.app`, `Codex.app`, `Ghostty.app`, `Google Chrome.app`, `Hammerspoon.app`, `Neovide.app`
- Codex CLI: `/Applications/Codex.app/Contents/Resources/codex`

Use the root entrypoints:

```bash
./setup.sh
./link.sh
```

`macos/Brewfile` includes the observed casks, including `clash-verge-rev` and `neovide-app`, plus the shared development tools that the common modules expect.
