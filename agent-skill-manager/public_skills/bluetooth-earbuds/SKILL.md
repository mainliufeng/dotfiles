---
name: bluetooth-earbuds
description: "Bluetooth earbuds operations on Linux/Hyprland: install and enable BlueZ, pair/trust/connect earbuds, recover from common pairing errors, and switch audio routes (A2DP/HFP/speaker) via pactl/wpctl and Waybar integration. Use when users ask to connect or troubleshoot Bluetooth headsets/earbuds."
---

# Bluetooth Earbuds

## Quick start

- Install packages (Arch/Garuda): `run0 pacman -S --needed bluez bluez-utils blueman`
- Enable service: `run0 systemctl enable --now bluetooth.service`
- Unblock radio: `run0 rfkill unblock bluetooth`
- Check controller: `bluetoothctl show`

## Pairing workflow (recommended)

1. Put earbuds into real pairing mode (not only open case).
2. Ensure phone is disconnected from earbuds.
3. Run:
   - `bluetoothctl`
   - `agent on`
   - `default-agent`
   - `scan on`
   - `pair <MAC>`
   - `trust <MAC>`
   - `connect <MAC>`
4. Verify:
   - `bluetoothctl info <MAC>` should show `Paired: yes` and `Connected: yes`.

## Common failures and fixes

- `org.bluez.Error.InProgress`
  - Cause: stale pairing session.
  - Fix: `cancel-pairing <MAC>` then retry `pair <MAC>`.

- `org.bluez.Error.AuthenticationCanceled`
  - Cause: earbuds left pairing mode or switched to phone.
  - Fix: re-enter pairing mode, disconnect phone side, retry.

- `org.bluez.Error.Failed br-connection-canceled`
  - Cause: BR/EDR audio channel canceled.
  - Fix order:
    - `disconnect <MAC>`
    - `bearer <MAC> bredr`
    - `connect <MAC> 0000110b-0000-1000-8000-00805f9b34fb`

## Audio routing

Detect Bluetooth card/sinks:
- `pactl list cards short | rg bluez_card`
- `pactl list sinks short | rg bluez_output`
- `pactl list sources short | rg bluez_input`

Switch profiles:
- High quality output: `pactl set-card-profile <bluez_card> a2dp-sink`
- Call mode with mic: `pactl set-card-profile <bluez_card> headset-head-unit`

Set defaults:
- `pactl set-default-sink <sink_name>`
- `pactl set-default-source <source_name>`
- Move active playback streams:
  - `pactl list sink-inputs short | awk '{print $1}' | xargs -r -I{} pactl move-sink-input {} <sink_name>`

## Name display notes

- Linux tools usually show standard Bluetooth fields only.
- Some vendors publish random alias before pairing.
- After pairing, run `info <MAC>` again; if still unclear, set local alias:
  - `set-alias "My Earbuds"`

## Repo-specific integration

This repo already contains:
- `hyprland/scripts/waybar-bluetooth.sh` (Waybar status module)
- `hyprland/scripts/audio-route-menu.sh` (A2DP/HFP/speaker menu)
- `hyprland/waybar/config` custom module `custom/bluetooth`

When user asks for UI-based route switching, prefer invoking/patching these scripts instead of rebuilding from scratch.
