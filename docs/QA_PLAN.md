# Quality Assurance Plan

## Purpose and release rule

QA evidence must identify **which runtime was tested**. Browser/Three.js results do not validate Godot GDScript, `.tscn` resources, Mobile-renderer behavior, touch handling, or Android performance. A code change alone never completes a milestone.

**Development cadence:** the user authorized a curated Nature Kit palm subset and later authorized integrating a small CC0 operation-visual subset. These assets are static visual proxies only; this does not waive or change M2/M3 acceptance gates. Keep native graphical/input and qualified agronomy-review evidence explicit rather than substituting headless checks. Run the deterministic suites relevant to each change; M0/M1 validation debt remains visible.

**M2 status: FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS — not COMPLETE.** Browser evidence passes (151 kg first-cycle delivery, $151 revenue, $1,501 resulting funds; 342 kg from a controlled two-palm block fixture; repeat-harvest readiness; Three.js scene sync). The native GDScript simulation passes **109 assertions**, Godot 4.3 project import/parse passes, and the headless main-scene smoke passes **110 structural/runtime assertions**, including the curated palm GLBs, all eight operation-asset GLBs, the process-flow disclaimer, and retained procedural FFB cues. The operation props are static visual placeholders only. The M3 crop-model smoke passes 65 software checks, including eight-model-year deterministic scenario fixtures, but this is not agronomic review. The `mesh_get_surface_count` message reproduces with a minimal BoxMesh and is classified as a non-fatal Dummy-renderer diagnostic. No usable non-Dummy renderer or display path is available here; native pixels, UI presentation, physical input, and mobile performance remain UNVERIFIED. The requested asset integration is a separate scoped slice and does not close M2/M3.

## Result vocabulary

- **PASS** — the stated test ran in the stated environment and met its assertions.
- **FAIL / BROKEN** — a reproducible test violated an assertion; include reproduction and logs.
- **NOT RUN** — no result exists.
- **UNVERIFIED** — source/code exists but the required runtime/device/acceptance test was not performed.
- **PASS (ad-hoc)** — a one-off test passed, but its script/environment is not committed and another developer cannot yet reproduce it reliably. It cannot close a release gate that requires repeatability.

Report browser, Godot headless, Godot editor/native play, and mobile-device results in separate columns/issues. The consolidated native deterministic command and separate manual graphical procedure are documented in [EXTERNAL_NATIVE_VALIDATION.md](EXTERNAL_NATIVE_VALIDATION.md); graphical acceptance is never automated or inferred from headless results.

## Current audit evidence

Baseline: code commit `e6c3ef39512573c2eb2ee481bbdc260b1a7051c7` on `arena/01a0f46d-palm-plantation`.

