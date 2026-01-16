#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
import json
import subprocess

clients = json.loads(subprocess.check_output(["hyprctl", "-j", "clients"]))
for c in clients:
    addr = c.get("address", "")
    ws = c.get("workspace", {}).get("name", "")
    klass = c.get("class", "")
    title = c.get("title", "")
    print(f"{addr}\t{ws}\t{klass}\t{title}")
PY
