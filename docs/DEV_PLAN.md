# Development Plan and Task Status

## Rules

This plan turns [ROADMAP.md](ROADMAP.md) into gated tasks and does not authorize scope growth. The user authorized a curated, game-relevant subset of Kenney Nature Kit palms and later a bounded CC0 operation-visual subset; the latter is integrated as static placeholders only. Neither changes M2/M3 acceptance status or authorizes purchases, commissions, process redesign, or scope growth. The five existing HUD action icons stay in place. The browser preview remains a separate prototype. See [GODOT_MVP.md](GODOT_MVP.md) and [`ASSET_PLAN.md`](ASSET_PLAN.md).

Task statuses are controlled values:

- **NOT STARTED** — no execution evidence yet.
- **IN PROGRESS** — active, but its completion evidence is incomplete.
- **BLOCKED** — cannot proceed until a named dependency is resolved.
- **COMPLETE** — its measurable evidence exists and all listed checks pass.
- **DEFERRED** — explicitly moved out of the approved scope through a recorded decision.

A feature can exist while its validation task is BLOCKED. Do not mark a task COMPLETE because code exists, a parser accepts it, or the separate browser prototype passes. Do not assign dates or silently expand scope. Status updates should link to a test command, report, or review decision.

## Current execution order

1. Continue the roadmap-aligned M2/M3 work without changing their open acceptance gates; retain native visible-renderer/physical-input evidence and qualified agronomic review as separate requirements.
2. Keep M3 deterministic multi-year behavior, units/assumptions, and regression coverage traceable; request a named model owner and qualified reviewer before acceptance.
3. Integrate only the explicitly requested curated palm and operation-visual subsets, with source/license provenance, structural engine checks, and honest visual/device acceptance status; operation assets remain static generic placeholders and the five HUD action icons are retained.
4. Keep M0/M1 validation debt visible, and keep browser evidence distinct from native Godot evidence.

The branch baseline under review is `e6c3ef39512573c2eb2ee481bbdc260b1a7051c7`. The browser prototype is separately authored and cannot complete a Godot task.

## M0 — Direction, scope, and production validation foundation

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M0-01 | Review and accept/revise the roadmap, eight gameplay layers, bounded launch scope, architecture, and no-scope-growth rule. | **COMPLETE** | User instructed development to start following this roadmap; work proceeds under the documented scope unless revised. |
| M0-02 | Run a clean Godot 4.3+ import and launch `scenes/main/main.tscn`; capture engine output. | **IN PROGRESS** | The clean editor import passes. Main launch via `--headless --path . --quit-after 5` exits 0 with no GDScript errors but logs 264 `mesh_get_surface_count` diagnostics from the `headless`/Dummy renderer. `tests/godot/run_main_scene_smoke.sh` passes 110 scene-structure/gameplay assertions; a minimal-project BoxMesh probe reproduces the same non-fatal engine diagnostic. X11/OpenGL fallback could not start because display/software-renderer dependencies are absent and apt network access failed. Visible renderer/UI/input acceptance remains UNVERIFIED. |
| M0-03 | Add a repository-backed, repeatable native test command and document its setup. | **COMPLETE** | `GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_native_acceptance.sh` checks the Godot version/import, passes 109 core simulation assertions, 65 focused crop-model checks, and 110 headless structural assertions. README/QA instructions record it; it does not automate graphical acceptance. |
| M0-04 | Choose and record minimum mobile device/OS, landscape resolution, and profiling procedure. | **NOT STARTED** | Device/build IDs and baseline test procedure recorded; no device is assumed from the current project setting alone. |

## M1 — Estate establishment (existing code; native validation debt)

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M1-01 | Exercise shelter placement, invalid sites, prerequisites, construction, and one-time costs in native Godot. | **COMPLETE** | `tests/godot/simulation_acceptance.gd` verifies valid/invalid placement, prerequisites, task completion, and exact one-time balance/inventory changes. This covers simulation behavior, not the rendered UI. |
| M1-02 | Exercise clearing prerequisites, exactly-once charge, progress, prepared state, and repeat/invalid requests. | **COMPLETE** | The native simulation suite covers pre-shelter rejection, out-of-block rejection, valid/duplicate clearing, exact cost, progress, and final PREPARED state. |
| M1-03 | Exercise the 4 × 4 planting grid, all 16 slots, reservations, resource consumption, and invalid indices. | **COMPLETE** | The native suite fills all sixteen slots and verifies unique palm IDs, slot IDs, world positions, exact seedling consumption, and duplicate/out-of-range rejection. |
| M1-04 | Verify the establishment flow with the mobile HUD and touch input at the agreed minimum resolution. | **BLOCKED** | Requires a manual run on the agreed M0 device/resolution; no target device or usable display/input environment is available here. Buttons, details, placement feedback, overlap, and dead tap areas remain visually/touch unverified. |