| Check | Current result | What it proves / does not prove |
|---|---|---|
| `gdparse` over every `scripts/**/*.gd` | **PASS (ad-hoc)** | GDScript grammar parsed using an ephemeral `gdtoolkit` environment. Does not prove Godot type/resource loading, signal wiring, scene startup, or runtime behavior; parser version is not pinned. |
| Godot 4.3 clean editor import | **PASS (repeatable)** | `godot --headless --editor --path . --quit` passes on a fresh project copy with no script parse errors. |
| Native Godot simulation acceptance | **PASS (headless/domain only)** | The single native command `GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_native_acceptance.sh` prints `PASS: 109 native simulation assertions`; the wrapper also runs editor import/parse, 65 focused crop-model checks, and the structural-smoke stage. The core simulation covers establishment, all slots, exact task/reservation counts, first harvest at the model boundary, exact worker/collection FFB quantities, sale accounting, and repeat harvest without proving rendered output. |
| M3 crop-model focused smoke | **PASS (65 targeted checks; software fixtures only)** | `tests/godot/crop_model_smoke.gd` checks calendar/stage/maturity boundaries, baseline/constrained/stress yield direction, deterministic eight-model-year trajectories, bounds, fertilizer/season effects, individual-age cohort forecasts, and condition averages with explicit pest-index units. Annual reserve resets are harness assumptions; these tests do not constitute agronomy validation or qualified review. |
| `node --check` on browser simulation, main, world, and test modules | **PASS** | JavaScript syntax only. |
| Browser simulation Node suite | **PASS (repeatable, browser-only)** | `node --test web-preview/tests/simulation.test.mjs` passes 5/5 simulation tests, including repeat-harvest readiness and two harvest/delivery/sale cycles. A separate fresh-state run measured 151 kg delivered, $151 first-sale revenue, and $1,501 resulting funds after the prototype establishment costs. The checked-in suite calculates yield dynamically rather than asserting those exact figures as literals; no browser UI or Godot behavior is implied. |
| Browser GLB loader/scene integration suite | **PASS (12 models; mocked image decode, no raster render)** | `node --test web-preview/tests/assets.test.mjs` checks all four palm and eight operation GLBs, texture dependencies, static model placement, and crop-palm mesh integration. It does not verify actual image decoding or rendered WebGL output. |
| Browser two-palm block harvest/delivery | **PASS (ad-hoc/browser simulation)** | A controlled fixture with two ready palms at 171 kg each accepted the block harvest and reconciled **342 kg delivered**. This exercises browser simulation accounting only; it is not native or rendered-browser evidence and is not a checked-in test. |
| Browser Three.js world-sync smoke | **PASS (ad-hoc/headless)** | Verified procedural scene objects, ready fruit bunches, worker-load visibility, collection quantity, and selection state using a lightweight DOM stub. No real browser rendering/input was tested. |
| Browser static HTTP smoke | **PASS (local helper server)** | `python3 web-preview/serve.py --port 8000` redirects the root to `/web-preview/`; JS, CSS, vendored Three.js, sample palm/operation GLBs, external colormaps, and action SVGs all respond with HTTP 200. This does not test WebGL/browser compatibility or touch behavior. |
| Configured Godot main-scene headless launch | **PASS (startup only) + Dummy diagnostic classified** | Supplied Godot `4.3.stable.official.77dcf97d8 --headless --path . --quit-after 5` exits 0 with no script errors; the five-frame capture contains 264 `ERROR: Parameter "m" is null.` diagnostics from `mesh_get_surface_count (servers/rendering/dummy/storage/mesh_storage.h:120)`. They are non-fatal Dummy-renderer diagnostics and do not prove pixels rendered. |
| Native main-scene structural smoke | **PASS (110 assertions; headless)** | `GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_main_scene_smoke.sh` checks import, configured scene startup, scene graph, camera/actors/terrain, young/mature/background GLB palms, all eight operation-asset GLBs with mesh and textured-material resources, static route/mill disclaimer, procedural FFB cues, the existing shelter and establishment flow, UI structure, native SVG action-icon wiring, cohort-outlook rows, and programmatic action-signal dispatch. Actual visibility/input is explicitly UNVERIFIED. |
| Curated palm asset import and structure | **PASS (engine import/structure only)** | Four generic Kenney GLB 2.0 models load from the pinned subset and the structural smoke checks their crop-stage/background use, mesh presence, and procedural ready-fruit cues. License/provenance is beside the files; rasterized appearance, botanical specificity, mobile performance, and device compatibility remain UNVERIFIED. |
| Standalone BoxMesh reproduction | **PASS (expected diagnostic reproduced)** | The same wrapper runs a one-node `MeshInstance3D` + `BoxMesh` in a minimal temporary Godot project with no Mobile-renderer setting; it emits the same Dummy storage diagnostic and exits 0. The engine message does not name an app-specific node/resource. |
| Visible/software-renderer attempt | **UNVERIFIED / ENVIRONMENT BLOCKED** | X11/OpenGL compatibility was attempted, but Godot fails before the project starts because `libXcursor.so.1`, a display server, and OpenGL 3.3 support are absent. `DISPLAY`, `WAYLAND_DISPLAY`, `/dev/dri`, Xvfb, GL/Vulkan driver libraries are absent; `apt-get update` cannot reach Debian mirrors, so installing Mesa/Xvfb is unavailable. |
| `git diff --check` | **PASS** | Whitespace/error-marker check only. Re-run after changes. |
| Actual visible main-scene gameplay, camera framing, HUD rendering/layout, mouse/touch | **NOT RUN / UNVERIFIED** | Structural checks and programmatic action signals do not prove pixels or real input. No functioning display/GPU or target device is available. |
| Manual browser WebGL interaction/layout | **NOT RUN / UNVERIFIED** | No actual browser acceptance in this audit. |
| Minimum mobile device, FPS, memory, thermal, save/load | **NOT RUN / UNVERIFIED** | No target device, save system, or profiler evidence. |
| Test infrastructure/CI | **PARTIAL** | Browser Node, native GDScript simulation, focused crop-model smoke, and headless main-scene structural smoke are present in the working tree. `tests/godot/run_native_acceptance.sh` is the single deterministic native command; it invokes import/parse, core simulation, focused model checks, and structural smoke. No actual rendered-scene screenshot/visual automation or CI workflow exists. |

