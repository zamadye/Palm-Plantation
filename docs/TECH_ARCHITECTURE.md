# Technical Architecture

## Purpose

This document records the audited implementation, production direction, performance budgets, and the staged browser-to-Godot transition. It does not authorize scope outside the user-approved roadmap. The user authorized a curated four-model Nature Kit palm subset and subsequently a small CC0 operation-visual subset; the latter is integrated only as static generic placeholders, with no process/vehicle logic. Neither asset slice changes M2's native rendered/input acceptance or M3's qualified model-review gate. The five existing HUD icons remain. The production runtime is Godot 4.x; browser/Three.js validation is separate.

## Current repository architecture (audited baseline)

| Layer | Current implementation |
|---|---|
| Project/runtime | One Godot project (`project.godot`) targeting Godot 4.3 features and the Mobile renderer; one main scene at `scenes/main/main.tscn`. |
| Coordinator/input | `scripts/main.gd` creates/synchronizes views, maps camera ground clicks to world actions, and connects UI signals to simulation commands. |
| Simulation | `scripts/simulation/plantation_simulation.gd` owns in-memory resources, accelerated time, crop growth/condition, month-keyed cohort outlook, task order, worker movement/work, harvest, FFB collection, and fixed-price sales. |
| Records | `scripts/simulation/*_record.gd` stores worker, palm, task, building, land-zone, and FFB-collection state as non-view data. |
| World/presentation | `scripts/world/world_builder.gd` and `visual_factory.gd` generate procedural meshes/materials and represent progress; background forest uses `MultiMeshInstance3D`, while young/mature palms and three distant landmarks use four curated generic Kenney GLBs. FFB cues remain procedural. |
| Camera/UI | `scripts/camera/strategy_camera.gd` provides pan/zoom/limited rotation; `scripts/ui/game_ui.gd` creates a responsive CanvasLayer HUD and contextual panels. |
| Browser preview | `web-preview/js/` separately implements the simulation, Three.js world, UI, and input. It parses the four shared palm GLBs and eight shared operation GLBs from `assets/`, including local texture dependencies; the five shared SVG action icons are also used in the browser HUD. It does not import Godot scenes/scripts or share simulation state. Three.js is vendored with its license. |
| Persistence/tests/build | No save/load, CI workflow, export preset, or production build pipeline exists. The current working tree contains a repeatable GDScript simulation runner and main-scene structural smoke; Godot 4.3 import/parse, 109 native simulation assertions, 65 crop-model checks, and 110 structural assertions pass headlessly. Visible rendering, physical input, and device behavior remain UNVERIFIED. |

The current boundary between simulation records and visual nodes is a useful starting point, not a claim that the simulation is deterministic, serializable, or production-ready. The current simulation updates through engine `_process(delta)` and uses simplified test values.

## Production architecture direction

Prefer a small, explicit architecture that can be tested without rendering. Avoid a broad framework rewrite before M1/M2 evidence.

1. **Domain/simulation state:** typed, engine-light records/resources for estate, blocks/cohorts, workers/crews, tasks, inventory, batches, market, stewardship, and ledger. Domain logic must not depend on `Node3D`, UI controls, or browser APIs.
2. **Commands and validation:** user intent becomes a command (for example, queue planting, assign crew, schedule harvest, route a batch). Validate prerequisites/cost/capacity once at the simulation boundary; emit one result with a reason on rejection.
3. **Simulation clock:** a controlled game calendar advances in deterministic fixed logical steps, independent of render frame rate. Pause/normal/fast-forward changes how many logical steps are requested, not the order of outcomes. Expensive batch updates must have a profiled budget.
4. **Task/operations system:** typed tasks reference stable IDs, have explicit queued/assigned/active/completed/cancelled/blocked transitions, and account for resources exactly once. Queue policy and route abstraction are data/logic, not view code.
5. **Projection/presentation:** Godot scene nodes are views of simulation state. Views can be rebuilt from a snapshot; they do not own authoritative inventory, growth, or money. Update low-frequency/static visuals less often than frame animation.
6. **Data definitions:** use reviewed Godot `Resource`/data definitions for crop parameters, seasons, crew types, task costs, and outlet rules. Keep units, source, uncertainty, and `test-only`/`illustrative`/`factual` label with each model parameter. Avoid duplicated hard-coded values in UI and simulation.
7. **Persistence:** local saves live under Godot `user://`, use a versioned schema, stable IDs, atomic/backup writes, and explicit migration/error handling. Never serialize scene-node references as the source of truth.
8. **UI/input:** UI issues commands through a narrow controller/service boundary and observes results/state. Camera controls, touch gestures, and panel taps must not conflict. The UI shows costs, prerequisites, status, blocked reasons, and calendar context.
9. **Rendering/assets:** retain low-complexity procedural geometry where it is clear and cheap. Use MultiMesh or batched representations for repeated distant palms/forest; reserve individual nodes for selected/nearby interactive visuals. Avoid per-tree physics bodies and expensive shadows.
10. **Observability:** automated tests and a debug panel/log should expose simulation day, task IDs/status, block/cohort IDs, resource deltas, delivery batches, and ledger transactions without becoming a player-facing cheat system.

### Simulation model and determinism

