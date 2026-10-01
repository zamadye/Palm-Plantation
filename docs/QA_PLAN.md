# Quality Assurance Plan

## Purpose and release rule

QA evidence must identify **which runtime was tested**. Browser/Three.js results do not validate Godot GDScript, `.tscn` resources, Mobile-renderer behavior, touch handling, or Android performance. A code change alone never completes a milestone.

**M2 First Harvest is the current milestone and is not COMPLETE.** The repository now has both browser-side and native GDScript simulation suites, but neither replaces a visible main-scene/UI run. Keep Godot logic, Godot scene/rendering, and browser results separate; M2 still requires the remaining native integration and edge-case gates.

## Result vocabulary

- **PASS** — the stated test ran in the stated environment and met its assertions.
- **FAIL / BROKEN** — a reproducible test violated an assertion; include reproduction and logs.
- **NOT RUN** — no result exists.
- **UNVERIFIED** — source/code exists but the required runtime/device/acceptance test was not performed.
- **PASS (ad-hoc)** — a one-off test passed, but its script/environment is not committed and another developer cannot yet reproduce it reliably. It cannot close a release gate that requires repeatability.

Report browser, Godot headless, Godot editor/native play, and mobile-device results in separate columns/issues.

## Current audit evidence

Baseline: code commit `e6c3ef39512573c2eb2ee481bbdc260b1a7051c7` on `arena/01a0f46d-palm-plantation`.

| Check | Current result | What it proves / does not prove |
|---|---|---|
| `gdparse` over every `scripts/**/*.gd` | **PASS (ad-hoc)** | GDScript grammar parsed using an ephemeral `gdtoolkit` environment. Does not prove Godot type/resource loading, signal wiring, scene startup, or runtime behavior; parser version is not pinned. |
| Godot 4.3 clean editor import | **PASS (repeatable)** | `godot --headless --editor --path . --quit` passes on a fresh project copy with no script parse errors. |
| Native Godot simulation acceptance | **PASS (headless/domain only)** | `godot --headless --path . --script res://tests/godot/simulation_acceptance.gd` prints `PASS: 83 native simulation assertions`; it covers establishment, all slots, two harvests, delivery, and two sales without loading the visual scene. |
| `node --check` on browser simulation, main, world, and test modules | **PASS** | JavaScript syntax only. |
| Browser simulation Node suite | **PASS (repeatable, browser-only)** | `node --test web-preview/tests/simulation.test.mjs` passes 5/5 tests, including two harvest/delivery/sale cycles. This tests JavaScript simulation logic, not the browser UI or Godot. |
| Browser Three.js world-sync smoke | **PASS (ad-hoc/headless)** | Verified procedural scene objects, ready fruit bunches, worker load visibility, collection quantity, and selection state using a lightweight DOM stub. No real browser rendering/input was tested. |
| Browser static HTTP smoke | **PASS (ad-hoc/local)** | Entry page, JS modules, CSS, and vendored Three.js responded with HTTP 200 from a local static server. No WebGL/browser compatibility or touch behavior was tested. |
| Headless main scene under Dummy renderer | **BROKEN (renderer-specific diagnostic)** | Godot exits 0 but logs `mesh_get_surface_count` null errors for MeshInstances; a standalone BoxMesh probe reproduces the same diagnostic. No script errors appear after type fixes; visible rendering is not tested. |
| `git diff --check` | **PASS** | Whitespace/error-marker check only. Re-run after changes. |
| Native rendered main-scene gameplay, signals, touch/UI, renderer | **NOT RUN / UNVERIFIED** | No desktop display/GPU or target device is available. The headless simulation runner does not load the main scene. |
| Manual browser WebGL interaction/layout | **NOT RUN / UNVERIFIED** | No actual browser acceptance in this audit. |
| Minimum mobile device, FPS, memory, thermal, save/load | **NOT RUN / UNVERIFIED** | No target device, save system, or profiler evidence. |
| Tracked tests/CI | **PARTIAL** | Browser Node and native GDScript simulation suites are tracked. No rendered-scene automation or CI workflow exists; parser, Three.js world-sync, and static HTTP checks remain ad hoc. |

Both simulation suites are repeatable from the repository. M2 is still not COMPLETE because main-scene/UI integration, remaining edge cases, and device acceptance are outstanding.

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

It currently passes 83 assertions on the simulation records and task flow. It does not load `scenes/main/main.tscn`, so it cannot verify the world renderer, HUD, input, or touch integration.

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

A Node built-in test suite now lives at `web-preview/tests/simulation.test.mjs`; run it from the repository root with:

```sh
node --test web-preview/tests/simulation.test.mjs
```

It currently checks fresh-state setup, one-time shelter/clearing costs, all sixteen planting reservations, maintenance inventory reservation, not-ready/duplicate harvest requests, worker movement/work state, delivery priority, FFB/cash conservation, and a completed second harvest/delivery/sale cycle. Extend it with cancellation/blocking, rounding, multiple-ready-palm, and broader queue edge cases. These tests exercise browser-side JavaScript simulation only. Next add real-browser rendering/input coverage for WebGL, drag/touch, and layout; label every result **Browser**. Browser results cannot satisfy N-01–N-08.

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