M2 is FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS and is not COMPLETE. Browser metrics, repeat readiness, scene sync, native GDScript simulation, Godot import/parse, and the 110-assertion native structural smoke are evidenced. Native pixels/UI, camera framing, and physical input remain UNVERIFIED. Do not infer a project rendering defect from the Dummy diagnostic or mark M2 complete without visible acceptance evidence.

## M2 acceptance matrix

| # | Roadmap acceptance criterion | Result | Evidence / limitation |
|---|---|---|---|
| 1 | Fresh native fixture reaches one harvest-ready palm. | **PASS (deterministic simulation)** | The native acceptance runner advances a fresh Godot simulation to readiness at the 36-model-month first-window boundary; the suite passes 109 assertions. This is not visible-renderer/input acceptance. |
| 2 | Reject non-ready/already-reserved palms; a valid request creates exactly one task and reservation. | **PASS** | Native assertions verify non-ready rejection without count changes, one task/reservation added, duplicate/already-reserved rejection without count changes, and exactly one harvest task for the palm. |
| 3 | Move exact computed FFB palm → worker → collection; no stock before delivery. | **PASS** | Native assertions capture expected yield before harvest; assert exact worker kilograms after harvest, zero collection stock before delivery, exact collection stock after delivery, zero worker load, cleared palm fruit, and no sale transaction before SELL. |
| 4 | Sale creates one transaction, clears exactly sold stock, and applies price once. | **PASS** | Native tests assert transaction count, stock clearing, exact cash increase, and rejection of a second sale on empty stock. |
| 5 | The same palm recovers and completes a repeat harvest without removal, duplication, or double sale. | **PASS** | Native tests exercise repeat readiness, palm retention, second harvest count, exact second delivery, and one additional sale. |
| 6 | Browser and Godot suites are separately reproducible; the project is run and native suite passes. | **PASS (working tree + clean staged-tree archive)** | Browser simulation 5/5 plus GLB loader/scene integration 4/4; the consolidated native command runs import/parse, 109 core simulation assertions, 65 focused crop-model checks, and 110 structural assertions. A `git archive` of the staged project tree was extracted without a `.godot` cache; the full native runner and browser Node suites passed from that clean tree. The headless renderer diagnostic is non-fatal and is not visual evidence. |
| 7 | Native main-scene rendered/input acceptance on a usable non-Dummy renderer. | **UNVERIFIED** | Environment checks found no usable GPU/OpenGL/Vulkan, display server, software renderer, or Xvfb. Per instruction, no further visual attempt was made. |

## M0/M1 validation debt (milestone statuses unchanged)

