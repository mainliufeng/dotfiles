# power-profile (ACPI platform profile / Lenovo thermal mode)

Pins the ACPI platform profile to a fixed value at boot, and re-applies it after
an AC transition.

```bash
~/dotfiles/linux/services/power-profile/setup.sh              # balanced (default)
~/dotfiles/linux/services/power-profile/setup.sh --profile performance
~/dotfiles/linux/services/power-profile/setup.sh --dry-run
~/dotfiles/linux/services/power-profile/setup.sh --uninstall
```

Installs (as root) a helper, a oneshot unit, a udev rule, and optionally a
drop-in for a non-default profile; then enables and starts the unit. The module
is in `linux/services/` rather than `linux/apps/` because the point of it is the
boot-time unit, not the helper.

## Why

On the X1 Carbon the firmware boots with `low-power` and **nothing on the machine
manages the attribute**: `power-profiles-daemon`, `tuned`, `TLP` and `powerdevil`
are all absent, so `low-power` survives every reboot. `low-power` caps the
package at ~2.4 GHz, and combined with a workload that pinned two cores it held
`x86_pkg_temp` at 95–97 °C and throttled the compositor into
`kwin_wayland: The main thread was hanging temporarily!`.

```console
$ cat /sys/firmware/acpi/platform_profile{,_choices}
low-power
low-power balanced performance
```

After switching to `balanced`: 95 °C → 56 °C, load 4.2 → 1.0, and the package
boosts normally instead of sitting at the throttled 2.4 GHz floor.

## Files

| Installed path | From |
| --- | --- |
| `/usr/local/bin/platform-profile` | `platform-profile` |
| `/etc/systemd/system/platform-profile.service` | `platform-profile.service` |
| `/etc/udev/rules.d/90-platform-profile.rules` | `90-platform-profile.rules` |
| `/etc/systemd/system/platform-profile.service.d/profile.conf` | generated, only with `--profile <non-balanced>` |

The helper is also usable on its own: `platform-profile` prints the current value
and the choices, `platform-profile performance` sets one. It validates the value
against `platform_profile_choices` first — the kernel accepts anything and
silently keeps the old value, so an unvalidated write would look like success.

## Why the unit is skipped on the Yoga

`platform-profile.service` carries `ConditionPathExists=/sys/firmware/acpi/platform_profile`.
The attribute only exists when the firmware publishes an ACPI platform profile,
so on a machine without one the unit is enabled but skipped rather than failed.
`setup.sh` treats `ConditionResult=no` as success and says so.

## Why a udev rule as well

The profile attribute is a firmware attribute: no udev device, no uevent. But the
EC may pick a profile by itself when the charger is plugged or unplugged, which
would silently undo the boot oneshot. The rule therefore watches the AC adapter
(`SUBSYSTEM=="power_supply", ATTR{type}=="Mains"`) and runs `systemctl --no-block
try-restart platform-profile.service`.

`try-restart` rather than `restart`, so a machine where this module was disabled
or removed does not get the unit resurrected by a charger event.

## Trade-off

`balanced` is faster but hotter than `low-power`. If a quiet, cool machine
matters more than speed, keep `low-power` and delete this module instead.

## Alternative

`power-profiles-daemon` does the same job and more: a D-Bus interface, automatic
AC/battery switching, and integration with the KDE power applet. It is the better
choice if the profile should follow the desktop's power mode. It writes the same
attribute, so **do not run both** — pick one.
