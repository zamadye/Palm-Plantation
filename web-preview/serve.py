#!/usr/bin/env python3
"""Serve the browser preview at / and expose the shared repository assets."""

from __future__ import annotations

import argparse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
WEB_ROOT = REPOSITORY_ROOT / "web-preview"
ASSET_ROOT = REPOSITORY_ROOT / "assets"


def safe_path(root: Path, relative: str) -> str:
    candidate = (root / relative).resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError:
        return str(root / "__not_found__")
    return str(candidate)


class PreviewHandler(SimpleHTTPRequestHandler):
    def translate_path(self, request_path: str) -> str:
        path = unquote(urlsplit(request_path).path)
        if path in {"", "/"}:
            return str(WEB_ROOT / "index.html")
        if path == "/assets":
            return str(ASSET_ROOT)
        if path.startswith("/assets/"):
            return safe_path(ASSET_ROOT, path.removeprefix("/assets/"))
        if path == "/web-preview":
            return str(WEB_ROOT)
        if path.startswith("/web-preview/"):
            return safe_path(WEB_ROOT, path.removeprefix("/web-preview/"))
        return safe_path(WEB_ROOT, path.lstrip("/"))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()
    server = ThreadingHTTPServer(("0.0.0.0", args.port), PreviewHandler)
    print(f"Palm Plantation web preview: http://0.0.0.0:{args.port}/", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
