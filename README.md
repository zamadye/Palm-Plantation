# Palm Plantation — Prototype 0.2

A compact Godot 4 strategy/management vertical slice. The scene is an elevated, zoomable miniature plantation, not a first-person farming game. The playable loop is:

**temporary camp → starter shelter → clear forest → prepare a 4 × 4 grid → plant → accelerate growth → maintain → mature fruit → harvest FFB → collect → sell for revenue**

## Project planning and status

The authoritative roadmap, design, architecture, QA gates, and current audit status live in [`PROJECT_STATUS.md`](PROJECT_STATUS.md) and the [`docs/`](docs/) planning set. The user-directed Godot native MVP/vertical-slice gates are tracked in [`docs/GODOT_MVP.md`](docs/GODOT_MVP.md); the README remains the quick-start and implementation overview. The browser build is still a prototype, not the production game. A curated generic Nature Kit palm subset and a small CC0 vehicle/industrial visual subset are integrated as placeholders; the latter is not process simulation and neither change the open M2/M3 acceptance gates. The five existing HUD action icons remain integrated.

## Run

Open this folder as a project in **Godot 4.3 or newer** and run `scenes/main/main.tscn` (or press F6/F5 in the editor). The project uses Godot's Mobile renderer and landscape layout. No plugins are required; the selected Kenney CC0 assets and their license/provenance records are included in the repository.

## Browser preview (no Godot installation)

`web-preview/` is a separate browser-side **JavaScript/Three.js implementation** of the compact map and current gameplay loop. It runs in WebGL and mirrors the shelter, clearing, planting, maintenance, fruit development, worker harvest/delivery, FFB collection, and prototype sale systems. It is not imported from or executed by Godot.

This is **not** a converter that imports `.gd` or `.tscn` files. Browsers cannot execute GDScript or Godot scenes directly. The web preview remains a separate JavaScript simulation and Three.js renderer, but it now loads the same curated local GLBs from the repository `assets/` directory: four palm models, a tractor and pickup, and six generic industrial-yard models. The five HUD buttons also use the repository SVG icons. A small local GLB loader reads these models and their embedded/external textures; it does not need an online asset service. Forest batches, workers, shelter, crop-state FFB cues, and other gameplay markers remain procedural. Vehicles and mill-yard models are static visual proxies only—not operational machinery or process simulation.

Run from the repository root (so the preview can fetch the shared `assets/` files):

```sh
python3 web-preview/serve.py --port 8000
```

Then open `http://localhost:8000` in a WebGL 2-capable browser; the helper redirects to the preview and serves both `web-preview/` and the shared `assets/` paths. No Godot, Node.js, build step, or internet-hosted JavaScript library is needed. The local `vendor/three.min.js` file provides the WebGL renderer. Drag to pan, wheel/pinch to zoom, Q/E to rotate, and use the five bottom actions to test the browser preview's prototype loop.

The preview mirrors gameplay behavior but is a separate web implementation, not the exact Godot runtime. Run the native project in Godot 4.3+ to test the source game itself.

### Developer browser-simulation tests

Playing the static browser preview does not require Node.js. To run the separately authored simulation tests (Node.js 22+), use the built-in test runner from the repository root:

```sh
node --test web-preview/tests/*.test.mjs
```

The five simulation checks and four GLB-asset loader checks cover browser-side logic, model parsing, and mocked scene integration only; they do not validate rendered pixels, real image decoding, external-texture appearance, Godot, or mobile input.

### Deterministic native acceptance

With Godot 4.3 available, run the single native acceptance command from the repository root:

```sh
GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64 tests/godot/run_native_acceptance.sh
```

This checks the Godot version, imports/parses the project, runs the core native simulation suite (109 assertions), the focused crop-model smoke (65 checks), and the headless main-scene structural smoke (110 assertions). The M3 smoke includes an eight-model-year deterministic baseline/limited-input/stress trajectory fixture and first-harvest timing regression. The structural stage also reports the known non-fatal Dummy-renderer diagnostic. Headless results do not establish visible pixels, camera framing, HUD layout, physical mouse/touch input, or device performance. For ordinary feature iterations, run the focused model smoke and only the relevant core regression cases; do not repeat the full visual acceptance runbook for every change.

