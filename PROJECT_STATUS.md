# Palm Plantation — Project Status

## Authority and change control

This file is the live, evidence-based status snapshot. The planning source of truth is the set of documents linked below; `README.md` remains the quick-start and implementation overview. If a README claim conflicts with these documents, use the documents for scope, milestone status, acceptance, and release readiness.

- [Roadmap and milestone gates](docs/ROADMAP.md)
- [Development task plan and statuses](docs/DEV_PLAN.md)
- [Game design and launch scope](docs/GAME_DESIGN.md)
- [Technical architecture and browser-to-Godot transition](docs/TECH_ARCHITECTURE.md)
- [Art direction](docs/ART_DIRECTION.md)
- [Asset plan](docs/ASSET_PLAN.md)
- [QA plan and current evidence](docs/QA_PLAN.md)
- [Launch checklist](docs/LAUNCH_CHECKLIST.md)

**Execution authorization:** the user has instructed us to start development following this roadmap; that is treated as approval to proceed under the documented scope. Unroadmapped ideas still go only into `FUTURE_BACKLOG` in `docs/ROADMAP.md` and are not implementation requests by default.

## Snapshot

| Item | Current state |
|---|---|
| Code baseline audited | `e6c3ef39512573c2eb2ee481bbdc260b1a7051c7` (`Add FFB harvest collection and sales loop`) |
| Working branch | `arena/01a0f46d-palm-plantation` |
| Production target | Godot 4.x; project declares Godot 4.3 features and the Mobile renderer; modest/mobile hardware is the design target |
| Current product milestone | **M2 — First Harvest** |
| M2 status | **IN PROGRESS, not COMPLETE.** The browser suite passes 5/5 tests and the Godot 4.3 headless simulation runner passes 83 assertions through a second harvest/sale cycle. The main scene has not been validated with a real renderer/UI, and mobile/device acceptance remains UNVERIFIED. |
| Documentation review | Accepted for execution by the user's instruction to start development following the roadmap |
| Release readiness | Not release-ready; no visible-renderer scene acceptance, target device, save/load, or performance evidence |

M0 and M1 validation debt is not waived by working on M2. M2 is the active feature target because the repository already contains a first-harvest slice; the preceding project-start and establishment gates still have to pass before M2 can be declared complete.

## Repository audit

The audited code baseline contains one Godot project and one main scene, plus a separately authored browser implementation in `web-preview/`. The browser code is JavaScript/Three.js; it neither imports nor runs the GDScript or `.tscn` scene. The Godot world and characters are predominantly procedural. The only standalone game art asset found is `assets/icon.svg`; Three.js is vendored in `web-preview/vendor/three.min.js` with `web-preview/THREE-LICENSE.txt`.

At the audited baseline there was no tracked test suite, CI workflow, export preset, save/load implementation, or QA automation. Development has now added a browser-only Node suite at `web-preview/tests/simulation.test.mjs` and a Godot headless simulation runner at `tests/godot/simulation_acceptance.gd`; CI, rendered main-scene acceptance, and device QA remain absent. Values such as the growth durations, yields, starting cash, and `$1/kg` FFB price are prototype parameters, not validated agricultural or commercial forecasts.

## Feature audit

Status describes the audited feature—not milestone completion. A feature may have code and still fail its acceptance gate.

- **IMPLEMENTED** — the behavior exists and has evidence within the stated scope; this does not complete its milestone.
- **PARTIALLY IMPLEMENTED** — some behavior exists, but meaningful target behavior or acceptance remains missing.
- **PLACEHOLDER** — a hard-coded or simplified stand-in exists and is not suitable as a validated production model.
- **NOT IMPLEMENTED** — no corresponding implementation was found.
- **BROKEN** — a reproducible failure has been observed in a named environment; cite the reproduction. The current BROKEN label is limited to Godot's headless Dummy-renderer mesh diagnostic and does not establish a visible-renderer defect.
- **UNVERIFIED** — source/configuration exists, but the required runtime, device, or acceptance behavior was not exercised.

