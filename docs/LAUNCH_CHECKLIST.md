# Launch Checklist

## Release posture

**Not release-ready.** M2 First Harvest is **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS**, not COMPLETE. Browser evidence includes a 151 kg first harvest, $151 revenue, $1,501 resulting funds, 342 kg delivered from a controlled two-palm block fixture, repeat-harvest readiness, and passing Three.js scene sync. The native GDScript simulation passes 109 assertions and Godot 4.3 project import/parse passes; the headless main-scene structure test passes 110 assertions. The M3 crop-model smoke passes 65 software checks, including eight-year deterministic scenario fixtures, but qualified review and named ownership are pending. Four generic CC0 palm GLBs and eight generic operation GLBs are integrated with provenance and structural checks. The operation subset is static visual dressing only; rendered appearance/mobile cost are unverified and the palms are not species-verified oil-palm art. Native rendered pixels/UI, physical input, target-device behavior, persistence, and performance remain UNVERIFIED. Do not use this checklist to imply a launch date or schedule.

The bounded launch scope is defined in [ROADMAP.md](ROADMAP.md). Godot 4.x is the production target. Android landscape is the proposed first mobile target, but the exact supported OS/device matrix must be accepted and recorded in M0. Browser shipping and iOS are not promised.

## Status vocabulary

- **NOT STARTED** — no release evidence.
- **IN PROGRESS** — active but not fully evidenced.
- **BLOCKED** — a required dependency/gate has not passed.
- **COMPLETE** — evidence exists and has been reviewed.
- **DEFERRED** — intentionally removed from launch scope by an approved decision.

Use the status in each line and link a build, test report, review, or signed decision. A feature existing in source is not a launch check.

## 1. Product and scope lock

- [x] **COMPLETE** — User authorized development following this roadmap; implementation proceeds under the documented scope and `FUTURE_BACKLOG` rule.
- [ ] **NOT STARTED** — Product name, target audience, supported language(s), store/region, and age/content rating are confirmed.
- [ ] **NOT STARTED** — Minimum supported OS/device and landscape resolution are recorded from M0.
- [x] **COMPLETE** — Four-block, one-crop, one-outlet campaign scope is frozen by the approved [roadmap](ROADMAP.md); excluded features remain subject to `FUTURE_BACKLOG` and require an approved scope change.
- [ ] **NOT STARTED** — Any real-world agronomy, finance, legal, environmental, or worker-safety claims are either reviewed with sources or clearly labeled illustrative.

## 2. Milestone and gameplay readiness

- [ ] **BLOCKED** — M0 through M9 are COMPLETE in [ROADMAP.md](ROADMAP.md), with evidence links.
- [ ] **BLOCKED** — M1 simulation acceptance passes headlessly, but the complete fresh-session flow through the visible native HUD/touch path has not been accepted.
- [ ] **BLOCKED** — M2 is FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS: the browser first cycle delivers 151 kg, sells for $151, and leaves $1,501; a controlled two-palm block delivers 342 kg; repeat readiness and browser scene sync pass. Native GDScript simulation passes 109 assertions, including the 36-model-month first-harvest boundary, and Godot import/parse passes, but native rendered pixels, HUD, and physical input remain UNVERIFIED. Browser evidence is separate; do not mark M2 COMPLETE.
- [ ] **BLOCKED** — M3 has documented scenario-only assumptions and 65 passing software checks, including eight-model-year baseline/limited-input/stress fixtures. A named model owner and qualified agronomic reviewer must still accept the sources, units/ranges, and timing before any values are treated as factual.
- [ ] **NOT STARTED** — All eight gameplay layers have at least their accepted launch-depth implementation and test coverage.
- [ ] **NOT STARTED** — No task, inventory, cash, batch, or save exploit duplicates/deletes value in the final regression suite.
- [ ] **NOT STARTED** — Campaign objectives, time controls, pause behavior, warnings, and recovery paths are complete and understandable.

## 3. Native build and platform

- [ ] **BLOCKED** — Clean Godot 4.x import passes in a fresh project copy with Godot 4.3, but release export and export settings remain UNVERIFIED; see [QA evidence](QA_PLAN.md).
- [ ] **NOT STARTED** — Signed release candidate installs and cold-starts on every supported device/OS class.
- [ ] **BLOCKED** — Main scene, camera framing, rendered HUD, touch input, app lifecycle, and offline play are not accepted on a shipped build. The headless Dummy diagnostic is classified as a non-fatal backend limitation, but it cannot verify visible rendering; no working display/GPU or target-device validation is available.
- [ ] **NOT STARTED** — Save/load, app suspend/resume, low storage, and recoverable load failure have been tested.
- [ ] **NOT STARTED** — Package name/version/icon/splash/permissions and minimum OS settings are reviewed; no unnecessary permission is requested.
- [ ] **NOT STARTED** — Final install package is at or below the approved package-size budget or an exception is approved.

