## gstack
```
处理网页浏览、网页测试和截图前，先按 `chrome-access-routing` 判断目标表面。不要直接让第三方浏览器 skill 抢真实 Chrome 登录态判断。

Codex 默认不把 gstack 挂到 `~/.codex/skills`，避免 gstack 的大流程/专项技能自动抢占普通编码任务。只有用户明确要求启用 gstack Codex skills 时，才运行 `cd ~/gstack && ./setup --host codex`，并说明这会重新引入广泛自动发现。

- 如果任务需要用户当前 macOS Chrome 窗口、真实标签页、真实登录态、Google Search Console / GSC、Google 账号会话、authenticated dashboard、Chrome 插件状态或可见桌面状态，必须先走 `chrome-access-routing`；在 macOS 上它会优先用 Computer Use 检查 `Google Chrome`。
- Chrome Extension、gstack `browse`、Browser、web-access 或 headless 路径看到的 signed-out / account chooser / blocked / empty shell，只能代表那条路由，不代表用户真实 Chrome 未登录；必须回到 `chrome-access-routing` 再判断。
- 如果任务不需要用户真实 Chrome、真实会话或桌面窗口，可以在用户明确要求 gstack 或需要其专项 QA 流程时手动使用 gstack 的 `browse` / `qa`；普通本地 web app dogfood 优先用当前可用的 Browser、Chrome DevTools 或项目自带测试工具。
- `web-access` 负责公开网页检索、抓取和联网资料核验；不要用它判断用户当前 macOS Chrome 的登录状态。
- 不要使用 `mcp__claude-in-chrome__*` 工具。

gstack 作为手动/专项参考时，可用技能包括：
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

如果需要临时使用 gstack，优先读取 `~/gstack/.agents/skills/<skill>/SKILL.md` 作为参考或按用户明确指令手动启用；不要因为普通编码任务自动安装到 Codex runtime。
```
