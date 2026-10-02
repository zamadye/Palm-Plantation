# Asset Plan

## Asset inventory (audited code baseline)

| Category | Current asset/state | Notes |
|---|---|---|
| App icon | `assets/icon.svg` | Original vector icon used by the Godot project. |
| Native UI action icons | `assets/ui/icons/{build,land,plant,workers,management}.svg` | Original 64 × 64 SVG set now integrated into Godot's five primary action buttons; text labels remain visible for non-color-only identification. |
| Terrain/world | Procedural Godot geometry/materials in `scripts/world/world_builder.gd` | Ground, road, clearings, pond, stakes, props, and markers are generated in code; three edge landmarks use curated generic palm GLBs. |
| Forest | Three batched `MultiMeshInstance3D` groups plus three imported landmark palms | Background forest stays procedural/instanced; landmark palm silhouettes use the selected Nature Kit subset. Appearance and draw cost are not device-validated. |
| Crop/palms/fruit | Procedural seedling and fruit cues plus curated young/mature palm GLBs in `scripts/world/visual_factory.gd` | Four generic palm forms are scaled/re-tinted at runtime; FFB bunches remain procedural and state-driven. The GLBs are not verified *Elaeis guineensis* art or agronomy evidence. |
| People/shelter/collection | Procedural meshes/primitive parts | One player avatar, one named worker, one starter shelter, and one collection point. No character animation/audio source assets. |
| Field transport / local-mill visuals | Eight imported generic Kenney GLBs plus two colormaps under `assets/environment/operations/` | One static tractor, one generic pickup, and one small mill-yard preview; visuals only, not operational equipment claims or process-stage implementation. |
| UI | Godot controls and theme values in GDScript; five original first-party SVG action icons under `assets/ui/icons/` | SVGs are native Godot resources; action text is retained alongside shapes. No third-party font/icon dependency added. Pixel legibility and mobile layout remain unverified. |
| Browser rendering | Vendored Three.js (`web-preview/vendor/three.min.js`) plus the local GLB loader; shared palm/operations GLBs and SVG icons resolve from repository `assets/` | Browser prototype now displays the same reviewed files without duplicating them. GLB hierarchy parsing is structurally tested; browser raster output and external texture appearance remain a separate visual check. Retain the Three.js license. |
| Textures/materials | No broad standalone production texture set identified | Production material appearance is mostly procedural. Two Kenney color maps (23,799 bytes total) are imported only as dependencies of the integrated generic City/Factory Kit visual placeholders; they do not constitute a full process-art texture set. |
| Audio | None identified | No music, ambience, voice, or effects in the audited baseline. |
| Asset provenance | App/action icons are original in-repository SVGs; four Kenney Nature Kit palm GLBs are under `assets/environment/palms/`; eight Kenney vehicle/industrial GLBs and two dependency textures are under `assets/environment/operations/`. | Palm and operations provenance/license records stay beside their production assets. The operations subset is integrated only as static generic visual proxies; it is not final art or process simulation. |

The asset inventory describes the repository, not a commitment that procedural art is final.

## Strategy

- **Prefer original, lightweight, consistent assets.** Retain procedural meshes where they provide readable management information cheaply. Replace a placeholder only when a tested asset improves clarity, accessibility, or production quality enough to justify size and performance cost.
- **Keep gameplay view scalable.** The strategy simulation targets block/cohort abstraction. Use instanced rows/vegetation for distant views and individual detailed objects only for selected or near-camera subjects.
- **Avoid large packs and unreviewed downloads.** No asset pack, model, font, sound, or texture is to be added solely to fill space. Every external file needs a source, license, attribution requirement, allowed-platform scope, and redistribution check.
- **Prefer original/commissioned or clearly redistributable sources.** Do not use scraped images, unknown-license assets, or vendor demo files in a release build. For fonts, verify embedding and redistribution rights. For audio, verify both composition and recording rights.
- **Keep source and engine import predictable.** For authored 3D assets use glTF 2.0/GLB unless a measured need justifies another format. Keep editable source files where they are required for rights/maintenance; keep generated/exported files within repository size conventions. Use Godot import compression/LOD settings proven on the target device.
- **Do not duplicate visual authority.** Godot remains the production runtime and source of scene/gameplay behavior. The browser prototype reuses approved source GLBs/SVGs for presentation, but has its own scene construction and simulation; it does not share Godot scene data or establish native acceptance.

