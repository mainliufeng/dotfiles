# Codex CLI Configuration

Managed configuration template for `~/.codex`. Run `~/dotfiles/codex/link.sh` (或仓库根目录的 `link.sh`) 将 `config.toml` 复制到运行时位置。

`~/.codex/config.toml` 必须是运行时文件，而不是指向本仓库的软链。Codex App 会在使用过程中写入项目 trust、迁移提示状态等本机状态；如果这里使用软链，这些运行时改动会直接污染 dotfiles repo。

默认行为：

- `~/.codex/config.toml` 不存在时，从 `~/dotfiles/codex/config.toml` 复制一份。
- `~/.codex/config.toml` 是旧软链时，保留当前内容并替换成真实文件。
- `~/.codex/config.toml` 已经是真实文件时，默认不覆盖。
- 如需强制用模板覆盖运行时配置，执行 `DOTFILES_CODEX_OVERWRITE_CONFIG=1 ~/dotfiles/codex/link.sh`。

配置默认启用 Chrome DevTools MCP server，并指向由 `scripts/start-chrome-remote` 启动的 Chrome/Chromium 实例：

```bash
~/dotfiles/scripts/start-chrome-remote https://codex.cloudflare.com
```

该脚本可在 Linux/WSL2 下工作，自动打开远程调试端口 `9222`。如需自定义，设置 `REMOTE_DEBUG_PORT` 或 `CHROME_TARGET` 环境变量即可。
