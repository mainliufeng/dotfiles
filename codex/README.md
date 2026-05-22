# Codex CLI Configuration

Managed configuration template for `~/.codex`. Run `~/dotfiles/codex/link.sh` (或仓库根目录的 `link.sh`) 将 `config.toml` 复制到运行时位置。

`~/.codex/config.toml` 必须是运行时文件，而不是指向本仓库的软链。Codex App 会在使用过程中写入项目 trust、迁移提示状态等本机状态；如果这里使用软链，这些运行时改动会直接污染 dotfiles repo。

默认行为：

- `~/.codex/config.toml` 不存在时，从 `~/dotfiles/codex/config.toml` 复制一份。
- `~/.codex/config.toml` 是旧软链时，保留当前内容并替换成真实文件。
- `~/.codex/config.toml` 已经是真实文件时，默认不覆盖。
- 如需强制用模板覆盖运行时配置，执行 `DOTFILES_CODEX_OVERWRITE_CONFIG=1 ~/dotfiles/codex/link.sh`。

Codex App 的内置 terminal/code font 由 `~/.codex/.codex-global-state.json` 管理。`link.sh` 会调用
`~/dotfiles/codex/apply-app-font.sh`，默认将 chrome theme 的 `fonts.code` 设置为 `Hack Nerd Font Mono`，避免 prompt 图标在 App terminal 里显示成方块。执行后如当前窗口还没变化，Reload Window 或重启 Codex App 即可。

`link.sh` 还会把 `~/dotfiles/codex/agents/*.toml` 链接到 `~/.codex/agents/`。其中
`spark` 使用 `gpt-5.3-codex-spark` 做快速、低风险的 subagent 任务；配合 `spark`
skill，可在 Codex App 中用 `$spark` 触发它。

## Proxy launcher

On macOS, `macos/link.sh` links `macos/bin/codex-app-proxy` into
`~/.local/bin`. It launches Codex with explicit proxy environment variables for
the local Clash Verge port:

```bash
codex-app-proxy --check
codex-app-proxy
codex-app-proxy --cli --version
```

`macos/link.sh` also links `macos/apps/Codex Proxy.app` into
`~/Applications/Codex Proxy.app`, so it can be launched from Finder, Spotlight,
or the Dock without typing the command each time.

Defaults:

- `HTTP_PROXY` / `HTTPS_PROXY`: `http://127.0.0.1:7897`
- `ALL_PROXY`: `socks5://127.0.0.1:7897`
- `NO_PROXY`: `localhost,127.0.0.1,::1`

Override with `CODEX_PROXY_PORT`, `CODEX_HTTP_PROXY`, `CODEX_ALL_PROXY`, or
`CODEX_NO_PROXY` when needed.

## Rcrai app launcher

`macos/link.sh` also installs `~/Applications/Codex Rcrai.app`. It launches the
same Codex.app binary with a separate `CODEX_HOME` and maps
`RCRAI_OPENAI_API_KEY` to `OPENAI_API_KEY` only for that app instance.

Defaults:

- `CODEX_HOME`: `~/.codex-rcrai`
- `OPENAI_BASE_URL`: `https://eng-coding.speaklyai.com/v1`
- `OPENAI_API_KEY`: copied from `RCRAI_OPENAI_API_KEY`

Because Finder, Spotlight, and Dock apps inherit environment variables from
launchd rather than the interactive shell, the launcher falls back to
`~/dotfiles-private/rcrai/env.sh` when `RCRAI_OPENAI_API_KEY` is missing. To
temporarily override the key, set it with:

```bash
launchctl setenv RCRAI_OPENAI_API_KEY '...'
```

Then launch `Codex Rcrai.app`. The launcher creates
`~/.codex-rcrai/config.toml` on first run and never writes the API key to disk.

配置默认启用 Chrome DevTools MCP server，并指向由 `scripts/start-chrome-remote` 启动的 Chrome/Chromium 实例：

```bash
~/dotfiles/scripts/start-chrome-remote https://codex.cloudflare.com
```

该脚本可在 Linux/WSL2 下工作，自动打开远程调试端口 `9222`。如需自定义，设置 `REMOTE_DEBUG_PORT` 或 `CHROME_TARGET` 环境变量即可。