| Gate | Result | Gate classification | Evidence / reason |
|---|---|---|---|
| M0-01: planning baseline accepted | **PASS** | A — foundation gate | `DEV_PLAN.md` records M0-01 COMPLETE and `PROJECT_STATUS.md` records authorization to proceed under the roadmap. |
| M0-02: Godot import and configured main-scene launch with no script/runtime errors in the captured log | **UNVERIFIED (strict clean-log criterion)** | A — foundation gate; current diagnostic is B — environment-dependent | Import/parse passes and the scene exits 0 with no GDScript errors, but Dummy logs the non-fatal `mesh_get_surface_count` engine error. No usable non-Dummy launch is available to determine whether the criterion passes on the production rendering path. |
| M0-03: documented repeatable native test command | **PASS (staged clean-tree archive)** | A — foundation gate | `GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_native_acceptance.sh` runs import/parse, core simulation (109 assertions), focused crop-model checks (65), and structural smoke (110). The staged tree was archived with `git archive`, extracted without `.godot` caches, and passed the same native runner plus the browser Node suite. This does not test rendered output or physical input. |
| M0-04: minimum device/OS/resolution and profiling procedure | **UNVERIFIED / NOT STARTED** | A — foundation/release gate; device-dependent | No accepted minimum device/OS/resolution is recorded; no target device or profile exists. This requires a product/device decision and later hardware validation. |
| M0 browser/native reporting separation | **PASS** | A — foundation gate | QA rows report browser and Godot results separately. Browser results do not clear native checks. |
| M0 non-Dummy visible-scene smoke (QA quality gate) | **UNVERIFIED / BLOCKED** | A and B | No usable display/renderer is available; see the A–E environment check below. |
| M1 shelter placement, prerequisites, exact one-time cost, construction | **PASS (simulation)**; player-facing path **UNVERIFIED** | A — native gate; visual portion B | Native GDScript assertions verify valid/invalid placement, prerequisites, construction, and exact balance/inventory changes. Physical input/rendered feedback was not tested. |
| M1 clearing prerequisites, exact cost, progress, repeat/invalid requests | **PASS (simulation)** | A — native gate | Native simulation assertions verify the clearing sequence and no duplicate charge. |
| M1 4×4 grid, all 16 slots, inventory/IDs/positions, invalid indices | **PASS (simulation)** | A — native gate | The native runner fills all slots and verifies unique slots/IDs/positions, inventory use, and invalid/duplicate rejection. |
| M1 same sequence replayed in Godot harness without script errors | **PASS (headless simulation)** | A — native gate | Native simulation and structural smoke pass; the Dummy renderer warning is separate and non-fatal. |
| M1 HUD/touch at agreed baseline resolution (`M1-04`) | **BLOCKED / UNVERIFIED** | A — native acceptance gate; B — environment-dependent | No agreed minimum device/resolution and no usable visible renderer/input device are available. Browser tests cannot substitute. |
| Browser scene-sync/manual browser UI checks | **PASS (scene sync only); manual UI UNVERIFIED** | C — browser-only QA | Scene sync uses a lightweight DOM stub; it is supplemental and cannot satisfy M0, M1, or native M2. |

M0 and M1 remain **IN PROGRESS**. Simulation checks are not a reason to mark either milestone complete; the target-device baseline and required native visual/input gates remain open. Browser-only QA is separate from those gates.

## M2 native runtime/rendering investigation

### Reproduction and root-cause classification

Godot version: `4.3.stable.official.77dcf97d8`, extracted from the user-provided branch archive.

Exact captured main-scene command:

```sh
/tmp/palm-godot/Godot_v4.3-stable_linux.x86_64 --headless --path /home/user/Palm-Plantation --quit-after 5
```

Renderer: **Dummy**. Godot 4.3 `--help` states that `--headless` selects display driver `headless`, whose supported rendering driver is `dummy`. The first relevant output is:

```text
ERROR: Parameter "m" is null.
   at: mesh_get_surface_count (servers/rendering/dummy/storage/mesh_storage.h:120)
```

The five-frame main-scene launch logs 264 instances, exits `0`, and has no GDScript parse/runtime errors. The `ERROR` label is a non-fatal renderer diagnostic; exit `0` is not evidence that any pixels were rendered.

The captured standalone command was:

```sh
/tmp/palm-godot/Godot_v4.3-stable_linux.x86_64 --headless --path /tmp/palm-godot/box-probe --script res://probe.gd
```

`tests/godot/run_main_scene_smoke.sh` now reproduces this from the repository by creating a temporary minimal project with only a project name (no Mobile renderer setting or imported assets), copying `tests/godot/dummy_renderer_probe.gd`, attaching one `MeshInstance3D` named `ProbeBoxMeshInstance` with a built-in `BoxMesh`, and running it with `--headless`. It emits the same error at the same Dummy storage path and exits `0`. Godot does not name a specific resource/node in that error; the only named test node is the isolated BoxMesh probe.

**Conclusion:** the reproduction supports cause **C — Godot's headless Dummy-renderer path**, not the project's Mobile renderer setting, an imported asset, a particular scene resource, or the procedural palm/terrain mesh construction. `--headless --display-driver headless --rendering-method gl_compatibility --rendering-driver opengl3 --path /home/user/Palm-Plantation --quit-after 3` still selects the Dummy path and repeats the diagnostic. This is classified as a non-fatal limitation of this validation backend, not a confirmed visible-renderer project defect. It was tested on Godot 4.3 only; no claim is made about other engine versions. No production gameplay/rendering code workaround was applied.

