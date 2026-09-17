# gefei-media

把本地一大坨**讲座视频 + 文档**发布成一个手机能直接看的网站，挂在 tailnet 上，
并且能「添加到主屏幕 / 安装成 App」（PWA）。

数据源是本机的媒体目录（默认 `~/Documents/gefei-share/`，夸克分享下载后按类型整理的），
**一个字节都不动**：站点产物写在它下面的 `.web/`，媒体用符号链接暴露给服务器。

```
~/Documents/gefei-share/           # 真源（只读使用）
├── 视频/<场次>/*.mp4              # 手机要能播 → 见下面「为什么转 mp4」
├── 文档/*.{pdf,docx,xlsx,pptx,txt}
├── 图片/ 文本/ 音频/ 代码/        # 只做计数 + 目录页，不解析
└── .web/                          # gefei-media-build 的产物（站点本体）
        │  gefei-media-serve（127.0.0.1 + Tailscale IP，默认 8097）
        ▼
tailscale serve --https=443 --set-path=/gefei-media
        ▼
https://liufeng-82tk.<tailnet>.ts.net/gefei-media/   →  手机浏览器 / 独立 App
```

## 命令

```bash
gefei-media-build     # 扫描媒体目录，重建 .web/（缩略图/时长有缓存，增量很快）
gefei-media-serve     # 前台起服务（systemd 也会跑它）
bash setup.sh         # 构建 + 装 systemd --user + 配 tailscale serve + 装单元
bash link.sh          # 把 bin/* 链到 ~/.local/bin
```

下载/整理完新素材后只需要：

```bash
gefei-media-build && systemctl --user restart gefei-media.service   # 重启只为清 HTML 缓存，可选
```

## 站点里有什么

- **入口一页**：`<details>` 按场次分组、客户端搜索（讲者/主题/场次/文件名）、
  每行缩略图 + 时长 + 体积，点「播放」进顶部固定播放器（`playsinline`，手机上不跳全屏）。
- **文档**：PDF 直接用浏览器内嵌看；`docx` 走 pandoc 转 HTML；`xlsx`/`pptx` 由本脚本
  直接读 OOXML zip 渲成 HTML（表格/分页文本 + 内嵌图），全部**相对路径**，所以在
  `/gefei-media/` 前缀下也不会指回 origin 根。转换都有限幅（xlsx 前 200 行 × 40 列、
  pptx 图缩到 1280 宽），否则单个页面能膨胀到几百 MB。
- **目录页**：`media/图片/`、`media/文本/`、`media/音频/`、`media/代码/` 给一个极简列表页
  （超过 800 项截断），10937 张群聊图不至于没入口。

## 为什么 `.ts` 要转成 `.mp4`

分享下载下来的是 Web.Cafe 直播的 **MPEG-TS**（`.ts`）。TS 在 iOS/Android 浏览器的
`<video>` 里**基本都放不了**，所以本模块假设视频目录里是 mp4：

```bash
# 无损重封装（不重编码，纯 I/O）
ffmpeg -i in.ts -map 0:v:0 -map 0:a:0 -c copy -bsf:a aac_adtstoasc -movflags +faststart out.mp4
```

构建脚本只收 `.mp4`；同名的 `.ts` 会被忽略（当作同一份内容的旧封装）。

## 为什么自己写 server 而不是 `python3 -m http.server`

**视频必须支持 HTTP Range。** 没有 206 分段响应，手机上要么起不来，要么不能拖动进度条。
`gefei-media-serve` 实现了单区间 Range、`ETag`/`Last-Modified` 校验、HTML 的 `no-cache`，
只绑 `127.0.0.1` 和 Tailscale IP（不暴露到局域网），沿用 quartz-web 的做法。

## PWA 的坑（和入口页一样）

- 公开路径是 **443 上的 `/gefei-media`**（不是独立端口：Tailscale 只允许 443 / 8443 / 10000，
  已被入口页、dsh、Entity Index 用满）。
- manifest 的 `start_url` / `scope` 都写 `.`（相对），**不写显式 `id`** —— 写 `"id": "."`
  时 Chrome 会解析成 origin 根，反而和入口页 scope 嵌套，装出来会变成更新入口 App。
- `/gefei-media/` 与入口页 `/home/` 是兄弟 scope，所以能各自装成独立 App。

## 排障

```bash
systemctl --user status gefei-media.service
curl -sI -r 0-1023 http://127.0.0.1:8097/media/...      # 期望 206 Partial Content
tailscale serve status
```

- **桌面 Chrome 打不开 `*.ts.net`**：KDE/clash 系统代理 bypass 缺 `100.64.0.0/10`，
  与本模块无关（手机不受影响）。
- **手机上点了没反应/转圈**：先确认是 mp4（`ffprobe`），再看 `curl -r` 是否 206。
- **文档页空白**：`pptx`/`xlsx` 的转换是尽力而为，EMF/WMF 图会丢；页面上同时给了原文件下载。
