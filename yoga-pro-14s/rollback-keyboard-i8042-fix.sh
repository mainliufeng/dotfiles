#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -- "$0" "$@"
fi

grub_default=/etc/default/grub
grub_cfg=/boot/grub/grub.cfg
backup="${grub_default}.rollback-bak.$(date +%Y%m%d-%H%M%S)"

remove_params=(
  i8042.reset
  i8042.nomux
  atkbd.reset
)

if [ ! -f "$grub_default" ]; then
  echo "Missing $grub_default" >&2
  exit 1
fi

cp -a "$grub_default" "$backup"

line=$(grep -E '^GRUB_CMDLINE_LINUX_DEFAULT=' "$grub_default" || true)
if [ -n "$line" ]; then
  value=${line#GRUB_CMDLINE_LINUX_DEFAULT=}
  value=${value#\'}
  value=${value%\'}
  value=${value#\"}
  value=${value%\"}
else
  value=""
fi

new_value=""
for token in $value; do
  keep=1
  for param in "${remove_params[@]}"; do
    if [ "$token" = "$param" ]; then
      keep=0
      break
    fi
  done
  if [ "$keep" -eq 1 ]; then
    new_value="${new_value:+$new_value }$token"
  fi
done

tmp=$(mktemp)
awk -v value="$new_value" '
  BEGIN { replaced = 0 }
  /^GRUB_CMDLINE_LINUX_DEFAULT=/ {
    print "GRUB_CMDLINE_LINUX_DEFAULT=\047" value "\047"
    replaced = 1
    next
  }
  { print }
  END {
    if (!replaced) {
      print "GRUB_CMDLINE_LINUX_DEFAULT=\047" value "\047"
    }
  }
' "$grub_default" > "$tmp"

install -m 0644 "$tmp" "$grub_default"
rm -f "$tmp"

grub-mkconfig -o "$grub_cfg"

echo
echo "Updated $grub_default"
echo "Backup: $backup"
echo "Removed params: ${remove_params[*]}"
echo "Reboot to return to the previous keyboard-controller path."
