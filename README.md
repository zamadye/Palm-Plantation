# Palm Plantation — Prototype 0.2

A compact Godot 4 strategy/management vertical slice. The scene is an elevated, zoomable miniature plantation, not a first-person farming game. The playable loop is:

**temporary camp → starter shelter → clear forest → prepare a 4 × 4 grid → plant → accelerate growth → maintain → mature fruit → harvest FFB → collect → sell for revenue**

## Run

Open this folder as a project in **Godot 4.3 or newer** and run `scenes/main/main.tscn` (or press F6/F5 in the editor). The project uses Godot's Mobile renderer and landscape layout. No plugins or downloaded asset packs are required.

## Browser preview (no Godot installation)

`web-preview/` is a separate browser-side **JavaScript/Three.js implementation** of the compact map and current gameplay loop. It runs in WebGL and mirrors the shelter, clearing, planting, maintenance, fruit development, worker harvest/delivery, FFB collection, and prototype sale systems. It is not imported from or executed by Godot.

This is **not** a converter that imports `.gd` or `.tscn` files. Browsers cannot execute GDScript or Godot scenes directly. Last-Harbord's web version also implements its own JavaScript renderer/game logic; its Python server only serves static files. Palm Plantation's world assets are generated procedurally by Godot scripts, so the web preview recreates those simple shapes in Three.js modules rather than loading Godot resources.

Run from this folder:

```sh
cd web-preview
python3 -m http.server 8000 --bind 0.0.0.0
```

Then open `http://localhost:8000` in a WebGL 2-capable browser. No Godot, Node.js, build step, or internet-hosted JavaScript library is needed. The local `vendor/three.min.js` file provides the WebGL renderer. Drag to pan, wheel/pinch to zoom, Q/E to rotate, and use the five bottom actions to test the browser preview's prototype loop.

The preview mirrors gameplay behavior but is a separate web implementation, not the exact Godot runtime. Run the native project in Godot 4.3+ to test the source game itself.

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
4. Speed up time to observe **SEEDLING → YOUNG PALM → MATURE PALM**. Select a palm or the block to assign **FERTILIZE** or **TREAT PESTS** work. Fruit then develops on mature palms and becomes visibly marked when ready.
5. Select a ripe palm and press **HARVEST**, or select the prepared block and harvest all available palms. This queues work; Rafi walks to the palm, performs a timed harvesting animation, and only then produces FFB.
6. Rafi carries each harvest to the small **FFB COLLECTION** point east of the field and deposits it. The contextual panel and sign show stored kilograms.
7. Select the collection point and press **SELL STORED FFB**. The prototype sells at **$1 per kg**, records a transaction, clears stored stock, and reports kilograms sold, revenue, and updated funds.
8. Harvesting does not remove the palm. After a short recovery and accelerated regrowth cycle, it develops another bunch and can be harvested again.

Harvest yield is intentionally deterministic and simplified: a mature palm starts at 180 kg, scaled by its current health (with a 25% minimum health factor). Prices and yields are prototype values, not a real plantation budget.

Tasks have an explicit type, target, worker assignment, duration, progress, and lifecycle status. Harvest and delivery use the same reusable queue; FFB delivery is prioritized immediately after a harvest so Rafi deposits the load before taking another harvest job.

## Implementation

- **Simulation/data:** `scripts/simulation/plantation_simulation.gd` owns task order, resources, accelerated days, fruit cycles, yield, delivery, and sales. `task_record.gd`, `worker_record.gd`, `building_record.gd`, `land_zone_record.gd`, `palm_record.gd`, and `ffb_collection_record.gd` keep simulation data separate from the view.
- **Presentation:** `scripts/main.gd` coordinates input and mirrors simulation changes into visual nodes. `scripts/world/world_builder.gd` builds the test map. `scripts/world/visual_factory.gd` creates the shelter, characters, fruiting palms, FFB collection point, and props.
- **Camera/UI:** `scripts/camera/strategy_camera.gd` handles smooth strategy-camera pan, zoom and limited rotation. `scripts/ui/game_ui.gd` builds the responsive HUD and action panels.
- **World:** procedural grassland/forest palette, background forest using `MultiMeshInstance3D`, a dirt access road, a small pond, survey stakes, temporary camp, utility pickup, field props, and procedural character/building/palm geometry.

## Assets and performance budget

There are **no imported 3D models, texture packs, audio files, or source photogrammetry assets**. The only standalone asset is the 599-byte vector app icon (`assets/icon.svg`). All world geometry is generated from built-in Godot meshes at runtime. Background trees are instanced; clearing-zone trees are individual lightweight meshes so they can disappear in stages. The map and plantation block are deliberately small; the design avoids per-tree physics bodies and large textures.

Performance was not benchmarked in this sandbox. The prototype is designed around a few MultiMesh forest batches, one directional shadow light, simple materials, and a small number of visible worker/palm nodes; actual device FPS still needs to be measured in Godot on target hardware.

## Known limitations

- One compact test map and one NPC worker; movement is direct-line prototype movement, not full pathfinding or obstacle avoidance.
- The starter shelter is a staged procedural model. Forest removal is visual progress-based hiding, not forestry physics.
- Growth is accelerated for testing; fruit cycle, health, yield, and the **$1/kg** selling price are deliberately simplified prototype rules.
- No vehicles, mill/factory, real commodity pricing, advanced economics, save/load, multiplayer, backend, or large-estate scaling systems.
- All GDScript files pass `gdparse` parsing. Godot is not installed in this environment, so the native scene has not been loaded or play-tested in-engine. The independent browser simulation passed a fresh-state headless end-to-end acceptance test, and its Three.js world-sync smoke test passed; neither substitutes for a Godot runtime test. Manual browser interaction, target-device rendering, and device FPS still need verification.
