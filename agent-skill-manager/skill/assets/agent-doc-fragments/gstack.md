## gstack
```
处理网页浏览、网页测试和截图前，先按 `chrome-access-routing` 判断目标表面。不要直接让第三方浏览器 skill 抢真实 Chrome 登录态判断。

- 如果任务需要用户当前 macOS Chrome 窗口、真实标签页、真实登录态、Google Search Console / GSC、Google 账号会话、authenticated dashboard、Chrome 插件状态或可见桌面状态，必须先走 `chrome-access-routing`；在 macOS 上它会优先用 Computer Use 检查 `Google Chrome`。
- Chrome Extension、gstack `browse`、Browser、web-access 或 headless 路径看到的 signed-out / account chooser / blocked / empty shell，只能代表那条路由，不代表用户真实 Chrome 未登录；必须回到 `chrome-access-routing` 再判断。
- 如果任务不需要用户真实 Chrome、真实会话或桌面窗口，才优先使用 gstack 的 `browse` 及相关 QA skills 处理网页浏览、网页测试、截图、本地 web app dogfood 和视觉 QA。
- `web-access` 负责公开网页检索、抓取和联网资料核验；不要用它判断用户当前 macOS Chrome 的登录状态。
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
