#!/bin/bash

# Claude Code 完成通知 Hook
# 读取 hook 输入 (JSON格式)
input=$(cat)

# 提取会话信息
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
hook_event=$(echo "$input" | jq -r '.hook_event_name // "Stop"')
cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
project_name=$(basename "$cwd")

# 通知配置
title="Claude Code 执行完成"
message="项目: $project_name\n会话: ${session_id:0:8}"

send_linux_notification() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -a "Claude Code" "$title" "$message"
        return 0
    fi
    return 1
}

send_windows_notification() {
    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -Command "
Add-Type -AssemblyName System.Windows.Forms
\$notification = New-Object System.Windows.Forms.NotifyIcon
\$notification.Icon = [System.Drawing.SystemIcons]::Information
\$notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
\$notification.BalloonTipTitle = '$title'
\$notification.BalloonTipText = '$message'
\$notification.Visible = \$true
\$notification.ShowBalloonTip(5000)
Start-Sleep -Seconds 2
\$notification.Dispose()
" 2>/dev/null
        return 0
    fi
    return 1
}

if ! send_linux_notification; then
    send_windows_notification || echo "$title - $message"
fi

# 可选：同时在终端播放提示音（如果支持）
if command -v paplay &> /dev/null; then
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
fi

# 记录日志（可选）
log_file="$HOME/.claude/hooks.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stop hook triggered - Project: $project_name, Session: ${session_id:0:8}" >> "$log_file"

exit 0