## Planned asset groups and priority

| Priority / milestone | Asset group | Plan and exit condition |
|---|---|---|
| P0 — M0/M1/M2 | Current test-art kit | Keep the existing map, characters, shelter, collection point, and HUD as test art. Palm bodies now mix procedural seedling art with the curated young/mature GLB subset; FFB remains procedural. Fix only roadmap-aligned clarity defects and keep visual acceptance separate from structural tests. |
| Existing bundle — retained | Native action icon kit | Five first-party SVG icons for BUILD/LAND/PLANT/WORKERS/MANAGEMENT are integrated into the Godot HUD with persistent text labels. Keep them; no rollback is requested. |
| P1 — M3 | Crop/cohort state visuals | Define a compact set of stages, health/risk indicators, fruit states, and season/environment cues from the reviewed model. Visualize uncertainty/status without implying scientific precision. |
| P1 — M4 | Crew/operation feedback | Improve worker role/state silhouettes and task/progress indicators. Keep animations lightweight; do not add a detailed skeletal rig unless profiling and usability justify it. |
| P1 — M5/M6 | Estate blocks, route, outlet/mill | Add only the map structures required by the four-block launch scenario and the single local processing route. Reuse modules and materials; build for zoomed-out legibility. |
| P1 — M7 | Stewardship/risk map overlays | Create non-color-only protected-area, water/soil, habitat, and hazard cues tied to tested rules. Use patterns/icons/borders as secondary encodings. |
| P1 — M8 | Final environment/character/UI polish | Replace only placeholders that fail readability or quality acceptance. Build a coherent limited palette, UI icon set, and any necessary animation/feedback assets. |
| P2 — M8 (optional) | Audio | If approved, add a small optional ambient bed and concise action/UI cues. No voice content is required for the launch baseline; audio must be mixable/mutable and not carry essential information. |
| P1 — M10 | App/package art | Final icon, splash/launch imagery, store screenshots, and credits only after scope, licensing, and final UI are locked. |

## Integrated native palm subset — curated, not accepted final art

The five first-party action SVGs under `assets/ui/icons/` remain loaded by `scripts/ui/game_ui.gd` with persistent text labels. On 2026-10-02 the user authorized a small, source/license-reviewed download subset and subsequently authorized integrating the selected visual assets into the Godot project. This permits the bounded static visual integration below only; it does not authorize purchases, commissions, gameplay/process redesign, scope expansion, or waiver of any M2/M3 acceptance gate.

Four unmodified GLB 2.0 models are included under `assets/environment/palms/` (combined model bytes: 84,852 B):

- `tree-palmdetailedshort.glb` represents the young-crop silhouette at 1.8× (approximately 1.9 m estimated from transformed GLB node extents; not runtime-measured).
- `tree-palmdetailedtall.glb` represents the mature-crop silhouette at 3.7× (approximately 5.0 m estimated from transformed GLB node extents; not runtime-measured).
- `tree-palm.glb` and `tree-palmbend.glb` are used as background-landmark variations, scaled 3.3× and 3.6× respectively, then scaled to 0.86× by the world builder.
- Imported leaf and bark material colours are remapped at runtime to the game's muted green/brown palette; no source GLB bytes are modified.
- The Nature Kit has no FFB model. Three procedural, high-contrast, state-dependent fruit cues are retained on mature crop palms, including the ready-state highlight.

These are generic stylized palms, not verified *Elaeis guineensis* models and not botanical evidence. They must be described as visual stand-ins, not oil-palm-specific asset art. Source, pin, CC0 1.0 notice, model checksums, scaling, and palette modifications are recorded in [`assets/environment/palms/PROVENANCE.md`](../assets/environment/palms/PROVENANCE.md); the pack's license notice is kept beside the files in `assets/environment/palms/LICENSE.txt`.

Godot 4.3 editor import/parse and 110 headless structural assertions pass for the selected scenes, imported operation proxies, and FFB cues. They do **not** prove rendered appearance, silhouette/readability, route or yard framing, mobile performance, or device compatibility; those remain UNVERIFIED. Keep the five action icons. The broader native MVP gates and external evidence needs are in [`GODOT_MVP.md`](GODOT_MVP.md).

Priority numbers do not define calendar timing. Roadmap gates, license review, and explicit scope decisions control future asset work. The curated palm subset and the bounded operation-visual subset below are imported into Godot; neither changes gameplay/process scope or closes an M2/M3 acceptance gate.

