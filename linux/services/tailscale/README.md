# Tailscale SSH

This module installs Tailscale on Arch/Garuda Linux, enables `tailscaled`, and
opts the machine into Tailscale SSH.

It intentionally does not enable `sshd.service`. Tailscale SSH handles incoming
SSH from the tailnet through Tailscale's policy layer, without exposing a normal
OpenSSH daemon on LAN or public networks.

## Install

```bash
cd ~/dotfiles
bash linux/services/tailscale/setup.sh
```

If the command prints a Tailscale login URL, open it in the browser and approve
the device.

To set a different local Tailscale operator:

```bash
TAILSCALE_OPERATOR=liufeng bash linux/services/tailscale/setup.sh
```

## Tailnet Policy

Recommended SSH policy for a personal machine:

```jsonc
"ssh": [
  {
    "action": "check",
    "src": ["autogroup:member"],
    "dst": ["autogroup:self"],
    "users": ["liufeng"],
    "checkPeriod": "1h"
  }
]
```

Notes:

- Keep `users` to the concrete Linux account (`liufeng`), not
  `autogroup:nonroot`, unless all non-root local accounts are intended targets.
- Do not include `root` unless root SSH is intentionally needed.
- Prefer `check` over `accept` for interactive machines.
- If the tailnet has more than one trusted admin, replace
  `autogroup:member` with a specific user or group.

## Verify

```bash
bash linux/services/tailscale/verify.sh
ssh liufeng@<tailscale-machine-name>
```

Run the SSH test from another device in the same tailnet. Testing SSH from the
machine to its own Tailscale IP can hit the local network path instead of the
Tailscale SSH path and return `connection refused` even when `RunSSH` is enabled.

From another tailnet device:

```bash
ssh liufeng@liufeng-82tk
# or
ssh liufeng@100.79.161.127
```

If the connection is denied by Tailscale policy, update the tailnet policy with
the `ssh` rule above.

## Proxy

If the daemon cannot reach the Tailscale control plane, configure the systemd
service to use the local proxy:

```bash
TAILSCALE_HTTPS_PROXY=http://127.0.0.1:7897 bash linux/services/tailscale/configure-proxy.sh
tailscale up --ssh --operator=liufeng
```

This writes `/etc/systemd/system/tailscaled.service.d/proxy.conf` and restarts
`tailscaled`. The proxy value is not committed into this repository.

## Traditional OpenSSH

If traditional SSH is not needed, keep it disabled:

```bash
sudo systemctl disable --now sshd
```

If traditional SSH is needed later, restrict it separately with
`PasswordAuthentication no`, `PermitRootLogin no`, `AllowUsers liufeng`, and a
firewall rule that only allows TCP 22 on `tailscale0`.
