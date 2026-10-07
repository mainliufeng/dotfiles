# 日常 Hyprland Agent 会话

这是系统 Hyprland 的可回退替换入口。SDDM 的原有 Hyprland 登录项不变；登录 zsh 在该入口中把本目录加入 PATH，系统 start-hyprland watchdog 随后启动本目录的 Hyprland 包装器和已验证的 fork。其他登录项、TTY 和系统包不变。

`hyprland.lua` 与 `hyprland.autostart.json` 从原有 hyprland.conf 及其 source 生成，保留快捷键、主布局、外观、输入设置、应用规则和启动项；原配置保留。`hyprctl` 只在具有 Lua seat 接口的 fork 中转换现有人的脚本命令。

登录后先创建 agent1/2/3（WS10/11/12，默认暂停），再启用 Cornice Agent 面板并启动原有应用。

```sh
hyprctl -j version
cornice desktop list
cornice desktop resume agent1
cornice desktop launch agent1 -- kitty
cornice desktop bind agent1 ~/.local/state/cornice-agent-desktop/agent1.binding.json
cornice desktop observe agent1
cornice desktop pause agent1
```

首次登录后需要再次验证 DRM 物理显示器、输入、缩放和 Agent 操作。嵌套验证不能证明物理会话已经切换。

撤销：`cornice takeover --undo` 恢复登录 profile 与 Cornice 设置，再注销重登恢复系统版。紧急情况下从 TTY 执行同一命令；不需要 sudo。启动入口配置的备份路径保存在 `~/.local/state/cornice-agent-desktop/native-backup-path`。

兼容层支持 Hyprvoice 的旧 `dispatch sendshortcut`，包括普通应用 `CTRL+V` 和终端
`CTRL+SHIFT+V`。纯转换回归：`python3 linux/desktop/hyprland/agent-session/test-compat.py`。
2026-10-07 已用日常安装的 `38351820` 合成器在私有嵌套会话验证：旧命令经包装器
转换后，真实 GTK 输入框收到中文剪贴板文字。记录：`/tmp/ad-wrryt1bu`。
此次修复只补转换规则，无需注销、重启 Hyprvoice 或替换合成器。
