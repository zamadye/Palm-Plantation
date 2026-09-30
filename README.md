# Palm Plantation — Prototype 0.1

A compact Godot 4 strategy/management vertical slice. The scene is an elevated, zoomable miniature plantation, not a first-person farming game. The playable loop is:

**temporary camp → build starter shelter → clear one forest block → prepare planting rows → plant palms → accelerated growth and maintenance**

## Run

Open this folder as a project in **Godot 4.3 or newer** and run `scenes/main/main.tscn` (or press F6/F5 in the editor). The project uses Godot's Mobile renderer and landscape layout. No plugins or downloaded asset packs are required.

## Browser preview (the actual Godot game)

This is a **Godot WebGL export**, not a separate JavaScript recreation. Godot exports the same project and main scene to HTML, JavaScript, WebAssembly, and game data; the Python helper serves those generated files over HTTP.

1. Install **Godot 4.3+** and the matching Web export templates.
2. From this folder run `python3 scripts/preview_web.py` (or pass `--godot /path/to/godot`; `GODOT_BIN` is also supported).
3. Open `http://localhost:8000` in a WebGL 2-capable browser. Use `--port 8080` to change the port.

The committed `Web` preset writes generated files to `build/web/` (ignored by Git). `scripts/preview_web.py --serve-only` serves an existing export without rebuilding it. The project keeps its Mobile renderer for the native game and selects Godot's Compatibility renderer for the Web platform, which is required for WebGL. Web export/runtime verification still requires a local Godot installation with matching templates.

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
- The GDScript files passed a `gdtoolkit` parser check, but this environment did not have a Godot executable or Web export templates. Neither the native scene nor the WebGL export could be run here, so a full playthrough and FPS measurement remain unverified. Use the browser-preview steps above on a machine with Godot 4.3+ and matching templates.
