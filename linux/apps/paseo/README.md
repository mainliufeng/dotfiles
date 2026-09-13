# Paseo (desktop app + always-on daemon)

[Paseo](https://paseo.sh) is a self-hosted control plane for coding agents
(Claude Code, Codex, Copilot, OpenCode, Pi). The desktop app bundles the daemon
that manages the agents; the phone app connects to that daemon through the
end-to-end encrypted Paseo relay, so no port forwarding or VPN is required.

This module installs the AUR package `paseo-bin` and keeps the daemon running.

```bash
~/dotfiles/linux/apps/paseo/setup.sh
```

Options:

- `--dry-run` — print the actions without changing the machine
- `--no-relay` — do not enable the relay in `~/.paseo/config.json`
- `--no-start` — do not start the daemon now

## What it does

1. Installs `paseo-bin` through `yay` (falls back to `paru`).
2. Symlinks `paseo-daemon.desktop` into `~/.config/autostart/`, so the daemon
   starts together with the graphical session (KDE Plasma honours XDG
   autostart entries).
3. Sets `daemon.relay.enabled: true` in `~/.paseo/config.json`, creating the
   file if needed. The relay is how the phone reaches this machine.
4. Starts `paseo.service` right away.

## Why the daemon is session-scoped

The packaged unit `/usr/lib/systemd/user/paseo.service` deliberately has no
`[Install]` section: binding it to a login target races the desktop session and
it must inherit the session environment (full login-shell `PATH`, `DISPLAY`,
`WAYLAND_DISPLAY`) for agents and browser tooling to work. It is therefore
started from an XDG autostart entry, not enabled with `systemctl --user enable`.

The daemon keeps running after the Paseo window is closed; launching the app
again attaches to the same daemon. Stop it with `systemctl --user stop
paseo.service`.

## Pairing the phone

Paseo Desktop → Settings → your host → **Pair a device** → scan the QR code
with the Paseo app. The QR/link is the trust anchor: it carries the daemon's
public key. Treat it like a password.

## Notes

- The desktop app is the GUI; the daemon is what the phone talks to.
- `paseo-bin` conflicts with `paseo-cli`/`paseo` in AUR — installing this module
  replaces a CLI-only Paseo installation.
- If you prefer a daemon that also starts before login (no graphical session),
  the `paseo-cli` package plus a systemd user unit is the alternative. This
  module intentionally follows upstream's session-scoped design.
