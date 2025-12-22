#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import time

def log_line(path, payload):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(payload, ensure_ascii=True) + "\n")


def main():
    base_dir = os.path.expanduser("~/.local/share/mako")
    log_path = os.path.join(base_dir, "notifications.jsonl")
    session_path = os.path.join(base_dir, "notify-log.session")
    os.makedirs(base_dir, exist_ok=True)
    with open(session_path, "w", encoding="utf-8") as f:
        f.write(str(int(time.time())) + "\n")
    pending = {}

    # Capture both calls and returns; dbus-monitor output is line-based.
    proc = subprocess.Popen(
        ["dbus-monitor", "--session"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )

    current = None
    pending_string = None
    for line in proc.stdout:
        line = line.rstrip("\n")

        if pending_string is not None:
            buf = pending_string["buf"] + "\n" + line
            if line.endswith("\""):
                buf = buf[:-1]
                current["args"].append(buf)
                pending_string = None
            else:
                pending_string["buf"] = buf
            continue

        m_call = re.match(
            r"^method call .* serial=(\d+) .* interface=org\.freedesktop\.Notifications; member=(\w+)$",
            line,
        )
        if m_call:
            serial = m_call.group(1)
            member = m_call.group(2)
            current = {
                "type": "call",
                "serial": serial,
                "member": member,
                "args": [],
            }
            continue

        m_return = re.match(r"^method return .* reply_serial=(\d+)$", line)
        if m_return:
            reply_serial = m_return.group(1)
            current = {"type": "return", "reply_serial": reply_serial, "args": []}
            continue

        if current is None:
            continue

        # Parse argument lines like: "   string \"foo\"" or "   uint32 4"
        m_arg = re.match(r"^\s+(string|uint32)\s+(.*)$", line)
        if not m_arg:
            continue

        arg_type = m_arg.group(1)
        raw = m_arg.group(2).rstrip()
        if arg_type == "string":
            value = raw.strip()
            if value.startswith("\""):
                value = value[1:]
                if value.endswith("\""):
                    value = value[:-1]
                    current["args"].append(value)
                else:
                    pending_string = {"buf": value}
            else:
                current["args"].append(value)
        else:
            current["args"].append(raw.strip())

        if current["type"] == "call" and current["member"] == "Notify":
            # Args order: app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout
            if len(current["args"]) >= 5:
                app_name = current["args"][0]
                replaces_id = current["args"][1]
                app_icon = current["args"][2]
                summary = current["args"][3]
                body = current["args"][4]
                pending[current["serial"]] = {
                    "app_name": app_name,
                    "replaces_id": replaces_id,
                    "app_icon": app_icon,
                    "summary": summary,
                    "body": body,
                }
                current = None
            continue

        if current["type"] == "return":
            # For Notify, first uint32 is the notification id
            if len(current["args"]) >= 1:
                notif_id = current["args"][0]
                info = pending.pop(current["reply_serial"], None)
                if info:
                    log_line(
                        log_path,
                        {
                            "ts": int(time.time()),
                            "id": str(notif_id),
                            "app": info["app_name"],
                            "summary": info["summary"],
                            "body": info["body"],
                        },
                    )
                current = None
            continue


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
