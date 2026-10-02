#!/usr/bin/env python3
"""Serve the browser preview and shared repository assets from one root."""

from __future__ import annotations

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]


class PreviewHandler(SimpleHTTPRequestHandler):
    def do_GET(self) -> None:
        request_path = urlsplit(self.path).path
        if request_path in {"", "/"}:
            self.send_response(302)
            self.send_header("Location", "/web-preview/")
            self.end_headers()
            return
        if request_path == "/web-preview":
            self.send_response(301)
            self.send_header("Location", "/web-preview/")
            self.end_headers()
            return
        super().do_GET()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()
    handler = partial(PreviewHandler, directory=str(REPOSITORY_ROOT))
    server = ThreadingHTTPServer(("0.0.0.0", args.port), handler)
    print(f"Palm Plantation web preview: http://0.0.0.0:{args.port}/web-preview/", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
