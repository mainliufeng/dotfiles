# Skill Catalog

This is the human-maintained list of skills that agent-skill-manager should manage.
Expand and correct this file as migration proceeds.

## Columns
- `skill`: canonical skill name
- `source`: where the skill comes from
- `targets`: desired runtimes
- `mode`: `default` means use target default install doc; `special:<name>` means read a matching file under `assets/special-installs/`
- `status`: migration note

| skill | source | targets | mode | status |
|---|---|---|---|---|
| commit | local repo | codex, claude-code, hermes | default | migrate first |
| hyprland | local repo | codex | default | migrate later |
| frontend-design | github / anthropics/skills | codex, claude-code | default | candidate |
| webapp-testing | github / anthropics/skills | codex, claude-code | default | candidate |
| docx | github / anthropics/skills | codex | default | candidate |
| pdf | github / anthropics/skills | codex | default | candidate |
| skill-creator | github / anthropics/skills | codex | default | candidate |
| remotion | github / remotion-dev/skills | codex | default | candidate |
| tapestry | github / michalparkola/tapestry-skills-for-claude-code | codex, claude-code | default | candidate |
| humanizer-zh | github / op7418/Humanizer-zh | codex, hermes | default | github source confirmed; install for codex + hermes |
| gstack | github / garrytan/gstack | codex, claude-code | special:gstack | special flow |
| notebooklm | github / teng-lin/notebooklm-py | codex, hermes | special:notebooklm | pipx CLI + managed local skill |
| impeccable | github / pbakaus/impeccable | codex | special:impeccable | codex skill bundle from upstream repo |
| web-access | github / eze-is/web-access | codex, hermes | default | github source confirmed; install for codex + hermes |
| superpowers | upstream bootstrap | codex, claude-code | special:superpowers | special flow |
| last30days | github / mvanhorn/last30days-skill | hermes | default | github source confirmed |
| chirp | github / zizi-cat/chirp | hermes | default | github source confirmed |
| md2wechat | github / geekjourneyx/md2wechat-skill | hermes | default | github source confirmed |
| xhs-note-creator | github / LinkRogers/xhs-note-creator | hermes | default | github source confirmed |
| xiaohongshu-ops | github / Xiangyu-CAS/xiaohongshu-ops-skill | hermes | default | github source confirmed |

## Migration notes

- `default` mode means: read the target-specific install-default doc and apply that behavior.
- `special:*` means there is enough nuance that the agent must read the named special-install document first.
- This file is intentionally markdown instead of YAML so it stays easy to edit during migration.
- Former OpenClaw-import skills should be switched to direct GitHub sources whenever an upstream repo exists.
- Public local skills resolve from `~/dotfiles/agent-skill-manager/public_skills/<skill-name>`.
- Private-only skills live in `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md` and are part of the manager's full source of truth when that file exists.
