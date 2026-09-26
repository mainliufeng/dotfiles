# vocal-enhance

把**会议室/直播录像**里听不清的人声救回来。一条命令，输出一个音画同步的新 mp4。

```
vocal-enhance "某场分享.mp4"
```

---

## 它解决什么问题

这类录像最常见的两个毛病，必须分开治：

| # | 病因 | 典型症状 |
|---|---|---|
| 1 | **整轨电平严重偏低** | 音量拧到 100% 还是听不清，得拧过头；越拧底噪越大 |
| 2 | **底噪偏高** | 人声和噪声只差几个 dB，放大后人声和噪声一起涨 |

对策：**先做神经降噪，再做 EBU R128 响度归一化**。顺序不能反——先拉响会把底噪一起拉起来。

实测（一段 23 分钟的直播回放录音，DNSMOS P.835 无参考评分）：

| 指标 | 原始 | 处理后 |
|---|---|---|
| OVRL 综合 | 1.17 | **2.47** |
| SIG 语音保真 | 1.50 | **3.18** |
| BAK 背景干净度 | 1.24 | **3.42** |

---

## 处理链

```
[1/4] 抽取音轨 (48000Hz 单声道)
[2/4] DeepFilterNet3 神经降噪            atten_lim=20dB
[3/4] EBU R128 两遍归一化                默认 -16 LUFS
[4/4] 回封视频 (视频流 copy, 不重编码)
```

**视频流直接复制**，不重编码，所以画质零损失、音画同步不变
（音轨的 `start_time` / `duration` 与原文件逐位一致）。

---

## 安装

```bash
./setup.sh      # 建 .venv, 装 torch(CPU)+deepfilternet, 预下载权重
./link.sh       # 把 bin/vocal-enhance 链到 ~/.local/bin
```

系统依赖只有一个：**ffmpeg**（Arch: `pacman -S ffmpeg`）。

`setup.sh` 是幂等的，重跑只会补缺。

### 依赖为什么钉版本

三个坑，踩过：

1. **`deepfilternet` 的包声明里没有 torch。** 直接 `pip install deepfilternet`
   装完 import 会失败，必须自己装 torch / torchaudio。
2. **torch 与 torchaudio 必须版本配对（钉 2.5.1）。** torchaudio ≥ 2.9 移除了
   `torchaudio.backend`，而 DFN 0.5.6 还在 `from torchaudio.backend.common import ...`。
3. **必须走 CPU 索引。** 默认索引会拉 2.5GB CUDA 依赖，而这里只用 CPU。

另外需要 `soundfile`，否则 torchaudio 报 `Couldn't find appropriate backend`。

---

## 用法

```bash
vocal-enhance input.mp4                  # 输出到同目录 <name>_人声增强.mp4
vocal-enhance input.mp4 -o out/          # 指定输出目录
vocal-enhance input.mp4 --lufs -14       # 平台上传用 -14 LUFS (默认 -16)
vocal-enhance input.mp4 --atten 30       # 更强降噪
vocal-enhance input.mp4 --only-audio     # 只出音频 (m4a)

# 批量
for f in ~/videos/*.mp4; do vocal-enhance "$f"; done
```

| 参数 | 默认 | 说明 |
|---|---|---|
| `-o, --out` | 源文件目录 | 输出目录 |
| `--lufs` | `-16` | 目标响度。本地观看 `-16`；视频号/YouTube 可用 `-14` |
| `--atten` | `20` | 最大抑制量(dB)。噪声重可到 `26~32` |
| `--only-audio` | 关 | 只输出 `.m4a`，不回封视频 |

环境变量：`DF_PY` 指定 venv 的 python；`ATTEN` / `LUFS` 设默认值。

---

## atten_lim 为什么是 20

DeepFilterNet 默认 `atten_lim=100`（不限幅抑制）。扫过 3~100dB 后：

| atten_lim | OVRL | **SIG**（语音保真）| BAK（噪声干净度）|
|---|---|---|---|
| 6 dB | 1.51 | 2.09 | 1.68 |
| 12 dB | 2.23 | 3.05 | 2.56 |
| **20 dB** | **2.47** | **3.18** | 3.00 |
| 32 dB | 2.56 | 3.12 | 3.28 |
| 100 dB（默认）| 2.44 | **2.81** | **3.58** |

**默认值为了追求"最安静"牺牲了语音保真度。** 噪声收益在 20dB 之后急剧递减
（20→100dB 只多降约 0.7dB 底噪），而 SIG 掉 0.37。ASR 交叉验证同向：
Whisper 的 `avg_logprob` 随抑制量单调下降，能识别的语音段从 22 降到 12。

先跑 20；只在噪声确实压不住时再往上调。

---

## 性能

处理后音频只需 **1.2~2% 的实时算力**（DFN 单线程约 9.6 倍实时），瓶颈不在模型。
整条命令是 I/O 与 ffmpeg 编译开销主导的。

一段 23 分钟的视频，**同一文件两次实测**：

| 阶段 | 低负载时 | 有负载时 |
|---|---|---|
| 抽音轨 | 0.47 s | 0.54 s |
| DeepFilterNet 降噪 | 30.9 s | 38.6 s |
| 响度测量（第一遍）| 13.0 s | 15.0 s |
| 归一化（第二遍）| 13.6 s | 16.3 s |
| 回封 | 14.2 s | 15.7 s |
| **流水线合计** | **72 s** | **86 s** |
| 命令额外做的成品响度校验 | — | 约 15 s |
| **命令端到端** | — | **约 105 s** |

**所以诚实的说法是一个区间：每 1 分钟视频 3.1~3.7 秒（流水线）；
若算上命令末尾的成品校验，约 4.5 秒。**

> 早先只写了「每 1 分钟 3.1 秒」，是在机器较空时测的。
> 同一命令在系统有负载时复测两次都是 105 秒，**每个阶段均匀慢 15~25%** ——
> 是负载导致，不是某一步退化。数字依赖机器负载，别当常量用。

---

## 局限

- **源是什么样就什么样。** 直播流的二次压缩音频（32kHz 单声道）是天花板——
  降噪不能恢复带宽，也不能重建立体声。
- **只有 `loudnorm` 的两遍法需要全片预扫**（因此不可流式）。对已存在的文件，
  预扫约花 1% 时长，可以「先扫后播」。真正的实时直播才必须换成单遍方案。
- **参数是按"会议/直播录像"调的。** 音乐、播客、影视等素材可能需要重新调 `--atten`。
- **只听「质量」，不保证「可懂度」提升。** DNSMOS / SQUIM 都是 no-reference
  估计器，证明的是预测质量提升，不是相对原始的可懂度提升。

---

## 备选：Rust 二进制（不需要 Python）

DeepFilterNet 官方另发**预编译静态二进制**（34.7 MB，零依赖）：

```bash
curl -L -o deep-filter \
  https://github.com/Rikorose/DeepFilterNet/releases/download/v0.5.6/deep-filter-0.5.6-x86_64-unknown-linux-musl
chmod +x deep-filter
./deep-filter input48k.wav -o out/     # 只吃 48kHz wav
```

好处是镜像能小一个数量级（约 150MB vs 约 1.2GB）。
**但它的 CLI 没有暴露 `--atten-lim`**，所以本模块用 Python 路径。
若哪天不需要调抑制量了，换成二进制更省事。

---

## 上游

- DeepFilterNet — https://github.com/Rikorose/DeepFilterNet （MIT / Apache-2.0）
- 模型权重约 8.3 MB，首次运行自动下载到 `~/.cache/DeepFilterNet/`