The separate external procedure for graphical startup and manual native M0/M1/M2 visual/input checks is in [`docs/EXTERNAL_NATIVE_VALIDATION.md`](docs/EXTERNAL_NATIVE_VALIDATION.md). Graphical acceptance is manual, never inferred from this deterministic command. A clean archive of the staged tree (without `.godot` caches) passes the native and browser suites; a usable visible renderer and target device remain unavailable here.

## Controls

- **BUILD / LAND / PLANT** in the bottom action bar, then tap or click the world to place or select an action.
- **Left mouse drag / one-finger drag:** pan. A short tap/click selects or confirms.
- **Mouse wheel / pinch:** zoom. The speed buttons advance the accelerated plantation clock.
- **Godot:** middle-mouse drag rotates the camera. **Browser preview:** Q / E rotate in small steps.
- Select the forest/plantation block, worker, shelter, palm, or the marked FFB collection point for its contextual panel. Palm and block actions queue worker tasks; ready mature palms expose **HARVEST**, and the collection panel exposes **SELL** when FFB is in stock.

## First playable sequence

1. Press **BUILD**. Place the green shelter outline in the camp clearing west of the road. The shelter costs $300 and 10 timber. The player and worker walk to the site; construction builds through visible 0/25/50/75/100% stages.
2. Press **LAND**, then click inside the four survey stakes east of camp—or select the block and use **CLEAR LAND**. Clearing costs $150 for crew and equipment. The worker walks to the block, enters CLEARING, and vegetation recedes progressively. On completion the state changes directly to **PREPARED LAND**.
3. The 4 × 4 planting grid appears on prepared soil. Press **PLANT**, then click an open marker. The worker walks to it, plants, and a seedling appears on completion; seedlings are consumed at that point.
4. Use the speed controls to advance the native **model calendar**. A field-planted palm moves from seedling (year 1) to young (years 2–3), reaches fruit-onset age around 30 model months, and approaches its first harvest window near 36 model months. The HUD shows year/month/day and a scenario season; palm details show stage progress, the next FFB-window estimate, health, fertilizer reserve, and pest pressure. These accelerated values are scenario assumptions, not a local growing recommendation.
5. Select a ripe palm and press **HARVEST**, or select the prepared block and harvest all available palms. This queues work; Rafi walks to the palm, performs a timed harvesting animation, and only then produces FFB.
6. Rafi carries each harvest to the small **FFB COLLECTION** point east of the field and deposits it. The contextual panel and sign show stored kilograms.
7. Select the collection point and press **SELL STORED FFB**. The prototype sells at **$1 per kg**, records a transaction, clears stored stock, and reports kilograms sold, revenue, and updated funds.
8. Harvesting does not remove the palm. After a short recovery and accelerated regrowth cycle, it develops another bunch and can be harvested again.

The native Godot crop model estimates one representative FFB lot from a scenario annual yield curve, accelerated palm age, health, pest pressure, and fertilizer reserve. Its 180 kg/palm-year peak point is a documented scenario value, not a regional forecast. The browser preview remains a separate implementation with its own older prototype values. See [`docs/CROP_MODEL.md`](docs/CROP_MODEL.md); the fixed `$1/kg` sale remains an M6 boundary, not part of M3.

Tasks have an explicit type, target, worker assignment, duration, progress, and lifecycle status. Harvest and delivery use the same reusable queue; FFB delivery is prioritized immediately after a harvest so Rafi deposits the load before taking another harvest job.

## Implementation

