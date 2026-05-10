# Skill Catalog

This is the human-maintained list of skills that agent-skill-manager should manage.
Expand and correct this file as migration proceeds.

## Columns
- `skill`: canonical skill name
- `source`: where the skill comes from
- `targets`: desired runtimes
- `platforms`: `all`, `macos`, `archlinux`, or `runtime-builtin`
- `mode`: `default` means use target default install doc; `special:<name>` means read a matching file under `assets/special-installs/`
- `status`: migration note

| skill | source | targets | platforms | mode | status |
|---|---|---|---|---|---|
| commit | local repo | codex, claude-code, hermes | all | default | keep |
| archlinux-desktop-ops | local repo | codex | archlinux | default | Arch Linux / Hyprland only; skip on macOS |
| iteration-drift-guard | local repo | codex, claude-code | all | default | general guardrail for long AI-assisted engineering iterations |
| frontend-design | github / anthropics/skills | codex, claude-code | all | default | keep; verify source vs local runtime copy |
| docx | builtin / openai-primary-runtime documents | codex | runtime-builtin | builtin:documents | replaced by Codex App Documents plugin; no external install |
| pdf | github / anthropics/skills | codex | all | default | review-needed; keep only for non-DOCX PDF operations |
| skill-creator | builtin / codex system skill | codex | runtime-builtin | builtin | Codex App system skill; no external install |
| remotion | github / remotion-dev/skills | codex | all | default | candidate |
| tapestry | github / michalparkola/tapestry-skills-for-claude-code | codex, claude-code | all | default | keep; verify source vs local runtime copy |
| humanizer-zh | github / op7418/Humanizer-zh | codex, hermes | all | default | github source confirmed; install for codex + hermes |
| gstack | github / garrytan/gstack | codex, claude-code | all | special:gstack | special flow |
| notebooklm | github / teng-lin/notebooklm-py | codex, hermes | all | special:notebooklm | pipx CLI + managed local skill |
| impeccable | github / pbakaus/impeccable | codex | all | special:impeccable | codex skill bundle from upstream repo |
| web-access | github / eze-is/web-access | codex, hermes | all | default | github source confirmed; install for codex + hermes |
| last30days | github / mvanhorn/last30days-skill | hermes | all | default | github source confirmed |
| chirp | github / zizi-cat/chirp | hermes | all | default | github source confirmed |
| md2wechat | github / geekjourneyx/md2wechat-skill | hermes | all | default | github source confirmed |
| xhs-note-creator | github / LinkRogers/xhs-note-creator | hermes | all | default | github source confirmed |
| xiaohongshu-ops | github / Xiangyu-CAS/xiaohongshu-ops-skill | hermes | all | default | github source confirmed |

## Migration notes

- `default` mode means: read the target-specific install-default doc and apply that behavior.
- `special:*` means there is enough nuance that the agent must read the named special-install document first.
- `runtime-builtin` platform means the target runtime already provides the capability; verify it exists and do not install an external duplicate.
- `archlinux` platform means the skill is only for the Arch Linux laptop. Skip it on macOS.
- This file is intentionally markdown instead of YAML so it stays easy to edit during migration.
- Former OpenClaw-import skills should be switched to direct GitHub sources whenever an upstream repo exists.
- Public local skills resolve from `~/dotfiles/agent-skill-manager/public_skills/<skill-name>`.
- Private-only skills live in `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md` and are part of the manager's full source of truth when that file exists.
