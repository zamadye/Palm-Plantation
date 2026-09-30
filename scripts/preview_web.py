#!/usr/bin/env python3
"""Export the actual Godot project for WebGL, then serve it with Python.

Requires Godot 4.3+ and matching Web export templates. Godot generates the
HTML, JavaScript, WebAssembly runtime, and project data under build/web/.
"""

from __future__ import annotations

import argparse
import os
import shlex
import shutil
import subprocess
import sys
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
EXPORT_DIR = PROJECT_ROOT / "build" / "web"
EXPORT_HTML = EXPORT_DIR / "index.html"


def resolve_godot(spec: str | None) -> list[str]:
    """Resolve a Godot executable, accepting paths that contain spaces."""
    configured = spec or os.environ.get("GODOT_BIN")
    if configured:
        direct_path = Path(configured).expanduser()
        candidates = (
            [[str(direct_path.resolve())]]
            if direct_path.is_file()
            else [shlex.split(configured, posix=os.name != "nt")]
        )
    else:
        candidates = [["godot"], ["godot4"]]

    for candidate in candidates:
        if not candidate:
            continue
        executable = candidate[0]
        path = Path(executable).expanduser()
        if path.is_file():
            candidate[0] = str(path.resolve())
            return candidate
        found = shutil.which(executable)
        if found:
            candidate[0] = found
            return candidate

    raise FileNotFoundError(
        "Godot 4.x was not found. Install Godot 4.3 or newer with Web export "
        "templates, then rerun with --godot /path/to/godot (or set GODOT_BIN)."
    )


def export_game(godot: list[str], release: bool) -> None:
    if not (PROJECT_ROOT / "export_presets.cfg").is_file():
        raise FileNotFoundError("The checked-in Web preset export_presets.cfg is missing.")

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    mode = "--export-release" if release else "--export-debug"
    output_path = EXPORT_HTML.relative_to(PROJECT_ROOT).as_posix()
    command = [
        *godot,
        "--headless",
        "--path",
        str(PROJECT_ROOT),
        mode,
        "Web",
        output_path,
    ]
    print("Exporting this Godot project to WebGL (no editor window is opened):")
    print("  " + " ".join(shlex.quote(part) for part in command))
    try:
        status = subprocess.run(command, cwd=PROJECT_ROOT, check=False).returncode
    except OSError as error:
        raise FileNotFoundError(f"Could not launch Godot: {error}") from error
    if status != 0:
        raise SystemExit(status)
    if not EXPORT_HTML.is_file():
        raise RuntimeError(
            f"Godot exited successfully but did not create {EXPORT_HTML}. "
            "Check that matching Web export templates are installed."
        )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export Palm Plantation with Godot, then serve the build using python -m http.server."
    )
    parser.add_argument(
        "--godot",
        help="Godot 4 executable or command (defaults to GODOT_BIN, godot, then godot4).",
    )
    parser.add_argument(
        "--port", type=int, default=8000, help="HTTP port for the preview (default: 8000)."
    )
    parser.add_argument(
        "--host",
        default="0.0.0.0",
        help="HTTP interface to bind (default: 0.0.0.0, suitable for preview hosting).",
    )
    parser.add_argument(
        "--release",
        action="store_true",
        help="Create an optimized release export instead of a debug export.",
    )
    parser.add_argument(
        "--serve-only",
        action="store_true",
        help="Serve an existing build/web export without invoking Godot.",
    )
    args = parser.parse_args()

    if not 0 <= args.port <= 65535:
        parser.error("--port must be between 0 and 65535")

    try:
        if args.serve_only:
            if not EXPORT_HTML.is_file():
                raise FileNotFoundError(
                    f"No Web export found at {EXPORT_HTML}. Run this script once without --serve-only."
                )
        else:
            export_game(resolve_godot(args.godot), args.release)
    except FileNotFoundError as error:
        print(f"Preview setup error: {error}", file=sys.stderr)
        return 2
    except RuntimeError as error:
        print(f"Preview setup error: {error}", file=sys.stderr)
        return 2

    # This is the same standard-library server users can start themselves with:
    # python3 -m http.server 8000 --bind 0.0.0.0 --directory build/web
    server_command = [
        sys.executable,
        "-m",
        "http.server",
        str(args.port),
        "--bind",
        args.host,
        "--directory",
        str(EXPORT_DIR),
    ]
    print(f"Serving Godot's generated index.html on port {args.port}.")
    print("  " + " ".join(shlex.quote(part) for part in server_command))
    try:
        return subprocess.run(server_command, cwd=PROJECT_ROOT, check=False).returncode
    except OSError as error:
        print(f"Could not start Python's HTTP server: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