- **Simulation/data:** `scripts/simulation/plantation_simulation.gd` owns task order, resources, accelerated days, fruit cycles, yield, delivery, and sales. `task_record.gd`, `worker_record.gd`, `building_record.gd`, `land_zone_record.gd`, `palm_record.gd`, and `ffb_collection_record.gd` keep simulation data separate from the view.
- **Presentation:** `scripts/main.gd` coordinates input and mirrors simulation changes into visual nodes. `scripts/world/world_builder.gd` builds the test map. `scripts/world/visual_factory.gd` creates the shelter, characters, fruiting palms, FFB collection point, and props.
- **Camera/UI:** `scripts/camera/strategy_camera.gd` handles smooth strategy-camera pan, zoom and limited rotation. `scripts/ui/game_ui.gd` builds the responsive HUD and action panels.
- **World:** procedural grassland/forest palette, background forest using `MultiMeshInstance3D`, a dirt access road with static collection/mill spurs, a small pond, survey stakes, temporary camp, field props, procedural character/building geometry, curated imported palm GLBs, and one generic tractor/pickup plus a clearly marked industrial-yard visual concept.

## Assets and performance budget

The native project imports four low-poly Kenney Nature Kit palm GLBs from `assets/environment/palms/` (about 85 kB combined), plus eight Kenney vehicle/industrial GLBs and two separately referenced colormaps under `assets/environment/operations/` (722,851 bytes acquired). Godot extracts two byte-identical 12,371-byte copies from embedded vehicle images, bringing that folder's model/texture payload to 747,593 bytes before import sidecars. Five original SVG action icons remain under `assets/ui/icons/`, with the app icon at `assets/icon.svg`. The palms are generic stylized forms, not verified *Elaeis guineensis* models; the Nature Kit has no FFB model, so the game's three state-driven bunch cues remain procedural. The operation subset supplies one generic tractor, one generic pickup, and a compact, clearly marked mill-yard visual concept. It does not provide verified plantation machinery, implement vehicle logistics, or simulate/replace any A–Z process stage or material flow. Source commits, CC0 notices, checksums, scales, import settings, and limitations are recorded in `assets/environment/palms/PROVENANCE.md` and `assets/environment/operations/PROVENANCE.md`. Other world geometry is generated from built-in Godot meshes. Background forest trees are instanced; clearing-zone trees are individual lightweight meshes so they can disappear in stages. These are MVP-slice test assets, not final production art or visual acceptance evidence.

Performance was not benchmarked in this sandbox. The prototype is designed around a few MultiMesh forest batches, one directional shadow light, simple materials, and a small number of visible worker/palm nodes; actual device FPS still needs to be measured in Godot on target hardware.

## Known limitations

- One compact test map and one NPC worker; movement is direct-line prototype movement, not full pathfinding or obstacle avoidance.
- The starter shelter is a staged procedural model. Forest removal is visual progress-based hiding, not forestry physics.
- Growth is accelerated for testing; fruit cycle, health, yield, and the **$1/kg** selling price are deliberately simplified prototype rules.
- No vehicle behavior/logistics, process-specific mill machinery or mill simulation, real commodity pricing, advanced economics, save/load, multiplayer, backend, or large-estate scaling systems. The generic tractor/pickup and mill-yard geometry are static visual placeholders only.
- The native Godot crop/calendar model is an M3 implementation slice, not a completed or agronomically reviewed model. Its month-keyed cohort outlook separates ready lots from individual-age windows within the next 30 model days and reports cohort condition averages with the pest index clearly labeled. The browser simulation remains separate. The native smoke now includes an eight-model-year deterministic baseline/limited-input/stress trajectory using explicitly test-only annual fertilizer-reserve resets; those fixtures are not field prescriptions or approved agronomy. Godot 4.3 import, 109 core simulation assertions, 65 focused crop-model checks, and 110 structural smoke assertions pass in the working tree; the scene smoke checks the curated palm GLBs, all eight operation GLBs, the static-route/mill disclaimer, and procedural FFB cues structurally. Headless scene launch still emits the documented `mesh_get_surface_count` Dummy-renderer diagnostic; a standalone BoxMesh probe reproduces it. M2 rendered output/HUD/physical input and M3 qualified review/model-owner signoff remain open; target-device rendering, asset appearance, and FPS remain UNVERIFIED. Follow the external runbook for milestone closure.
