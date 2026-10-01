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
| M2 status | **IN PROGRESS, not COMPLETE.** A checked-in Node test suite now passes for the separate browser simulation. The native Godot project has not been loaded or played in Godot, so the production implementation and its acceptance gate remain UNVERIFIED. |
| Documentation review | Accepted for execution by the user's instruction to start development following the roadmap |
| Release readiness | Not release-ready; no native runtime, device, save/load, or performance acceptance evidence |

M0 and M1 validation debt is not waived by working on M2. M2 is the active feature target because the repository already contains a first-harvest slice; the preceding project-start and establishment gates still have to pass before M2 can be declared complete.

## Repository audit

The audited code baseline contains one Godot project and one main scene, plus a separately authored browser implementation in `web-preview/`. The browser code is JavaScript/Three.js; it neither imports nor runs the GDScript or `.tscn` scene. The Godot world and characters are predominantly procedural. The only standalone game art asset found is `assets/icon.svg`; Three.js is vendored in `web-preview/vendor/three.min.js` with `web-preview/THREE-LICENSE.txt`.

At the audited baseline there was no tracked test suite, CI workflow, export preset, save/load implementation, or QA automation. Development has now added a **browser-only Node test suite** at `web-preview/tests/simulation.test.mjs`; there is still no native Godot test suite or CI. Values such as the growth durations, yields, starting cash, and `$1/kg` FFB price are prototype parameters, not validated agricultural or commercial forecasts.

## Feature audit

Status describes the audited feature—not milestone completion. A feature may have code and still fail its acceptance gate.

- **IMPLEMENTED** — the behavior exists and has evidence within the stated scope; this does not complete its milestone.
- **PARTIALLY IMPLEMENTED** — some behavior exists, but meaningful target behavior or acceptance remains missing.
- **PLACEHOLDER** — a hard-coded or simplified stand-in exists and is not suitable as a validated production model.
- **NOT IMPLEMENTED** — no corresponding implementation was found.
- **BROKEN** — a reproducible failure has been observed in a named environment; cite the reproduction. No confirmed BROKEN feature was found in the limited checks below.
- **UNVERIFIED** — source/configuration exists, but the required runtime, device, or acceptance behavior was not exercised.

| Area | Audit status | Evidence and limitation |
|---|---|---|
| Godot project configuration and main scene | **UNVERIFIED** | Godot 4.3+ and Mobile-renderer configuration and scene files exist. No Godot executable was available to import, start, or play the scene. |
| Simulation/data separation | **PARTIALLY IMPLEMENTED** | Records exist for palms, workers, tasks, buildings, land, and FFB collection. State is in-memory only; there is no persistence or production-scale model. |
| Estate strategy / land portfolio | **NOT IMPLEMENTED** | The player receives one fixed forest block. No acquire/lease, land-value, tenure, or portfolio decision exists. |
| Shelter, clearing, field preparation, and planting | **PARTIALLY IMPLEMENTED** | One shelter, one fixed clearing zone, and sixteen planting slots are modeled with timed worker tasks. There is no native runtime validation, land-selection strategy, or wider establishment model. |
| Crop growth and maintenance | **PARTIALLY IMPLEMENTED** | Seedling/young/mature stages, fruit states, fertilizer, pest risk, and health are represented. Current day-scale thresholds and effects are simplified prototype values, not agronomically validated. |
| Workforce | **PARTIALLY IMPLEMENTED** | One named worker and a FIFO task queue exist. Energy, morale, and experience are largely presentation/data placeholders; hiring, wages, skills, schedules, and multiple crews do not exist. |
| First harvest and FFB delivery | **PARTIALLY IMPLEMENTED** | A ready palm can be reserved, harvested by a worker, carried to a collection point, and recorded as stored FFB. Capacity, freshness, vehicle logistics, and mill processing are absent. |
| FFB sale / market | **PLACEHOLDER** | Stored kilograms can be sold at a hard-coded `$1/kg`; this is an accounting demonstration, not a market model. |
| Browser prototype loop | **IMPLEMENTED (browser prototype only)** | The checked-in Node suite passes five simulation tests covering the fresh-state cycle, resource/slot rules, readiness/reservation gates, worker harvest/delivery, sale accounting, and repeat readiness. It is not the production runtime; manual browser interaction/rendering remains unverified. |
| Browser static delivery | **IMPLEMENTED (local smoke only)** | An in-process HTTP smoke check returned 200 for the entry page, modules, stylesheet, and vendored Three.js. This is not browser compatibility testing. |
| Visual presentation | **PARTIALLY IMPLEMENTED** | Procedural meshes, MultiMesh background forest, camera, characters, and responsive HUD code exist. Final art, accessibility, device layout, and native rendering are not accepted. |
| Weather, soil, climate, biodiversity, community, and regulation | **NOT IMPLEMENTED** | No operational or stewardship model exists. |
| Save/load, settings, localization, audio, analytics, online features | **NOT IMPLEMENTED** | None found in the audited baseline. |
| Known BROKEN behavior | **No confirmed defect from the checks run** | This is not a clean-bill-of-health claim: native Godot and device behavior are still UNVERIFIED. |

