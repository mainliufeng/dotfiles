#!/usr/bin/env bash
set -euo pipefail

conf_path="/etc/systemd/timesyncd.conf"
backup_path="/etc/systemd/timesyncd.conf.bak.$(date +%Y%m%d%H%M%S)"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

if [[ -f "$conf_path" ]]; then
  cp -a "$conf_path" "$backup_path"
  echo "Backed up to $backup_path"
fi

cat > "$conf_path" <<'EOF'
[Time]
NTP=ntp1.aliyun.com ntp2.aliyun.com ntp3.aliyun.com ntp4.aliyun.com ntp5.aliyun.com
FallbackNTP=
EOF

systemctl restart systemd-timesyncd.service
timedatectl show-timesync --all
