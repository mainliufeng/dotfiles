# clash-tools

包含两个命令：
- `clash-fetch-subscription`：抓取订阅，支持 YAML / base64 / ss/vmess 等分享链接，输出 Clash `proxies` YAML。
- `clash-merge`：合并多个 Clash 配置或订阅为完整配置，自动生成分组。

## 安装

```
cd "$(dirname "$0")"
./setup.sh
```

- 会用本地 venv 安装构建依赖（PyInstaller、requests、PyYAML），生成两个独立二进制并安装到 `/usr/local/bin`（不可写时会提示 sudo）。
- 可用 `PREFIX=/custom ./setup.sh` 修改安装前缀。

## 使用

- 抓订阅：`clash-fetch-subscription --url "https://example.com/sub" --user-agent "clash-verge/v2.0.0"`
- 合并：`clash-merge config1.yaml config2.yaml https://sub.example.com/sub`  
  - 传入 URL 会先以 UA `clash-verge/v2.0.0` 下载到临时文件，再参与合并。
  - 支持别名：`clash-merge bb=https://sub1... biu=https://sub2... local.yaml`，分组里的来源名用别名。
