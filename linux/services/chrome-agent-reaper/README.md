# chrome-agent-reaper（agent 浏览器的 tab 回收）

定时把 agent 专用 Chrome（CDP `127.0.0.1:9222`）里的陈旧 tab 关掉。

```bash
~/dotfiles/linux/services/chrome-agent-reaper/setup.sh      # 安装并启用 timer
~/dotfiles/linux/services/chrome-agent-reaper/setup.sh --dry-run
~/dotfiles/linux/services/chrome-agent-reaper/setup.sh --uninstall
```

## 部署时的实测基线（2026-09-21）

以后出问题先比这组数字：看是环境变了，还是回收器退化了。

| 观测 | 部署当天 |
| --- | --- |
| profile | `~/.local/share/chrome-agent`，浏览器启于 09-19 20:38，从未清理过 |
| tab / 渲染进程 | 70 个 page target / 97 个渲染进程 |
| 内存 | **11.77 GB RSS + 9.67 GB swap**（按进程树聚合，105 个进程） |
| 整机 | 31 GiB 内存用掉 25 GiB；65 GiB swap 用掉 50 GiB |
| Memory Saver | `high_efficiency_mode.state=2`（开）、`aggressiveness=1`（中等） |
| `attached=true` 的 tab | **69 / 70** |
| `chrome://discards` | 被 `chrome://debug-webuis-disabled` 挡住，默认读不到 |
| windowId 去重 | 1 个窗口 |
| 报 `visibilityState === 'visible'` 的 tab | **全部**（信号不自洽，不可用） |
| 常驻 CDP 客户端 | 3 个（`node-MainThread` / `python3` / `chrome-devtools`，后者已连 1 天以上） |

同一时刻整机还有**另一批与浏览器无关**的负载，别混为一谈：后台语音 ASR 调研作业在跑
whisper 压测（两个 8 线程的 `whisper-bench` / `whisper-cli` 各 ~500% CPU）+ 两个 `bzip2`
解压模型包 + 27 个并发 `curl` 下模型，把 20 核的 load average 顶到 23、
`/proc/pressure/io` 的 `some avg300` 顶到 18.8。那一波“卡死”的主因是这些，不是浏览器；
浏览器的位置是内存和 swap 的头号用家。

## 已知局限

1. **`--quit-if-idle` 常常不会触发。** `chrome-devtools-mcp` 是常驻连接，一个还开着的
   （哪怕已经闲置的）agent 会话会一直占着 9222 —— 实测部署当天挂着 3 个，其中一个已连 1 天以上。
   这种情况下只有 tab 回收在起作用，浏览器本身的内存拿不回来；要拿回来得等那些 MCP 进程退出
   （或杀掉它们），再手动跑一次 `chrome-agent-reap --quit-if-idle`。
2. **只管 `~/.local/share/chrome-agent` 这一个实例。** 本机还有一个 `~/.cache/chrome-devtools`
   （174 MB），是 `~/.claude.json` 里那个没配 `browserUrl` 的 `chrome-devtools-mcp`
   自己起的 Chrome，不受这个 timer 管。
3. **保护“正在使用”只能靠活动重置时钟**，因为 visibility 信号在这台机器上是坏的（见下）。
   如果某个 agent 会连续一小时以上只读同一个不刷新的页面，理论上仍可能被关。
   要更保守就调大 TTL，或用 `--keep` 把站点固定住。

## 改动这个脚本时注意

`isMain` 守卫两边都要 `realpath`：脚本是通过 `~/.local/bin` 的 symlink 调用的，而 Node 对 ESM
会把 `import.meta.url` 解析成真实路径。直接比字面路径的话，**symlink 调用会静默不跑 `main()`**
—— 无输出、exit 0、看起来像“跑成功了但什么都没做”。`setup.sh` 的冒烟测试因此有意走 symlink，
能检出这类失败。

## 为什么不能靠 Chrome 的 Memory Saver

先说结论：**Memory Saver 在这个场景里救不了你，别指望它。**

实测（`chrome://settings/performance` 对应的 profile prefs + CDP `Target.getTargets`）：

| 观测 | 值 |
| --- | --- |
| `performance_tuning.high_efficiency_mode.state` | `2`（Memory Saver 已启用） |
| `performance_tuning.high_efficiency_mode.aggressiveness` | `1`（中等模式） |
| `Target.getTargets` 里 `attached=true` 的 page target | **69 / 70** |

`chrome-devtools-mcp` 走 `--browserUrl http://127.0.0.1:9222` 会把**它驱动的每个 tab
都挂上 DevTools 客户端**。而 Chrome 不会丢弃挂了 DevTools 的 tab（也基本不会冻结它），
于是 Memory Saver 名义上开着、实际一个 tab 都不敢动，profile 一路涨到 70 个 tab、
11.8 GB RSS + 9.7 GB swap、97 个渲染进程。

另外 `chrome://discards`（Chrome 自己列「为什么这个 tab 不能丢」的页面）在
Chrome 152 里已经被 `chrome://debug-webuis-disabled` 挡住，默认读不到，所以
排查时拿不到 Chrome 的逐条理由 —— 只能自己按策略回收。

## 回收策略

`~/dotfiles/scripts/chrome-agent-reap`（node，零依赖，用内置 WebSocket 讲 CDP）：