| Candidate cause | Finding |
|---|---|
| A. Project configuration | Not supported as cause: a minimal project with no renderer setting reproduces the same message under `--headless`. |
| B. Rendering backend | Supported: the stack names `servers/rendering/dummy/storage/mesh_storage.h`, and the command selects the headless Dummy backend. |
| C. Dummy renderer limitation | Best-supported classification: the minimal BoxMesh case reproduces the error without the game's scene or project configuration. |
| D. Mesh resource construction | No malformed project mesh is identified. A normal built-in `BoxMesh` is sufficient to reproduce; the C++ log does not name the failing project resource. |
| E. Imported asset | Not supported: the minimal reproduction has no imported assets. |
| F. Scene initialization | Not required to reproduce: the standalone `MeshInstance3D` is added directly to the test SceneTree; the game's main scene also initializes without GDScript errors. |
| G. Script-generated geometry | Not required to reproduce: the isolated case uses only built-in `BoxMesh`, not the project's `SurfaceTool` palm/terrain geometry. |
| H. Godot-version-specific regression | Unresolved beyond the tested version: reproduction is on Godot 4.3; no second engine version was available for comparison. |
| I. Another cause | No additional cause is supported by the current evidence. |

### Repeatable structural smoke and results

Run from the repository root after obtaining Godot 4.3+:

```sh
GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_main_scene_smoke.sh
```

The wrapper performs editor import, launches the configured main scene, runs `tests/godot/main_scene_smoke.gd`, then runs the isolated BoxMesh probe. It accepts only the specifically matched Dummy `mesh_get_surface_count` diagnostic; GDScript parse/load errors, other engine errors, failed assertions, or nonzero commands fail the wrapper. Use `KEEP_LOGS=1` to retain full per-stage logs under `/tmp`.

Current result: import **PASS**; configured main-scene startup **PASS** (zero GDScript errors); scene-graph/runtime smoke **PASS, 110 assertions**; standalone diagnostic reproduction **PASS**. The scene smoke instantiates the real main scene, checks terrain and forest meshes, three imported background palm variants, imported young/mature crop models, all eight operation GLBs with mesh and texture materials, the static route and mill disclaimer, runtime palm scale/palette overrides, procedural ready-FFB cues, strategy-camera state, player/worker mesh nodes, sixteen planting markers, the UI panels and five action buttons, the Estate Overview cohort outlook, and simulation state. In an isolated test instance it dispatches the BUILD button signal and advances the existing shelter → clearing → planting flow until a procedural seedling view is created. That is programmatic scene/simulation evidence, not a real pointer or rendered-frame test.

| Requested visual/input check | Result |
|---|---|
| Camera configuration/current state | **PASS (structural)**; visual framing and composition **UNVERIFIED** |
| World/terrain resources and plantation grid | **PASS (mesh resources/nodes constructed)**; rasterized visibility/culling **UNVERIFIED** |
| Player character and worker | **PASS (nodes/meshes assigned)**; rendered appearance/animation **UNVERIFIED** |
| Background and crop palms | **PASS (three generic imported background variants; imported young/mature crop forms; runtime scale/palette checks; procedural FFB cues)**; rendered appearance, botanical specificity, and visual clarity **UNVERIFIED** |
| Existing shelter | **PASS (created/completed in the isolated main-scene smoke with component meshes)**; visual appearance **UNVERIFIED** |
| HUD and contextual panel | **PASS (controls/panels initialize and script-level signals/details work)**; rendered layout, overlap, legibility **UNVERIFIED** |
| Mouse/touch input and basic physical interaction | **UNVERIFIED**; only a programmatic button-signal dispatch is tested |
| No GDScript runtime errors in tested scene/simulation path | **PASS**; known Dummy renderer mesh diagnostics remain in the engine log |

### Visible/software renderer availability and next validation method

Current environment check (A–E):

