# Palm Plantation — Project Status

## Authority and change control

This file is the live, evidence-based status snapshot. The planning source of truth is the set of documents linked below; `README.md` remains the quick-start and implementation overview. If a README claim conflicts with these documents, use the documents for scope, milestone status, acceptance, and release readiness.

- [Roadmap and milestone gates](docs/ROADMAP.md)
- [Development task plan and statuses](docs/DEV_PLAN.md)
- [Game design and launch scope](docs/GAME_DESIGN.md)
- [Native crop-model assumptions and implementation](docs/CROP_MODEL.md)
- [Technical architecture and browser-to-Godot transition](docs/TECH_ARCHITECTURE.md)
- [Art direction](docs/ART_DIRECTION.md)
- [Asset plan](docs/ASSET_PLAN.md)
- [QA plan and current evidence](docs/QA_PLAN.md)
- [External native validation runbook](docs/EXTERNAL_NATIVE_VALIDATION.md)
- [Launch checklist](docs/LAUNCH_CHECKLIST.md)

**Execution authorization:** the user has instructed us to start development following this roadmap; that is treated as approval to proceed under the documented scope. Unroadmapped ideas still go only into `FUTURE_BACKLOG` in `docs/ROADMAP.md` and are not implementation requests by default.

## Snapshot

| Item | Current state |
|---|---|
| Code baseline audited | `e6c3ef39512573c2eb2ee481bbdc260b1a7051c7` (`Add FFB harvest collection and sales loop`) |
| Working branch | `arena/01a0f46d-palm-plantation` |
| Production target | Godot 4.x; project declares Godot 4.3 features and the Mobile renderer; modest/mobile hardware is the design target |
| Current product milestone | **M2 — First Harvest and M3 — Crop Model** (both acceptance gates remain open) |
| Current development focus | **Browser visual integration of reviewed Kenney assets**: the independent Three.js preview now loads the same four generic palm GLBs, eight vehicle/industrial GLBs, their local texture dependencies, and the five shared SVG action icons from repository `assets/`. All vehicle/mill models remain static visual proxies only; no transport or process logic is added, the four-block/one-mill scope is unchanged, and M2/M3 gates remain open. |
| M2 status | **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS** — not COMPLETE. Browser evidence: the fresh-state first cycle delivers 151 kg, sells for $151, and leaves $1,501; repeat-harvest readiness passes; a controlled two-palm browser fixture delivers 342 kg (171 kg per ready palm); Three.js scene-sync checks pass. Browser Node coverage is 5/5 simulation plus 5/5 asset/icon checks. Ad-hoc Chromium 153/WebGL2 (SwiftShader) QA on 2026-10-02 rendered all five SVG icons and all 12 downloaded GLBs/textures at desktop and mobile-sized viewports, then exercised the existing shelter → clearing → planting flow without console/request failures. This is not a checked-in browser suite or native evidence. Native Godot 4.3 GDScript simulation passes 109 assertions, project import/parse passes, and the headless main-scene structural smoke passes 110 assertions. Native rendered pixels/UI and physical mobile/touch acceptance remain UNVERIFIED. |
| Documentation review | Accepted for execution by the user's instruction to start development following the roadmap |
| Release readiness | Not release-ready; no visible-renderer scene acceptance, target device, save/load, or performance evidence |

M0 and M1 validation debt is not waived. The user explicitly authorized the curated four-model Kenney palm subset and later authorized integrating the reviewed 8-GLB/2-texture operation subset under `assets/environment/operations/`. The new tractor, pickup, and generic mill-yard props are static visual placeholders; they do not implement any process stage or waive M2/M3 acceptance. `web-preview/` remains a separate prototype. M2's external rendered/input gate and M3's owner/reviewer gate stay open; neither is waived by code or headless tests.

## Repository audit

The working tree contains one Godot project and main scene plus a separately authored browser implementation in `web-preview/`. The browser code is JavaScript/Three.js; it neither imports nor runs the GDScript or `.tscn` scene, but it now parses the shared local GLBs and references the same SVG action icons from `assets/`. The Godot world and characters remain predominantly procedural; four curated, generic Kenney Nature Kit palm GLBs provide young/mature crop and background landmark forms, while fruit bunches remain procedural. Eight additional generic Kenney GLBs are placed as static tractor, pickup, and mill-yard visual proxies; they have no operation/process behavior, and their provenance is recorded under `assets/environment/operations/`. First-party standalone assets are `assets/icon.svg` and the five action icons in `assets/ui/icons/`; the palm subset has a pinned CC0 provenance/license record under `assets/environment/palms/`. Three.js is vendored in `web-preview/vendor/three.min.js` with `web-preview/THREE-LICENSE.txt`.

