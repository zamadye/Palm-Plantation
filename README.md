# Palm Plantation — Prototype 0.1

A compact Godot 4 strategy/management vertical slice. The scene is an elevated, zoomable miniature plantation, not a first-person farming game. The playable loop is:

**temporary camp → build starter shelter → clear one forest block → prepare planting rows → plant palms → accelerated growth and maintenance**

## Run

Open this folder as a project in **Godot 4.3 or newer** and run `scenes/main/main.tscn` (or press F6/F5 in the editor). The project uses Godot's Mobile renderer and landscape layout. No plugins or downloaded asset packs are required.

## Browser preview (no Godot installation)

`web-preview/` is a small browser-side **JavaScript/Three.js port** of the Prototype 0.1 view and core loop, modeled on the no-Godot web approach in Last-Harbord. It uses WebGL in the browser and the same map layout, actions, resources, worker, shelter, rows, palms, and growth sequence.

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
- **Middle mouse drag:** limited camera rotation. **Q / E** rotate in small steps.
- Select a worker or palm in the world for its status panel. Palm actions include **FERTILIZE**, **INSPECT**, and **TREAT PESTS**.

## First playable sequence

1. Press **BUILD**. Place the green shelter outline in the camp clearing west of the road. The starting shelter costs $300 and 10 timber. The player and worker walk to the site; construction builds through visible 0/25/50/75/100% stages.
2. Press **LAND**, then click inside the four survey stakes east of camp. The worker walks there and clears the marked forest block; trees disappear around the work area as progress advances.
3. Press **PREPARE** (the contextual LAND button after clearing). The worker lays out four planting rows with 16 evenly spaced positions.
4. Press **PLANT**, then click open row markers. Orders queue for the worker, and seedlings appear when each planting job finishes.
5. Select a palm to inspect its age, growth stage, health, fertilizer, and pest state. Maintenance is performed by the worker. Speed up time to observe seedling → young → developing → mature visual stages.

## Implementation

- **Simulation/data:** `scripts/simulation/plantation_simulation.gd` owns task order, resources, accelerated days, growth, worker records, and land-zone state. `worker_record.gd`, `building_record.gd`, `land_zone_record.gd`, and `palm_record.gd` are data-only records.
- **Presentation:** `scripts/main.gd` coordinates input and mirrors simulation changes into visual nodes. `scripts/world/world_builder.gd` builds the test map. `scripts/world/visual_factory.gd` creates the shelter, characters, palms, and props.
- **Camera/UI:** `scripts/camera/strategy_camera.gd` handles smooth strategy-camera pan, zoom and limited rotation. `scripts/ui/game_ui.gd` builds the responsive HUD and action panels.
- **World:** procedural grassland/forest palette, background forest using `MultiMeshInstance3D`, a dirt access road, a small pond, survey stakes, temporary camp, utility pickup, field props, and procedural character/building/palm geometry.

## Assets and performance budget

There are **no imported 3D models, texture packs, audio files, or source photogrammetry assets**. The only standalone asset is the 599-byte vector app icon (`assets/icon.svg`). All world geometry is generated from built-in Godot meshes at runtime. Background trees are instanced; clearing-zone trees are individual lightweight meshes so they can disappear in stages. The map and plantation block are deliberately small; the design avoids per-tree physics bodies and large textures.

Performance was not benchmarked in this sandbox. The prototype is designed around a few MultiMesh forest batches, one directional shadow light, simple materials, and a small number of visible worker/palm nodes; actual device FPS still needs to be measured in Godot on target hardware.

## Known limitations

- One compact test map and one NPC worker; movement is direct-line prototype movement, not full pathfinding or obstacle avoidance.
- The starter shelter is a staged procedural model. Forest removal is visual progress-based hiding, not forestry physics.
- Growth is accelerated for testing; health and pest changes are intentionally simplified.
- No save/load, harvesting economy, mill, multiplayer, backend, or large-estate scaling systems yet.
- The GDScript files passed a `gdtoolkit` parser check, but this environment does not have Godot installed, so the native scene has not been loaded or play-tested in-engine. The browser preview is a separate JavaScript implementation and does not validate Godot runtime behavior. Target-device FPS also remains unmeasured.
