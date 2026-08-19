#!/usr/bin/env bash
# llama.cpp 本地推理 + pi 集成安装（macOS Apple Silicon）
# 按需执行，不随全局 setup 自动运行。
#
# 重要：必须用官方 GitHub release 的二进制（~/.local/llama.cpp/），
# brew 版 llama.cpp 的 ggml dylib 未编译 Metal 后端，只能纯 CPU 跑（~10 t/s）。
# 官方版需 GGML_METAL_NO_RESIDENCY=1 规避 macOS 15+ 的 residency sets 崩溃
# （ggml-metal-device.m assert，见 llama.cpp #22593 / whisper-dictate workaround）。
#
# 用法: bash ~/dotfiles/llama/setup.sh [qwen4b|lfm25|qwopus|qwen9b]
#   qwen4b (默认): Qwen3.5-4B Q4_K_M（~2.6GB，工具调用评测 97.5% 第一，阿里官方）
#   lfm25         : LFM2.5-2.6B Q8_0（~2.87GB，第三方实测工具调用 96.7%；pi 集成有 thinking 不收敛风险）
#   qwopus        : Qwopus3.5-4B-Coder Q4_K_M（~2.78GB，社区微调，工具调用满分 + MTP）
#   qwen9b        : Qwen3.5-9B Q4_K_M（~5.5GB，更强 coding）
set -euo pipefail

MODEL="${1:-qwen4b}"
case "$MODEL" in
  qwen4b)  GGUF_NAME="Qwen3.5-4B-Q4_K_M.gguf";        GGUF_URL="https://huggingface.co/unsloth/Qwen3.5-4B-GGUF/resolve/main/Qwen3.5-4B-Q4_K_M.gguf" ;;
  lfm25)   GGUF_NAME="LFM2.5-2.6B-Q8_0.gguf";         GGUF_URL="https://huggingface.co/LiquidAI/LFM2.5-2.6B-GGUF/resolve/main/LFM2.5-2.6B-Q8_0.gguf" ;;
  qwopus)  GGUF_NAME="Qwopus3.5-4B-coder-Q4_K_M.gguf"; GGUF_URL="https://huggingface.co/Jackrong/Qwopus3.5-4B-Coder-GGUF/resolve/main/Qwopus3.5-4B-coder-Q4_K_M.gguf" ;;
  qwen9b)  GGUF_NAME="Qwen3.5-9B-Q4_K_M.gguf";        GGUF_URL="https://huggingface.co/unsloth/Qwen3.5-9B-GGUF/resolve/main/Qwen3.5-9B-Q4_K_M.gguf" ;;
  *) echo "未知模型: $MODEL（可选 qwen4b|lfm25|qwopus|qwen9b）" >&2; exit 1 ;;
esac

MODELS_DIR="${MODELS_DIR:-$HOME/models}"
LLAMA_DIR="$HOME/.local/llama.cpp"
GGUF="$MODELS_DIR/$GGUF_NAME"

echo "==> 1/5 安装 llama.cpp（官方 Metal release）"
if ! command -v "$LLAMA_DIR"/llama-b*/llama-server >/dev/null 2>&1; then
  mkdir -p "$LLAMA_DIR"
  RELEASE="$(curl -sL https://api.github.com/repos/ggml-org/llama.cpp/releases/latest | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["tag_name"])')"
  curl -sL --fail -o "$LLAMA_DIR/llama-macos.tar.gz" \
    "https://github.com/ggml-org/llama.cpp/releases/download/$RELEASE/llama-$RELEASE-bin-macos-arm64.tar.gz"
  tar xzf "$LLAMA_DIR/llama-macos.tar.gz" -C "$LLAMA_DIR"
fi
ls -d "$LLAMA_DIR"/llama-b*/llama-server

echo "==> 2/5 下载模型 $GGUF_NAME"
mkdir -p "$MODELS_DIR"
if [ ! -s "$GGUF" ]; then
  curl -L --fail -o "$GGUF" "$GGUF_URL"
fi
ls -lh "$GGUF"

echo "==> 3/5 配置 pi llama.cpp provider（auth.json，无密钥）"
python3 - <<'EOF'
import json, os
path = os.path.expanduser("~/.pi/agent/auth.json")
data = json.load(open(path)) if os.path.exists(path) else {}
data["llama.cpp"] = {
    "type": "api_key",
    "env": {"LLAMA_BASE_URL": "http://127.0.0.1:8080"},
}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
print("    auth.json providers:", list(data.keys()))
EOF

echo "==> 4/5 注入 pi models-store（非交互模式需要）"
python3 - "$GGUF_NAME" <<'EOF'
import json, os, sys
path = os.path.expanduser("~/.pi/agent/models-store.json")
data = json.load(open(path)) if os.path.exists(path) else {}
mid = os.path.basename(sys.argv[1]).replace(".gguf", "")
entry = {
    "id": mid, "name": mid, "api": "openai-completions",
    "provider": "llama.cpp", "baseUrl": "http://127.0.0.1:8080/v1",
    "reasoning": False, "input": ["text"],
    "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
    "contextWindow": 32768, "maxTokens": 8192,
    "compat": {"supportsStore": False, "supportsDeveloperRole": False,
               "supportsReasoningEffort": False, "supportsUsageInStreaming": True,
               "supportsStrictMode": False, "maxTokensField": "max_tokens"},
}
data.setdefault("llama.cpp", {"models": [], "checkedAt": 0})
models = data["llama.cpp"]["models"]
models = [m for m in models if m["id"] != mid]
models.append(entry)
data["llama.cpp"]["models"] = models
with open(path, "w") as f:
    json.dump(data, f, indent=2)
print("    models-store llama.cpp:", [m["id"] for m in models])
EOF

echo "==> 5/5 启动 llama-server router（后台，Metal）"
# GGML_METAL_NO_RESIDENCY=1：规避 macOS 15+ residency sets assert 崩溃
GGML_METAL_NO_RESIDENCY=1 nohup "$LLAMA_DIR"/llama-b*/llama-server \
  --models-dir "$MODELS_DIR" \
  --no-models-autoload \
  --jinja \
  --flash-attn on \
  --host 127.0.0.1 \
  --port 8080 \
  -ngl 999 \
  -c 32768 \
  --threads 8 \
  --parallel 1 \
  --reasoning-budget 768 \
  --reasoning-budget-message "我已经想得足够多了，现在直接调用工具或给出最终答案。" \
  --predict 8192 \
  >"$MODELS_DIR/llama-server.log" 2>&1 &
sleep 4
curl -s http://127.0.0.1:8080/health && echo
echo "    log: $MODELS_DIR/llama-server.log"
echo "    完成。pi 内 /llama 加载模型 → /model 选择。"
