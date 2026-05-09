# macOS

This directory contains macOS-only setup.

Observed on this Mac when the layout was created:

- Homebrew: `/opt/homebrew/bin/brew`
- Homebrew version: `5.1.10`
- Installed casks: `codex-app`, `ghostty`
- Applications present: `Codex.app`, `Ghostty.app`, `Google Chrome.app`, `Clash Verge.app`
- Codex CLI: `/Applications/Codex.app/Contents/Resources/codex`

Use the root entrypoints:

```bash
./setup.sh
./link.sh
```

`macos/Brewfile` includes the observed casks, including `clash-verge-rev`, plus the shared development tools that the common modules expect.
