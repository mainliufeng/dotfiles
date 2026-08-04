# macOS

This directory contains macOS-only setup.

The current audited inventory and migration boundary are documented in
[`app-inventory.md`](app-inventory.md).

Observed on this Mac when the layout was created:

- Homebrew: `/opt/homebrew/bin/brew`
- Homebrew version: `5.1.10`
- Installed casks: `alfred`, `clash-verge-rev`, `codex-app`, `font-hack-nerd-font`, `ghostty`, `hammerspoon`, `neovide-app`
- Applications present: `Alfred 5.app`, `Clash Verge.app`, `Codex.app`, `Ghostty.app`, `Google Chrome.app`, `Hammerspoon.app`, `Neovide.app`
- Codex CLI: `/Applications/Codex.app/Contents/Resources/codex`
- Happy CLI: installed by the common `npm` module with `npm install -g happy`
- Hermes Agent: the common `hermes-agent` module installs the CLI and builds
  Hermes Desktop on macOS, exposed at `~/Applications/Hermes.app`

Use the root entrypoints:

```bash
./setup.sh
./link.sh
```

`macos/Brewfile` includes the observed Homebrew, Mac App Store, Go, Cargo, and
npm packages. `install-extra-apps.sh` handles GUI applications that were
manually installed on the audited Mac without colliding with those existing
bundles. Apps without a safe automated mapping remain in the manual inventory.

The common `hermes-agent` module uses the official Nous Research installer.
On macOS it passes `--include-desktop`, preserves runtime data under
`~/.hermes`, and links the built native app into `~/Applications`. Re-running
setup skips the expensive Electron build when both the CLI and Desktop app are
already present; use `hermes update` for routine upgrades.

`macos/link.sh` also installs a user LaunchAgent that checks the default Codex/ChatGPT app instance once per minute and relaunches it in the background after a crash. This keeps local Codex Scheduled tasks available while the Mac is awake. It does not override lid-close sleep.