The audited code baseline had no test suite, CI workflow, export preset, save/load implementation, or QA automation. The current working tree contains browser and Godot simulation runners plus `tests/godot/main_scene_smoke.gd` and `tests/godot/run_main_scene_smoke.sh` for repeatable simulation/import/structural checks. CI, visible-renderer acceptance, and device QA remain absent. Values such as the growth durations, yields, starting cash, and `$1/kg` FFB price are prototype parameters, not validated agricultural or commercial forecasts.

## Feature audit

Status describes the audited feature—not milestone completion. A feature may have code and still fail its acceptance gate.

- **IMPLEMENTED** — the behavior exists and has evidence within the stated scope; this does not complete its milestone.
- **PARTIALLY IMPLEMENTED** — some behavior exists, but meaningful target behavior or acceptance remains missing.
- **PLACEHOLDER** — a hard-coded or simplified stand-in exists and is not suitable as a validated production model.
- **NOT IMPLEMENTED** — no corresponding implementation was found.
- **BROKEN** — a reproducible project behavior fails in a named environment; cite the reproduction. No project-specific rendering defect has been confirmed by the current headless test.
- **KNOWN ENVIRONMENT LIMITATION** — a failure is reproduced and attributable to a test backend/environment; do not extrapolate it to another backend, and keep untested behavior UNVERIFIED.
- **UNVERIFIED** — source/configuration exists, but the required runtime, device, or acceptance behavior was not exercised.