## M2 — First Harvest (**native acceptance gate remains open; status unchanged**)

**M2 review status: FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS.** Browser evidence, Godot import/parse, native GDScript simulation, and native structural scene smoke pass. Native rendered pixels, HUD presentation, and physical input remain UNVERIFIED, so M2 is not COMPLETE.

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M2-01 | Convert the ad-hoc browser E2E flow into a checked-in, fresh-state test with deterministic assertions. | **COMPLETE** | `node --test web-preview/tests/simulation.test.mjs` passes the committed browser-only suite (5/5 tests), including repeat-harvest readiness. A separate fresh-state browser-simulation run measured first-cycle delivery of **151 kg**, sale revenue of **$151**, and resulting funds of **$1,501**. These exact measured figures are review evidence; the suite calculates yield dynamically rather than pinning those values as literals. Native acceptance remains separate. |
| M2-02 | Complete the readiness-gate, duplicate-reservation, task-queue, worker-state, and native main-scene/runtime validation. | **IN PROGRESS (automated portion PASS; visible acceptance UNVERIFIED)** | The 109-assertion native suite asserts that non-ready/duplicate requests do not change task/reservation counts, valid requests create one task/reservation, and first harvest does not occur before the 36-model-month boundary. Import and 110 structural scene assertions pass. A standalone BoxMesh reproduces the non-fatal Dummy-renderer diagnostic. Native rendered pixels/HUD and physical input remain UNVERIFIED; a visible non-Dummy run is still required. |
| M2-03 | Execute first harvest → collection → sale → repeat harvest in the native Godot project. | **IN PROGRESS (simulation PASS; rendered/input gate open)** | The 109-assertion native suite captures computed palm yield before harvest; verifies the first lot opens at the 36-model-month boundary; checks exact worker and collection kilograms, no stock before delivery, zero worker load, cleared palm fruit, and no sale before SELL; and passes repeat harvest/delivery/sale. Import and 110 structural scene assertions pass. Visible pixels, camera framing, HUD layout, and physical mouse/touch remain UNVERIFIED pending a non-Dummy graphical run. |
| M2-04 | Complete conservation and accounting coverage: palm yield = worker load = deposited stock = sold quantity; sale is applied once. | **COMPLETE (simulation/accounting scope)** | Native assertions now compare exact computed yield, worker load, collection stock, cleared palm quantity, and pre-sale transaction state. Native and browser suites verify one-time sale revenue and repeat-cycle accounting. A separate controlled browser fixture with two ready palms at 171 kg each delivered **342 kg total**; this is browser simulation evidence, not native visual acceptance. |
| M2-05 | Perform separate manual browser visual/input acceptance and label the result Browser-only. | **NOT STARTED (separate browser QA; not a native M2 gate)** | The ad-hoc Three.js scene-sync smoke passes for scene objects, ready fruit, worker load, collection quantity, and selection state. Manual click/drag, zoom, action bar, detail panels, and rendered WebGL/input acceptance remain unverified; browser-only results cannot close native M2-03. |
| M2-06 | Complete second crop-cycle and task delivery-priority coverage in both test harnesses. | **COMPLETE** | Both browser and native simulation suites verify repeat-harvest readiness, complete a second harvest, deliver after harvest, and reconcile the second sale. |

**M2 stop rule:** M2 cannot be COMPLETE until Roadmap M2 criteria 1–6 and the native main-scene interaction/rendering criterion (7) pass. Simulation/accounting evidence and Godot import pass, but browser or headless success alone cannot verify native pixels, HUD presentation, or physical input. Keep criterion 7 UNVERIFIED until directly observed on a usable non-Dummy renderer.

## M3 — Credible Crop and Agronomy Model

