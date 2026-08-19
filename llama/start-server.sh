#!/usr/bin/env bash
# 启动 llama.cpp router server（供 pi 使用）
# 用法: bash ~/dotfiles/llama/start-server.sh
set -euo pipefail

MODELS_DIR="${MODELS_DIR:-$HOME/models}"
PORT="${PORT:-8080}"

if curl -s --max-time 2 "http://127.0.0.1:$PORT/health" >/dev/null 2>&1; then
  echo "llama-server 已在运行 (port $PORT)"
  exit 0
fi

nohup llama-server \
  --models-dir "$MODELS_DIR" \
  --no-models-autoload \
  --jinja \
  --host 127.0.0.1 \
  --port "$PORT" \
  -ngl 999 \
  -c 32768 \
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
