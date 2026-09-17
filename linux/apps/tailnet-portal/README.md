# tailnet-portal

Tailnet 的**入口页**（front door），手机装成一个 App 用。

```
https://liufeng-82tk.tail6b9726.ts.net/           → 302 → /home/（入口页）
├── /home/          入口页（本模块，scope 限定在这里）
├── /workbench/     Knowledge Workbench
├── /gefei-knowledge/ 哥飞 · 出海知识库（Quartz）
├── /gefei-ask/       哥飞 · 问大咖（Quartz）
├── :10000/         Knowledge Entity Index（绝对路径，需独占端口）
└── :8443/          dsh · DeepSeek Harness
```

卡片来自两个清单：`sites.tsv`（公开，入库）和 `sites.local.tsv`（本机私有，不入库）。

## 为什么入口页不能占根路径

**PWA 的 scope 不能互相嵌套。** 入口页如果 scope 是 `/`，就把 `/gefei-*`、`/workbench`
全包在自己的作用域里；在入口 App 的窗口里打开子站再「安装」，Chrome 认为还在同一个
App 范围内，于是**当成更新同一个 App**（表现为：首页图标变成了知识库，没多出新 App）。

所以入口页挪到 `/home/`（scope `/home/`），和子站成为**兄弟**而不是父子：从入口 App 点卡片
会跳出到浏览器/子 App，安装就是独立 App。根路径 302 到 `/home/`，便于直接输域名。

`:10000` 和 `:8443` 因为**端口不同 = 不同 origin**，各自的 scope `/` 与 443 上的路径互不干扰，
所以它们可以占根路径。

⚠️ 另一个坑：manifest 里写相对 `"id": "."` 时 Chrome 会把它解析成 **origin 根 `/`**
（而不是 manifest 所在目录），反而制造嵌套。**不要写显式 `id`**，用默认值（= `start_url`）即可。

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

## 为什么 Entity Index 独占 :10000

`~/Code/self/knowledge/scripts/serve-knowledge.mjs` 的所有链接和 API 都是绝对路径
（`/research`、`/api/catalog/...`、`/entity/...`），挂到子路径会全部指回根。
Tailscale Serve 不做路径重写，所以给它根路径 = 独占一个 HTTPS 端口。

Tailscale 只允许 **443 / 8443 / 10000** 三个 HTTPS 端口；443 现在归入口页，
8443 归 dsh，10000 归 Entity Index —— 已用满。

## 每个站点都能装成 App

入口页、两个 Quartz 库、Workbench 自带 manifest + service worker，直接可装。
Entity Index 和 dsh 是别人的服务、没有 manifest，由 **`tailnet-pwa-proxy`** 反向
代理注入：

```
:10000/ -> 127.0.0.1:8095 (pwa-proxy) -> http://100.79.161.127:8787  (Entity Index)
:8443/  -> 127.0.0.1:8096 (pwa-proxy) -> http://127.0.0.1:8789        (dsh)
```

代理做三件事：自己提供 `/__pwa/{manifest,icon,sw.js,register.js}`、把 PWA 的
`<head>` 标签注入 `text/html` 响应、其余原样透传（cookie / 重定向 / SSE 都不动）。
要包装新服务就加一行 [wrapped.tsv](wrapped.tsv)，然后跑 `bash setup.sh`。

如果上游要求 `?token=` 认证（dsh 就是），在 wrapped.tsv 最后一列填它启动时
**打印 token 的日志文件**。代理遇到 401 会自动带着 token 跳一次，浏览器拿到 cookie
后就不再需要 token。token 每次重启都会变，所以是每次请求现读日志，不写死。

三个坑：
- 上游可能无视 `Accept-Encoding: identity` 仍返回 gzip（`serve-knowledge.mjs` 就是），
  代理必须先解压再注入。
- SW 文件在 `/__pwa/` 下却要控制整个 origin，必须回 `Service-Worker-Allowed: /`，
  否则浏览器拒绝注册。

## 排障

```bash
systemctl --user status tailnet-portal.service
tailscale serve status
```

**桌面 Chrome 打不开 `*.ts.net`**：KDE/clash 系统代理的 bypass 没含 Tailscale 网段
（`100.64.0.0/10`），Chrome 会把请求丢给 clash 得到 `ERR_CONNECTION_CLOSED`。
手机不受影响。修法是在代理 bypass 里加 `100.64.0.0/10`。
