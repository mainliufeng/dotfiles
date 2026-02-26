# Telegram Codex Gateway Ops

运维入口统一放在 `mobius` 仓库：

- `apps/telegram-codex-gateway/service/scripts/telegram-codex-gateway`

## 首次安装

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
telegram-codex-gateway sleep-test 35
```

