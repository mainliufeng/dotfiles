#!/usr/bin/env bash
# llama.cpp 本地推理 + pi 集成安装（macOS Apple Silicon）
# 按需执行，不随全局 setup 自动运行。
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
GGUF="$MODELS_DIR/$GGUF_NAME"

echo "==> 1/4 安装 llama.cpp (brew)"
if ! command -v llama-server >/dev/null 2>&1; then
  brew install llama.cpp
else
  echo "    已安装: $(llama-server --version 2>&1 | head -1)"
fi

echo "==> 2/4 下载模型 $GGUF_NAME"
mkdir -p "$MODELS_DIR"
if [ ! -s "$GGUF" ]; then
  curl -L --fail -o "$GGUF" "$GGUF_URL"
fi
ls -lh "$GGUF"

echo "==> 3/4 配置 pi llama.cpp provider（auth.json，无密钥）"
# 等价于 pi 内 /login llama.cpp；llama.cpp provider 是 pi 内置扩展，
# 模型目录由 router 动态发现，不需要 models.json 条目。
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

echo "==> 4/4 启动 llama-server router（后台）"
# router 模式：不带 --model，--models-dir 扫描 GGUF，/llama 按需加载
# --reasoning-budget / --predict 用于防止长 prompt 下思考不收敛（LFM2.5 等强制 thinking 模型）
nohup llama-server \
  --models-dir "$MODELS_DIR" \
  --no-models-autoload \
  --jinja \
  --host 127.0.0.1 \
  --port 8080 \
  -ngl 999 \
  -c 32768 \
  --reasoning-budget 768 \
  --reasoning-budget-message "我已经想得足够多了，现在直接调用工具或给出最终答案。" \
  --predict 4096 \
  >"$MODELS_DIR/llama-server.log" 2>&1 &
sleep 3
curl -s http://127.0.0.1:8080/health && echo
echo "    log: $MODELS_DIR/llama-server.log"
echo "    完成。pi 内 /llama 加载模型 → /model 选择。"