| Area | Audit status | Evidence and limitation |
|---|---|---|
| Godot 4.3 project import and GDScript compilation | **IMPLEMENTED (validated headless)** | A headless editor import passes with no script parse errors; the strengthened native simulation runner passes 109 assertions. This does not validate the visible renderer or UI. |
| Main-scene structure and runtime logic | **PASS (headless structural smoke)** | `tests/godot/run_main_scene_smoke.sh` reports 110 passing assertions after loading/instantiating `scenes/main/main.tscn`; world, camera, characters, terrain, imported young/mature/background palm GLBs, all eight operation GLBs and textures, the static route/yard disclaimer, procedural FFB cues, constructed shelter, HUD, simulation, native SVG action-icon wiring, cohort-outlook rows, and programmatic UI signal flow are checked. This is not a pixel-render test. |
| Visible main-scene rendering, UI layout, and physical input | **UNVERIFIED** | Headless execution uses Godot's Dummy renderer and emits `mesh_get_surface_count` null diagnostics. The error is reproduced by a minimal project with one `MeshInstance3D`/`BoxMesh`; no scene resource/node is named in the engine log. No visible renderer, screenshot, touch, or mouse-hit-test acceptance has been performed. |
| Simulation/data separation | **PARTIALLY IMPLEMENTED** | Records exist for palms, workers, tasks, buildings, land, and FFB collection. State is in-memory only; there is no persistence or production-scale model. |
| Estate strategy / land portfolio | **NOT IMPLEMENTED** | The player receives one fixed forest block. No acquire/lease, land-value, tenure, or portfolio decision exists. |
| Shelter, clearing, field preparation, and planting | **PARTIALLY IMPLEMENTED** | A Godot 4.3 headless simulation suite now validates prerequisites, costs, progress, all sixteen slots, reservations, and inventory. The rendered scene/touch flow, land-selection strategy, and wider establishment model remain unverified or absent. |
| Crop growth and maintenance | **PARTIALLY IMPLEMENTED (M3 IN PROGRESS)** | Native Godot uses a 30-day/month model calendar, staged field age, maturity-boundary-aware first/repeat harvest timing, a sourced-context/assumption-labeled age-yield curve, and seasonal health/pest pressure. Eight-year baseline/limited-input/stress fixtures pass as software regressions; coefficients remain scenario-only pending qualified review and the browser prototype stays separate. |
| Workforce | **PARTIALLY IMPLEMENTED** | One named worker and a FIFO task queue exist. Energy, morale, and experience are largely presentation/data placeholders; hiring, wages, skills, schedules, and multiple crews do not exist. |
| First harvest and FFB delivery | **PARTIALLY IMPLEMENTED** | The simulation loop is functionally evidenced in browser and GDScript: a fresh browser cycle delivered 151 kg, and the `$1/kg` sale returned $151 with $1,501 resulting funds; a controlled two-ready-palm browser fixture delivered 342 kg total. Capacity, freshness, vehicle logistics, and mill processing are absent; the imported vehicle models are static visuals only. Native visible interaction remains UNVERIFIED. |
| FFB sale / market | **PLACEHOLDER** | Stored kilograms can be sold at a hard-coded `$1/kg`; this is an accounting demonstration, not a market model. |
| Browser prototype loop | **IMPLEMENTED (browser prototype only)** | The checked-in Node suite passes 5/5 simulation tests plus 5/5 asset/icon tests; all twelve shared GLBs are parsed/placed and all five referenced action SVG files are validated. A separate Chromium 153/WebGL2 software-render run confirmed 12/12 GLBs with textures and all five icons visibly rendered at 1440×900 and 390×844; pointer-driven BUILD → LAND → PLANT screenshots show the existing flow and resource deductions. This is ad-hoc, not a checked-in browser harness or production runtime. Gameplay behavior was not extended by this asset slice; static operation props have no vehicle/mill simulation. Native visuals and physical mobile input remain unverified. |
| Browser static delivery | **IMPLEMENTED (local HTTP + ad-hoc Chromium)** | `python3 web-preview/serve.py --port 8000` serves the app directly at `/`, maps JS/CSS/vendor files from `web-preview/`, and exposes shared GLBs, external colormaps, and SVG icons at `/assets/` with HTTP 200. Headless Chromium decoded/rendered all five icons and 12/12 model/texture assets with no console or request failures. This is not target-browser/device acceptance. |
| Curated palm model integration | **IMPLEMENTED (engine import/structural checks only)** | Four generic CC0 Kenney GLB palms are integrated for the young/mature crop and background landmark views, with source hashes, license, scale, and runtime palette changes documented. They are not species-verified oil-palm art; visual/device/performance acceptance remains UNVERIFIED. FFB cues remain procedural. |
| Operation-asset integration | **IMPLEMENTED (static visual proxies only)** | Eight reviewed CC0 GLBs and two original colormaps are imported; Godot also extracts two byte-identical copies from embedded vehicle images. They form one generic tractor, one pickup, and a small mill-yard preview using a shell, stack, tank, hopper, conveyor, and pipe/valve. A status sign and node metadata explicitly state process flow is not simulated. No process stage, material flow, vehicle behavior, or logistics were implemented; appearance/device acceptance remains UNVERIFIED. |
| Visual presentation | **PARTIALLY IMPLEMENTED** | Procedural meshes, MultiMesh background forest, four curated generic palm GLBs, eight static operation-asset GLBs, camera, characters, responsive HUD, and five shared first-party SVG action icons exist. Ad-hoc Chromium screenshots confirm browser rasterization, textures, and responsive icon display; icons were enlarged after QA from 24/20px to 30/26px. The broad bird's-eye view is still dominated by procedural forest and prototype geometry, so imported props are easy to overlook; gameplay remains unchanged by design. Final art, botanical specificity, accessibility, target-device layout/performance, and native rendered appearance are not accepted. |
| Test infrastructure | **PARTIALLY IMPLEMENTED** | Browser Node (5/5 simulation + 5/5 asset/icon checks), native Godot core simulation (109 assertions), focused M3 crop-model smoke (65 checks), and headless main-scene structural smoke (110 assertions) are present. Ad-hoc rendered-browser screenshots/interaction QA were made for this audit, but no checked-in browser-render automation, CI, or target-device automation exists. |
| Weather, soil, climate, biodiversity, community, and regulation | **NOT IMPLEMENTED** | No operational or stewardship model exists. |
| Save/load, settings, localization, audio, analytics, online features | **NOT IMPLEMENTED** | None found in the audited baseline. |
| Known headless diagnostic | **KNOWN ENVIRONMENT LIMITATION (Dummy renderer; non-fatal)** | Godot 4.3 CLI documents `--headless` as display driver `headless` with renderer `dummy`. Main-scene launch (`--headless --path . --quit-after 5`) exits 0, reports 264 `mesh_get_surface_count` null diagnostics, and has no GDScript errors. A separate minimal project with no Mobile-renderer setting and one named `ProbeBoxMeshInstance` using `BoxMesh` emits the same diagnostic and exits 0. The message is not fatal and does not identify an app-specific mesh; visible-renderer behavior remains UNVERIFIED. |