| Check | Finding | Result |
|---|---|---|
| A. GPU/OpenGL/Vulkan path | No `/dev/dri`, NVIDIA, or KFD device nodes; no registered GL/GLX/EGL/Vulkan/OSMesa libraries; `glxinfo` and `vulkaninfo` are absent. | **UNAVAILABLE** |
| B. X11/display path | `DISPLAY`, `WAYLAND_DISPLAY`, and `XDG_RUNTIME_DIR` are unset; `/tmp/.X11-unix` has no sockets; no X server process/binary is present; `libXcursor` is absent. | **UNAVAILABLE** |
| C. Software renderer | No Mesa llvmpipe/swrast, EGL, OSMesa, or software-renderer libraries/tools were found. | **UNAVAILABLE** |
| D. Xvfb/equivalent | `Xvfb`, `xvfb-run`, Xwayland, Weston, and equivalent display-server tools are absent. | **UNAVAILABLE** |
| E. Godot backend | Supplied Godot is `4.3.stable.official.77dcf97d8`. Its help maps X11/Wayland to Vulkan/OpenGL and headless to Dummy; only the Dummy path is usable here. Earlier X11 attempts failed before project startup. | **Dummy only; no usable non-Dummy backend** |

**Decision: stop visual testing here.** Do not launch another visual attempt or claim rendering/input acceptance without a usable backend. Rendered pixels, camera framing, world/palm/shelter/worker visibility, HUD readability, visual harvest interaction, and physical input remain **UNVERIFIED**.

A visible run was previously attempted with:

```sh
/tmp/palm-godot/Godot_v4.3-stable_linux.x86_64 --display-driver x11 --rendering-method gl_compatibility --rendering-driver opengl3 --path /home/user/Palm-Plantation --quit-after 3
```

It exits before project startup because `libXcursor.so.1` and a usable display server are missing; Godot also reports no OpenGL 3.3 support. A default X11/Mobile-renderer attempt likewise could not initialize Vulkan or Wayland in this host and exited `139` during DisplayServer teardown. The environment has empty `DISPLAY`/`WAYLAND_DISPLAY`, no `/dev/dri`, no Xvfb, and no installed GL/Vulkan driver libraries. `sudo apt-get update` could not connect to Debian mirrors, preventing installation of Mesa/Xvfb. Therefore no usable software/virtual renderer is available here.

Usable next method: run the project on a Godot 4.3 host with a working visible DisplayServer and Vulkan-capable device using the project's Mobile renderer, then perform the documented camera/world/character/palm/shelter/HUD and real mouse/touch checks. A provisioned Mesa software backend may be used for supplemental rendering checks, but must not be reported as target-device acceptance. Until such a run occurs, visual criteria remain **UNVERIFIED**. No Dummy-specific workaround belongs in production gameplay code.

## Required test layers

### 1. Static and import checks

- Run parser/linter/format checks on all GDScript and JavaScript files from a clean checkout.
- Run Godot 4.3+ headless editor import and project validation; capture engine version, command, exit code, and full errors/warnings.
- Confirm the configured main scene and all external resources load.
- Check licenses/notices and `git diff --check`.
- Pin or document tool versions; avoid relying on untracked venvs, caches, or locally edited files.

### 2. Simulation unit tests (Godot production)

The current native runner is `tests/godot/simulation_acceptance.gd`. Run it with Godot 4.3+ from the repository root:

```sh
godot --headless --path . --script res://tests/godot/simulation_acceptance.gd
```

It currently passes 109 assertions on the simulation records and task flow. It does not load `scenes/main/main.tscn`, so it cannot verify the world renderer, HUD, input, or touch integration.

Test pure domain logic without scene rendering where possible:

- resource reservation, charge-once and release/complete rules;
- land and task state transitions, invalid actions, unique IDs;
- crop-stage/calendar boundaries, yield rounding, health and risk bounds;
- task queue/priority, worker assignment, cancellation/blocking behavior;
- harvest reservation, exact FFB quantity conservation, delivery capacity;
- sale arithmetic, duplicate-sale prevention, ledger reconciliation;
- deterministic replays for a fixed seed and model version;
- save/load round-trip and migration once M9 exists.

Assertions should check state and side effects—not only toast text or animation.

### 3. Native Godot integration/end-to-end tests

Run the production project in Godot 4.x with the Mobile renderer enabled. Minimum scenarios:

| ID | Scenario | Required assertions |
|---|---|---|
| N-01 | Fresh start and main scene | Project imports, main scene launches, HUD/camera/world are present, no script/runtime errors. |
| N-02 | Shelter and land establishment | Valid prerequisite/placement, exact one-time cost, clear progress/state, invalid/repeated attempts have no side effects. |
| N-03 | Full planting grid | All 16 current prototype slots are independently fillable once; resources/IDs/positions reconcile; invalid indices are harmless. |
| N-04 | First crop maturity | One test palm reaches ready state under a controlled accelerated fixture; a non-ready palm cannot be harvested. |
| N-05 | Harvest and reservation | Exactly one valid task is assigned; repeat/duplicate selection is rejected; palm is not removed. |
| N-06 | FFB delivery and sale | Palm yield = carried amount = deposited amount = sold amount; storage clears once; transaction and cash increase reconcile. |
| N-07 | Repeat cycle | Same palm returns to a valid development/readiness state and can be harvested again without duplicate yield. |
| N-08 | UI/input integration | Touch selection/placement, camera pan/zoom, contextual panels, disabled actions, and back/close behavior work at the supported resolution. |

Use fixtures to make long growth timelines testable. Keep the fixture's compressed duration explicitly separate from any reviewed real-world parameters.

### 4. Browser-only test suite

The browser Node suites live at `web-preview/tests/`. Run simulation and asset-loader/scene-integration coverage from the repository root with:

```sh
node --test web-preview/tests/*.test.mjs
```

The five simulation checks cover fresh-state setup, one-time shelter/clearing costs, all sixteen planting reservations, maintenance inventory reservation, not-ready/duplicate harvest requests, worker movement/work state, delivery priority, FFB/cash conservation, and a completed second harvest/delivery/sale cycle. Four asset-loader checks parse the twelve shared GLBs, mock texture loading, and verify palm/operation models are attached to the Three.js scene. They do not exercise actual image decoding or rendered pixels. Next add real-browser rendering/input coverage for WebGL, imported model appearance, drag/touch, and layout; label every result **Browser**. Browser results cannot satisfy N-01–N-08.

### 5. Manual mobile UX and accessibility

On each supported device class, test:

- all objectives/actions with touch only; tap versus drag is not confused;
- camera movement/zoom and UI hit areas do not overlap;
- text, units, map markers, selection, and status indicators remain readable at minimum viewport;
- important status is not communicated by color alone;
- action rejection explains its prerequisite/cost/blocker;
- pause/normal/fast-forward and interruption/resume behave consistently;
- reduced motion/audio-off use remains fully understandable;
- first-time players can complete the first harvest-to-sale loop without developer instructions (M8 usability threshold: at least 4/5 observed sessions).

### 6. Performance, stress, and device compatibility

Use the provisional budgets in [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md): 30-minute dense-estate run, 30 FPS floor with p95/p99 frame-time thresholds, 512 MiB peak memory, startup/save/load/input limits, ≤200 draw calls target, one shadow caster maximum, and simulation-step limit. M0 names the device/resolution. M9 captures build/device IDs, profiler output, thermal state, and worst-case scene. A desktop editor FPS result is not mobile evidence.

### 7. Release/package verification

Install the exact signed candidate build on each supported device/OS. Verify first launch, offline play, new game, save/load, suspend/resume, audio/settings, safe failure, package size, and the full core loop. Confirm all license/privacy/store/support items in [LAUNCH_CHECKLIST.md](LAUNCH_CHECKLIST.md).

## Milestone quality gates

- **M0:** user-accepted documents, reproducible Godot import, a visible main-scene smoke on a non-Dummy renderer, documented test tools, and a named device baseline.
- **M1:** N-01 through N-03 pass natively, including exact resource/slot edge cases; required scene/input path is checked separately.
- **M2:** N-04 through N-07 pass in the native runner and are exercised through the native main-scene path; browser suite separately passes; no FFB/cash duplication/loss.
- **M3–M7:** deterministic unit/integration fixtures pass; domain/model reviews and sources are recorded where required.
- **M8:** manual usability/accessibility gates pass in the bounded launch scenario.
- **M9:** save/load, compatibility, stress, and performance gates pass on the supported baseline device.
- **M10:** signed release candidate passes the full final matrix; no open critical/high-severity defects or unlicensed assets.

Any failed gate is a blocker. Record the exact environment, reproduction, observed result, expected result, severity, and affected runtime. A browser pass cannot clear a Godot failure, and an unrun native check must stay UNVERIFIED.