| Area | Audit status | Evidence and limitation |
|---|---|---|
| Godot 4.3 project import and GDScript compilation | **IMPLEMENTED (validated headless)** | A clean-copy `--headless --editor --quit` import passes with no script parse errors; the native simulation runner passes 83 assertions. This does not validate the visible renderer or UI. |
| Main-scene rendering and UI integration | **UNVERIFIED** | The main scene starts under Godot's headless Dummy renderer, but that renderer logs `mesh_get_surface_count` null errors for MeshInstances; an isolated BoxMesh probe produces the same error. No desktop/mobile visible-renderer or touch run has been performed. |
| Simulation/data separation | **PARTIALLY IMPLEMENTED** | Records exist for palms, workers, tasks, buildings, land, and FFB collection. State is in-memory only; there is no persistence or production-scale model. |
| Estate strategy / land portfolio | **NOT IMPLEMENTED** | The player receives one fixed forest block. No acquire/lease, land-value, tenure, or portfolio decision exists. |
| Shelter, clearing, field preparation, and planting | **PARTIALLY IMPLEMENTED** | A Godot 4.3 headless simulation suite now validates prerequisites, costs, progress, all sixteen slots, reservations, and inventory. The rendered scene/touch flow, land-selection strategy, and wider establishment model remain unverified or absent. |
| Crop growth and maintenance | **PARTIALLY IMPLEMENTED** | Seedling/young/mature stages, fruit states, fertilizer, pest risk, and health are represented. Current day-scale thresholds and effects are simplified prototype values, not agronomically validated. |
| Workforce | **PARTIALLY IMPLEMENTED** | One named worker and a FIFO task queue exist. Energy, morale, and experience are largely presentation/data placeholders; hiring, wages, skills, schedules, and multiple crews do not exist. |
| First harvest and FFB delivery | **PARTIALLY IMPLEMENTED** | A ready palm can be reserved, harvested by a worker, carried to a collection point, and recorded as stored FFB. Capacity, freshness, vehicle logistics, and mill processing are absent. |
| FFB sale / market | **PLACEHOLDER** | Stored kilograms can be sold at a hard-coded `$1/kg`; this is an accounting demonstration, not a market model. |
| Browser prototype loop | **IMPLEMENTED (browser prototype only)** | The checked-in Node suite passes five tests covering the fresh-state cycle, resource/slot rules, readiness/reservation gates, and two harvest/delivery/sale cycles. It is not the production runtime; manual browser interaction/rendering remains unverified. |
| Browser static delivery | **IMPLEMENTED (local smoke only)** | An in-process HTTP smoke check returned 200 for the entry page, modules, stylesheet, and vendored Three.js. This is not browser compatibility testing. |
| Visual presentation | **PARTIALLY IMPLEMENTED** | Procedural meshes, MultiMesh background forest, camera, characters, and responsive HUD code exist. Final art, accessibility, device layout, and native rendering are not accepted. |
| Test infrastructure | **PARTIALLY IMPLEMENTED** | Browser Node tests (5/5) and a native Godot simulation runner (83 assertions) are tracked. No native rendered-scene tests, CI, or device automation exists. |
| Weather, soil, climate, biodiversity, community, and regulation | **NOT IMPLEMENTED** | No operational or stewardship model exists. |
| Save/load, settings, localization, audio, analytics, online features | **NOT IMPLEMENTED** | None found in the audited baseline. |
| Known BROKEN behavior | **BROKEN (headless Dummy-renderer diagnostic only)** | Launching the 3D main scene with `--headless` emits `mesh_get_surface_count` null errors; the same error occurs with a standalone BoxMesh in a headless probe. This is attributed to the Dummy renderer path and does not establish a visible-renderer defect. Real-renderer behavior remains UNVERIFIED. |

## Validation evidence at this audit