## Validation evidence at this audit

| Check | Result | Boundary |
|---|---|---|
| `gdparse` on every `scripts/**/*.gd` file | **PASS (ad-hoc)** | Parser-only check using an ephemeral `gdtoolkit` environment; parser version is not pinned. The engine-executed Godot simulation and scene smoke runners are separate checks. |
| `node --check` on browser simulation, main, world, and test modules | **PASS** | JavaScript syntax only. |
| Browser simulation tests | **PASS (repeatable, browser-only)** | `node --test web-preview/tests/simulation.test.mjs` passes 5/5 tests, including establishment, all sixteen planting reservations, harvest readiness/reservations, exact two-cycle delivery/sale accounting, and repeat readiness. A separate fresh-state run observed 151 kg delivered, $151 first-sale revenue, and $1,501 resulting funds; the suite calculates its yield dynamically rather than pinning those figures as literals. These tests do not validate Godot. |
| Browser GLB-asset structure tests | **PASS (12 shared models; Node suite itself has no raster renderer)** | `node --test web-preview/tests/assets.test.mjs` parses all four palm and eight operation GLBs, builds non-empty Three.js mesh hierarchies, and validates the five action icon references/assets. Separate ad-hoc Chromium QA confirmed real texture/image decoding and visible browser appearance; target-browser/device appearance remains unverified. |
| Browser screenshot/interaction QA | **PASS (ad-hoc; headless Chromium 153/WebGL2 SwiftShader)** | Actual page rasterized 12/12 GLBs and all five action icons at desktop/mobile-sized viewports with zero console or failed requests. Pointer-driven BUILD, shelter completion, LAND clearing, prepared 4×4 grid, and one PLANT task were captured frame-by-frame; gameplay logic was not modified. Fixed-step QA instrumentation means real-time performance and physical touch remain unverified. |
| Three.js world-sync smoke | **PASS (headless/ad-hoc)** | Created/synced procedural scene objects, ready fruit bunches, worker-load visibility, collection quantity, and selection state with a lightweight DOM stub. This is separate from rendered browser pixels/input evidence. |
| Browser static HTTP smoke | **PASS (local/ad-hoc)** | Expected app, SVG, GLB, and external texture paths responded with HTTP 200 and suitable content types. Not a target-browser/mobile-device compatibility test. |
| Godot 4.3 clean editor import | **PASS** | `Godot_v4.3-stable_linux.x86_64 --headless --editor --path . --quit` passes on the project and on a fresh copy without `.godot` cache; no script parse errors. |
| Native Godot simulation acceptance | **PASS (headless/domain only)** | `tests/godot/run_native_acceptance.sh` runs 109 core simulation assertions, 65 focused crop-model checks, and the structural smoke after import/parse. The core suite checks task/reservation counts, first harvest at the 36-model-month boundary, exact FFB flow/accounting, and repeat harvest/delivery/sale. It does not prove rendered pixels or physical input. |
| M3 crop-model smoke | **PASS (65 focused checks; software-only fixtures)** | `tests/godot/crop_model_smoke.gd` covers calendar/stage/maturity boundaries, directional yield behavior, deterministic eight-model-year baseline/limited-input/stress trajectories, model bounds, fertilizer/season effects, individual-age cohort windows, and cohort condition averages with pest-index units. Annual reserve resets are test assumptions, not agronomy validation or qualified review. |
| Godot 4.3 configured main-scene launch | **PASS (runtime startup only)** | `Godot_v4.3-stable_linux.x86_64 --headless --path . --quit-after 5` exits 0 with no GDScript errors; Dummy renderer logs 264 non-fatal `mesh_get_surface_count` diagnostics. |
| Main-scene structural/runtime smoke | **PASS (110 assertions; headless)** | `GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_main_scene_smoke.sh` imports the project, starts the configured main scene, checks all eight reviewed operation GLBs instantiate with meshes and are marked visual-only, checks the existing shelter→clearing→planting view flow and UI action dispatch, and reproduces the Dummy diagnostic in an isolated BoxMesh project. Actual appearance, camera framing, and visible rendering are explicitly UNVERIFIED. |
| Root-cause classification | **PASS: Dummy renderer limitation supported by minimal reproduction** | Godot 4.3 `--headless` selects `display-driver=headless` and renderer `dummy` (CLI help); a default minimal project with one `MeshInstance3D` using `BoxMesh` logs the same `servers/rendering/dummy/storage/mesh_storage.h:120` error and exits 0. The message identifies no specific project node/resource. |
| Visible-renderer attempt | **UNVERIFIED / BLOCKED BY ENVIRONMENT** | X11/OpenGL compatibility attempt fails before project startup: `libXcursor.so.1` and a display server are missing; Godot reports no OpenGL 3.3 support. No `DISPLAY`, `WAYLAND_DISPLAY`, `/dev/dri`, Xvfb, GL/Vulkan driver libraries, or network access to install the missing software backend is available. |
| `git diff --check` | **PASS** | Whitespace/error-marker check only. |
| Visible camera framing, 3D appearance, HUD layout, mouse/touch, device performance | **NOT RUN / UNVERIFIED** | Scene graph and programmatic signals pass, but there is no functioning visible renderer or target device in this environment. |
| Browser controls and responsive layout | **PASS (ad-hoc automated browser clicks/screenshots); physical touch UNVERIFIED** | Chromium accepted BUILD/LAND/PLANT pointer actions and rendered all five SVG icons at 1440×900 and 390×844. This was an automated, fixed-step QA run, not manual mouse/touch acceptance on a device; drag/pinch and target-browser behavior remain unverified. |
| Android/mobile FPS, memory, thermal, and battery testing | **NOT RUN / UNVERIFIED** | No target device or profiler evidence exists. |

