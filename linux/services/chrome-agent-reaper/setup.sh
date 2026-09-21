#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotfiles_root="$(cd "$module_dir/../../.." && pwd)"
reaper="$dotfiles_root/scripts/chrome-agent-reap"
bin_dir="$HOME/.local/bin"

dry_run=0
start_now=1
uninstall=0

usage() {
  cat <<'EOF'
Usage: setup.sh [options]

Periodically close stale tabs in the agent-only Chrome (CDP 9222), so a long
lived agent profile does not accumulate dozens of tabs and tens of GB of RAM.

Why this exists: Chrome's Memory Saver cannot help here. chrome-devtools-mcp
attaches a DevTools client to every tab it drives, and Chrome never discards an
attached tab — measured 69 of 70 tabs attached, so Memory Saver was nominally on
and did nothing. Reclaiming those tabs has to be explicit.

  1. link chrome-agent-reap into ~/.local/bin (+ the units into ~/.config/systemd/user)
  2. systemctl --user enable --now chrome-agent-reaper.timer
  3. run once with --dry-run to show what the first cycle would do

Options:
  --dry-run    Print the actions without changing the machine
  --no-start   Enable the timer but do not start it now
  --uninstall  Disable the timer and remove the linked units/symlink
  -h, --help   Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --no-start) start_now=0; shift ;;
    --uninstall) uninstall=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

run() {
  if [[ "$dry_run" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[chrome-agent-reaper] this installer is Linux-only" >&2
  exit 1
fi

if [[ "$uninstall" == "1" ]]; then
  run systemctl --user disable --now chrome-agent-reaper.timer
  if [[ "$dry_run" != "1" ]]; then
    unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
    rm -f "$unit_dir/chrome-agent-reaper.service" "$unit_dir/chrome-agent-reaper.timer"
    rm -f "$HOME/.local/bin/chrome-agent-reap"
    systemctl --user daemon-reload
  fi
  echo "[chrome-agent-reaper] uninstalled (the reaper script itself stays in dotfiles)"
  exit 0
fi

# 1. Link --------------------------------------------------------------------
run "$module_dir/link.sh"

# 2. Timer -------------------------------------------------------------------
run systemctl --user enable chrome-agent-reaper.timer
if [[ "$start_now" == "1" ]]; then
  run systemctl --user restart chrome-agent-reaper.timer
fi

if [[ "$dry_run" == "1" ]]; then
  echo "[dry-run] node $reaper --dry-run"
  exit 0
fi

# 3. Checks ------------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
  echo "[chrome-agent-reaper] warning: node is not on PATH; the unit calls /usr/bin/node directly" >&2
fi

systemctl --user --no-pager --lines=0 list-timers chrome-agent-reaper.timer || true

# 首次跑只登记、不关任何东西，所以这一步是安全的冒烟测试。
# 有意走 ~/.local/bin 的 symlink 而不是真实路径：symlink 调用曾经因为 import.meta
# 守卫比较字面路径而静默什么都不做（无输出、exit 0），只看真实路径是发现不了的。
echo
echo "[chrome-agent-reaper] smoke test (dry-run, 不会关任何 tab):"
smoke_out="$("$bin_dir/chrome-agent-reap" --dry-run 2>&1 || true)"
printf '%s\n' "$smoke_out"
if [[ -z "${smoke_out//[[:space:]]/}" ]]; then
  cat >&2 <<EOF
[chrome-agent-reaper] ERROR: $bin_dir/chrome-agent-reap 没有任何输出。
  这意味着 timer 会每 15 分钟“成功”地什么都不做。检查 $reaper 的 CLI main() 守卫。
EOF
  exit 1
fi

cat <<'EOF'

[chrome-agent-reaper] done.

  chrome-agent-reap --dry-run          看这一轮会关什么
  chrome-agent-reap                    立刻回收一次
  chrome-agent-reap --quit-if-idle     没有任何 CDP 客户端连着时连浏览器一起收掉
  journalctl --user -u chrome-agent-reaper.service -n 20

TTL 默认普通页 45 分钟、搜索页 10 分钟，可用 CHROME_AGENT_REAP_TTL /
CHROME_AGENT_REAP_TTL_SEARCH 覆盖（写进 `systemctl --user edit` 的 drop-in 更稳）。
EOF
