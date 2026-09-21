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
- `--tailscale` — bind `daemon.listen` to this machine's Tailscale IPv4 and
  allowlist the tailnet's MagicDNS suffix
- `--tailscale-ip IP` — same, with an explicit address

## What it does

1. Installs `paseo-bin` through `yay` (falls back to `paru`).
2. Symlinks `paseo-daemon.desktop` into `~/.config/autostart/`, so the daemon
   starts together with the graphical session (KDE Plasma honours XDG
   autostart entries), plus the CLI/PATH shadows and the applications-menu
   entry described below.
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

## Direct connection over Tailscale

Instead of the relay, the phone can reach the daemon over the tailnet. Bind the
daemon to the Tailscale address, allowlist the tailnet's MagicDNS suffix, and
restart:

```bash
~/dotfiles/linux/apps/paseo/setup.sh --tailscale
```

That sets `daemon.listen` to `<tailscale-ip>:6767`, appends the MagicDNS suffix
(e.g. `.tail6b9726.ts.net`) to `daemon.hostnames`, and restarts `paseo.service`.
Then, on the phone (Tailscale connected to the same tailnet, MagicDNS on):

```
Paseo -> Settings -> Add host -> Direct connection
Port 6767   Use SSL off
Host liufeng-82tk.tail6b9726.ts.net   (or the 100.x.y.z IP)
```

If the host was already paired through the relay, the direct connection is added
to the same host.

Notes:

- `daemon.listen` is a single address and a startup setting, so after binding to
  the Tailscale IP the daemon **no longer listens on `localhost:6767`**. The
  desktop app is unaffected: it talks to its daemon over a unix socket, and the
  shipped app treats a non-default `daemon.listen` as an additional host.
- Connecting **by name** needs `daemon.hostnames` to accept it: Paseo's
  DNS-rebinding guard only allows `localhost`, `*.localhost` and bare IPs by
  default. A leading dot is a suffix rule, so `.tail6b9726.ts.net` covers
  `liufeng-82tk.tail6b9726.ts.net` and survives a hostname change. Hostnames are
  runtime-safe and were applied with `paseo daemon reload` (no restart).
- The phone must have **MagicDNS enabled** to resolve the name; the IP always
  works.
- Tailscale already encrypts and authenticates the link; Paseo's relay is
  end-to-end encrypted, a direct connection is not. A Paseo password
  (`paseo daemon set-password`) is optional defense-in-depth for a shared
  tailnet.
- Set `"daemon": {"relay": {"enabled": false}}` and restart to drop the relay
  once direct access works, or leave it enabled as a fallback.

## `paseo` runs the CLI, `paseo-gui` opens the app

The package installs `/usr/bin/paseo` as the Electron **GUI** wrapper: every
invocation boots the app, which is a window — even for CLI subcommands. Agents
(Claude, Codex, Pi) load Paseo's bundled `paseo` skill and call the CLI from
scripts, so `paseo ls`, `paseo run`, `paseo send` used to spray windows: the
burst shows up as repeated `[desktop] app startup` lines in
`~/.config/Paseo/logs/main.log` and one extra `Paseo --type=renderer` process
per call.

The app also ships the real CLI at `/opt/Paseo/resources/bin/paseo`, which runs
the same entrypoint as plain Node (`ELECTRON_RUN_AS_NODE=1`). `link.sh` therefore:

- shadows `paseo` in `~/.local/bin` with that node CLI — `~/.local/bin` precedes
  `/usr/bin` for the session and for every agent the daemon spawns, so scripts
  and skills keep calling `paseo` and no longer get the GUI;
- links `~/.local/share/applications/paseo.desktop` (an absolute-path copy of the
  packaged entry) so the applications menu still opens the GUI;
- links `~/.local/bin/paseo-gui` for deliberately opening the app from a shell.

This lives in dotfiles rather than in the skills for a reason: Paseo-managed
skill files (`.paseo-managed-files.json`) are rewritten by the app, and the
shadow is a plain PATH entry that survives `paseo-bin` upgrades.

Check it in a login shell — `which -a paseo` should list `~/.local/bin/paseo`
first, and `paseo ls` should add no new `app startup` line:

```bash
grep -c '\[desktop\] app startup' ~/.config/Paseo/logs/main.log   # before
paseo ls >/dev/null
grep -c '\[desktop\] app startup' ~/.config/Paseo/logs/main.log   # same number
```

## Notes

- The desktop app is the GUI; the daemon is what the phone talks to.
- `paseo-bin` conflicts with `paseo-cli`/`paseo` in AUR — installing this module
  replaces a CLI-only Paseo installation.
- If you prefer a daemon that also starts before login (no graphical session),
  the `paseo-cli` package plus a systemd user unit is the alternative. This
  module intentionally follows upstream's session-scoped design.
