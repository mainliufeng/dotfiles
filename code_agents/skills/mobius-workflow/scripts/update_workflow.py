#!/usr/bin/env python3

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path


def resolve_root(root_arg: str) -> Path:
    if root_arg.startswith("~"):
        return Path(os.path.expanduser(root_arg)).resolve()
    return Path(root_arg).resolve()


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise FileNotFoundError(f"Missing file: {path}")


def write_json(path: Path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def now_iso() -> str:
    return datetime.utcnow().isoformat() + "Z"


def parse_dep_list(values: list[str] | None) -> list[str]:
    if not values:
        return []
    deps: list[str] = []
    for item in values:
        if not item:
            continue
        parts = [part.strip() for part in item.split(",") if part.strip()]
        deps.extend(parts)
    return list(dict.fromkeys(deps))


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Update workflow.json fields (no session/result files)."
    )
    parser.add_argument("--workflow-id", required=True, help="Workflow id")
    parser.add_argument(
        "--root", default="~/.mobius-workflow", help="Workflow root directory"
    )
    parser.add_argument("--name", help="Set workflow name")
    parser.add_argument("--root-prompt", help="Set workflow rootPrompt")
    parser.add_argument(
        "--status",
        choices=["draft", "running", "paused", "done"],
        help="Set workflow status",
    )

    parser.add_argument("--node-id", help="Target node id for node updates")
    parser.add_argument("--title", help="Set node title")
    parser.add_argument("--prompt", help="Set node prompt")
    parser.add_argument(
        "--mode", choices=["interactive", "automatic"], help="Set node mode"
    )
    parser.add_argument(
        "--node-status",
        choices=["idle", "running", "awaiting_input", "done", "failed"],
        help="Set node status",
    )
    parser.add_argument(
        "--set-depends",
        action="append",
        help="Replace dependsOn list (comma-separated)",
    )
    parser.add_argument(
        "--add-dep", action="append", help="Add dependency id (comma-separated)"
    )
    parser.add_argument(
        "--remove-dep", action="append", help="Remove dependency id (comma-separated)"
    )

    args = parser.parse_args()

    root = resolve_root(args.root)
    workflow_path = root / "workflows" / args.workflow_id / "workflow.json"
    workflow = load_json(workflow_path)

    touched = False

    if args.name is not None:
        workflow["name"] = args.name
        touched = True
    if args.root_prompt is not None:
        workflow["rootPrompt"] = args.root_prompt
        touched = True
    if args.status is not None:
        workflow["status"] = args.status
        touched = True

    node_fields_requested = any(
        value is not None
        for value in [
            args.title,
            args.prompt,
            args.mode,
            args.node_status,
            args.set_depends,
            args.add_dep,
            args.remove_dep,
        ]
    )

    if node_fields_requested and not args.node_id:
        raise SystemExit("--node-id is required for node updates")

    if args.node_id:
        nodes = workflow.get("nodes", [])
        node = next((item for item in nodes if item.get("id") == args.node_id), None)
        if not node:
            raise SystemExit(f"Node not found: {args.node_id}")

        if args.title is not None:
            node["title"] = args.title
            touched = True
        if args.prompt is not None:
            node["prompt"] = args.prompt
            touched = True
        if args.mode is not None:
            node["mode"] = args.mode
            touched = True
        if args.node_status is not None:
            node["status"] = args.node_status
            touched = True

        if args.set_depends:
            node["dependsOn"] = parse_dep_list(args.set_depends)
            touched = True

        if args.add_dep:
            deps = list(node.get("dependsOn", []))
            deps.extend(parse_dep_list(args.add_dep))
            node["dependsOn"] = list(dict.fromkeys(deps))
            touched = True

        if args.remove_dep:
            remove_set = set(parse_dep_list(args.remove_dep))
            deps = [dep for dep in node.get("dependsOn", []) if dep not in remove_set]
            node["dependsOn"] = deps
            touched = True

        if touched:
            node["updatedAt"] = now_iso()

    if not touched:
        print("No changes requested.")
        return

    workflow["updatedAt"] = now_iso()
    write_json(workflow_path, workflow)

    print(
        json.dumps(
            {"workflowId": args.workflow_id, "updatedAt": workflow["updatedAt"]},
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
