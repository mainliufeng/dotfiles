#!/usr/bin/env bash
# 启动 llama.cpp router server（供 pi 使用，Metal 版）
# 用法: bash ~/dotfiles/llama/start-server.sh
set -euo pipefail

MODELS_DIR="${MODELS_DIR:-$HOME/models}"
PORT="${PORT:-8080}"
# 官方 Metal release（brew 版无 Metal 后端，勿用）
LLAMA_SERVER_BIN="${LLAMA_SERVER_BIN:-$(ls -d "$HOME"/.local/llama.cpp/llama-b*/llama-server 2>/dev/null | head -1)}"
if [ -z "$LLAMA_SERVER_BIN" ]; then
  echo "未找到官方 llama-server，先运行: bash ~/dotfiles/llama/setup.sh" >&2
  exit 1
fi

if curl -s --max-time 2 "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
  echo "llama-server 已在运行 (port $PORT)"
  exit 0
fi

# GGML_METAL_NO_RESIDENCY=1：规避 macOS 15+ residency sets assert 崩溃
GGML_METAL_NO_RESIDENCY=1 nohup "$LLAMA_SERVER_BIN" \
  --models-dir "$MODELS_DIR" \
  --no-models-autoload \
  --jinja \
  --flash-attn on \
  --host 127.0.0.1 \
  --port "$PORT" \
  -ngl 999 \
  -c 32768 \
  --threads 8 \
  --parallel 1 \
  --reasoning-budget 768 \
  --reasoning-budget-message "我已经想得足够多了，现在直接调用工具或给出最终答案。" \
  --predict 8192 \
  >"$MODELS_DIR/llama-server.log" 2>&1 &

for i in $(seq 1 15); do
  if curl -s --max-time 2 "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
    echo "llama-server 已启动 (port $PORT, log: $MODELS_DIR/llama-server.log)"
    exit 0
  fi
  sleep 1
done
echo "启动失败，查看 $MODELS_DIR/llama-server.log" >&2
exit 1
