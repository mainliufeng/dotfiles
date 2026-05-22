## gstack
```
处理网页浏览、网页测试和截图前，先按 `chrome-access-routing` 判断目标表面。

- 如果任务需要用户当前 macOS Chrome 窗口、真实标签页、Chrome 插件状态或可见桌面状态，优先走 Computer Use / Chrome 相关通道。
- 如果任务不需要用户真实 Chrome，会话或桌面窗口，优先使用 gstack 的 `browse` 及相关 QA skills 处理网页浏览、网页测试、截图、本地 web app dogfood 和视觉 QA。
- 不要使用 `mcp__claude-in-chrome__*` 工具。

可用的 gstack skills：
- `office-hours`
- `plan-ceo-review`
- `plan-eng-review`
- `plan-design-review`
- `design-consultation`
- `review`
- `ship`
- `land-and-deploy`
- `canary`
- `benchmark`
- `browse`
- `qa`
- `qa-only`
- `design-review`
- `setup-browser-cookies`
- `setup-deploy`
- `retro`
- `investigate`
- `document-release`
- `codex`
- `cso`
- `autoplan`
- `careful`
- `freeze`
- `guard`
- `unfreeze`
- `gstack-upgrade`

如果 gstack skills 没有生效，运行：`cd ~/gstack && ./setup --host codex`
```
