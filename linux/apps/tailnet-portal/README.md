# tailnet-portal

Tailnet 的**入口页**（front door），手机装成一个 App 用。

```
https://liufeng-82tk.tail6b9726.ts.net/          ← 入口页（本模块）
├── /workbench/       Knowledge Workbench（从根路径挪过来）
├── /gefei-knowledge/ 哥飞 · 出海知识库（Quartz）
├── /gefei-ask/       哥飞 · 问大咖（Quartz）
├── :10000/           Knowledge Entity Index（绝对路径，需独占端口）
└── :8443/            dsh · DeepSeek Harness
```

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

## 排障

```bash
systemctl --user status tailnet-portal.service
tailscale serve status
```

**桌面 Chrome 打不开 `*.ts.net`**：KDE/clash 系统代理的 bypass 没含 Tailscale 网段
（`100.64.0.0/10`），Chrome 会把请求丢给 clash 得到 `ERR_CONNECTION_CLOSED`。
手机不受影响。修法是在代理 bypass 里加 `100.64.0.0/10`。
