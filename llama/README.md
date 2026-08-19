# llama.cpp 本地推理 + pi 集成

本机（Mac M4 24GB）llama.cpp 本地推理配置，接入 pi coding agent。
独立目录、**按需执行**，不随全局 setup/link 自动安装。

## 模型选型

- **Qwen3.5-4B Q4_K_M**（默认，~2.6GB）：阿里官方，Apache-2.0。独立评测（LM Studio，
  13 模型 40 场景）工具调用 97.5% 第一；llama.cpp 模板生态最成熟，pi 集成稳定。
- **Qwopus3.5-4B-Coder Q4_K_M**（~2.78GB）：基于 Qwen3.5-4B 的社区微调（Trace Inversion +
  MTP 加速 1.4-2.2x），工具调用 15 场景满分、BugFind +19；社区模型需自测。
- **Qwen3.5-9B Q4_K_M**（~5.5GB）：更强 coding 的升级档（ABS 19 模型综合第一）。
- **LFM2.5-2.6B Q8_0**（~2.87GB）：Liquid AI 端侧 agent 模型，第三方实测工具调用 96.7%
  最高，但 GGUF 模板硬编码 `<think>`，pi 集成下有 thinking 不收敛风险（需 --predict 兜底），
  已降为备选。

调研细节见 Knowledge：`research/synthesis/2026/2026-08-19-domestic-small-model-tool-calling.md`。

## 安装（按需）

```bash
bash ~/dotfiles/llama/setup.sh             # Qwen3.5-4B Q4_K_M（默认）
bash ~/dotfiles/llama/setup.sh qwopus     # Qwopus3.5-4B-Coder
bash ~/dotfiles/llama/setup.sh qwen9b     # Qwen3.5-9B
bash ~/dotfiles/llama/setup.sh lfm25      # LFM2.5-2.6B Q8_0（备选）
```

做的事：

1. `brew install llama.cpp`（需支持 router 模式的新版）
2. 下载 GGUF 到 `~/models/`（`MODELS_DIR` 可覆盖）
3. 写入 pi credential：`~/.pi/agent/auth.json` 的 `llama.cpp` key
   （`{type: "api_key", env: {LLAMA_BASE_URL: "http://127.0.0.1:8080"}}`，无密钥，不动其它 provider）
4. 后台启动 llama-server router

## 启动/停止

```bash
bash ~/dotfiles/llama/start-server.sh   # 幂等启动
# 停止: pkill -f "llama-server.*models-dir"
```

router 参数说明：

- 不带 `--model` = router 模式（发现多个 GGUF，按需加载/卸载）
- `--no-models-autoload`：模型显式通过 pi 的 `/llama` 加载
- `--jinja`：启用兼容 chat template 与工具调用（必须）
- `-ngl 999`：尽可能多层 offload 到 Metal
- `-c 32768`：每模型 32K 上下文（模型原生 128K，全开内存压力大）
- `--reasoning-budget 768` + message：thinking 预算上限，防止长 prompt 下思考不收敛
- `--predict 4096`：单请求生成上限兜底（截断后客户端可能报 tool call 错误，是最后防线）

## pi 使用

配置已写入 auth.json，pi 内直接：

```text
/llama        # 加载 LFM2.5-2.6B-Q8_0.gguf
/model        # 选择 llama.cpp provider 下的模型
```

非交互：

```bash
pi --provider llama.cpp --model LFM2.5-2.6B-Q8_0.gguf "任务"
```

环境变量（不持久化）：`LLAMA_BASE_URL=http://127.0.0.1:8080 pi`

健康检查：`curl http://127.0.0.1:8080/health`、`curl http://127.0.0.1:8080/models`

## 边界与坑（来自调研）

1. **pi 集成注意**：pi 的 system prompt 可达 13K+ tokens、max_tokens 取上下文上限；
   强制 thinking 且不收敛的模型（如 LFM2.5 模板硬编码 `<think>`）会无限生成，已用
   `--reasoning-budget` + `--predict` 兜底。Qwen3.5 系模板成熟，通常无此问题。
2. **许可证**：Qwen3.5-4B Apache-2.0；LFM2.5 用 LFM Open License v1.0（年收入 ≥ $10M
   商用需另行许可）；Qwopus 社区微调 Apache-2.0。
3. **非交互模式**：llama.cpp provider 的模型列表来自 router catalog（`/llama` 同步），
   `--list-models` 默认不刷新；非交互 `--provider llama.cpp` 需要 models-store.json
   已含该模型条目（setup 后首次 `pi /llama` 加载会自动持久化）。
4. reasoning 使每任务 token 成本翻倍（~1400 vs 685），小任务链可接受。
5. 本目录不含任何密钥；pi 其它 provider 的密钥走 `~/dotfiles/pi/models.json` 的
   `!bash` 间接引用（见 `~/dotfiles-private/`）。

## 相关

- pi 基础安装与其它 provider：`~/dotfiles/pi/`
- pi llama.cpp 官方文档：`~/.npm-global/lib/node_modules/@earendil-works/pi-coding-agent/docs/llama-cpp.md`
- llama.cpp router：`tools/server/README.md#model-presets`
