# External Native Validation Runbook

## Purpose and status

This runbook is for completing native graphical and physical-input acceptance on a machine that can run the project with a usable non-Dummy renderer. It does not add gameplay, change the renderer, or substitute headless structure checks for visual acceptance.

**M2 remains FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS.** The deterministic native core simulation/import/structural checks and focused M3 crop-model smoke pass in the current working tree; native rendered pixels, visual layout, physical input, and target-device performance remain **UNVERIFIED**. If the external machine cannot start a visible non-Dummy backend, stop and record those checks as **UNVERIFIED**. Do not use fake screenshots or test-only rendering.

## Prerequisites

- A clean checkout containing the project and acceptance files.
- Godot **4.3** (record the full version/build string).
- A usable graphical display and a supported GPU/Vulkan or OpenGL driver, or an independently verified software-rendering/display stack.
- A mouse and/or the supported touch device/input path.
- The agreed target device, resolution, and orientation, when testing the mobile target.
- A writable evidence directory with space for logs, screenshots, and an optional short recording.

Do not silently substitute Dummy rendering for a visible renderer. The browser/Three.js prototype is a separate runtime and cannot satisfy native acceptance.

## A. Record environment information

Record this before launching the game. Do not leave any fields blank; if unknown, write `UNVERIFIED`.

| Field | Value to record |
|---|---|
| Test date/time and tester |  |
| OS, distribution/version, and kernel |  |
| Device/model and model identifier |  |
| CPU/model and core count |  |
| GPU/model, driver, and driver version |  |
| RAM |  |
| Display resolution and refresh rate |  |
| Orientation (landscape/portrait) |  |
| Input device(s): mouse, touchscreen, or both |  |
| Godot full version/build |  |
| Godot display driver and renderer/backend (for example, Vulkan, OpenGL, or verified software renderer; never infer from project settings) |  |
| Git commit SHA tested (`git rev-parse HEAD`) |  |
| Git working-tree state (`git status --short`) |  |
| Evidence directory |  |

Useful host checks include `uname -a`, the OS release file, CPU/RAM tools for the platform, the platform's GPU/driver utility, and Godot's startup log. Capture the renderer/backend as reported by the running engine, not only as configured in `project.godot`.

## B. Clean-checkout procedure

Use a commit that contains the complete project and test files; record its exact SHA. Do not validate a partial checkout or copy selected source files into it and call that a clean checkout.

```sh
git clone https://github.com/zamadye/Palm-Plantation.git Palm-Plantation-validation
cd Palm-Plantation-validation
git checkout <commit-sha-containing-the-project-and-tests>
git status --short
git rev-parse HEAD
```

Replace `<commit-sha-containing-the-project-and-tests>` with the exact commit to test before running the commands. Confirm the working tree is clean and that `project.godot`, `scenes/main/main.tscn`, `tests/godot/simulation_acceptance.gd`, `tests/godot/main_scene_smoke.gd`, and this runbook exist. If any are missing, stop, mark the suites **NOT RUN**, and do not report fresh-checkout validation as passing; report that checkout was not available.

Set the Godot executable for the following commands:

```sh
export GODOT_BIN=/absolute/path/to/Godot_v4.3-stable_linux.x86_64
"$GODOT_BIN" --version
```

Confirm the version is Godot 4.3. Record the full version string and commit SHA in the evidence record.

### Deterministic native command

Run the single native import/simulation command:

```sh
GODOT_BIN="$GODOT_BIN" tests/godot/run_native_acceptance.sh
```

This single command checks the Godot 4.3 version, runs a headless editor import/GDScript parse, runs `tests/godot/simulation_acceptance.gd` (109 core assertions), runs `tests/godot/crop_model_smoke.gd` (65 focused M3 checks, including deterministic eight-model-year scenario fixtures), then runs `tests/godot/run_main_scene_smoke.sh` (110 structural assertions in the current working tree). The scene smoke checks all eight imported operation GLBs, their mesh resources, and the visual-only mill/route disclaimer. Structural stages are explicitly headless and non-visual; no stage validates rendered pixels, physical input, camera framing, or device performance.

The browser prototype has a separate Node suite; run it independently and report it as browser-only evidence:

```sh
node --test web-preview/tests/*.test.mjs
```

## C. Native startup and graphical run (manual)

This is a separate, **manual graphical** process. It is not an automated visual test.

Create an evidence directory named with the commit SHA and date, then launch the configured main scene without `--headless`:

```sh
COMMIT_SHA="$(git rev-parse --short HEAD)"
TEST_DATE="$(date +%F)"
EVIDENCE_DIR="evidence/${COMMIT_SHA}/${TEST_DATE}"
mkdir -p "$EVIDENCE_DIR"
set -o pipefail
"$GODOT_BIN" --path "$PWD" --verbose 2>&1 | tee "$EVIDENCE_DIR/godot-startup.log"
```

Alternatively, open this project in the Godot 4.3 editor and run the configured project main scene. Record which method was used. Do not force the Dummy driver or replace project meshes/rendering to make the run proceed.

Record:

- Startup success or failure and time to first interactive frame.
- Reported display driver and renderer/backend.
- All errors and warnings from the console/log; distinguish the known headless Dummy diagnostic from errors on the visible backend.
- Whether the actual scene is visibly rendered (yes/no); if no, mark visual checks **UNVERIFIED** and stop the visual portion.
- Screenshot(s) where useful and a short screen recording if available. Keep originals and identify their commit SHA/device/backend.

