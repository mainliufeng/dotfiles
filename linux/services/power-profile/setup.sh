#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

profile="balanced"
dry_run=0
uninstall=0

usage() {
  cat <<'EOF'
Usage: setup.sh [options]

Set the ACPI platform profile to a fixed value at boot, so the machine does not
silently keep whatever the EC/BIOS booted with (on the X1 Carbon that is
"low-power", which caps the package at 2.4 GHz and held it at 95 C).

Installs, as root:

  /usr/local/bin/platform-profile                     (from this module)
  /etc/systemd/system/platform-profile.service         (from this module)
  /etc/udev/rules.d/90-platform-profile.rules          (from this module)
  /etc/systemd/system/platform-profile.service.d/profile.conf   (only with --profile)

then enables and starts platform-profile.service.

Options:
  --profile <name>   low-power | balanced | performance (default: balanced)
  --uninstall        Remove every installed file and disable the unit
  --dry-run          Print the actions without changing the machine
  -h, --help         Show this help

Requires an ACPI platform profile (check /sys/firmware/acpi/platform_profile_choices).
Machines without one are left alone. If you would rather have the desktop UI and
automatic AC/battery switching handled for you, install power-profiles-daemon
instead of this module - the two would fight over the same attribute.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || { echo "--profile needs a value" >&2; exit 2; }
      profile="$2"
      shift 2
      ;;
    --uninstall) uninstall=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[power-profile] this installer is Linux-only" >&2
  exit 1
fi

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  as_root=()
else
  as_root=(sudo)
fi

run() {
  if [[ "$dry_run" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

unit_path=/etc/systemd/system/platform-profile.service
rules_path=/etc/udev/rules.d/90-platform-profile.rules
helper_path=/usr/local/bin/platform-profile
dropin_dir=/etc/systemd/system/platform-profile.service.d
dropin_path="$dropin_dir/profile.conf"

# 1. Uninstall ---------------------------------------------------------------
if [[ "$uninstall" == "1" ]]; then
  run "${as_root[@]}" systemctl disable --now platform-profile.service || true
  run "${as_root[@]}" rm -f "$unit_path" "$rules_path" "$helper_path" "$dropin_path"
  run "${as_root[@]}" rmdir "$dropin_dir" 2>/dev/null || true
  run "${as_root[@]}" systemctl daemon-reload
  run "${as_root[@]}" udevadm control --reload-rules
  echo "[power-profile] removed. The profile now follows the firmware again."
  exit 0
fi

# 2. Preconditions -----------------------------------------------------------
profile_file=/sys/firmware/acpi/platform_profile
choices_file=/sys/firmware/acpi/platform_profile_choices

if [[ ! -e "$profile_file" ]]; then
  echo "[power-profile] $profile_file is missing: this machine exposes no ACPI platform profile, nothing to do."
  exit 0
fi

choices="$(cat "$choices_file" 2>/dev/null || true)"
if [[ " $choices " != *" $profile "* ]]; then
  echo "[power-profile] '$profile' is not one of: ${choices:-<unreadable>}" >&2
  echo "[power-profile] current value is: $(cat "$profile_file")" >&2
  exit 1
fi

# 3. Install -----------------------------------------------------------------
run "${as_root[@]}" install -m 0755 "$module_dir/platform-profile" "$helper_path"
run "${as_root[@]}" install -m 0644 "$module_dir/platform-profile.service" "$unit_path"
run "${as_root[@]}" install -m 0644 "$module_dir/90-platform-profile.rules" "$rules_path"

# The unit defaults to balanced; anything else goes in a drop-in so the shipped
# unit stays identical to the one in this repo.
if [[ "$profile" == "balanced" ]]; then
  run "${as_root[@]}" rm -f "$dropin_path"
else
  run "${as_root[@]}" install -d "$dropin_dir"
  if [[ "$dry_run" == "1" ]]; then
    echo "[dry-run] write $dropin_path (PLATFORM_PROFILE=$profile)"
  else
    printf '[Service]\nEnvironment=PLATFORM_PROFILE=%s\n' "$profile" | "${as_root[@]}" tee "$dropin_path" >/dev/null
  fi
fi

run "${as_root[@]}" systemctl daemon-reload
run "${as_root[@]}" udevadm control --reload-rules
run "${as_root[@]}" systemctl enable --now platform-profile.service

# 4. Verify ------------------------------------------------------------------
if [[ "$dry_run" == "1" ]]; then
  echo "[dry-run] not verifying; rerun without --dry-run"
  exit 0
fi

# An unmet ConditionPathExists is not a failure: the unit is enabled and will
# apply as soon as the attribute appears (e.g. booting the X1 again).
if [[ "$(systemctl show -p ConditionResult --value platform-profile.service)" == "no" ]]; then
  echo "[power-profile] enabled, but this boot does not expose $profile_file yet; it will apply when it does."
  exit 0
fi

systemctl --no-pager --lines=0 status platform-profile.service || true

applied="$(cat "$profile_file")"
if [[ "$applied" != "$profile" ]]; then
  echo "[power-profile] FAILED: requested $profile but the kernel reports $applied" >&2
  echo "[power-profile] journalctl -u platform-profile.service" >&2
  exit 1
fi

cat <<EOF

[power-profile] done. profile=$applied
  The boot oneshot is enabled; the udev rule re-applies it after an AC transition.
  Change the value later with:  sudo systemctl edit platform-profile.service
EOF