## Integrated operation visual subset — generic placeholders, not final art

The user's 2026-10-02 download authorization and subsequent explicit integration request covered a small, license-identified subset now located under `assets/environment/operations/` (**722,851 bytes acquired: 8 GLBs plus 2 separately referenced textures**). Godot extracts two byte-identical 12,371-byte PNG copies from images embedded in the vehicle GLBs, bringing the production model/texture payload to **747,593 bytes before `.import` sidecars**. `VisualFactory` and `PlantationWorld` place one generic tractor, one generic pickup, and one compact industrial-yard visual preview. The mill sign labels this **VISUAL CONCEPT — PROCESS FLOW NOT SIMULATED**. These are static scene props, not operation/process nodes; no capacity, task, material-flow, or vehicle logic was added.

| Integrated visual proxy | Source/license | Relevance and limitation |
|---|---|---|
| `kenney-car-kit/tractor.glb` (188,236 B) and `truck.glb` (188,652 B) | Kenney Car Kit, CC0 1.0 | Generic tractor and open-bed pickup; neither is oil-palm-specific or a purpose-built FFB lorry. |
| `kenney-city-kit-industrial/building-c.glb` (175,844 B), `chimney-large.glb` (20,932 B), `detail-tank-large.glb` (47,452 B), plus `Textures/colormap.png` (11,986 B) | Kenney City Kit (Industrial) 2.0, CC0 1.0 | Generic mill-yard shell, stack, and storage-tank cues; not process-specific machinery or engineering specifications. |
| `kenney-factory-kit/conveyor-v1.glb` (18,688 B), `hopper-high-round.glb` (16,644 B), `pipe-large-valve.glb` (42,604 B), plus `Textures/colormap.png` (11,813 B) | Kenney Factory Kit 3.0, CC0 1.0 | Generic material-flow components only; they do not replace sterilization, threshing, digestion, pressing, clarification, kernel recovery, utilities, or residual-treatment stages. The conveyor bytes were checked against the original `conveyor-long.glb`. |

File-level sources, exact mirror commits/archive hashes, license notices, validation, and SHA-256 checksums are in [`assets/environment/operations/PROVENANCE.md`](../assets/environment/operations/PROVENANCE.md). That record also documents the static scene placements, limitations, and unverified visual/device acceptance. Only shortlisted models and their notices/textures are retained, not full packs or preview files. Direct official ZIP endpoints were not reachable from the sandbox shell, so source archives were retrieved from pinned GitHub mirrors and their internal CC0 notices inspected.

The Sketchfab “Oil Fruit Palm” candidate was not downloaded: the page reports CC BY 4.0 and 74.3k triangles, botanical identity is unconfirmed, and the official download workflow requires an authorized request. No ripping or permission bypass was used. The existing palms therefore remain generic stand-ins; they are not newly verified oil-palm art.

These files are imported and placed only as static visual placeholders—not accepted final art and not operational/gameplay integration. They add no simulated process node and do not replace, collapse, or omit any real stage. Preserve the full A–Z process order, dependencies, inputs/outputs, and material flows in [`OIL_PALM_OPERATIONS.md`](OIL_PALM_OPERATIONS.md); accelerate only elapsed calendar time.

## Lifecycle-complete visual inventory and count (planning estimate)

This estimate maps a visually readable A–Z oil-palm operation at the **existing bounded strategy scale**: one estate, four managed blocks, a limited crew roster, one collection route/outlet and one local mill. It is a planning ledger—not a universal minimum, blanket authorization to download every listed asset, or approval to implement the entire inventory. The user-authorized and integrated subset is recorded in [`assets/environment/operations/PROVENANCE.md`](../assets/environment/operations/PROVENANCE.md). The process source and order are documented in [`OIL_PALM_OPERATIONS.md`](OIL_PALM_OPERATIONS.md). The current game can keep many low-detail parts procedural if they pass later visual acceptance.

The count explicitly separates the **full-process core representation** from **optional visual detail**. The simulation requirement is that every real process stage and material flow remains represented; only elapsed calendar time is accelerated. An item marked optional below is an extra model/material variation, close-up, decorative set, or alternate site/mill configuration—not permission to omit the underlying process mechanic. A core process may use a compact modular scene, UI/overlay or procedural cue instead of a unique standalone model, and this visual estimate does not change the four-block/one-mill roadmap boundary.

