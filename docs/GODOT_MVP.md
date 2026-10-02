# Godot Native MVP Track

**Status: IN PROGRESS — not an MVP-complete or release-ready claim.** This track records the user's direction to move the current browser prototype toward a Godot-first MVP. The scope assumption for this work is a native, single-map **first-harvest vertical slice**, not completion of all eight launch layers in `ROADMAP.md`.

## Production boundary

- `project.godot`, `scenes/main/main.tscn`, GDScript, and resources under `res://` are the production path.
- `web-preview/` remains a separately authored prototype and interaction reference. It loads the same curated local GLB/SVG visual files, but is not a Godot importer, a source of production simulation state, or a production runtime.
- Do not claim an MVP pass from the browser version, headless scene graph, or a parse-only result. Native visual/input and target-device evidence are separate gates.

## MVP vertical-slice target

A fresh Godot session should support this coherent loop on one compact map:

`inspect → establish → clear/prepare → plant → advance model time → maintain → harvest → deliver → sell → repeat`

The slice keeps the current one-worker/one-block test scale and explicit scenario economy. It does not silently add markets, crews, persistence, or stewardship systems from later roadmap milestones. `$1/kg` remains a test fixture until M6.

## Current native foundation

- Godot 4.3 project, Mobile renderer setting, main scene, camera, world builder, simulation, HUD, and first-harvest loop are present.
- Five original 64 × 64 SVG action icons (`BUILD`, `LAND`, `PLANT`, `WORKERS`, `MANAGEMENT`) are integrated into native Godot buttons with text labels and are now shared with the browser HUD. Their use in the prototype does not change native acceptance status.
- Seedlings, workers, forest batches, shelter, and most field props remain lightweight procedural test visuals. Young/mature palm bodies and three distant palm landmarks use a curated subset of generic Kenney Nature Kit GLBs; FFB bunch cues remain procedural. A separate reviewed CC0 subset adds one generic tractor, one pickup, and a compact static mill-yard visual concept. These are test-art stand-ins, not verified *Elaeis guineensis* models, process-specific equipment, or accepted final art; the mill process chain remains unsimulated.
- Godot import/parse and structural scripts pass headlessly, including imported palm scenes. Dummy-renderer output does not establish the appearance of any icon, scene, or HUD.

## MVP gates still open

| Gate | Status | Evidence needed |
|---|---|---|
| Native Godot project/import | **PASS (working tree)** | Godot 4.3 editor import and project parse with no script errors. |
| First-harvest domain loop | **FUNCTIONALLY IMPLEMENTED** | Deterministic Godot simulation covers establishment, crop timing, harvest, delivery, sale fixture, and repeat cycle. This alone does not accept the UI. |
| Core action asset import/wiring | **PASS (structural only)** | All five original SVG resources import and are attached to the corresponding Godot action buttons; the scene smoke checks this. Pixel clarity remains unverified. |
| Rendered native scene and touch/readability | **UNVERIFIED** | Run the main scene on a usable non-Dummy renderer and directly inspect map, worker, palms, icon/label balance, HUD overlap, and supported input at the agreed mobile resolution. |
| Build/export platform and device baseline | **NOT SET** | M0 still needs an explicit platform/device/OS/resolution decision and an export/install smoke on that target. Do not invent a target device. |
| Mobile performance/package budget | **UNMEASURED** | Profile the actual Godot build on the agreed modest device; current budgets are limits, not results. |
| Asset completeness/provenance | **IN PROGRESS** | Four generic Kenney palm GLBs now have pinned-source/license records and pass Godot import/structural checks; FFB remains procedural. Visual acceptance, botanical specificity, mobile performance, other art completeness, and target-device validation remain open. Do not add unknown-license packs. |

## Asset integration status

1. Retain the five existing first-party action SVGs and their text labels/non-color identification; no rollback is requested.
2. The user authorized a curated four-model Nature Kit palm subset and subsequently authorized integrating the reviewed operation-visual subset under `assets/environment/operations/`. The latter is static, generic visual dressing only—not a process/vehicle simulation or a replacement for any A–Z stage. See [`ASSET_PLAN.md`](ASSET_PLAN.md), the [palm provenance](../assets/environment/palms/PROVENANCE.md), and the [operation-asset provenance](../assets/environment/operations/PROVENANCE.md) for scope, CC0 notices, import settings, and validation.
3. The imported palms are generic visual stand-ins, not species-verified oil-palm art; the kit has no FFB model, so state-driven fruit cues remain procedural. This slice does not change the M2/M3 status or acceptance criteria and does not authorize unrelated asset packs.
4. Godot import/structural checks are not visual, mobile-performance, or device acceptance. Future additions still need provenance, target-budget review, and direct validation; the browser prototype does not define native asset acceptance.

MVP remains **IN PROGRESS** until native visual/input, target-build, and asset gates have direct evidence. M2 remains **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS**; M3 remains **IN PROGRESS** pending a named owner and qualified review. Neither milestone closes from this MVP document.
