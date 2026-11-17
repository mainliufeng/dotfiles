#!/usr/bin/env python3
"""Fail-closed Codex diagnostic integration boundary.

This module deliberately does not launch Codex. See CODEX_ADAPTER.md for the
isolation prerequisites. Collecting evidence is not authorization to transmit it.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
from pathlib import Path
from typing import Any

MAX_EVIDENCE_BYTES = 256 * 1024
BLOCKER = (
    "Codex diagnostic execution is disabled: an authenticated model client with "
    "tool access has not been verified to be isolated from host credentials, "
    "Docker/system sockets, localhost services, and unrestricted host files."
)


def capability() -> dict[str, Any]:
    """Machine-readable capability, not a probe of the user's credentials."""
    return {
        "backend": "codex",
        "enabled": False,
        "status": "blocked",
        "reason": BLOCKER,
        "model_invoked": False,
        "automatic_repairs": False,
    }


def _read_evidence(path: Path) -> bytes:
    # Reject symlinks (including a swapped final component) and non-regular files.
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode):
            raise ValueError("Evidence must be a regular JSON file")
        if info.st_size > MAX_EVIDENCE_BYTES:
            raise ValueError("Evidence exceeds the 256 KiB limit")
        with os.fdopen(fd, "rb", closefd=False) as source:
            raw = source.read(MAX_EVIDENCE_BYTES + 1)
        if len(raw) > MAX_EVIDENCE_BYTES:
            raise ValueError("Evidence exceeds the 256 KiB limit")
        value = json.loads(raw)
        if not isinstance(value, dict):
            raise ValueError("Evidence must be a JSON object")
        return raw
    finally:
        os.close(fd)


def diagnose(evidence_path: str | Path, output_dir: str | Path) -> dict[str, Any]:
    """Record a blocked attempt; never execute a model or transmit evidence.

    The result contains a digest and byte count, never evidence content or its
    path. An existing result is not overwritten, including through a symlink.
    A new output directory is private. Callers must use an owned private parent.
    """
    raw = _read_evidence(Path(evidence_path))
    output = Path(output_dir)
    output.mkdir(mode=0o700, parents=True, exist_ok=True)
    st = output.lstat()
    if not stat.S_ISDIR(st.st_mode) or st.st_uid != os.getuid():
        raise ValueError("Output directory must be an owned, non-symlink directory")
    if st.st_mode & 0o077:
        raise ValueError("Output directory must not be accessible to group or others")
    result = capability() | {
        "evidence_sha256": hashlib.sha256(raw).hexdigest(),
        "evidence_bytes": len(raw),
        "transmitted": False,
    }
    fd = os.open(output / "diagnosis.json", os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8") as target:
        json.dump(result, target, ensure_ascii=False, indent=2)
        target.write("\n")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--status", action="store_true")
    parser.add_argument("--evidence", type=Path)
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    if args.status:
        result = capability()
    elif args.evidence and args.output_dir:
        try:
            result = diagnose(args.evidence, args.output_dir)
        except (OSError, ValueError) as exc:
            # Do not echo content, command output, or potentially sensitive paths.
            print(json.dumps({"status": "invalid_input", "error_type": type(exc).__name__, "model_invoked": False}))
            return 2
    else:
        parser.error("Pass --status or both --evidence and --output-dir")
    print(json.dumps(result, ensure_ascii=False))
    return 3  # A blocked diagnostic must never be interpreted as success.


if __name__ == "__main__":
    raise SystemExit(main())
