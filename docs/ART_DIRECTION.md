# Art Direction

## Intent

The visual identity is a **readable miniature estate-management diorama**: elevated camera, clear block boundaries, approachable stylized 3D forms, and enough agricultural detail to make management decisions legible on a mobile screen. The art should feel grounded and calm rather than photorealistic, toy-like, or arcade-bright.

The camera/map view is a core design tool, not a temporary placeholder for a first-person game. Production art must preserve information hierarchy and run within the modest/mobile budgets in [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md).

## Audited baseline

The current Godot world is procedurally assembled from primitive meshes and materials. It includes terrain tiles, MultiMesh background forest, road/clearing/pond, a fixed block and planting markers, procedural palms/fruit, a shelter, characters, collection point, selection indicators, and a CanvasLayer HUD. The single standalone game asset is `assets/icon.svg`. There are no imported character models, texture sets, audio files, or authored environment packs in the audited baseline.

Current geometry and palette demonstrate a prototype, not final art. Do not mark visual work complete because procedural meshes render in source code; the native renderer, mobile readability, and final art acceptance remain unverified.

## Visual principles

### 1. Read the estate at a glance

- Establish a clear hierarchy: whole estate → block → crop cohort/row → selected plant or task.
- Use silhouette, scale, outline, icon, text, and pattern together. Never make forest/cleared/prepared/at-risk states depend on hue alone.
- Keep grid rows, block limits, access routes, restricted areas, and delivery points distinct at the minimum supported zoom.
- Selection and placement feedback must remain visible against both forest and prepared soil.

### 2. Natural, restrained palette

Use a muted tropical palette: varied forest/leaf greens, warm soil browns, low-saturation stone/wood, soft sky/water, and carefully limited high-contrast operational accents. The prototype's red-orange fruit, warm worker clothing, subdued ground, and forest greens provide a starting reference, not a locked palette.

Reserve distinct accent roles for:

- valid/committed actions;
- warning, blocked, or high-risk state;
- selection and target preview;
- harvest-ready FFB and delivery status;
- protected/no-go areas.

Color must meet contrast requirements and have a second cue such as label, border pattern, symbol, animation, or shape.

### 3. Agricultural states are visible and honest

- Show crop age/stage, canopy/fruit state, stress, and harvest readiness with readable visual changes, but do not imply the model is scientifically exact.
- Show clearing as a clear, bounded state transition; do not use spectacle or reward language that glamorizes unreviewed land conversion.
- Depict protected areas, buffers, soil/water pressure, and operational limits visibly once M7 systems exist.
- A high-level map may abstract detail; a selected panel supplies the information needed to understand a decision.

### 4. Human-centered workforce representation

- Workers must be visually identifiable as people with readable roles/states and appropriate practical clothing/PPE for the fictional scenario.
- Avoid caricature, dehumanizing scale, or treating workers only as throughput icons. The UI should describe work assignments and capacity respectfully.
- Animation should communicate walking, work, carrying, waiting, or blocked state without requiring high-cost motion-capture assets.
- The current named worker, Rafi, is a prototype character; final narrative, language, and cultural representation need review before launch content is locked.

### 5. Calm interface over the world

- Keep management data in clean, high-contrast panels separated from the 3D scene.
- Use short labels, clear units, readable number formatting, large touch areas, and plain-language reasons for disabled actions.
- Avoid cluttering the map with always-visible labels; show contextual information on selection and focused tasks.
- Motion is purposeful: feedback for a state change, not continuous decorative motion that drains battery or obscures play.

## Shape, camera, and lighting

- Preserve an elevated, slightly isometric/oblique strategy view with pan and zoom. Camera controls should not fight touch selection or UI interaction.
- Use simple shapes and clean silhouettes at estate scale. Use stronger detail only for selected/nearby objects; distant rows/forest can use instancing and simplified meshes.
- Prioritize stable ambient lighting and one shadow-casting key light; avoid stacked dynamic lights and large real-time shadow ranges.
- Procedural terrain variation is acceptable when deterministic and restrained. Avoid noisy texture/detail that competes with block boundaries.
- Limit transparent layers/particles, large textures, and dense alpha foliage for mobile fill-rate and overdraw.

## Animation and feedback

- Keep animations brief and legible; long simulation time is shown by progress/clock, not long mandatory waits.
- Task progress needs both a world cue and a HUD/status cue for construction, clearing, planting, harvest, and delivery.
- Do not animate a state as complete until the simulation has committed it. Repeated notifications should be throttled or consolidated.
- Essential feedback must still work with audio disabled and reduced motion; audio/visual polish is secondary to clear text/status.

## Asset acceptance

An art asset is ready for launch only when it:

1. has a documented source and license/credit;
2. has a defined in-game scale and silhouette/readability test;
3. uses approved material/texture/import settings and naming;
4. has an LOD/instancing plan when repeated or distant;
5. is tested in Godot at the minimum supported resolution and on the baseline mobile device;
6. does not exceed the asset/performance budgets; and
7. has an accessible non-color-only state cue where it communicates gameplay.

See [ASSET_PLAN.md](ASSET_PLAN.md) for file formats, provenance, and priority. The immediate art direction is to keep procedural assets until a replacement has a measurable readability or production value; do not add asset packs merely to make the repository look finished.