**Boundary:** M3 is crop/calendar/agronomy only. `$1/kg` is a prototype fixture value unless explicitly promoted to a sourced market-price assumption; market-price simulation belongs to M6.

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M3-01 | Define the accelerated calendar, crop stages, cohorts, harvest windows, and units with domain sources. | **IN PROGRESS (definition documented; review open)** | `docs/CROP_MODEL.md` and `scripts/simulation/crop_model.gd` define model days/months, source-informed stage/first-window timing, first/repeat harvest windows, a per-palm 30-day cohort outlook, units, and scenario-only assumptions. A named owner and qualified review are still required for milestone acceptance. |
| M3-02 | Replace or explicitly scenario-label prototype growth, fruit, health, pest, fertilizer, and yield parameters. | **IN PROGRESS (implementation labeled; review open)** | Native Godot uses the data-driven calendar, age/yield curve, maturity-boundary-aware fruit development, seasonal condition rates, input response, short-horizon condition projection, and cohort condition averages with explicit pest-index units. Coefficients remain scenario assumptions pending qualified review; the browser prototype remains separate. |
| M3-03 | Build deterministic baseline, low-input, and stress-case agronomy fixtures. | **COMPLETE (test-fixture implementation only)** | `tests/godot/crop_model_smoke.gd` passes 65 checks, including deterministic eight-model-year baseline/limited-input/stress trajectories, directional health/output comparisons, bounds, and first-harvest timing. Annual fertilizer-reserve resets are explicit test assumptions, not field prescriptions; this does not replace qualified review or milestone acceptance. |
| M3-04 | Review agricultural claims, units, and in-game time compression with a qualified reviewer. | **BLOCKED (external assignment required)** | A named model owner and qualified agronomic reviewer must be assigned to review assumptions, ranges, units, timing compression, and fixture interpretation; neither is currently named. No parameter is approved as factual. |

### M3 implementation checklist

- [x] Keep crop/calendar/agronomy scope bounded and market-price simulation in M6.
- [x] Record current variables, units, source context, and scenario assumptions in `docs/CROP_MODEL.md`.
- [x] Implement the accelerated calendar, named scenario periods, growth stages, and first/repeat harvest windows.
- [x] Add deterministic baseline, constrained, and stress fixture checks with directional outputs, including eight-model-year trajectories and repeatability/bounds checks.
- [ ] Assign a model owner and obtain qualified review before presenting coefficients as representative.
- [x] Add per-palm harvest-window timing to the month-keyed cohort outlook, separating ready-now lots from forecast lots within a 30-day model horizon; keep projections scenario-labeled.
- [ ] Obtain qualified review of cohort/calendar behavior before treating its coefficients or forecasts as representative.
- [x] Preserve `$1/kg` as a prototype fixture; market-price simulation remains in M6.

M3 remains **IN PROGRESS**: deterministic implementation and fixture work are present, but milestone acceptance is blocked on an assigned owner, qualified agronomic review, and approval of the documented scenario assumptions. The browser model remains separate.

## M4 — Workforce and field operations

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M4-01 | Define crew roles, capacity, task priority, scheduling, cancellation/reassignment, and welfare/safety indicators. | **NOT STARTED** | Task rules are documented, bounded to launch, and expose observable success/failure states. |
| M4-02 | Implement multiple assignable work units and resolve route/time costs at strategy scale. | **NOT STARTED** | Native tests cover two simultaneous crews, queue order, blocked work, completion, and reassignment without duplicate ownership. |
| M4-03 | Model harvest carrying/collection capacity and visible congestion feedback. | **NOT STARTED** | Load/queue stress tests conserve FFB and show an actionable message instead of silently dropping work. |
| M4-04 | Validate a deterministic 100-task workload. | **NOT STARTED** | All tasks complete or remain visibly blocked under documented capacity; no duplicate, lost, or orphan task remains. |

## M5 — Estate strategy and finance

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M5-01 | Define the four-block scenario, development choices, constraints, and opportunity costs. | **NOT STARTED** | Scenario spec includes at least two viable development orders and their measurable trade-offs. |
| M5-02 | Implement auditable cash/resource ledger categories and periodic summaries. | **NOT STARTED** | Automated reconciliation proves opening balance + inflows − outflows = closing balance for each fixture. |
| M5-03 | Implement bounded capital/operating costs and expansion decisions. | **NOT STARTED** | Insufficient-fund, repeat-purchase, and deferred-development tests prove no hidden/free transaction. |
| M5-04 | Compare strategy outcomes with transparent assumptions. | **NOT STARTED** | At least two deterministic strategy fixtures produce explainable differences in liquidity, output, and stewardship. |

