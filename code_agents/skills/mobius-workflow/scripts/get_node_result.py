#!/usr/bin/env python3

import argparse
import json
import os
import sys
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


def main() -> None:
    parser = argparse.ArgumentParser(description="Get node result file.")
    parser.add_argument("--workflow-id", required=True, help="Workflow id")
    parser.add_argument("--node-id", required=True, help="Node id")
    parser.add_argument(
        "--root", default="~/.mobius-workflow", help="Workflow root directory"
    )
    parser.add_argument(
        "--format", choices=["json", "text"], default="json", help="Output format"
    )

    args = parser.parse_args()

    root = resolve_root(args.root)
    result_path = (
        root / "workflows" / args.workflow_id / "nodes" / f"{args.node_id}.result.json"
    )
    result = load_json(result_path)

    if args.format == "text":
        text = result.get("result", "")
        if text:
            print(text)
        else:
            print("(no result)")
        return

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
