# QMD

为 `~/Code/self/knowledge` 安装并配置本地 Markdown 搜索索引。

```bash
./setup.sh
```

模块固定使用 Bun 安装 QMD `2.5.3`，并创建四个 collection：文章正文投影、Topics、Synthesis 和 Sources。文章正文由 Knowledge 仓库脚本从 canonical HTML 生成到 `~/.cache/knowledge-qmd/articles/`；QMD SQLite 索引和模型也只保留在本机 cache。

`qmd` 已加入 `modules/common.txt`，因此每台笔记本运行 `~/dotfiles/setup.sh --common-only` 都会幂等完成安装、collection 配置和 BM25 初始化。Knowledge 的 `scripts/knowledge-search.mjs` 也会在搜索前自检并自动调用本模块；新 clone 后可显式运行 `node scripts/knowledge-search.mjs init`。

中文语义检索使用 Qwen3-Embedding-0.6B。全库 BM25 索引是默认路径；向量是可选的离线增强，按高价值 collection 生成，避免对 1,441 份文档做耗时的全量 embedding：

```bash
qmd embed -c knowledge-articles
qmd embed -c knowledge-topics
```

更新 Knowledge 后重建文章投影和索引：

```bash
cd ~/Code/self/knowledge
node scripts/knowledge-search.mjs update
```
