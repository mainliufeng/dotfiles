---
name: touchpad-recovery
description: Use when a Linux laptop touchpad suddenly becomes slow, jittery, or unreliable, especially when two-finger scrolling degrades, the cursor feels heavy, or KDE/libinput sessions show touchpad or i2c-hid symptoms.
---

# Touchpad Recovery

## Overview

Use this skill for Linux laptop touchpad incidents where the symptom looks bigger than a simple settings mistake.

Work in layers:
- Confirm desktop/session and input stack.
- Rule out settings drift and gesture daemons.
- Check logs for libinput or i2c-hid faults.
- Rebind the touchpad device only if the evidence points to a kernel/device state issue.

## Quick triage

1. Confirm session type:
   - `printf 'XDG_SESSION_DESKTOP=%s\nXDG_CURRENT_DESKTOP=%s\nWAYLAND_DISPLAY=%s\nDISPLAY=%s\n' "$XDG_SESSION_DESKTOP" "$XDG_CURRENT_DESKTOP" "$WAYLAND_DISPLAY" "$DISPLAY"`
   - `loginctl session-status ${XDG_SESSION_ID:-$(loginctl | awk '/seat/ {print $1; exit}')}`
2. Inspect devices:
   - `libinput list-devices`
   - `sed -n '/Touchpad/,+18p' /proc/bus/input/devices`
3. Check recent faults:
   - `journalctl --since '2 hours ago' --no-pager | grep -iE 'i2c_hid|touchpad|libinput|input'`
   - `grep -iE 'libinput|touchpad|i2c-hid|jump' /var/log/Xorg.0.log | tail -n 200`

## Common causes

- KDE input settings drift:
  - Wrong accel profile or very low pointer acceleration.
- Gesture daemon interference:
  - `libinput-gestures` or similar background tools can degrade two-finger events.
- Kernel/device state fault:
  - Typical signs:
    - `i2c_hid_acpi ... incomplete report`
    - `kernel bug: Touch jump detected and discarded`

## Recovery sequence

### 1. Rule out settings and user-session issues

- Inspect KDE config:
  - `~/.config/kcminputrc`
  - `~/.config/touchpadxlibinputrc`
- Reasonable checks:
  - Mouse accel profile should usually prefer adaptive over forced flat.
  - Touchpad `pointerAcceleration` should not be accidentally near zero.
- Reload KDE touchpad handling:
  - `qdbus6 org.kde.kded6 /kded org.kde.kded6.reconfigure`
  - `qdbus6 org.kde.kded6 /modules/kded_touchpad org.kde.touchpad.disable`
  - `qdbus6 org.kde.kded6 /modules/kded_touchpad org.kde.touchpad.enable`

### 2. Rule out gesture-daemon interference

- Check for common daemons:
  - `pgrep -af 'libinput-gestures|libinput-debug-events'`
  - `systemctl --user list-units --all --plain --no-legend | grep -i 'libinput.*gestures'`
- If present, stop or restart them before deeper action:
  - `systemctl --user restart '<unit>'`
  - or temporarily stop:
    - `systemctl --user stop '<unit>'`

### 3. Escalate only on kernel/device evidence

If logs show repeated libinput jump errors or `i2c_hid_acpi` incomplete reports, prefer a targeted I2C HID rebind rather than rebooting the whole session first.

Recommended helper:
- `scripts/rebind-touchpad.sh --dry-run`
- `scripts/rebind-touchpad.sh`

This helper:
- Finds the touchpad event device.
- Walks up sysfs to the parent `i2c-*` node.
- Detects the matching I2C HID driver.
- Runs a `pkexec`-backed unbind/bind on that device only.

## Manual fallback

If the script cannot resolve the device automatically, derive the parent I2C node from sysfs:

1. Find the touchpad event:
   - `sed -n '/Touchpad/,+12p' /proc/bus/input/devices`
2. Resolve sysfs:
   - `readlink -f /sys/class/input/event5/device`
3. Walk up until you find a parent like `i2c-PNP0C50:00`.
4. Rebind only that node:

```bash
pkexec /bin/sh -lc '
echo i2c-PNP0C50:00 > /sys/bus/i2c/drivers/i2c_hid_acpi/unbind &&
sleep 1 &&
echo i2c-PNP0C50:00 > /sys/bus/i2c/drivers/i2c_hid_acpi/bind
'
```

## Verification

- Re-check recent logs:
  - `journalctl --since '2 minutes ago' --no-pager | grep -iE 'i2c_hid|touchpad|libinput|input'`
- Confirm the device was re-enumerated:
  - `libinput list-devices | sed -n '/Touchpad/,+24p'`
- Then test:
  - Cursor movement
  - Two-finger scrolling
  - Tap and click behavior

## When not to use

- External USB mouse only issues
- Obvious hardware breakage such as no input device appearing at all after boot
- Broad system instability where a full reboot is already required