Full test scenarios, gates, and pass/fail evidence policy are in [QA_PLAN.md](docs/QA_PLAN.md).

## Milestone status

| ID | Milestone | Status | Next gate |
|---|---|---|---|
| M0 | Direction, review, and production validation foundation | **IN PROGRESS** | Godot 4.3 import and structural main-scene smoke pass; non-Dummy visible rendering and target-device baseline remain outstanding. |
| M1 | Estate establishment | **IN PROGRESS — validation debt** | Native simulation and main-scene structural shelter/clearing/planting flow pass; visible HUD/touch flow remains unverified. |
| M2 | First Harvest | **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS** | Browser evidence (151 kg / $151 / $1,501 first cycle, 342 kg two-palm block delivery, repeat readiness, and scene sync), 109 native GDScript assertions, Godot import/parse, and 110 structural scene assertions pass. Native visible-renderer and physical-input gate remains UNVERIFIED; do not mark M2 COMPLETE until it passes. |
| M3 | Credible Crop and Agronomy Model | **IN PROGRESS** | Native calendar/stage/yield/cohort behavior and maturity-boundary timing are covered by scenario documentation and 65 checks, including eight-year deterministic baseline/limited-input/stress fixtures. A named model owner and qualified agronomic review remain open; no numeric assumption is approved as factual. |
| M4–M10 | Workforce through release | **NOT STARTED** | See [ROADMAP.md](docs/ROADMAP.md); no further scope is implicitly approved by this status table. |

## Immediate next actions

1. Keep M2 **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS** until a usable non-Dummy native run visibly verifies the harvest → delivery → sale → repeat loop and physical input.
2. Obtain a named model owner and qualified agronomic reviewer for M3; have them review the documented scenario assumptions, units/ranges, eight-year fixtures, and accelerated timing before approving any factual interpretation.
3. On a usable non-Dummy renderer and agreed target device, review the integrated generic palm and operation-asset silhouettes, yard/route framing, process-flow disclaimer, growth-stage contrast, and procedural FFB cues; profile before treating any as accepted art. Until then, keep visual/performance acceptance UNVERIFIED, preserve M0/M1 validation debt, and report browser and native evidence separately.
