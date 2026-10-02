# tailnet-portal

Tailnet 的**入口页**（front door），手机装成一个 App 用。

```
https://liufeng-82tk.tail6b9726.ts.net/           → 302 → /home/（入口页）
├── /home/          入口页（本模块，scope 限定在这里）
├── /workbench/     Knowledge Workbench
├── /gefei-knowledge/ 哥飞 · 出海知识库（Quartz）
├── /gefei-ask/       哥飞 · 问大咖（Quartz）
├── /knowledge/     Knowledge 知识库（代理重写绝对路径）
├── /topic-desk/    选题台（本机私有清单）
├── :10000/         Knowledge 旧入口（转到 /knowledge/）
└── :8443/          dsh · DeepSeek Harness
```

卡片来自两个清单：`sites.tsv`（公开，入库）和 `sites.local.tsv`（本机私有，不入库）。

## 为什么入口页不能占根路径

**PWA 的 scope 不能互相嵌套。** 入口页如果 scope 是 `/`，就把 `/gefei-*`、`/workbench`
全包在自己的作用域里；在入口 App 的窗口里打开子站再「安装」，Chrome 认为还在同一个
App 范围内，于是**当成更新同一个 App**（表现为：首页图标变成了知识库，没多出新 App）。

所以入口页挪到 `/home/`（scope `/home/`），和子站成为**兄弟**而不是父子：从入口 App 点卡片
会跳出到浏览器/子 App，安装就是独立 App。根路径 302 到 `/home/`，便于直接输域名。

Android 已安装的 WebAPK 按 scheme、host 和 path 接管链接，intent filter 不包含端口。
因此，不能靠不同端口隔离手机已有的根路径 Knowledge App。Knowledge 也改为
`/knowledge/` 的独立 scope，并移除上游重复的 manifest 标签。

每个 App 使用自己的 `start_url`、`scope` 和稳定身份；显式 id 使用完整路径
（例如 `/topic-desk/`），不使用会解析到根路径的 `id: "."`。
旧 Knowledge App 的手机接管规则不会因服务器改动立即消失，需要在手机上卸载旧 App，
再从 `/knowledge/` 重装一次。桌面 Chrome 安装检查通过不代表手机桌面已出现图标。

## 命令

```bash
tailnet-portal-build     # 按 sites.tsv 重新生成页面（改了清单就跑）
tailnet-portal-serve     # 前台服务（systemd 也会跑它）
bash setup.sh            # 构建 + 装 systemd --user + 配 tailscale serve
```

## 加一个站点

编辑 [sites.tsv](sites.tsv) 加一行，然后：

```bash
 tailnet-portal-build && systemctl --user restart tailnet-portal.service
```

本机私有服务写 **`sites.local.tsv`**（同名格式，可选，已在 `.gitignore` 里）：
sites.tsv 属于公开仓库，别把只在本机跑的服务写进去。两份清单按名称去重，sites.tsv 优先。

链接写 `/path/`（同域相对路径），跨端口的写 `https://@host:8443/`（`@host` 在构建时
替换成 tailnet 域名，避免把域名写死进公共仓库）。

## 为什么 Workbench 挪到了 /workbench
入口页需要根路径。Workbench 原来占着 `/`，它的 `index.html`／`manifest`／`app.js`
用的是绝对路径（`/manifest.webmanifest`、`/sw.js`），挪到子路径会让它们指回根。
已把它们改成**相对路径**（`manifest.webmanifest`、`start_url: "."`），这样它在
**本地 `/` 和线上 `/workbench/` 都能用**，是前缀无关的正确写法。

代价：手机上已安装的 Workbench 图标如果没自动更新 start_url，需要重装一次。

## Knowledge 的独立路径

Knowledge 上游使用绝对路径。PWA 代理现在支持 wrapped.tsv 的第八列 `mount`：
对 Knowledge 使用 `/knowledge`，去掉传给上游的前缀，再将 HTML 资源/导航地址、
图谱 fetch 地址和图谱节点 href 加回该前缀。代理注入单一 manifest、独立 SW scope，
不会改动上游 Knowledge 的源码或实体数据。dsh 保留原代理配置。

## 每个站点都能装成 App

入口页、两个 Quartz 库、Workbench 自带 manifest + service worker，直接可装。
Knowledge 和 dsh 由 **`tailnet-pwa-proxy`** 提供 PNG 图标及安装配置：

```
/knowledge/ -> 127.0.0.1:8095/knowledge/ (pwa-proxy) -> Knowledge 上游
:10000/    -> 同一代理，兼容旧路径
:8443/  -> 127.0.0.1:8096 (pwa-proxy) -> http://127.0.0.1:8789        (dsh)
```

代理做三件事：自己提供 `/__pwa/{manifest,icon,sw.js,register.js}`、把 PWA 的
`<head>` 标签注入 `text/html` 响应、未指定 mount 时保留原转发行为；指定 mount 时同时重写站内导航和 Location。
要包装新服务就加一行 [wrapped.tsv](wrapped.tsv)，然后跑 `bash setup.sh`。

如果上游要求 `?token=` 认证（dsh 就是），在 wrapped.tsv 第七列填它启动时
**打印 token 的日志文件**。代理遇到 401 会自动带着 token 跳一次，浏览器拿到 cookie
后就不再需要 token。token 每次重启都会变，所以是每次请求现读日志，不写死。

三个坑：
- 上游可能无视 `Accept-Encoding: identity` 仍返回 gzip（`serve-knowledge.mjs` 就是），
  代理必须先解压再注入。
- SW 文件在安装资源目录下，需回 `Service-Worker-Allowed` 为该 App 的 scope，
  否则浏览器拒绝注册。

## 排障

```bash
systemctl --user status tailnet-portal.service
tailscale serve status
```

**桌面 Chrome 打不开 `*.ts.net`**：KDE/clash 系统代理的 bypass 没含 Tailscale 网段
（`100.64.0.0/10`），Chrome 会把请求丢给 clash 得到 `ERR_CONNECTION_CLOSED`。
手机不受影响。修法是在代理 bypass 里加 `100.64.0.0/10`。
