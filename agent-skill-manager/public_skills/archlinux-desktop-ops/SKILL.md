---
name: archlinux-desktop-ops
description: 仅用于 mainliufeng 的 Arch Linux / Hyprland 笔记本。用于管理 Hyprland workspace/window、蓝牙耳机连接与音频路由、触摸板异常恢复，以及调用 dotfiles 中已有桌面脚本；不要在 macOS 上使用。
---

# Arch Linux Desktop Ops

这个 skill 覆盖 mainliufeng 本机 Arch Linux + Hyprland 桌面环境的日常操作。

如果当前主机不是 Arch Linux，或者没有 Hyprland 相关命令和配置，直接说明该 skill 不适用，不要尝试把这些命令迁移到 macOS。

## 使用场景

- 创建、关闭、切换 Hyprland workspace
- 打开标准开发窗口布局
- 移动、聚焦、浮动、调整 Hyprland 窗口
- 连接或排障蓝牙耳机
- 切换蓝牙耳机 A2DP / HFP / speaker 音频路由
- 触摸板突然变慢、漂移、双指滚动异常时恢复

## Hyprland

优先使用本 skill 自带脚本，而不是临时拼复杂 `hyprctl` 命令。

常用脚本：

```bash
scripts/hypr-ws-create.sh <workspace>
scripts/hypr-ws-close.sh <workspace>
scripts/hypr-ws-open-project.sh <workspace> <project-path>
scripts/hypr-ws-open-terms.sh <workspace> <count>
scripts/hypr-win-focus.sh <rule>
scripts/hypr-win-move.sh <workspace>
scripts/hypr-win-float.sh
scripts/hypr-win-resize.sh <width> <height>
scripts/hypr-win-center.sh
scripts/hypr-win-pick.sh
scripts/hypr-list-clients.sh
```

默认开发布局：

- Codex / shell / Neovim 三窗口
- 先确认目标项目路径存在
- 如果已有同名 workspace，先询问是否复用或关闭

## Bluetooth Earbuds

常用检查：

```bash
run0 systemctl status bluetooth.service
bluetoothctl show
rfkill list bluetooth
pactl list cards short | rg bluez_card
pactl list sinks short | rg bluez_output
```

配对流程：

1. 让耳机进入真正配对模式，不只是打开盒盖。
2. 确认手机端已断开该耳机。
3. 运行 `bluetoothctl`：
   - `agent on`
   - `default-agent`
   - `scan on`
   - `pair <MAC>`
   - `trust <MAC>`
   - `connect <MAC>`
4. 用 `bluetoothctl info <MAC>` 确认 `Paired: yes` 和 `Connected: yes`。

常见失败：

- `org.bluez.Error.InProgress`：先 `cancel-pairing <MAC>` 再重试。
- `org.bluez.Error.AuthenticationCanceled`：重新进入配对模式，断开手机侧连接。
- `org.bluez.Error.Failed br-connection-canceled`：尝试 `bearer <MAC> bredr` 后连接音频 UUID。

音频路由：

```bash
pactl set-card-profile <bluez_card> a2dp-sink
pactl set-card-profile <bluez_card> headset-head-unit
pactl set-default-sink <sink_name>
pactl set-default-source <source_name>
pactl list sink-inputs short | awk '{print $1}' | xargs -r -I{} pactl move-sink-input {} <sink_name>
```

本仓库已有：

- `~/dotfiles/linux/desktop/hyprland/scripts/waybar-bluetooth.sh`
- `~/dotfiles/linux/desktop/hyprland/scripts/audio-route-menu.sh`
- `~/dotfiles/linux/desktop/hyprland/waybar/config` 中的 `custom/bluetooth`

需要 UI 菜单时，优先调用或修补这些脚本。

## Touchpad Recovery

适用症状：

- 触摸板突然变慢、漂移、卡顿
- 双指滚动失效或明显变差
- KDE / libinput 会话出现 touchpad 或 `i2c-hid` 相关异常

排查顺序：

1. 先排除桌面设置和用户会话问题。
2. 再排查 `libinput-gestures` 等后台手势工具干扰。
3. 只有看到 kernel/device 证据时才升级到设备重绑。

常用命令：

```bash
libinput list-devices
hyprctl devices
journalctl -k -b | rg -i 'touchpad|i2c|hid|libinput'
```

恢复脚本：

```bash
scripts/rebind-touchpad.sh
```

执行设备重绑前，先确认目标设备和当前会话状态；不要把重绑当成第一步。

## 结束前检查

- Hyprland 操作后，用 `hyprctl clients` 或 `hyprctl activeworkspace` 验证结果。
- 蓝牙操作后，用 `bluetoothctl info <MAC>` 和 `pactl list cards short` 验证连接与音频 profile。
- 触摸板恢复后，让用户实际滑动和双指滚动确认体感。
