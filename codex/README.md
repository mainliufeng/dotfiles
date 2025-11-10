# Codex CLI Configuration

Managed configuration for `~/.codex`. Run `~/dotfiles/codex/link.sh` (或仓库根目录的 `link.sh`) 将 `config.toml` 软链到预期位置。

配置默认启用 Chrome DevTools MCP server，并指向由 `scripts/start-chrome-remote` 启动的 Chrome/Chromium 实例：

```bash
~/dotfiles/scripts/start-chrome-remote https://codex.cloudflare.com
```

该脚本可在 Linux/WSL2 下工作，自动打开远程调试端口 `9222`。如需自定义，设置 `REMOTE_DEBUG_PORT` 或 `CHROME_TARGET` 环境变量即可。