Only continue to M0/M1/M2 visual/input checks after confirming a usable non-Dummy backend and visible project pixels.

## D. M0 validation — project startup and baseline scene

Starting from the fresh checkout, verify and record each item:

1. **Startup state:** configured main scene launches without a script/runtime error on the visible backend; initial status/resources/objective are coherent.
2. **Initial world:** terrain and map boundaries are visible and not unexpectedly missing or culled.
3. **Shelter:** starter shelter is visible in its initial state and remains visible as applicable.
4. **Worker/player:** both characters are visible and positioned in the world.
5. **Camera:** the estate is framed, world scale is legible, and pan/zoom do not lose the playable area.
6. **Terrain:** field/clearing/plantation area and the relevant world surface are visible.
7. **Basic interaction:** use the supported mouse/touch path to select an existing interactable or open a contextual panel; confirm feedback.

M0 is not complete merely because import or a headless process exits successfully. Record the startup log and the visible renderer/backend.

## E. M1 validation — establishment, visuals, and physical input

Use a fresh native game state and the project's existing interface. Verify each item visually and through physical input; record the interaction and result:

1. Shelter/build state and construction progress/complete state.
2. Clearing action and its visible progress.
3. Prepared-land state after clearing.
4. The complete 4×4 planting grid and its markers.
5. Planting at a selected marker; verify one small procedural seedling appears at the selected location. This validates establishment placement, not mature-palm artwork.
6. Inventory/resources update once and do not go negative.
7. Worker movement, active task, and task completion feedback.
8. HUD labels, values, action controls, contextual panels, and status readability at the agreed resolution.
9. Touch/mouse selection, placement, camera pan/zoom, and panel actions; confirm hit areas do not conflict.
10. Invalid/duplicate actions produce understandable feedback and no unintended resource/land change.

Do not mark M1 complete if only simulation assertions pass: its recorded HUD/touch validation debt remains a separate native gate.

## F. M2 validation — first harvest, delivery, sale, and repeat

Start from a fresh native state. Use only the current gameplay flow; do not edit simulation records, accelerate through test-only hooks, or use the browser prototype as a substitute. The current native crop-model slice expects the first commercial harvest window near 36 model months after field planting; use the in-game speed controls and record the actual displayed calendar. Record the displayed/computed palm yield before requesting harvest.

1. Establish the plantation through the existing shelter → clearing → planting flow.
2. Advance the native simulation until a palm becomes harvest-ready.
3. Visually identify the mature palm and its harvest-ready orange FFB cues; record the palm/yield value shown by the existing game. Check for missing/culling/material defects in the imported generic palm silhouette, but do not treat it as species-verified *Elaeis guineensis* art or agronomic evidence.
4. Request harvest through the native UI/input path.
5. Verify the worker/task state and that only one harvest task is assigned to the palm.
6. Observe the worker reach and harvest the palm.
7. Observe the worker carrying FFB; record carried quantity if shown by the existing interface.
8. Observe delivery to the collection point.
9. Verify the collection stock equals the captured expected yield and that the worker load is zero after delivery.
10. Confirm there is no sale transaction/revenue before using SELL; then invoke SELL through the native UI/input path.
11. Verify revenue and resulting funds against the visible fixture price and delivered quantity.
12. Verify transaction count/details and that collection stock clears exactly once.
13. Wait for the same palm to recover, visually confirm readiness again, then repeat harvest → delivery → sale and verify no duplicate quantity or transaction.

If the existing game does not expose a value needed for a visual check, record that visual check as **UNVERIFIED**; do not add UI or use structural/headless output as a substitute. The deterministic native suite remains the source for exact domain-level quantities.

## G. Evidence and result record

For each M0, M1, M2 section and each individual check, record exactly one of **PASS / FAIL / UNVERIFIED**. Attach evidence where useful:

- Screenshot(s) and short screen recording, if available.
- Full startup/runtime console log and any error/warning excerpts.
- Exact OS/device/model, CPU/GPU/RAM, resolution/orientation, input method, Godot version, and renderer/backend.
- Exact commit SHA and clean working-tree output.
- The deterministic native command output and structural-smoke output, separately labeled from graphical results.
- Reproduction steps, expected result, observed result, and evidence file path for every FAIL or UNVERIFIED item.

| Section/check | Result (PASS/FAIL/UNVERIFIED) | Expected / observed result | Evidence file(s) | Device/backend | Commit SHA |
|---|---|---|---|---|---|
| M0 startup/world |  |  |  |  |  |
| M1 establishment/HUD/input |  |  |  |  |  |
| M2 harvest/delivery/sale/repeat |  |  |  |  |  |

A M2 closure review requires native deterministic criteria to pass and the M2 graphical/input checks to be directly observed on a usable non-Dummy renderer. Browser evidence and headless structure checks do not close that gate.

## Current sandbox result

**Fresh-checkout validation not executed in current environment.** The current Git `HEAD` contains only the tracked README; the project files and tests are in the working tree and are not present in a fresh checkout of that commit. No external graphical validation was attempted because environment inspection found no usable non-Dummy renderer/display path. M0/M1 statuses remain unchanged; M2 remains open. M3 gameplay implementation has since begun under the user's updated direction; no M3 completion is claimed.
