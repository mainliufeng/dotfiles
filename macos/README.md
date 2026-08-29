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
- Codex is the default local agent runtime; `codex-app` provides both the app
  and CLI on macOS

Use the root entrypoints:

```bash
./setup.sh
./link.sh
```

`macos/Brewfile` includes the observed Homebrew, Mac App Store, Go, Cargo, and
npm packages. `install-extra-apps.sh` handles GUI applications that were
manually installed on the audited Mac without colliding with those existing
bundles. Apps without a safe automated mapping remain in the manual inventory.

Hermes is no longer installed by the default module list. Existing
`~/.hermes` runtime data can be retained as an offline archive, but local
automation and messaging should use Codex Scheduled tasks and the Codex
gateway.

`macos/link.sh` also installs a user LaunchAgent that checks the default Codex/ChatGPT app instance once per minute and relaunches it in the background after a crash. This keeps local Codex Scheduled tasks available while the Mac is awake. It does not override lid-close sleep.
