# QMD

为 `~/Code/self/knowledge` 安装并配置本地 Markdown 搜索索引。

```bash
./setup.sh
```

模块固定使用 Bun 安装 QMD `2.5.3`，并创建四个 collection：文章正文投影、Topics、Synthesis 和 Sources。文章正文由 Knowledge 仓库脚本从 canonical HTML 生成到 `~/.cache/knowledge-qmd/articles/`；QMD SQLite 索引和模型也只保留在本机 cache。

中文语义检索使用 Qwen3-Embedding-0.6B。首次需要向量检索时运行：

```bash
qmd embed
```

更新 Knowledge 后重建文章投影和索引：

```bash
cd ~/Code/self/knowledge
node scripts/knowledge-search.mjs update
```