### Count method

- A **family** is a reusable model/scene concept, such as the worker rig or mill reception module. Components can be packed into one scene; a family does not imply one separately purchased model.
- A **variant** is a visually distinct life stage, tool/vehicle configuration, material state, outfit, or treatment route. Many variants can be mesh/material swaps and do not require extra GLB files.
- An **icon** is a unique action/status glyph; an **overlay** is a patterned map layer that remains readable without colour alone.
- A **runtime instance** is a placed object in the scene. One source model can generate many instances; instance counts must not be added to file/family counts.

| Deliverable class | Total planning count | Full-process core representation | Optional visual detail | Current repository coverage / note |
|---|---:|---:|---:|---|
| Reusable 3D/model-scene families | **35** | **33** | **2** | Several roles are procedural; one generic tractor, pickup, industrial shell, stack/tank, hopper, conveyor, and pipe provide only broad visual proxies. No process-specific mill machinery, PPE/tools, or by-product models are included. Counted by family below; multiple station meshes may be packed into one modular scene. |
| Visual variants | **47** | **38** | **9** | Four generic Kenney palm GLBs provide rough silhouettes; procedural fruit/seedling and scene materials cover a few temporary states. Variants may be mesh/material swaps, not separate files. |
| Action/status icon designs | **20** | **20** (5 existing + 15 proposed) | **0** | Five native SVGs already exist (`build`, `land`, `plant`, `workers`, `management`); 15 more give the full operations vocabulary. |
| Non-colour map overlay patterns | **8** | **8** | **0** | Selection/placement cues are procedural; no dedicated lifecycle/safeguard overlay set exists. Use text, borders, patterns and symbols as well as colour. |
| **Full-process core representation** | **99** | **99** | — | `33 core families + 38 core variants + 20 core icons + 8 core overlays = 99`. Some are procedural/UI roles, not new model files. |
| **Optional visual detail** | **11** | — | **11** | `2 optional families + 9 optional variants = 11`. This count does not make any process stage optional in the simulation. |
| **Total logical visual slots** | **110** | **99** | **11** | `35 families + 47 variants + 20 icons + 8 overlays = 110`. A scoped recommendation, not a universal required number or procurement list. |
| Optional presentation polish (outside the 110) | **+6 animation clips, +4 lightweight VFX** | — | Separate | Only add if M4/M8 readability or device tests justify them; simple procedural task poses/effects may suffice. |

Read “beyond the four imported palms” as **34 non-palm model/scene families plus a reviewed oil-palm lifecycle family**, with **47 total visual variants**, **15 additional icon designs**, and **8 overlay patterns** in the full ledger. The four generic GLBs only partly cover palm silhouettes; they do not satisfy the species-accurate lifecycle set. These roles overlap as scenes/materials/icons and must not be treated as 110 new files or 110 purchases.

The **99-slot** full-process baseline assumes the seedlings/nursery are visually represented on the estate. If the scenario buys planting stock from an outside nursery, use the supplier/order UI instead and remove up to four physical roles (two nursery families and two container variants): the visual-role estimate becomes **95**. Either way, the four-block/one-mill launch boundary and nursery-to-field dependency remain unchanged.

If each 3D family, icon and overlay is authored as one standalone source resource, the full plan represents about **63 base source slots** (`35 + 20 + 8`). If every variant is also split into a separate source file, the conservative ceiling is **110 source resources**, before optional animation/VFX. An atlas, material set, modular scene, or procedural Godot resource can reduce the on-disk file count. Conversely, a close-up educational camera or separate mill-machine scenes could increase it. The 99 core roles and 11 optional visual details are not separate-file promises. The raw difference between 110 logical slots and the 17 current standalone model/icon files is **not** a shopping list: generated world geometry already supplies provisional road, soil, forest, worker, shelter, pond, and collection-point roles; the imported operation models add only generic vehicle/yard silhouettes.

### Process-to-visual matrix (bounded launch)

This maps each real-world slice to its smallest readable strategy-camera treatment and separates the required process representation from additional asset detail. Every row is part of the full operational chain; optional means only a more detailed, alternate or decorative visual. Some core representations are procedural or UI-based.

