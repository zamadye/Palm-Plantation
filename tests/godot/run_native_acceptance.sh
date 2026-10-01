#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

if [[ "$GODOT_BIN" == */* ]]; then
  if [[ ! -x "$GODOT_BIN" ]]; then
    echo "ERROR: GODOT_BIN is not an executable file: $GODOT_BIN" >&2
    exit 2
  fi
elif ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "ERROR: Godot executable '$GODOT_BIN' not found. Set GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64." >&2
  exit 2
fi

VERSION="$("$GODOT_BIN" --version)"
if [[ "$VERSION" != 4.3.* ]]; then
  echo "ERROR: this acceptance command is pinned to Godot 4.3; found '$VERSION'." >&2
  exit 2
fi

echo "Godot runtime: $VERSION"
echo
echo "RUN: clean editor import and GDScript parse/load"
"$GODOT_BIN" --headless --editor --path "$ROOT" --quit

echo
echo "RUN: deterministic native GDScript simulation acceptance"
"$GODOT_BIN" --headless --path "$ROOT" --script res://tests/godot/simulation_acceptance.gd

echo
echo "RUN: targeted crop-calendar and yield-model checks"
"$GODOT_BIN" --headless --path "$ROOT" --script res://tests/godot/crop_model_smoke.gd

echo
echo "RUN: headless main-scene structural smoke (not visual acceptance)"
GODOT_BIN="$GODOT_BIN" "$ROOT/tests/godot/run_main_scene_smoke.sh"
