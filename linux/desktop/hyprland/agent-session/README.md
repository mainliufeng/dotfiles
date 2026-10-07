# 日常 Hyprland Agent 会话

这是系统 Hyprland 的可回退替换入口。SDDM 的原有 Hyprland 登录项不变；登录 zsh 在该入口中把本目录加入 PATH，系统 start-hyprland watchdog 随后启动本目录的 Hyprland 包装器和已验证的 fork。其他登录项、TTY 和系统包不变。

`hyprland.lua` 是已迁移的原生 Lua 配置，之后直接维护该文件；`hyprland.autostart.json` 保留启动项。原 hyprland.conf 保留供撤销。桌面脚本直接调用新版 Lua API，`hyprctl` 使用系统正式工具，不提供旧命令兼容层。

数字工作区 1–10 绑定到笔记本屏幕，供 Super+数字切换；Agent 从 11 开始，避免私有输出占用人的快捷键。

登录后先创建 agent1/2/3（WS11/12/13，各自私有虚拟输出，默认暂停），再启用 Cornice Agent 面板并启动原有应用。

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

2026-10-07 移除 PATH 中的 `hyprctl` 代理、旧命令转换器及一次性配置转换脚本。
Hyprvoice 自身已改用新版 `hl.dsp.send_shortcut`，不依赖 dotfiles 代理。
实际回归使用与当前会话相同的已安装合成器，在私有嵌套会话通过系统
`/usr/bin/hyprctl` 验证中文粘贴与 Ctrl 释放、窗口循环、置顶/浮动/全屏、
包含引号与 Lua 分隔符的中文工作区、布局命令和 DPMS：`/tmp/ad-zrj541x2`。

本目录只管理本地版本选择与登录启动。seat、独立输入/截图、human/full 锁及休眠门禁
均由 Hyprland 和 Cornice 原生实现；直接运行合成器与 Cornice 不依赖这里的登录脚本。
