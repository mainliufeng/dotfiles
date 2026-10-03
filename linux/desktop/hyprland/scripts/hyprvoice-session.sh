#!/usr/bin/env bash
set -euo pipefail
# Import the new compositor socket/display before starting the user service.
# Fresh dotfiles checkouts can be used before this optional app is installed.
[[ -x "$HOME/.local/bin/hyprvoice" ]] || exit 0
[[ -f "$HOME/.config/systemd/user/hyprvoice.service" ]] || exit 0
variables=(WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE)
if [[ -n "${DISPLAY:-}" ]]; then
  variables+=(DISPLAY)
fi
systemctl --user import-environment "${variables[@]}"
systemctl --user restart hyprvoice.service
