#!/usr/bin/env bash
set -euo pipefail

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Audio Route" "$1"
  fi
}

get_bt_card() {
  pactl list cards short | awk '$2 ~ /^bluez_card\./{print $2; exit}'
}

get_bt_mac() {
  local card="$1"
  local mac="${card#bluez_card.}"
  echo "${mac//_/:}"
}

get_sink_by_mac() {
  local mac="$1"
  pactl list sinks short | awk -v mac="$mac" '$2=="bluez_output."mac{print $2; exit}'
}

get_source_by_mac() {
  local mac="$1"
  pactl list sources short | awk -v mac="$mac" '$2=="bluez_input."mac{print $2; exit}'
}

get_internal_sink() {
  local s
  s="$(pactl list sinks short | awk '$2 ~ /^alsa_output\./ && $2 ~ /Speaker__sink$/ {print $2; exit}')"
  if [[ -n "$s" ]]; then
    echo "$s"
    return
  fi
  pactl list sinks short | awk '$2 ~ /^alsa_output\./ {print $2; exit}'
}

get_internal_source() {
  local s
  s="$(pactl list sources short | awk '$2 ~ /^alsa_input\./ && $2 ~ /Mic1__source$/ {print $2; exit}')"
  if [[ -n "$s" ]]; then
    echo "$s"
    return
  fi
  pactl list sources short | awk '$2 ~ /^alsa_input\./ {print $2; exit}'
}

move_all_sink_inputs() {
  local sink="$1"
  local ids
  ids="$(pactl list sink-inputs short | awk '{print $1}')"
  if [[ -z "$ids" ]]; then
    return
  fi
  while read -r id; do
    [[ -n "$id" ]] && pactl move-sink-input "$id" "$sink" >/dev/null 2>&1 || true
  done <<< "$ids"
}

move_all_source_outputs() {
  local source="$1"
  local ids
  ids="$(pactl list source-outputs short | awk '{print $1}')"
  if [[ -z "$ids" ]]; then
    return
  fi
  while read -r id; do
    [[ -n "$id" ]] && pactl move-source-output "$id" "$source" >/dev/null 2>&1 || true
  done <<< "$ids"
}

set_bt_a2dp() {
  local bt_card bt_mac bt_sink profile
  bt_card="$(get_bt_card)"
  if [[ -z "$bt_card" ]]; then
    notify "未检测到已连接蓝牙音频设备"
    exit 1
  fi

  for profile in a2dp-sink a2dp-sink-sbc_xq a2dp-sink-sbc; do
    if pactl set-card-profile "$bt_card" "$profile" >/dev/null 2>&1; then
      break
    fi
  done

  bt_mac="$(get_bt_mac "$bt_card")"
  sleep 0.5
  bt_sink="$(get_sink_by_mac "$bt_mac")"
  if [[ -z "$bt_sink" ]]; then
    notify "蓝牙 A2DP 输出未就绪"
    exit 1
  fi

  pactl set-default-sink "$bt_sink"
  pactl set-sink-mute "$bt_sink" 0 || true
  move_all_sink_inputs "$bt_sink"
  notify "已切到耳机高音质输出 (A2DP)"
}

set_bt_hfp() {
  local bt_card bt_mac bt_sink bt_source profile
  bt_card="$(get_bt_card)"
  if [[ -z "$bt_card" ]]; then
    notify "未检测到已连接蓝牙音频设备"
    exit 1
  fi

  for profile in headset-head-unit headset-head-unit-cvsd; do
    if pactl set-card-profile "$bt_card" "$profile" >/dev/null 2>&1; then
      break
    fi
  done

  bt_mac="$(get_bt_mac "$bt_card")"
  sleep 0.5
  bt_sink="$(get_sink_by_mac "$bt_mac")"
  bt_source="$(get_source_by_mac "$bt_mac")"

  if [[ -n "$bt_sink" ]]; then
    pactl set-default-sink "$bt_sink"
    pactl set-sink-mute "$bt_sink" 0 || true
    move_all_sink_inputs "$bt_sink"
  fi
  if [[ -n "$bt_source" ]]; then
    pactl set-default-source "$bt_source"
    move_all_source_outputs "$bt_source"
  fi

  notify "已切到耳机通话模式 (HFP, 含麦克风)"
}

set_laptop_audio() {
  local sink source
  sink="$(get_internal_sink)"
  source="$(get_internal_source)"

  if [[ -z "$sink" ]]; then
    notify "未找到笔记本扬声器"
    exit 1
  fi

  pactl set-default-sink "$sink"
  pactl set-sink-mute "$sink" 0 || true
  move_all_sink_inputs "$sink"

  if [[ -n "$source" ]]; then
    pactl set-default-source "$source"
    move_all_source_outputs "$source"
  fi

  notify "已切到笔记本扬声器/麦克风"
}

choose_action() {
  if [[ "${1:-}" != "" ]]; then
    echo "$1"
    return
  fi

  local options choice
  options=$'耳机：高音质输出 (A2DP)\n耳机：通话模式 (HFP, 含麦克风)\n笔记本：扬声器 + 麦克风'

  if command -v wofi >/dev/null 2>&1; then
    choice="$(printf '%s\n' "$options" | wofi --dmenu --prompt '音频切换' --lines 6)"
  elif command -v rofi >/dev/null 2>&1; then
    choice="$(printf '%s\n' "$options" | rofi -dmenu -p '音频切换')"
  elif command -v zenity >/dev/null 2>&1; then
    choice="$(zenity --list --title='音频切换' --column='选项' \
      '耳机：高音质输出 (A2DP)' \
      '耳机：通话模式 (HFP, 含麦克风)' \
      '笔记本：扬声器 + 麦克风' 2>/dev/null || true)"
  else
    notify "未找到 wofi/rofi/zenity"
    exit 1
  fi

  echo "$choice"
}

action="$(choose_action "${1:-}")"
case "$action" in
  "耳机：高音质输出 (A2DP)"|"bt-a2dp")
    set_bt_a2dp
    ;;
  "耳机：通话模式 (HFP, 含麦克风)"|"bt-hfp")
    set_bt_hfp
    ;;
  "笔记本：扬声器 + 麦克风"|"speaker")
    set_laptop_audio
    ;;
  "")
    exit 0
    ;;
  *)
    notify "未知操作: $action"
    exit 1
    ;;
esac
