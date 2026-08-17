# deepseek-harness

把 [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) 的 Web UI 包成一个 macOS / Linux 都能用的桌面 app。

上游本身只提供 `npx @deepseek-ai/dsh web`，会在 `http://127.0.0.1:3080` 起一个 Web UI，但不会自动打开浏览器。这个模块做两件事：

1. 提供一个 `dsh-app` 启动器：起服务 → 等端口就绪 → （命令行场景）用默认浏览器打开。
2. 生成真正的桌面 app：
   - macOS：`~/Applications/DeepSeek Harness.app` —— 原生 WKWebView **独立窗口**（非浏览器、无地址栏、非 Electron，双击即开，有自己的图标）
   - Linux：`~/.local/share/applications/deepseek-harness.desktop`（指向 `dsh-app`，用系统默认浏览器）

> 服务本体 `@deepseek-ai/dsh` 不在安装时预装，首次启动时由 `npx` 按需拉取（之后有本地缓存）。

## 安装

把本仓库 clone 下来后（或你已有 dotfiles checkout），在机器上跑一次模块安装：

```bash
# 只装这一个模块
cd ~/dotfiles
./deepseek-harness/setup.sh

# 或走整套 dotfiles 流程（本模块已注册为 common 模块）
./setup.sh && ./link.sh
```

安装后：

```bash
# 命令行启动
dsh-app

# 指定端口 / 只起服务不开浏览器
dsh-app --port 8080
dsh-app --no-open
```

也可以直接点击桌面图标 / Spotlight 搜索 "DeepSeek Harness" 打开。

## 实现说明

- `bin/dsh-app`：跨平台启动脚本。`dsh` 命令解析顺序为 `$DSH_BIN` → PATH 上的 `dsh` → `npx @deepseek-ai/dsh@latest`。命令行用它时，起服务后会用默认浏览器打开（`--no-open` 可关掉）。
- `src/deepseek-harness.swift`：macOS 原生壳，用 WKWebView 起一个**独立窗口**（无浏览器 chrome、无 Electron 下载），起服务后用轮询等就绪，再加载本地 URL。窗口关闭即结束服务。
- `setup.sh`：按平台安装桌面入口。
  - macOS：用系统 `swiftc` 编译 `src/deepseek-harness.swift` 成原生 arm64 二进制，包进手写的 `.app` bundle（不需要 Xcode 工程）。图标由官方 `favicon.svg` 转成 `.icns`。
  - Linux：生成 `.desktop` 指向 `~/.local/bin/dsh-app`。
- `assets/icon.svg`：取自上游 `apps/web/public/favicon.svg`（DeepSeek 官方鲸鱼 logo）。

## 依赖

- 已装好 Node.js（跑 `npx` 需要）。
- macOS 需要 Xcode Command Line Tools（`swiftc`，编译原生壳用；`xcode-select --install` 装）。
- Linux 用 `xdg-open` 打开默认浏览器。
