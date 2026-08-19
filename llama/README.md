# llama.cpp 本地推理 + pi 集成

本机（Mac M4 24GB）llama.cpp 本地推理配置，接入 pi coding agent。
独立目录、**按需执行**，不随全局 setup/link 自动安装。

## 模型选型

- **LFM2.5-2.6B Q8_0**（默认，~2.87GB）：Liquid AI 端侧 agent 模型，专为工具调用/多步 agent 训练。
  第三方实测（RTX 5090 + llama.cpp server，30 任务工具调用 battery，2026-08-06）：
  96.7% 成功率 > Qwen3.5-9B 86.7% > Gemma-4-E4B 83.3% > Qwen3.5-4B 80.0%。
  调研细节见 Knowledge：`research/synthesis/2026/2026-08-19-small-local-model-tool-calling.md`。
- **LFM2.5-2.6B Q4_K_M**（~1.6GB）：更快更省内存，质量略降。
- 备选：Qwen3.5-2B（BFCL-v4 thinking 43.6，但 llama.cpp 模板有已知 issue #19872 需实测）。

## 安装（按需）

```bash
bash ~/dotfiles/llama/setup.sh        # Q8_0
bash ~/dotfiles/llama/setup.sh q4     # Q4_K_M
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

1. **thinking 必须开着**：LFM2.5-2.6B 关 reasoning 后工具调用成功率 96.7% → 70.0%
   （单工具档 100% → 60%）。默认跑没问题；要关时需 patched chat template
   （`--chat-template-file` 预闭合 `<think>`）+ `--predict` 上限，否则请求挂起。
2. **许可证**：LFM Open License v1.0（非 Apache 2.0），年收入 ≥ $10M 的商用需另行许可；
   个人/非营利研究不受限。
3. **Qwen3.5 系**：llama.cpp GGUF 模板工具调用有已知问题（issue #19872），用 Qwen3.5 前先实测。
4. reasoning 使每任务 token 成本翻倍（~1400 vs 685），小任务链可接受。
5. 本目录不含任何密钥；pi 其它 provider 的密钥走 `~/dotfiles/pi/models.json` 的
   `!bash` 间接引用（见 `~/dotfiles-private/`）。

## 相关

- pi 基础安装与其它 provider：`~/dotfiles/pi/`
- pi llama.cpp 官方文档：`~/.npm-global/lib/node_modules/@earendil-works/pi-coding-agent/docs/llama-cpp.md`
- llama.cpp router：`tools/server/README.md#model-presets`
