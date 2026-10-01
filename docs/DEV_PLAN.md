# Development Plan and Task Status

## Rules

This plan turns [ROADMAP.md](ROADMAP.md) into gated tasks. It is not permission to begin gameplay work: **do not implement or change gameplay until the user accepts the documentation baseline.** Before acceptance, the only allowed work is documentation review/correction and non-gameplay repository hygiene requested by the user.

Task statuses are controlled values:

- **NOT STARTED** — no execution evidence yet.
- **IN PROGRESS** — active, but its completion evidence is incomplete.
- **BLOCKED** — cannot proceed until a named dependency is resolved.
- **COMPLETE** — its measurable evidence exists and all listed checks pass.
- **DEFERRED** — explicitly moved out of the approved scope through a recorded decision.

A feature can exist while its validation task is BLOCKED. Do not mark a task COMPLETE because code exists, a parser accepts it, or the separate browser prototype passes. Do not assign dates or silently expand scope. Status updates should link to a test command, report, or review decision.

## Current execution order

1. Complete documentation review/acceptance (M0).
2. Make a Godot 4.3+ import/main-scene check reproducible and name the supported device baseline.
3. Validate M1 establishment on the native Godot project.
4. Complete the native M2 First Harvest acceptance suite; keep browser evidence separate.
5. Only then begin accepted M3+ scope, in roadmap order.

The branch baseline under review is `e6c3ef39512573c2eb2ee481bbdc260b1a7051c7`. The browser prototype is separately authored and cannot complete a Godot task.

## M0 — Direction, scope, and production validation foundation

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M0-01 | Review and accept/revise the roadmap, eight gameplay layers, bounded launch scope, architecture, and no-scope-growth rule. | **COMPLETE** | User instructed development to start following this roadmap; work proceeds under the documented scope unless revised. |
| M0-02 | Run a clean Godot 4.3+ import and launch `scenes/main/main.tscn`; capture engine output. | **IN PROGRESS** | A clean-copy editor import passes with Godot 4.3 and no script errors. Headless main-scene launch reports `mesh_get_surface_count` null errors from the Dummy renderer (reproduced with a standalone BoxMesh); a real rendering/display run is still required. |
| M0-03 | Add a repository-backed, repeatable native test command and document its setup. | **COMPLETE** | `tests/godot/simulation_acceptance.gd` passes 83 assertions on a clean project copy using the Godot 4.3 binary provided in the branch. README/QA instructions record the command. |
| M0-04 | Choose and record minimum mobile device/OS, landscape resolution, and profiling procedure. | **NOT STARTED** | Device/build IDs and baseline test procedure recorded; no device is assumed from the current project setting alone. |

## M1 — Estate establishment (existing code; native validation debt)

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M1-01 | Exercise shelter placement, invalid sites, prerequisites, construction, and one-time costs in native Godot. | **COMPLETE** | `tests/godot/simulation_acceptance.gd` verifies valid/invalid placement, prerequisites, task completion, and exact one-time balance/inventory changes. This covers simulation behavior, not the rendered UI. |
| M1-02 | Exercise clearing prerequisites, exactly-once charge, progress, prepared state, and repeat/invalid requests. | **COMPLETE** | The native simulation suite covers pre-shelter rejection, out-of-block rejection, valid/duplicate clearing, exact cost, progress, and final PREPARED state. |
| M1-03 | Exercise the 4 × 4 planting grid, all 16 slots, reservations, resource consumption, and invalid indices. | **COMPLETE** | The native suite fills all sixteen slots and verifies unique palm IDs, slot IDs, world positions, exact seedling consumption, and duplicate/out-of-range rejection. |
| M1-04 | Verify the establishment flow with the mobile HUD and touch input at the agreed minimum resolution. | **BLOCKED** | Recorded manual run on the M0 device; buttons, details, and placement feedback remain usable without overlap or dead tap areas. |

## M2 — First Harvest (**current milestone**)

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M2-01 | Convert the ad-hoc browser E2E flow into a checked-in, fresh-state test with deterministic assertions. | **COMPLETE** | `node --test web-preview/tests/simulation.test.mjs` passes the committed browser-only suite (5/5 tests); native acceptance remains separate. |
| M2-02 | Complete the readiness-gate, duplicate-reservation, task-queue, and worker-state test matrix. | **IN PROGRESS** | Not-ready and duplicate requests, worker walking/harvesting, and post-harvest delivery priority are asserted; cancellation/blocking and remaining transition cases remain. |
| M2-03 | Execute first harvest → collection → sale → repeat harvest in the native Godot project. | **IN PROGRESS** | The native GDScript simulation harness passes the two-harvest, delivery, sale, and exact balance path. Main-scene/UI integration and a real renderer run are still unverified. |
| M2-04 | Complete conservation and accounting coverage: palm yield = worker load = deposited stock = sold quantity; sale is applied once. | **IN PROGRESS** | Browser and native suites now verify two single-palm batches, delivered/sold quantity, sale revenue, and duplicate-sale behavior; zero/rounding/multiple-ready edge cases remain. |
| M2-05 | Perform separate manual browser visual/input acceptance and label the result Browser-only. | **NOT STARTED** | Manual acceptance should cover click/drag, zoom, action bar, detail panels, harvest/sale, and WebGL rendering; it cannot close native M2-03. |
| M2-06 | Complete second crop-cycle and task delivery-priority coverage in both test harnesses. | **COMPLETE** | Both browser and native simulation suites complete a second harvest, verify that delivery follows harvest, and reconcile the second sale. |

**M2 stop rule:** M2 cannot be COMPLETE until M2-02/M2-03/M2-04 pass and the native main-scene interaction/rendering path is validated. M2-01 and M2-06 close browser/native simulation-test tasks only; browser or headless simulation success alone does not complete the milestone.

## M3 — Credible crop and agronomy model

| ID | Task | Status | Completion evidence |
|---|---|---|---|
| M3-01 | Define the accelerated calendar, crop stages, cohorts, harvest windows, and units with domain sources. | **NOT STARTED** | Model note lists each parameter, range, source, uncertainty, and whether it is factual or scenario-only. |
| M3-02 | Replace or explicitly scenario-label prototype growth, fruit, health, pest, fertilizer, and yield parameters. | **NOT STARTED** | Data-driven values match the reviewed model note; no prototype value is presented as a real-world recommendation. |
| M3-03 | Build deterministic baseline, low-input, and stress-case agronomy fixtures. | **NOT STARTED** | Automated tests assert state validity and documented directional changes under the same seed. |
| M3-04 | Review agricultural claims, units, and in-game time compression with a qualified reviewer. | **NOT STARTED** | Review record and corrections are linked from the model documentation; unsupported claims are removed or labeled. |

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
