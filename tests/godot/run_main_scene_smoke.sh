#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

if [[ "$GODOT_BIN" != */* ]]; then
	GODOT_BIN="$(command -v "$GODOT_BIN" || true)"
fi
if [[ -z "$GODOT_BIN" || ! -x "$GODOT_BIN" ]]; then
	echo "FAIL: set GODOT_BIN to an executable Godot 4.3+ binary." >&2
	exit 2
fi

VERSION="$("$GODOT_BIN" --version 2>&1)"
echo "Godot runtime: $VERSION"
LOG_DIR="$(mktemp -d "${TMPDIR:-/tmp}/palm-main-scene-smoke.XXXXXX")"
KEEP_LOGS="${KEEP_LOGS:-0}"
cleanup() {
	if [[ "$KEEP_LOGS" == "1" ]]; then
		echo "Captured logs retained at: $LOG_DIR"
	else
		rm -rf "$LOG_DIR"
	fi
}
trap cleanup EXIT

run_checked() {
	local label="$1"
	shift
	local log="$LOG_DIR/$label.log"
	printf '\nRUN:'
	printf ' %q' "$@"
	printf '\n'
	local result=0
	"$@" >"$log" 2>&1 || result=$?
	if [[ $result -ne 0 ]]; then
		cat "$log"
		echo "FAIL: $label command exited $result." >&2
		exit "$result"
	fi
	if grep -Eq 'SCRIPT ERROR:|Parse Error:|ERROR: Failed to load script' "$log"; then
		cat "$log"
		echo "FAIL: $label produced a GDScript parse/load error." >&2
		exit 1
	fi
	local mesh_error_lines
	local mesh_stack_lines
	mesh_error_lines="$(grep -c '^ERROR: Parameter \"m\" is null\.$' "$log" || true)"
	mesh_stack_lines="$(grep -c 'at: mesh_get_surface_count (servers/rendering/dummy/storage/mesh_storage.h:120)' "$log" || true)"
	local unexpected_errors
	unexpected_errors="$(grep '^ERROR:' "$log" | grep -v '^ERROR: Parameter \"m\" is null\.$' || true)"
	if [[ -n "$unexpected_errors" || "$mesh_error_lines" != "$mesh_stack_lines" ]]; then
		cat "$log"
		echo "FAIL: $label produced unexpected engine/runtime errors." >&2
		[[ -n "$unexpected_errors" ]] && printf '%s\n' "$unexpected_errors" >&2
		exit 1
	fi
	if [[ "$mesh_error_lines" -gt 0 ]]; then
		echo "UNVERIFIED: $label used Godot's Dummy renderer and emitted $mesh_error_lines mesh_get_surface_count diagnostic(s)."
		grep -A1 -m1 '^ERROR: Parameter "m" is null\.$' "$log" || true
	fi
	case "$label" in
		project_import)
			sed -n '1,3p' "$log"
			;;
		scene_graph_smoke)
			grep -E '^(Native main-scene|PASS \||UNVERIFIED \||Smoke assertions:|RESULT:)' "$log" || true
			;;
		dummy_box_probe)
			grep -E '^Standalone probe|^Probe completed' "$log" || true
			;;
	esac
}

run_checked project_import "$GODOT_BIN" --headless --editor --path "$PROJECT_DIR" --quit
echo "PASS: project import and engine GDScript parse/load stage."

run_checked main_scene_launch "$GODOT_BIN" --headless --path "$PROJECT_DIR" --quit-after 5
echo "PASS: configured main scene starts and runs its initial frames without GDScript errors."

run_checked scene_graph_smoke "$GODOT_BIN" --headless --path "$PROJECT_DIR" --script res://tests/godot/main_scene_smoke.gd
echo "PASS: repository-backed main-scene structure/gameplay smoke assertions."

probe_project="$LOG_DIR/dummy-renderer-probe"
mkdir -p "$probe_project"
cat >"$probe_project/project.godot" <<'EOF'
config_version=5

[application]
config/name="Godot Dummy Renderer Mesh Probe"
EOF
cp "$SCRIPT_DIR/dummy_renderer_probe.gd" "$probe_project/probe.gd"
run_checked dummy_box_probe "$GODOT_BIN" --headless --path "$probe_project" --script res://probe.gd
probe_log="$LOG_DIR/dummy_box_probe.log"
if ! grep -q 'mesh_get_surface_count' "$probe_log"; then
	echo "FAIL: standalone BoxMesh did not reproduce the expected Dummy-renderer diagnostic." >&2
	exit 1
fi
echo "PASS: standalone BoxMesh reproduced the same Dummy-renderer diagnostic; process exit remains non-fatal."

echo
echo "RESULT: native project import, scene startup, node initialization, and scripted interaction checks PASS."
echo "RESULT: rendered pixels, visual framing, and physical mouse/touch acceptance remain UNVERIFIED in this headless environment."
