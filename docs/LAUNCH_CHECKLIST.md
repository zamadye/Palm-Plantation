# Launch Checklist

## Release posture

**Not release-ready.** The audited project is a prototype. M2 First Harvest is current but not COMPLETE; browser-side checks pass ad hoc, while Godot native runtime, target-device behavior, persistence, and performance remain UNVERIFIED. Do not use this checklist to imply a launch date or schedule.

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
- [ ] **NOT STARTED** — Four-block, one-crop, one-outlet campaign scope is frozen; every excluded feature is kept out of release work.
- [ ] **NOT STARTED** — Any real-world agronomy, finance, legal, environmental, or worker-safety claims are either reviewed with sources or clearly labeled illustrative.

## 2. Milestone and gameplay readiness

- [ ] **BLOCKED** — M0 through M9 are COMPLETE in [ROADMAP.md](ROADMAP.md), with evidence links.
- [ ] **BLOCKED** — M1 fresh-session establishment flow passes in the native Godot build.
- [ ] **BLOCKED** — M2 native first harvest → delivery → sale → repeat cycle passes reproducibly; browser evidence is separate.
- [ ] **NOT STARTED** — All eight gameplay layers have at least their accepted launch-depth implementation and test coverage.
- [ ] **NOT STARTED** — No task, inventory, cash, batch, or save exploit duplicates/deletes value in the final regression suite.
- [ ] **NOT STARTED** — Campaign objectives, time controls, pause behavior, warnings, and recovery paths are complete and understandable.

## 3. Native build and platform

- [ ] **BLOCKED** — Clean Godot 4.x import and release export succeed from a clean checkout; engine version and export settings are documented.
- [ ] **NOT STARTED** — Signed release candidate installs and cold-starts on every supported device/OS class.
- [ ] **NOT STARTED** — Main scene, camera, HUD, touch input, app lifecycle, and offline play work on the exact shipped build.
- [ ] **NOT STARTED** — Save/load, app suspend/resume, low storage, and recoverable load failure have been tested.
- [ ] **NOT STARTED** — Package name/version/icon/splash/permissions and minimum OS settings are reviewed; no unnecessary permission is requested.
- [ ] **NOT STARTED** — Final install package is at or below the approved package-size budget or an exception is approved.

## 4. Quality and performance

- [ ] **BLOCKED** — Repository-backed Godot tests and documented clean-checkout commands pass.
- [ ] **NOT STARTED** — Browser test results are separately labeled; they are not substituted for Godot results.
- [ ] **NOT STARTED** — 30-minute dense-estate profiling on the minimum device meets the accepted frame-time, memory, startup, save/load, input, draw-call, simulation-step, and thermal budgets.
- [ ] **NOT STARTED** — Worst-case camera, maximum accepted estate state, active task load, and open HUD have been profiled.
- [ ] **NOT STARTED** — Manual touch, readability, color-independent state cues, reduced-motion/audio-off, and first-time usability checks pass.
- [ ] **NOT STARTED** — No open critical/high-severity defect; remaining lower-severity defects have an explicit launch decision and workaround.
- [ ] **NOT STARTED** — Crash/logging behavior is useful for support but contains no unnecessary personal data or gameplay secrets.

## 5. Content, asset, and licensing readiness

- [ ] **NOT STARTED** — Every launch-path asset has a source, license, attribution, modification record, and mobile redistribution permission.
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

1. Roadmap authorization is recorded; any new or unroadmapped feature still requires a scope change.
2. Godot is not installed in the environment and official release-asset downloads fail at the asset CDN; project import, native play, and release export are UNVERIFIED.
3. M1 and M2 native acceptance suites are not repository-backed or executed.
4. No target device, save/load, performance profile, release build, or supported OS matrix has been established.
5. The checked-in browser simulation suite validates only the separate browser prototype; browser rendering/input and Godot remain unverified.
