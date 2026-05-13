# Tailscale on macOS

This installs Tailscale.app with Homebrew so the Mac can join the tailnet and
SSH into `liufeng-82tk`.

It does not enable macOS Remote Login. For this setup, the Mac is the SSH
client and the Linux machine is the Tailscale SSH server.

## Install

```bash
cd ~/dotfiles
bash macos/tailscale/setup.sh
```

Approve the VPN/system extension prompts, then sign in from the Tailscale menu
bar app.

If the CLI integration is installed from Tailscale.app Settings, terminal status
checks can use `tailscale status`. Without CLI integration, use the app UI.

## Connect To Linux

```bash
ssh liufeng@liufeng-82tk
```

If MagicDNS is unavailable, use the Linux host's Tailscale IP:

```bash
ssh liufeng@100.79.161.127
```

Expected result after browser check:

```bash
hostname
whoami
```

```text
liufeng-82tk
liufeng
```

## Tailnet SSH Policy

The destination is the Linux host, so the policy user is the Linux login user:

```jsonc
"ssh": [
  {
    "action": "check",
    "src": ["autogroup:member"],
    "dst": ["autogroup:self"],
    "users": ["liufeng"]
  }
]
```

Avoid `root` and `autogroup:nonroot` unless you intentionally want every
non-root local account to be reachable.

## Verify

On the Mac:

```bash
bash macos/tailscale/verify.sh
```

Then test the intended direction from the Mac to this Linux machine:

```bash
ssh liufeng@liufeng-82tk
```

The reverse direction, Linux to Mac, requires the Mac to run a normal SSH server
or the macOS CLI-only Tailscale SSH server variant. It is not needed for using
the Mac as the client.

## Mac As SSH Destination

Tailscale SSH server support on macOS is limited to the open source
`tailscale` + `tailscaled` CLI-only variant. The normal GUI app is the right
choice for this Mac-as-client setup, but do not expect it to act as a Tailscale
SSH server.

## Traditional macOS SSH

Keep Remote Login off unless you also need normal OpenSSH access:

```bash
sudo systemsetup -setremotelogin off
```

If Remote Login is enabled later, restrict it separately with macOS firewall or
network policy. Do not rely on Tailscale SSH policy to secure non-Tailscale SSH.