| Process slice | Required process visual | Optional added asset detail | Placement / scope note |
|---|---|---|---|
| Site suitability, land rights and safeguards | Four block markers/boundaries; suitability and no-go overlay; riparian/water edge cue. | Habitat tree set, survey equipment, fine-grained habitat/soil map layers. | Four managed blocks only; protected/buffer areas are constraints, not new playable land. |
| Nursery and planting material | Seedling/palm juvenile cue, seedling order/status UI; one simple nursery bed/bag and water cue if raised in-estate. | Separate pre-nursery trays, shade-house detail, grading/reject closeups and elaborate irrigation hardware. | Zero or one on-map nursery. A finite supplier/order screen can replace a physical nursery site. |
| Field establishment and immature care | Prepared/covered ground, juvenile palm forms, soil/water condition and task markers. | Species-specific cover crop, weed species, mulch detail and nutrient-deficiency closeups. | Reuse cohort proxies across the four blocks; no universal spacing/terrain kit is implied. |
| Mature crop, soil/water and monitoring | Mature palm + developing/ripe bunch states; soil, water and health overlays. | Named pest/disease closeups, beneficial-insect species and cultivar detail. | No species diagnosis or fixed treatment implied by a colour tint; pest overlay may remain optional. |
| Labour, tools and safety | Shared worker rig/role outfit; harvest tool silhouettes; core PPE/first-aid and fertilizer task cue. | Tool animations, detailed sprayer/diagnostic meshes, branded inputs or close-up handling. | `N_active_workers` from the bounded roster; use labels and shapes, not colour alone. Do not depict chemical instructions. |
| Harvest and loose-fruit recovery | Distinguishable FFB maturity, loose fruit, hand-collection cue and harvest status. | Detailed cut stalk/fruit grading, individual bunch geometry and close-up hand poses. | Instances are tied to harvestable quantities and collection capacity; no free resource spawning. |
| Field collection and transport | One roadside ramp/bin/scale; in-field carrier + haul vehicle; route/queue status. | Cooperative/trader shed, alternate tractor/trailer, detailed weigh station. | One collection point and the existing bounded local delivery route; instance counts follow capacity. |
| Mill intake and processing | One mill/yard and distinct sterilizer, thresher, digester and press process nodes in the correct order; nodes may share a modular scene/flow display. | Machine internals, separate high-detail submeshes, gauges and animated mechanisms. | One local mill only. Keep the process nodes in one compact modular mill scene if needed; do not add a refinery chain. |
| Products, by-products and environmental handling | CPO and kernel output cues plus one explicit residual/POME-treatment zone and selected route. | Alternative pond/biogas systems, boiler/turbine detail, EFB compost/mulch configurations and monitoring equipment. | One chosen mill configuration; material streams must be conserved and untreated POME must never read as acceptable discharge. |
| Traceability, business and records | UI receipt/ledger, block/supplier identity and mill-batch/route status. | Barcode scanner, document stack, separate office props and detailed certification dashboard. | Core proof can be in UI; no extra physical traceability building is necessary. Certification is not implied unless modelled. |
| Replanting and next rotation | Replant status overlay, felled/stump state, juvenile stock cue and block-level production-gap indicator. | Full removal equipment and detailed rehabilitation closeups. | Replanting remains gate-controlled; no automatic block expansion. |

### 35 reusable model/scene families (33 core process families, 2 optional detail families)