## Validation evidence at this audit

| Check | Result | Boundary |
|---|---|---|
| `gdparse` on every `scripts/**/*.gd` file | **PASS** | Parser-only check using an ephemeral `gdtoolkit` environment; no parser dependency or test runner is committed. |
| `node --check` on browser simulation, main, and world modules | **PASS** | JavaScript syntax only. |
| Browser simulation tests | **PASS (repeatable, browser-only)** | `node --test web-preview/tests/simulation.test.mjs` passes 5/5 tests, including the fresh-state loop, all sixteen planting reservations, invalid/duplicate harvest gates, worker movement/work, exact delivery/sale accounting, duplicate-sale prevention, and repeat readiness. These tests do not validate Godot. |
| Three.js world-sync smoke | **PASS (headless/ad-hoc)** | Created/synced scene objects, ripe bunches, worker load, collection quantity, and selection indicator with a lightweight DOM stub. Not a rendered browser test. |
| Browser static HTTP smoke | **PASS (local/ad-hoc)** | Expected static paths responded with HTTP 200. Not a real-browser, mobile-browser, or WebGL compatibility test. |
| `git diff --check` before documentation edits | **PASS** | Whitespace check only. |
| Godot import, main-scene launch, native gameplay | **NOT RUN / UNVERIFIED** | No Godot executable is installed in the environment. |
| Manual browser controls, touch, visual/layout inspection | **NOT RUN / UNVERIFIED** | No manual browser acceptance was performed in this audit. |
| Android/mobile FPS, memory, thermal, and battery testing | **NOT RUN / UNVERIFIED** | No target device or profiler evidence exists. |

Full test scenarios, gates, and pass/fail evidence policy are in [QA_PLAN.md](docs/QA_PLAN.md).

## Milestone status

| ID | Milestone | Status | Next gate |
|---|---|---|---|
| M0 | Direction, review, and production validation foundation | **IN PROGRESS** | Documentation approval is recorded; a Godot 4.3+ import/main-scene smoke and target-device baseline remain outstanding. |
| M1 | Estate establishment | **IN PROGRESS — validation debt** | Native fresh-state shelter, clearing, and planting acceptance passes, including resource/slot edge cases. |
| M2 | First Harvest | **IN PROGRESS — CURRENT** | Checked-in reproducible acceptance evidence plus successful native Godot end-to-end execution; browser evidence stays a separate gate. |
| M3–M10 | Agronomy through release | **NOT STARTED** | See [ROADMAP.md](docs/ROADMAP.md); no scope is implicitly approved by this status table. |

## Immediate next actions

1. Obtain a Godot 4.3+ runtime through an approved/reachable install path; the official release-asset download is currently blocked in this environment.
2. Establish a repeatable native import/launch/test command and name the minimum mobile device baseline.
3. Add and run native M1/M2 acceptance tests; keep browser and Godot results separate.
4. Continue M2 only against its stated acceptance gates; do not add unroadmapped gameplay.
5. Update this file only when evidence changes. A code change or browser pass alone does not make a milestone COMPLETE.
