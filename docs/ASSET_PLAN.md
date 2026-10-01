# Asset Plan

## Asset inventory (audited code baseline)

| Category | Current asset/state | Notes |
|---|---|---|
| App icon | `assets/icon.svg` (599 bytes per repository README) | Only standalone game art asset found. |
| Terrain/world | Procedural Godot geometry/materials in `scripts/world/world_builder.gd` | Ground, road, clearings, pond, stakes, props, and markers are generated in code. |
| Forest | Three batched `MultiMeshInstance3D` groups plus a few procedural palms | No forest model/texture pack; current appearance and draw cost are not device-validated. |
| Crop/palms/fruit | Procedural meshes in `scripts/world/visual_factory.gd` | Growth/fruit states are represented by shape/colour changes; not final art or agronomy evidence. |
| People/shelter/collection | Procedural meshes/primitive parts | One player avatar, one named worker, one starter shelter, one collection point. No animation/audio source assets. |
| UI | Godot controls, theme values, and text/icons created in GDScript | No imported font or icon library identified. Mobile readability is unverified. |
| Browser rendering | `web-preview/vendor/three.min.js` (603,445 bytes) with `web-preview/THREE-LICENSE.txt` | Vendored dependency for the separate browser prototype; retain its license and keep it distinct from Godot production assets. |
| Textures/materials | No standalone texture set identified | Most material appearance is assigned procedurally. |
| Audio | None identified | No music, ambience, voice, or effects in the audited baseline. |
| Asset provenance | No imported pack/source files identified | Future non-original assets need a provenance/credit record before use. |

The asset inventory describes the repository, not a commitment that procedural art is final.

## Strategy

- **Prefer original, lightweight, consistent assets.** Retain procedural meshes where they provide readable management information cheaply. Replace a placeholder only when a tested asset improves clarity, accessibility, or production quality enough to justify size and performance cost.
- **Keep gameplay view scalable.** The strategy simulation targets block/cohort abstraction. Use instanced rows/vegetation for distant views and individual detailed objects only for selected or near-camera subjects.
- **Avoid large packs and unreviewed downloads.** No asset pack, model, font, sound, or texture is to be added solely to fill space. Every external file needs a source, license, attribution requirement, allowed-platform scope, and redistribution check.
- **Prefer original/commissioned or clearly redistributable sources.** Do not use scraped images, unknown-license assets, or vendor demo files in a release build. For fonts, verify embedding and redistribution rights. For audio, verify both composition and recording rights.
- **Keep source and engine import predictable.** For authored 3D assets use glTF 2.0/GLB unless a measured need justifies another format. Keep editable source files where they are required for rights/maintenance; keep generated/exported files within repository size conventions. Use Godot import compression/LOD settings proven on the target device.
- **Do not duplicate visual authority.** Godot assets/views are production. Any browser recreation remains a separate prototype asset set and must not be mistaken for shared scene data.

## Planned asset groups and priority

| Priority / milestone | Asset group | Plan and exit condition |
|---|---|---|
| P0 — M0/M1/M2 | Current procedural kit | Keep the existing map, palms, characters, shelter, collection point, and HUD as test art. Fix only clarity defects required to validate the accepted M1/M2 flow; record visual issues separately from unverified runtime. |
| P1 — M3 | Crop/cohort state visuals | Define a compact set of stages, health/risk indicators, fruit states, and season/environment cues from the reviewed model. Visualize uncertainty/status without implying scientific precision. |
| P1 — M4 | Crew/operation feedback | Improve worker role/state silhouettes and task/progress indicators. Keep animations lightweight; do not add a detailed skeletal rig unless profiling and usability justify it. |
| P1 — M5/M6 | Estate blocks, route, outlet/mill | Add only the map structures required by the four-block launch scenario and the single local processing route. Reuse modules and materials; build for zoomed-out legibility. |
| P1 — M7 | Stewardship/risk map overlays | Create non-color-only protected-area, water/soil, habitat, and hazard cues tied to tested rules. Use patterns/icons/borders as secondary encodings. |
| P1 — M8 | Final environment/character/UI polish | Replace only placeholders that fail readability or quality acceptance. Build a coherent limited palette, UI icon set, and any necessary animation/feedback assets. |
| P2 — M8 (optional) | Audio | If approved, add a small optional ambient bed and concise action/UI cues. No voice content is required for the launch baseline; audio must be mixable/mutable and not carry essential information. |
| P1 — M10 | App/package art | Final icon, splash/launch imagery, store screenshots, and credits only after scope, licensing, and final UI are locked. |

Priority numbers do not define calendar timing. A milestone gate, not a date, controls when assets are commissioned or imported.

## Asset budget and mobile constraints

Use the provisional budgets in [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md) as the technical authority. Asset-specific rules:

- Keep the initial installed package target at or below 150 MiB, including runtime and launch content; profile before approving any exception.
- Avoid full-resolution unique textures for repeated vegetation. Prefer shared materials, procedural colour, instancing, and compact mipmapped/compressed textures where supported.
- Repeated palms/forest should use instancing/LOD or a deliberate impostor strategy; avoid one physics body or an expensive unique material per tree.
- Keep the number of real-time shadow casters low; the current baseline is one shadowed key light plus a non-shadow fill light.
- Prefer low-poly silhouettes, baked/static detail, and limited transparency over expensive foliage shaders/particles.
- Font size, icon contrast, asset silhouette, and texture detail must be checked at the minimum supported screen resolution, not only desktop editor zoom.
- Track generated versus hand-authored source and test worst-case camera distance/rotation. No per-frame asset construction for a large estate.

These are limits to test, not current measured results.

## Provenance and license register

Before an external asset is merged, add a record containing:

- asset ID/name and repository path;
- creator, source URL/vendor, acquisition date if relevant, and original/editable source location;
- exact license/version and required attribution/notice;
- permission for modification, mobile distribution, and inclusion in a commercial package;
- modifications and tools used;
- engine import settings and platforms tested;
- reviewer and acceptance status.

Keep third-party notices beside the dependency/asset when practical and include required notices in the final package. The existing Three.js license remains with the browser vendor file; do not assume it licenses any separate visual content.

## Do not add yet

Until M8 and explicit approval, do not add a large commercial environment pack, photogrammetry, high-resolution PBR terrain set, voice-over, elaborate character rigs, or decorative assets that do not support the strategy loop. Do not add assets with uncertain provenance. Asset scope changes follow the same `FUTURE_BACKLOG` review rule as gameplay.
