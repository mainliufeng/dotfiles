# Telegram Codex Gateway Ops

这个服务本体在 `mobius` 仓库：

- `~/Code/self/mobius/apps/telegram-codex-gateway/service`

macOS 上由本目录提供 dotfiles 运维入口：

- `~/.local/bin/telegram-codex-gateway`

Linux 上仍可使用 `mobius` 仓库内的 systemd 脚本：

- `apps/telegram-codex-gateway/service/scripts/telegram-codex-gateway`

## macOS 安装

```bash
cd ~/dotfiles
./link.sh --platform macos --platform-only
./setup.sh --platform macos --platform-only
```

安装动作会：

- 从 `~/Code/self/mobius` 构建 `@mobius/telegram-codex-gateway-service`
- 在 `~/.local/share/telegram-codex-gateway/release.json` 记录当前 mobius 工作区
- 链接命令到 `~/.local/bin/telegram-codex-gateway`
- 写入 LaunchAgent 到 `~/Library/LaunchAgents/com.mainliufeng.telegram-codex-gateway.plist`
- 如缺少配置，创建 `~/.config/telegram-codex-gateway.env` 模板

配置好 token 后启动：

```bash
telegram-codex-gateway env-edit
telegram-codex-gateway start
telegram-codex-gateway health
```

macOS 环境变量文件至少需要：

```bash
TG_GATEWAY_BOT_TOKEN=123456:replace_me
TG_GATEWAY_PROVIDER=codex-sdk
CODEX_PATH=/Users/liufeng/.local/bin/codex
AGENT_CWD=/Users/liufeng/Code/self/mobius
TG_GATEWAY_ALLOWED_CHAT_IDS=
TG_GATEWAY_HTTP_HOST=127.0.0.1
TG_GATEWAY_HTTP_PORT=7408
```

## Linux 首次安装

```bash
cd ~/Code/self/mobius/apps/telegram-codex-gateway/service
./scripts/telegram-codex-gateway deploy
```

这会把服务安装到本地目录并注册 systemd：

- `~/.local/share/telegram-codex-gateway/app`
- `~/.config/systemd/user/telegram-codex-gateway.service`
- `~/.local/bin/telegram-codex-gateway`

## 日常命令

```bash
telegram-codex-gateway doctor
telegram-codex-gateway status
telegram-codex-gateway logs 200
telegram-codex-gateway follow
telegram-codex-gateway health
telegram-codex-gateway restart
telegram-codex-gateway env-edit
telegram-codex-gateway jobs-edit
```
