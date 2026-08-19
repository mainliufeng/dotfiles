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

1. 安装 llama.cpp 官方 GitHub release（Metal 版）到 `~/.local/llama.cpp/`
2. 下载 GGUF 到 `~/models/`（`MODELS_DIR` 可覆盖）
3. 写入 pi credential：`~/.pi/agent/auth.json` 的 `llama.cpp` key（无密钥）
4. 注入 pi `models-store.json`（非交互 `--provider llama.cpp` 需要）
5. 后台启动 llama-server router（Metal）

## 启动/停止

```bash
bash ~/dotfiles/llama/start-server.sh   # 幂等启动（Metal 版）
# 停止: pkill -f "llama-server.*models-dir"
```

## 关键踩坑（务必读）

1. **brew 版 llama.cpp 没有 Metal 后端**（ggml dylib 未链接 Metal.framework），
   `-ngl 999` 无效，纯 CPU 只有 ~10 t/s。必须用官方 GitHub release 二进制
   （`~/.local/llama.cpp/llama-b*/llama-server`）。
2. **官方版在 macOS 15+ 会崩**：`GGML_ASSERT([rsets->data count] == 0) failed`
   （ggml-metal-device.m，residency sets 问题，见 llama.cpp #22593）。
   解决：启动前 `export GGML_METAL_NO_RESIDENCY=1`（GPU 内存空闲 ~1s 后可驱逐，影响可忽略）。
3. **pi 的 agent 循环会让上下文逐轮膨胀**（system prompt + 工具结果累积，实测可到 30K tokens），
   上下文至少 32K（`-c 32768`），否则请求会被拒。
4. **pi 的 system prompt 默认 ~13K tokens**（AGENTS.md/skills/packages 会叠加），
   非交互可用 `--no-skills --no-context-files --no-prompt-templates` 减负（降到 ~1.5K）。
5. **pi text 模式（-p）无输出**：疑似 pi bug，用 `--mode json` 可拿到完整事件流。

router 参数说明：

- 不带 `--model` = router 模式（发现多个 GGUF，按需加载/卸载）
- `--no-models-autoload`：模型显式通过 pi 的 `/llama` 加载
- `--jinja`：启用兼容 chat template 与工具调用（必须）
- `-ngl 999`：尽可能多层 offload 到 Metal
- `-c 32768`：每模型 32K 上下文（模型原生 128K，全开内存压力大）
- `--reasoning-budget 768` + message：thinking 预算上限，防止长 prompt 下思考不收敛
- `--predict 8192`：单请求生成上限兜底（截断后客户端可能报 tool call 错误，是最后防线）

## pi 使用

配置已写入 auth.json，pi 内直接：

```text
/llama        # 加载 Qwen3.5-4B-Q4_K_M.gguf
/model        # 选择 llama.cpp provider 下的模型
```

非交互（注意 -p text 模式无输出，用 --mode json）：

```bash
pi --provider llama.cpp --model Qwen3.5-4B-Q4_K_M --mode json -p "任务"
# 减小 system prompt（AGENTS.md/skills 等）：
pi --provider llama.cpp --model Qwen3.5-4B-Q4_K_M --no-skills --no-context-files --no-prompt-templates -p "任务"
```

环境变量（不持久化）：`LLAMA_BASE_URL=http://127.0.0.1:8080 pi`

健康检查：`curl http://127.0.0.1:8080/health`、`curl http://127.0.0.1:8080/models`

## 边界与坑（来自调研）

1. **许可证**：Qwen3.5-4B Apache-2.0；LFM2.5 用 LFM Open License v1.0（年收入 ≥ $10M
   商用需另行许可）；Qwopus 社区微调 Apache-2.0。
2. **非交互模式**：llama.cpp provider 的模型列表来自 router catalog（`/llama` 同步），
   `--list-models` 默认不刷新；非交互 `--provider llama.cpp` 需要 models-store.json
   已含该模型条目（setup.sh 已注入；交互 `/llama` 加载后也会自动持久化）。
3. reasoning 使每任务 token 成本翻倍（~1400 vs 685），小任务链可接受。
4. 本目录不含任何密钥；pi 其它 provider 的密钥走 `~/dotfiles/pi/models.json` 的
   `!bash` 间接引用（见 `~/dotfiles-private/`）。

## 相关

- pi 基础安装与其它 provider：`~/dotfiles/pi/`
- pi llama.cpp 官方文档：`~/.npm-global/lib/node_modules/@earendil-works/pi-coding-agent/docs/llama-cpp.md`
- llama.cpp router：`tools/server/README.md#model-presets`
