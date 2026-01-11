#!/usr/bin/env python3

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise FileNotFoundError(f"Missing file: {path}")


def resolve_root(root_arg: str) -> Path:
    if root_arg.startswith("~"):
        return Path(os.path.expanduser(root_arg)).resolve()
    return Path(root_arg).resolve()


def find_workflow_dir(root: Path, workflow_id: str) -> Path:
    return root / "workflows" / workflow_id


def select_messages(messages, mode: str, tail: int | None):
    if mode == "last-assistant":
        for message in reversed(messages):
            if message.get("role") == "assistant":
                return [message]
        return []
    if mode == "tail":
        if tail is None or tail <= 0:
            return messages
        return messages[-tail:]
    return messages


def format_text(dep):
    lines = [f"[{dep['id']}] {dep['title']} ({dep['status']})"]
    if dep.get("messages"):
        for message in dep["messages"]:
            role = message.get("role", "unknown")
            content = message.get("content", "")
            lines.append(f"- {role}: {content}")
    else:
        lines.append("- (no messages)")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Get dependency node results for a workflow node.")
    parser.add_argument("--workflow-id", required=True, help="Workflow id")
    parser.add_argument("--node-id", required=True, help="Node id to inspect")
    parser.add_argument("--root", default="~/.workflow_desktop", help="Workflow root directory")
    parser.add_argument(
        "--mode",
        choices=["last-assistant", "all", "tail"],
        default="last-assistant",
        help="Message selection mode",
    )
    parser.add_argument("--tail", type=int, default=None, help="Tail N messages (mode=tail)")
    parser.add_argument("--format", choices=["json", "text"], default="json", help="Output format")

    args = parser.parse_args()

    root = resolve_root(args.root)
    workflow_dir = find_workflow_dir(root, args.workflow_id)
    workflow_file = workflow_dir / "workflow.json"
    workflow = load_json(workflow_file)

    nodes = {node["id"]: node for node in workflow.get("nodes", [])}
    node = nodes.get(args.node_id)
    if not node:
        raise SystemExit(f"Node not found: {args.node_id}")

    deps = node.get("dependsOn", [])
    results = []
    for dep_id in deps:
        node_file = workflow_dir / "nodes" / f"{dep_id}.json"
        node_data = load_json(node_file)
        dep_meta = nodes.get(dep_id, {})
        messages = node_data.get("messages", [])
        selected = select_messages(messages, args.mode, args.tail)
        results.append(
            {
                "id": dep_id,
                "title": dep_meta.get("title", ""),
                "status": node_data.get("status", dep_meta.get("status", "")),
                "mode": node_data.get("mode", dep_meta.get("mode", "")),
                "messages": selected,
            }
        )

    payload = {
        "workflowId": args.workflow_id,
        "nodeId": args.node_id,
        "dependsOn": results,
        "generatedAt": datetime.utcnow().isoformat() + "Z",
    }

    if args.format == "text":
        for dep in results:
            print(format_text(dep))
            print("")
        return

    print(json.dumps(payload, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
