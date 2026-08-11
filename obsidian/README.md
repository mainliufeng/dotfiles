# Obsidian

为 Knowledge vault 安装并配置需要的社区插件。

当前固定安装 Front Matter Title `4.1.1`。Knowledge 继续使用稳定的英文文件名，Obsidian 的文件切换、搜索和图谱使用 frontmatter `title` 显示中文标题。

```bash
./setup.sh
```

默认 vault 是 `~/Code/self/knowledge`。需要用于其他 vault 时：

```bash
OBSIDIAN_VAULT=/path/to/vault ./setup.sh
```

脚本会校验 GitHub release 文件的 SHA-256，合并 `.obsidian/community-plugins.json`，不会移除已安装的其他社区插件。