- The strategy layer should primarily update blocks and cohorts, not one full simulation object per real tree.
- Logical outcomes use a fixed ordering, stable IDs, and seeded scenario randomness. Given the same save, seed, command sequence, and model version, a test replay should produce the same state/ledger.
- Keep actual elapsed/render time separate from game time. Walking/animation may be visual; work duration, growth, seasons, and transaction order are logical simulation rules.
- Use conservation checks: planting consumes a seedling once; harvest quantity moves palm → worker/field load → collection → outlet → accepted/sold/rejected; cash changes map to ledger rows.
- The native M3 crop slice lives in `scripts/simulation/crop_model.gd` and `docs/CROP_MODEL.md`: it separates the accelerated calendar, age/yield curve, scenario periods, input/condition effects, and per-palm cohort harvest outlook from scene presentation. The outlook distinguishes ready lots from windows due within the next 30 model days. Cited timing references inform the broad curve; numeric condition rates remain scenario assumptions pending qualified review. `$1/kg` remains a prototype fixture unless explicitly promoted to a sourced market-price assumption; market-price simulation belongs to M6.

## Browser prototype and Godot production transition

The browser version is a separate JavaScript/Three.js program. A static server only serves those files; it does not compile GDScript, load `.tscn`, or convert Godot scenes. Do not build or describe a converter/importer.

### Stages

1. **Documentation and freeze:** accept the product/design/architecture scope before gameplay changes. Preserve `web-preview/` as a labeled prototype; do not treat its feature list as proof of native behavior.
2. **Separate test baselines:** make a repeatable Node/browser test surface for browser-only behavior and a Godot-native test surface for production. Capture current browser E2E and world-sync scenarios as fixtures; keep each result tagged with its runtime.
3. **Native validation first:** install/use Godot 4.3+, import and launch the existing project, then execute M1/M2 in Godot. Fix native defects on the production branch; do not accept a browser pass as a substitute.
4. **Native vertical slices:** implement only accepted milestones in Godot using the intended domain/view boundary. Port behavior by specification and tests—not by mechanically copying JavaScript or maintaining two production sources.
5. **Optional golden fixtures:** if cross-runtime parity remains valuable, share small JSON inputs/expected domain outcomes (values and state transitions only). Browser and Godot must still have separate test runners and result reports; one engine cannot pass for the other.
6. **Freeze or retire browser feature development:** after the native M2 slice is accepted, decide whether the web preview remains a clearly labeled demo/logic sandbox or is frozen. It is never the save format, live-game backend, or authority for production data.
7. **Release:** Godot builds, Godot save schema, Godot profiling, and supported mobile-device tests are the shipping gates. Browser export is outside launch scope unless separately approved.

## Provisional performance budgets

These are **targets**, not measured results. Confirm the minimum device and profiling method in M0. If profiling shows a target is inappropriate, propose a documented budget change before relaxing it; do not quietly increase limits.

| Metric | Provisional target | Measurement gate |
|---|---|---|
| Sustained frame pacing | At least 30 FPS on the agreed minimum mobile device at 1280×720 landscape equivalent; p95 frame time ≤33.3 ms and p99 ≤50 ms during a 30-minute dense-estate run. 60 FPS is a preferred higher-tier target, not the minimum gate. | Godot profiler/device capture at worst camera angle, maximum launch estate, active operations, and open HUD. |
| Long stalls | No recurring frame stall >100 ms after the initial load/warm-up; no sustained interval below 24 FPS for more than 5 seconds. | Timestamped frame-time capture across the same stress run. |
| Memory | Peak process resident memory ≤512 MiB on the minimum device for the 30-minute stress run. | Platform profiler; include OS/device, build, resolution, and peak RSS. |
| Startup | Cold start to interactive estate ≤10 seconds on the minimum device. | Five cold launches; report median and worst result. |
| Save/load | Typical launch-scope save and load each complete in ≤2 seconds without blocking the UI for a long frame. | 20 round-trips on representative maximum-state save; report median and worst. |
| Input feedback | Visible response to a valid tap/selection within 100 ms, excluding explicitly long-running simulation outcomes. | Device capture with UI and world-selection paths. |
| Draw calls/shadows | ≤200 3D draw calls at the target camera for launch content; one shadow-casting directional light maximum; instancing for repeated distant vegetation. | Godot rendering profiler in the dense-estate test. |
| Simulation step | p95 logical-step time ≤4 ms and no logical step >8 ms at maximum accepted launch state. | Deterministic worst-case state under a profiler; rendering time reported separately. |
| Installed package | Target ≤150 MiB for the initial install, including runtime and launch content. | Final signed package size; any exception needs an explicit product decision. |
| Thermal stability | No thermal throttling that causes the sustained frame target to fail during the 30-minute stress run. | Device thermal/performance capture; ambient conditions recorded. |

Current performance is **UNVERIFIED**. Procedural meshes and MultiMesh use are design choices, not a benchmark. The project has a shadowed key directional light and a non-shadow fill light; device cost is unknown.

## Failure handling and risk boundaries

- Godot 4.3 headless import, simulation, and structural checks pass in the current environment. The absence of a usable non-Dummy renderer is a visual-acceptance blocker, not evidence that visible project rendering works or is broken.
- If a native project fails to import or run, record the exact engine version, command, log, and reproduction before changing runtime code.
- Keep browser failures and Godot failures separate in issues and QA reports.
- Do not add backend, network, accounts, telemetry, or cloud persistence to solve a local save/validation problem; those are outside launch scope.
- No new technical subsystem is approved unless it supports an accepted milestone and has an owner, test path, performance impact, and removal/recovery plan.