| # | Scope | Family | Process role / recommended reuse |
|---:|:---:|---|---|
| 1 | Core | *Elaeis guineensis* lifecycle set | Nursery/field age forms; visually distinguish oil palm from generic coconut palms. |
| 2 | Core | Fresh fruit bunch | Developing/ripe/overripe state cues; share geometry where practical. |
| 3 | Core | Loose fruit / brondolan | Field recovery, collection and mill-side product cue. |
| 4 | Core | EFB and frond residue | Empty bunches, pruned fronds and mulch/stack states. |
| 5 | Core | Felled palm / stump / replant residue | Replant transition without implying that old palms disappear instantly. |
| 6 | Core | Nursery beds, bags and seedling handling | Pre-/main-nursery layout and field-ready stock can be scene variants. |
| 7 | Optional | Nursery shade structure | A simple reusable row/cover, not a detailed commercial greenhouse. |
| 8 | Core | Nursery irrigation system | Shared tank/pump/hose pieces for the seedling area. |
| 9 | Core | Survey stakes and block marker | Layout and the four block identities. |
| 10 | Core | Soil/ground-state patch | Prepared, covered, dry, wet or eroded map states. |
| 11 | Core | Legume/cover-crop patch | Soil cover and early-establishment cue. |
| 12 | Core | Weed/understory patch | Maintenance/access state; distinguish managed cover from overgrowth without implying every ground plant is harmful. |
| 13 | Optional | Native tree/habitat set | Boundary/background variation; reused and instanced, not a new pack per block. |
| 14 | Core | Riparian/water-body patch | Water feature and protected buffer read. |
| 15 | Core | Drainage/water-control kit | Ditch, culvert, gate and/or footbridge variants selected by scenario. |
| 16 | Core | Worker rig and role outfit | One lightweight human base with shared task roles/outfits. |
| 17 | Core | Harvest-tool kit | Short-handled dodos and long-pole egrek as distinct tool variants. |
| 18 | Core | Pruning tool | Frond access/maintenance cue, selected for the scenario and palm height. |
| 19 | Core | Fertilizer application kit | Bag/spreader or simple hand-application props. |
| 20 | Core | Sprayer/IPM scouting kit | Generic scouting/trap and sprayer cues; no chemical brand, mixture or dose. |
| 21 | Core | PPE, first aid and input-storage kit | Task-appropriate protective equipment and a readable safe-storage cue. |
| 22 | Core | Loose-fruit/bunch hand-collection kit | Basket/sack and a small handcart can share a modular family. |
| 23 | Core | In-field carrier and trailer | Scenario variant: motorbike/trailer or compact tractor/implement. |
| 24 | Core | FFB haul truck | Roadside-to-mill delivery; reusable one vehicle model. |
| 25 | Core | Collection ramp/bin/scale | One field-side aggregation/recording point. |
| 26 | Core | Estate office/camp/tool store | Worker and operation hub, reused rather than dressing every block. |
| 27 | Core | Mill building and yard shell | One recognizable local-mill complex; hosts the required process nodes in a compact modular scene. No refinery. |
| 28 | Core | Weighbridge and FFB reception | Gate, weighing, inspection and intake staging. |
| 29 | Core | Sterilizer/cage module | Steam-sterilization process node; operating values remain scenario-specific. |
| 30 | Core | Thresher and EFB conveyor | Fruit separation and empty-bunch side stream. |
| 31 | Core | Digester | Fruit mash preparation before pressing. |
| 32 | Core | Screw-press station | Mesocarp-oil extraction; press cake enters the recovery route. |
| 33 | Core | Clarification/drying/CPO storage | Oil purification/drying and a clear finished-CPO storage cue. |
| 34 | Core | Fibre/nut/kernel recovery and storage | Distinct kernel stream; kernel crushing/PKO may remain outside the local mill scope. |
| 35 | Core | Mill utilities and residuals zone | Boiler/turbine, POME treatment/monitoring and EFB/compost destination, arranged as readable submodules. |

### 47 explicit visual variants

These are distinct looks/choices needed across the 35 families; they may be authored as mesh swaps, shared materials, subscenes or map states.

| Variant group | Total | Core | Optional | Required distinction |
|---|---:|---:|---:|---|
| Oil-palm life forms | 5 | 5 | 0 | Nursery seedling; field juvenile; immature/non-bearing; mature/fruiting; tall/declining. |
| FFB bunch maturity | 4 | 4 | 0 | Immature; developing; ripe; overripe/damaged. Exact colours/harvest threshold are scenario-reviewed. |
| Nursery container sizes | 2 | 2 | 0 | Early-stage and main-nursery stock (only if nursery is shown on-map). |
| Soil/ground conditions | 5 | 5 | 0 | Prepared/bare; covered; mulched; dry; wet/eroded. Combine materials when the camera does not need separate meshes. |
| Cover-crop appearances | 3 | 1 | 2 | A readable soil-cover state is core; species/seasonal alternatives are optional and local. |
| Weed/understory states | 2 | 2 | 0 | Managed/low cover and access-obstructing growth. |
| Habitat tree silhouettes | 3 | 0 | 3 | Reused forest/background forms; environment dressing may remain procedural. |
| Drainage/water-control pieces | 4 | 3 | 1 | Core: ditch, culvert and water gate; optional: footbridge. |
| Worker role/outfit looks | 3 | 3 | 0 | Field maintenance, harvest/PPE, mill/transport. Shared base model; not three full rigs. |
| Harvesting tools | 2 | 2 | 0 | Dodos and egrek; a pruning tool is counted as its own family. |
| Input/IPM equipment | 3 | 3 | 0 | Fertilizer tool, generic sprayer and monitoring/trap cue; no brands or application instructions. |
| PPE pieces | 5 | 5 | 0 | Helmet, boots, gloves, eye/face protection and task-specific protection. Actual combinations require local safety review. |
| Vehicle looks | 3 | 2 | 1 | Core: in-field carrier and haul truck; optional: trailer/tractor alternative. |
| POME treatment routes | 2 | 1 | 1 | One selected scenario (pond train or covered treatment/biogas system) is core; the other is an optional alternate configuration. |
| EFB/biomass route | 1 | 0 | 1 | Optional alternate cue for field mulch/compost versus mill fuel/compost; match the selected mill. |
| **Total** | **47** | **38** | **9** | Includes model, material and scene-state variants; not 47 compulsory new model downloads. |

