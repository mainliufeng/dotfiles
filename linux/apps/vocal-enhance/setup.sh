#!/usr/bin/env bash
# Install / refresh the Python environment for `vocal-enhance`.
#
# Idempotent. 只做一件事: 在模块目录下建一个 .venv, 装上
#   torch(CPU) + torchaudio + deepfilternet + soundfile
# 并预下载模型权重, 这样第一次跑不会卡在下载上。
#
# 三个必须踩对的坑 (见 README「依赖为什么钉版本」):
#   1. deepfilternet 的包声明里【没有】torch 依赖, 必须手动装
#   2. torch / torchaudio 必须版本配对 —— torchaudio >= 2.9 删了
#      `torchaudio.backend`, 而 DFN 0.5.6 还在 import 它
#   3. 必须走 CPU 索引, 否则会拉 2.5GB 的 CUDA 依赖
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
TORCH_VER="${TORCH_VER:-2.5.1}"
PY_VER="${PY_VER:-3.12}"

chmod +x "$ROOT_DIR"/bin/*

echo "[vocal-enhance] 模块目录: $ROOT_DIR"

# --- 0. 系统依赖 -------------------------------------------------------------
for c in ffmpeg ffprobe; do
  command -v "$c" >/dev/null || {
    echo "[vocal-enhance] 缺少 $c —— 先装它 (Arch: pacman -S ffmpeg)" >&2
    exit 1
  }
done
echo "[vocal-enhance] ffmpeg: $(command -v ffmpeg)"

# --- 1. venv -----------------------------------------------------------------
if [[ -x "$VENV_DIR/bin/python" ]]; then
  echo "[vocal-enhance] venv 已存在: $VENV_DIR"
else
  echo "[vocal-enhance] 创建 venv (python $PY_VER) -> $VENV_DIR"
  if command -v uv >/dev/null 2>&1; then
    uv venv "$VENV_DIR" --python "$PY_VER"
  else
    # 没有 uv 时退回到标准库; 注意系统 python 可能是 3.14,
    # 而 torch 目前没有 3.14 的轮子, 所以这里显式要 3.12。
    PY_BIN="$(command -v "python$PY_VER" || command -v python3)"
    "$PY_BIN" -m venv "$VENV_DIR"
    "$VENV_DIR/bin/python" -m pip install --upgrade pip >/dev/null
  fi
fi

PIP=("$VENV_DIR/bin/python" -m pip)
command -v uv >/dev/null 2>&1 && PIP=(uv pip install --python "$VENV_DIR/bin/python")

# --- 2. torch / torchaudio (CPU) --------------------------------------------
if "$VENV_DIR/bin/python" -c "import torch,torchaudio,sys; sys.exit(0 if torch.__version__.startswith('$TORCH_VER') else 1)" 2>/dev/null; then
  echo "[vocal-enhance] torch $TORCH_VER 已就绪"
else
  echo "[vocal-enhance] 安装 torch/torchaudio $TORCH_VER (CPU 版)"
  "${PIP[@]}" "torch==$TORCH_VER" "torchaudio==$TORCH_VER" \
    --index-url https://download.pytorch.org/whl/cpu
fi

# --- 3. deepfilternet + 音频 IO ---------------------------------------------
echo "[vocal-enhance] 安装 deepfilternet / soundfile"
"${PIP[@]}" deepfilternet soundfile

# --- 4. 预下载模型权重 --------------------------------------------------------
echo "[vocal-enhance] 预下载 DeepFilterNet3 权重"
"$VENV_DIR/bin/python" -W ignore -c "
from df.enhance import init_df
init_df()
" >/dev/null 2>&1 && echo "[vocal-enhance] 权重就绪" \
                || echo "[vocal-enhance] 权重下载失败 (首次运行时还会重试)"

# --- 5. 自检 -----------------------------------------------------------------
"$VENV_DIR/bin/python" -W ignore -c "
import torch, torchaudio, df, soundfile
print(f'[vocal-enhance] 自检通过: torch {torch.__version__} / torchaudio {torchaudio.__version__}')
" 2>/dev/null || { echo "[vocal-enhance] 自检失败" >&2; exit 1; }

echo "[vocal-enhance] 完成。试着跑:  vocal-enhance 某个视频.mp4"
