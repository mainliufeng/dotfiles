# quartz-web

把 `~/Documents/vaults/` 下的外部 Obsidian 库发布成**只读网站**，通过 Tailscale
给手机浏览器看，并且可以「添加到主屏幕 / 安装成 App」（PWA）。

## 为什么不是 Obsidian 手机端

Obsidian 手机 App 只能打开手机本地文件夹，没有"连接远程 vault"的能力。要做到
**数据留在电脑、手机远程看**，只能让电脑当服务器、手机用浏览器。Quartz 把 vault
渲染成带双链、关系图谱、反向链接和搜索的静态站，阅读体验接近 Obsidian。

## 原理

```
~/Documents/vaults/<vault>          # md 真源，只读，一个字节不动
        │  quartz build -d <vault> -o <out>
        ▼
~/Code/self/quartz-sites/<name>/public     # 静态产物
        │  quartz-web-serve（每站一个本地端口，绑 127.0.0.1 + Tailscale IP）
        ▼
tailscale serve --https=443 --set-path=/<name>   # tailnet 内 HTTPS，有效证书
        ▼
https://liufeng-82tk.<tailnet>.ts.net/<name>/   →  手机浏览器 / 安装成 App
```

一个 Quartz checkout（`~/Code/source/quartz`）服务所有站点：每次构建按其
`sites.conf` 定义写一份 `quartz.config.yaml`，指向对应 vault。Quartz 源码是上游
仓库，**不做任何修改**（配置是本地生成的 `quartz.config.yaml`，不受 `git pull` 影响）。

## 命令

```bash
quartz-web-build              # 重建全部站点
quartz-web-build gefei-ask    # 只重建一个
quartz-web-serve              # 前台运行多站静态服务（systemd 也会跑它）
```

产物和构建日志在 `~/Code/self/quartz-sites/<name>/`。

## 安装 / 自启

```bash
~/dotfiles/linux/setup.sh --platform-only     # 含本模块
# 或者单独：
bash ~/dotfiles/linux/apps/quartz-web/setup.sh
~/dotfiles/link.sh --platform-only
```

`setup.sh` 会：确保 Quartz checkout 和依赖 → 写 `~/.config/systemd/user/quartz-web.service`
并 enable → 为每个站点配 `tailscale serve` HTTPS。

## 站点清单

编辑 [sites.conf](sites.conf)，每行：

```
name|vault(相对 $HOME)|页面标题|App 短名|本地端口|公开路径前缀
```

为什么用**路径**而不是**端口**：Tailscale 只允许 443 / 8443 / 10000 三个 HTTPS
端口，而 443 的根路径（Knowledge Workbench）和 8443 已被其它服务占用。Tailscale
Serve 会在转发前**剥掉路径前缀**，所以本地服务仍从 `/` 开始，但构建时必须传
`--baseDir <前缀>`，否则 `404.html` 里的绝对资源路径会缺前缀。

## 已知坑（都已在脚本里处理）

- **esbuild 死锁**：Quartz 默认按 CPU 核数起 worker，esbuild service 模式会
  `all goroutines are asleep - deadlock!`。必须 `--concurrency 2`。
- **npm ≥ 11 拦 install 脚本**：esbuild 的 postinstall 被拦会导致构建缺二进制。
  需要 `npm install-scripts approve esbuild @parcel/watcher && npm rebuild`。
- **clean URL**：Quartz 链接不带 `.html`，且未知路径要靠 `404.html` 让 SPA 接管。
  `python3 -m http.server` 两者都不支持，所以 `quartz-web-serve` 自己实现。
- **Quartz 不自带根首页**：vault 没有根 `index.md` 时 `/` 是空的。
  `quartz-web-postprocess` 会找 vault 的首页笔记做跳转，找不到就生成目录落地页。
- **非法 YAML frontmatter 会直接中断构建**：源 vault 里有一篇 title 内嵌 ASCII 直引号
  （`title: "…"排学"…"`），YAML 解析失败。已改成单引号。换 vault 时若构建秒退，
  先查 `~/Code/self/quartz-sites/<name>/build.log`。
- **OG 图插件会崩**：`@quartz-community/og-image` 遇到 keycap emoji（`1️⃣`）报
  `codepoint 31-20e3 not found in map`。私有镜像不需要社交预览图，已在 base config 里关掉。

## 边界

- **只读**：改了 vault 要重新 `quartz-web-build`。
- 只支持核心 Markdown/Obsidian 语法；社区插件（Dataview 等）和 `.canvas` 不渲染。
- 站点在 tailnet 内，**不要** `tailscale funnel`（那会暴露到公网）。