| Check | Result | Boundary |
|---|---|---|
| `gdparse` on every `scripts/**/*.gd` file | **PASS (ad-hoc)** | Parser-only check using an ephemeral `gdtoolkit` environment; parser version is not pinned. The committed Godot runner is a separate engine-executed simulation suite. |
| `node --check` on browser simulation, main, world, and test modules | **PASS** | JavaScript syntax only. |
| Browser simulation tests | **PASS (repeatable, browser-only)** | `node --test web-preview/tests/simulation.test.mjs` passes 5/5 tests, including establishment, all sixteen planting reservations, harvest readiness/reservations, exact two-cycle delivery/sale accounting, and repeat harvest. These tests do not validate Godot. |
| Three.js world-sync smoke | **PASS (headless/ad-hoc)** | Created/synced scene objects, ripe bunches, worker load, collection quantity, and selection indicator with a lightweight DOM stub. Not a rendered browser test. |
| Browser static HTTP smoke | **PASS (local/ad-hoc)** | Expected static paths responded with HTTP 200. Not a real-browser, mobile-browser, or WebGL compatibility test. |
| Godot 4.3 clean editor import | **PASS** | `Godot_v4.3-stable_linux.x86_64 --headless --editor --path . --quit` passes on the project and on a fresh copy without `.godot` cache; no script parse errors. |
| Native Godot simulation acceptance | **PASS (headless/domain only)** | `Godot_v4.3-stable_linux.x86_64 --headless --path . --script res://tests/godot/simulation_acceptance.gd` prints `PASS: 83 native simulation assertions` and exits 0, including a second harvest/delivery/sale. It does not load the rendered main scene. |
| Godot main scene in headless Dummy renderer | **BROKEN (renderer-specific diagnostic)** | Scene command exits 0 but logs `mesh_get_surface_count` null errors for meshes; a one-BoxMesh headless probe reproduces the same diagnostic. No script errors appear after type fixes. Visible rendering still needs a non-Dummy renderer. |
| `git diff --check` | **PASS** | Whitespace/error-marker check only. |
| Godot visible main-scene play, UI/touch, device performance | **NOT RUN / UNVERIFIED** | No display/GPU or target mobile device is available in this environment. |
| Manual browser controls, touch, visual/layout inspection | **NOT RUN / UNVERIFIED** | No manual browser acceptance was performed in this audit. |
| Android/mobile FPS, memory, thermal, and battery testing | **NOT RUN / UNVERIFIED** | No target device or profiler evidence exists. |

Full test scenarios, gates, and pass/fail evidence policy are in [QA_PLAN.md](docs/QA_PLAN.md).

## Milestone status

| ID | Milestone | Status | Next gate |
|---|---|---|---|
| M0 | Direction, review, and production validation foundation | **IN PROGRESS** | Clean Godot 4.3 import and native simulation tests pass; a non-Dummy main-scene rendering run and target-device baseline remain outstanding. |
| M1 | Estate establishment | **IN PROGRESS — validation debt** | Native simulation suite passes shelter, clearing, and all sixteen planting checks; visible main-scene/touch flow remains unverified. |
| M2 | First Harvest | **IN PROGRESS — CURRENT** | Browser and native simulation suites pass two harvest/sale cycles; remaining queue/accounting edge cases and visible native scene/UI validation are open. |
| M3–M10 | Agronomy through release | **NOT STARTED** | See [ROADMAP.md](docs/ROADMAP.md); no scope is implicitly approved by this status table. |

## Immediate next actions

1. Use the branch-provided Godot 4.3 binary for clean import and headless simulation tests; those commands are now repeatable.
2. Run the actual main scene with a visible non-Dummy renderer and validate HUD/input integration; the current sandbox has no display/GPU.
3. Name the minimum mobile device baseline and execute M1 touch/layout and M9 performance gates when that device is available.
4. Expand M2 queue/cancellation, rounding, zero-stock, and multiple-ready-palm tests; keep browser and Godot reports separate.
5. Update this file only when evidence changes. A code change or headless simulation pass alone does not make M2 COMPLETE.