### 20 UI action/status icons and 8 map overlays

The five existing action icons remain. The 15 required additions are nursery, cover/soil, fertilizer, water/drainage, scouting/IPM, harvest, loose fruit, collection/transport, mill, CPO, kernel/by-product, safety/PPE, stewardship, traceability/records and replanting. This gives 20 process/action glyphs in total (5 present + 15 proposed). Keep words with critical controls and do not communicate status by colour alone.

Eight overlays cover: (1) land suitability/use constraint, (2) protected habitat/riparian buffer, (3) soil/erosion, (4) water/drainage/dryness/flooding, (5) crop stage/health, (6) pest/disease observation, (7) crew safety/work zone, and (8) harvest–delivery–mill/traceability status. All eight overlays are core process/risk views; pest/disease status must not be hidden in an unrelated crop-colour tint. Some can be procedural patterns, but each must have a distinct, testable visual language.

### Runtime placements — not additional asset files

| Map role | Launch placement count / formula |
|---|---:|
| Managed block boundaries/labels | **4** (one per managed block) |
| Nursery | **1** on-map nursery scene if seedlings are raised in-estate; otherwise show a finite supplier/order in UI and do not invent a physical nursery site. |
| Estate work hub | **1** shared shelter/store/office scene; the current starter shelter is procedural. |
| Field collection point | **1** shared point in the current baseline; current collection point is procedural. |
| Local mill/outlet | **1** complex, with one instance of each selected process submodule in the mill family set. |
| Active worker characters | `N_active_workers` from the bounded crew roster; reuse one base rig and outfit/task variants. |
| Visible palm proxies | `P_visible` chosen from camera scale/device profiling and crop cohorts; instance with MultiMesh/LOD where suitable. `P_visible` is not the number of simulated trees and is not fixed by the count of palm models. |
| Roads, drains, trees, fruit and field props | Instanced/reused along the finite four-block map; the placement count follows the approved map layout and performance test. |

### Presence/gap summary

- **Present as standalone native art:** 4 generic palm GLBs and 5 first-party UI action SVGs (plus an app icon outside the 110-slot count). The four palm files are not four complete crop stages: two are used as crop silhouettes and two as distant landmarks; none is verified species-specific *E. guineensis* art.
- **Present as procedural/test geometry:** soil, roads, background trees, pond, markers, seedling/FFB cues, player/worker, shelter, and collection point. These remain placeholders rather than accepted final visuals.
- **Present as generic imported visual proxies:** one tractor, one pickup, and one static mill-yard preview assembled from a building, stack, tank, hopper, conveyor, and pipe/valve. The assets do not simulate transport or identify equipment with verified local/process-specific function.
- **Major unrepresented process visuals:** nursery stages and water supply, real harvest tools/PPE, separate bunch and loose-fruit handling, process-specific mill stations, CPO/kernel/by-product streams, and POME/EFB treatment/replant cues. The static route is not vehicle logistics or traceability.
- **Download scope and integration status:** the inventory remains a sizing/reference artifact, not blanket procurement approval. The user-authorized 8-GLB/2-texture subset is in `assets/environment/operations/` with licenses, provenance, and hashes; it is imported only for generic static visual proxies. No purchase or commission was made. The four-palm set is also integrated as generic silhouettes. Process-specific mill machinery, PPE/tools, treatment/by-product models, and verified *E. guineensis* art remain gaps.

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