## M6 — Mill, processing, and markets

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M6-01 | Specify one local outlet’s throughput, queue, acceptance, freshness/quality, and price inputs. | **NOT STARTED** | Model document defines units, limits, and scenarios; any factual inputs are sourced/reviewed. |
| M6-02 | Implement batch/vehicle-to-outlet delivery and bounded processing behavior. | **NOT STARTED** | Normal/over-capacity tests conserve kilograms and identify each batch exactly once. |
| M6-03 | Replace fixed placeholder sale with transparent transaction calculation and ledger entry. | **NOT STARTED** | Same input/seed produces same result; changing a visible input changes only documented outcomes. |
| M6-04 | Complete a traceable harvest-to-sale scenario. | **NOT STARTED** | One batch is traceable from palm/stand through delivery and processing to final ledger entry without quantity or cash mismatch. |

## M7 — Stewardship and operating risk

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M7-01 | Define protected/no-go areas and launch stewardship indicators. | **NOT STARTED** | Map/data spec identifies boundaries, units, consequences, source, and review status. |
| M7-02 | Implement bounded soil/water, habitat, fire/pest, worker, and community effects. | **NOT STARTED** | Each accepted factor has at least one tested decision, cost, and visible outcome; unsupported real-world claims are excluded. |
| M7-03 | Add mitigation choices and decision feedback. | **NOT STARTED** | Scenario tests show at least two mitigations with distinct cost/outcome trade-offs. |
| M7-04 | Complete domain/jurisdiction review of any factual legal, environmental, or welfare claim. | **NOT STARTED** | Review record exists; unreviewed rules are explicitly fictional/illustrative. |

## M8 — Onboarding, content, and presentation

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M8-01 | Design a skippable tutorial that teaches all eight layers through the bounded campaign. | **NOT STARTED** | Script and prompts are reviewed; every prompt is reachable, dismissible, and revisitable. |
| M8-02 | Implement mobile-readable objectives, forecasts, consequences, error recovery, and pause/normal/fast-forward controls. | **NOT STARTED** | Touch test at minimum resolution shows readable labels, non-color-only state cues, and no critical overlap; pause advances no logical state and all time speeds preserve deterministic outcomes. |
| M8-03 | Replace only high-value placeholders with approved art/audio from the asset plan. | **NOT STARTED** | All launch-path assets have source, license, credits, import settings, and device validation. |
| M8-04 | Run first-time usability sessions. | **NOT STARTED** | At least 4 of 5 observed testers complete the first harvest-to-sale loop and identify the next objective without developer help. |

## M9 — Persistence, reliability, and mobile performance

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M9-01 | Design a versioned local save schema and safe migration/failure behavior. | **NOT STARTED** | Schema, version policy, backup behavior, and invalid-save handling are documented before implementation. |
| M9-02 | Implement local save/load and interruption recovery. | **NOT STARTED** | Round-trip, migration, suspend/resume, low-storage, and corrupted-save tests pass without losing the prior valid save. |
| M9-03 | Profile the agreed baseline device against all mobile budgets. | **NOT STARTED** | 30-minute capture includes build/device IDs, frame time, memory, thermal state, startup, and save/load. |
| M9-04 | Optimize only measured hotspots and re-run acceptance. | **NOT STARTED** | Before/after profiler evidence shows the budget is met with no gameplay regression in the suite. |
| M9-05 | Complete compatibility and accessibility regression pass. | **NOT STARTED** | Every supported device/OS/resolution and input path has a recorded pass/fail result. |

## M10 — Release candidate and launch

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M10-01 | Freeze scope and resolve all critical/high-severity defects. | **NOT STARTED** | Signed release-candidate scope; zero open release-blocking defects. |
| M10-02 | Produce and install the signed Godot release build on supported devices. | **NOT STARTED** | Build artifact hash, install/start/offline/save/restart evidence, and device IDs are recorded. |
| M10-03 | Complete legal, privacy, licensing, credits, store/package, support, and rollback review. | **NOT STARTED** | Every applicable item in `LAUNCH_CHECKLIST.md` is checked and approved. |
| M10-04 | Run final release-candidate test matrix and authorize launch. | **NOT STARTED** | M0–M9 complete, QA evidence attached, no critical/high issue, explicit release approval recorded. |

## Change control

A new task or feature must first be placed in `FUTURE_BACKLOG` or an existing milestone and approved by the user. Record its dependency, measurable acceptance, cost/risk, and which existing scope it displaces. Update the roadmap, design, architecture, QA, and launch docs before code work begins. Never solve an unapproved scope gap by silently adding a feature.