## 4. Quality and performance

- [x] **COMPLETE** — Godot simulation tests pass 109 assertions, and the full native runner also passes from a clean archive of the staged tree; setup/commands are documented in the [README](../README.md) and [QA plan](QA_PLAN.md). This closes deterministic test reproducibility only, not rendered-scene or physical-input acceptance.
- [x] **COMPLETE** — Native main-scene headless structural smoke passes 110 assertions; it checks scene/runtime nodes and scripted flow, not visual rendering or physical input. See the [QA investigation](QA_PLAN.md).
- [x] **COMPLETE** — Browser evidence is labeled separately and is not substituted for Godot results: the browser first cycle measured 151 kg, $151 revenue, and $1,501 resulting funds; the controlled two-palm block delivered 342 kg; repeat readiness and Three.js scene sync pass. Manual browser rendering/input and native rendering remain separately unverified; see the [QA plan](QA_PLAN.md).
- [ ] **NOT STARTED** — 30-minute dense-estate profiling on the minimum device meets the accepted frame-time, memory, startup, save/load, input, draw-call, simulation-step, and thermal budgets.
- [ ] **NOT STARTED** — Worst-case camera, maximum accepted estate state, active task load, and open HUD have been profiled.
- [ ] **NOT STARTED** — Manual touch, readability, color-independent state cues, reduced-motion/audio-off, and first-time usability checks pass.
- [ ] **NOT STARTED** — No open critical/high-severity defect; remaining lower-severity defects have an explicit launch decision and workaround.
- [ ] **NOT STARTED** — Crash/logging behavior is useful for support but contains no unnecessary personal data or gameplay secrets.

## 5. Content, asset, and licensing readiness

- [ ] **IN PROGRESS** — The four curated palm GLBs and eight generic operation GLBs have pinned sources, CC0 notices, checksums, and import/scale records; complete launch-path asset inventory, notice packaging, final review, and visual/device acceptance remain open.
- [ ] **NOT STARTED** — Required third-party notices, including the vendored Three.js notice if the browser prototype ships, are present in the correct package.
- [ ] **NOT STARTED** — No missing, debug-only, temporary, or unlicensed asset is visible in the release path.
- [ ] **NOT STARTED** — App icon, store screenshots, description, and any trailer show the actual shipped Godot game, not the separate browser prototype as though it were the same runtime.
- [ ] **NOT STARTED** — Text, units, local terminology, names, worker representation, and any regional setting receive product/cultural review.

## 6. Legal, privacy, and store readiness

- [ ] **NOT STARTED** — Applicable store/platform policy and distribution requirements are reviewed for the selected region/platform.
- [ ] **NOT STARTED** — Privacy disclosure matches actual behavior. If no accounts, telemetry, ads, purchases, or network features ship, this is stated accurately; do not add those systems implicitly.
- [ ] **NOT STARTED** — App age/content rating and agricultural/educational disclaimers are accurate and approved.
- [ ] **NOT STARTED** — Credits, trademark/product name, fonts, audio, code, and visual asset notices are complete.
- [ ] **NOT STARTED** — Support contact, known-issues text, versioning, and rollback/revocation procedure are ready.

## 7. Release candidate and authorization

- [ ] **NOT STARTED** — A release-candidate build is immutable, identified by commit/build hash, and tested on the final device matrix.
- [ ] **NOT STARTED** — QA report links every pass/fail/not-run result, including device/OS, test data, and engine version.
- [ ] **NOT STARTED** — No unreviewed scope, factual model, or license exception remains.
- [ ] **NOT STARTED** — Product owner explicitly authorizes launch after all required gates pass.
- [ ] **NOT STARTED** — Launch package, support/rollback materials, and final release notes are archived with the build.

## Current blocked items

1. The headless mesh diagnostic is classified: Godot 4.3 `--headless` selects the Dummy renderer; the main-scene run logs 264 non-fatal `mesh_get_surface_count` messages and exits 0, and a minimal standalone BoxMesh project reproduces it. No production workaround was applied because this does not establish a visible-renderer defect.
2. Import, main-scene startup, and 110 structural/runtime smoke assertions pass, but rasterized 3D/UI, camera framing, physical mouse/touch, and visible interaction remain UNVERIFIED. X11/OpenGL software fallback cannot start in this environment.
3. M2 is FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS. Browser metrics/repeat readiness/scene sync, native GDScript simulation, and Godot import pass; the remaining M2 blocker is visible native main-scene acceptance (rendered pixels, HUD presentation, and physical input) on a usable non-Dummy renderer. No target device, save/load, performance profile, release build/export, or supported OS matrix is established.
4. The browser suite validates only the separate browser prototype; its ad-hoc Three.js scene-sync smoke passes, but manual browser rendering/input remains unverified and cannot close native acceptance.