| 规则 | 行为 |
| --- | --- |
| TTL 是**观察到的闲置时长**，不是页面年龄 | 第一次见到只登记；连续观察到闲置满 TTL 才关。首次部署不可能误伤 |
| 「有活动」的判据 | URL 变了（导航），或页面 `performance.getEntriesByType('resource').length` 变了。命中就把闲置时钟拨回现在 |
| 普通页面 | 闲置 45 分钟 |
| 搜索页 / `about:blank` / 新标签页 | 闲置 10 分钟 |
| `--keep` / `CHROME_AGENT_KEEP` 里的域名 | 永不关 |
| `devtools://` `chrome-extension://` `chrome-untrusted://` `view-source:` | 跳过 |
| 未 `attached` 的 tab | 不 attach、不探测 —— attach 会把被杀掉的休眠页唤醒重载，那等于白干 |
| 最后一个 tab | 不关（关空会连带退出窗口；要关浏览器用 `--quit-if-idle`） |
| 端口不通 / 浏览器没起 | 安静退出 0，不会把 timer 刷成 failed |

### 为什么**不**拿 `document.visibilityState` 当保护条件

直觉上「当前前台标签不能关」是对的，但这台机器上这个信号是坏的，用了就等于什么都关不掉。实测：

```
windowId 去重(Browser.getWindowForTarget) : 1 个窗口
54 个 tab 的 document.visibilityState    : 全部 'visible'
其中 document.hasFocus() === true 的       : 30 个
```

一个 tab strip 里不可能全部是前台标签，说明这个 Wayland 会话下 Chrome 的可见性/焦点跟踪没在反映真实状态
（大概率是窗口未合成/不在当前工作区时 Chrome 拿不准 occlusion）。

所以脚本自己会校准：先数窗口数，只有在 `报 visible 的数量 <= 窗口数` 时（信号自洽）才把
visibility 当额外保护；不自洽就整轮忽略它并在输出里说明（`trustVisibility: false`）。
这是为什么保护 agent 正在用的 tab 只能靠「活动重置闲置时钟」，不能靠可见性。

状态写在 `~/.cache/chrome-agent/reap-state.json`（`targetId → firstSeen`），
用来记住「什么时候第一次见到这个 tab」，并按当前存在的 tab 裁剪。

### `--quit-if-idle`：连浏览器一起收掉

tab 回收解决的是增量，浏览器本身常驻才是内存大头。带这个开关时，如果

1. 除了自己之外**没有任何进程连着 9222**（用 `ss -Htnp state established` 数 client 侧连接，
   自己的 pid 要排除掉），并且
2. 距上次见到客户端已超过 `--idle-min`（默认 60 分钟）

就发 `Browser.close` 把整个浏览器关掉。登录态在 profile 里，重启不丢。

**已知局限**：`chrome-devtools-mcp` 是常驻连接，一个还开着的（哪怕已经闲置的）agent
会话会一直占着它，这时 `--quit-if-idle` 不会触发。这种情况下只有 tab 回收在起作用。

## 配套改动

- `~/dotfiles/scripts/chrome-agent`：**默认不再带 `--restore-last-session`**。
  不然重启一次就把上一轮的几十个 tab 原样捞回来，回收等于白做。
  需要恢复时用 `CHROME_AGENT_RESTORE=1 chrome-agent`。
- agent 侧的规矩写在 skill 里：读页面优先用 `chrome-agent-read`（本来就是开 tab、读回、关 tab），
  用 MCP 自己开的 tab 用完要显式 `Target.closeTarget`。见
  `~/.pi/agent/skills/local-env/references/agent-browser.md`。

## 排查

```bash
chrome-agent-reap --dry-run          # 这一轮会关什么（不写状态、不动手）
chrome-agent-reap --json             # 机器可读
chrome-agent-reap                   # 立刻回收一次
systemctl --user list-timers chrome-agent-reaper.timer
journalctl --user -u chrome-agent-reaper.service -n 50
```

URL 分类（搜索页 vs 工作页）是纯函数，可以直接单测，不用等真实页面回归：

```bash
node -e "import('/home/liufeng/dotfiles/scripts/chrome-agent-reap').then(m=>{
  console.log(m.isSearch('https://cn.bing.com/search?q=x'));            // true
  console.log(m.isSearch('https://search.google.com/search-console/x')); // false（GSC 是工作台）
  console.log(m.isSearch('https://aistudio.google.com/usage'));          // false
})"
```

`search.google.com`（Search Console 的 `/search-console/...` 会被 `/search` 前缀误命中）和
`aistudio.google.com` 因此被显式列进 `NOT_SEARCH_HOSTS`。

只关了极少数 tab 时，先确认是不是刚部署：第一轮只登记，第二轮才开始关。

TTL 想改又不想动单元文件，用 drop-in：

```bash
systemctl --user edit chrome-agent-reaper.service
# [Service]
# Environment=CHROME_AGENT_REAP_TTL=20 CHROME_AGENT_REAP_TTL_SEARCH=5
```

## 与 wechat-performance-snapshot 的关系

`wechat-performance-snapshot.service` 也依赖这个 profile 的登录态和 CDP 9222。
它跑的时候会连上 9222，所以 `--quit-if-idle` 不会跟它抢；它自己开的 tab
如果留在那儿，也会被下一轮 TTL 收掉。
