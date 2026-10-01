# Integrated operational visual-asset subset

**Status:** the selected CC0 subset is imported into the Godot project and placed as static visual proxies. `scripts/world/visual_factory.gd` and `scripts/world/world_builder.gd` instantiate all eight GLBs as one field tractor, one generic pickup, and one compact mill-yard preview. The yard is marked **VISUAL CONCEPT — PROCESS FLOW NOT SIMULATED**. These assets add no collision, vehicle behavior, mill operation, process-stage logic, or material-flow simulation. No rendered-appearance acceptance, target-device profiling, or release-art approval is claimed.

Retrieved **2026-10-02**. The downloaded subset has **8 GLBs plus 2 separately referenced textures (722,851 bytes total)**, scoped to the existing four-block estate, field collection/haul route, and one local mill. Godot 4.3 extracts the two identical 12,371-byte Car Kit images embedded in the vehicle GLBs as PNG import dependencies; these exact duplicate files add 24,742 bytes, for **747,593 bytes of model/texture files in the production folder before `.import` sidecars**. The subset does not cover the full 110 logical visual roles in `docs/ASSET_PLAN.md`, replace any real operational stage, or authorize gameplay-scope expansion.

## Kenney Car Kit — CC0 1.0

- **Creator:** Kenney (Kenney Vleugels).
- **Official pack:** [Car Kit](https://kenney.nl/assets/car-kit); the official page lists Creative Commons CC0.
- **Pinned acquisition mirror:** [`Hidencod/tge-assets`](https://github.com/Hidencod/tge-assets), commit `dc56ea9f77595fc96433b7d944ad5ce5ef1b61c2`, directory `packs/car-kit/`.
- **Mirror license evidence:** the pinned repository README identifies the assets as Kenney models under CC0 1.0; its `LICENSE` says converted GLBs and thumbnails are also CC0. The local [`LICENSE.txt`](kenney-car-kit/LICENSE.txt) preserves that notice.
- **Acquisition:** the two GLBs below were copied byte-for-byte from the pinned mirror. They are converted, self-contained GLBs, not original editable source projects.
- **Rights:** CC0 1.0 permits reuse and redistribution, including commercially; attribution is not required, though credit to Kenney is appreciated. See <https://creativecommons.org/publicdomain/zero/1.0/>.

| Local file | Mirror file | Bytes | SHA-256 | Structural check | Candidate role / limitation |
|---|---|---:|---|---|---|
| `kenney-car-kit/tractor.glb` | `packs/car-kit/tractor.glb` | 188,236 | `d15329598d19e1a0f28b4ad7ad505a8284e1ab067846f64bedec5c2ab49e7069` | GLB 2.0; 5 meshes; 3,260 vertices; 2,044 triangles; embedded image | Generic compact tractor silhouette for field-side collection; no trailer or oil-palm-specific equipment. |
| `kenney-car-kit/truck.glb` | `packs/car-kit/truck.glb` | 188,652 | `80454be69df2a50f32c225b5d6a29c62d9ce23bc446f26970a5e9a9e9ba99293` | GLB 2.0; 5 meshes; 3,264 vertices; 2,082 triangles; embedded image | Generic open-bed pickup candidate for collection/short haul; not a purpose-built FFB lorry and has no fruit cargo. |

Godot extracts the embedded image from each Car Kit GLB as `kenney-car-kit/tractor_colormap.png` and `truck_colormap.png`. Each is 12,371 bytes with SHA-256 `f3622a03a20c6696065cae9cbe391351be873508af190c2ebd1d420c055787a5`; each extracted file matches its GLB image buffer byte-for-byte, and the two maps are identical. These importer-generated dependencies are not additional source-pack downloads.

## Kenney City Kit (Industrial) 2.0 — CC0 1.0

- **Creator:** Kenney (Kenney Vleugels); official pack page: [City Kit (Industrial)](https://kenney.nl/assets/city-kit-industrial).
- **Pinned source archive mirror:** [`Paumen/Taalei`](https://github.com/Paumen/Taalei), merged PR #444 commit `9b0c2696a2d9a4ee0159c4ac317d13461db4f2b9`, file `kits/sources/kenney_city-kit-industrial_2.0/kenney_city-kit-industrial_2.0.zip`.
- **Archive verification:** 5,045,077 bytes; SHA-256 `5b381164e5760f3830a2dbee43b972deee38b2a695d091b56e238ab2910c96d2`. The archive's own `License.txt` identifies City Kit Industrial 2.0, Kenney, and CC0 1.0; it explicitly allows personal, educational, and commercial use. The source notice is retained with whitespace normalized as [`License.txt`](kenney-city-kit-industrial/License.txt).
- **Acquisition:** the shortlisted GLBs and `Models/GLB format/Textures/colormap.png` were extracted unchanged from the pinned archive. Preview renders in the archive were checked when choosing this small subset; previews and unrelated source files are not retained.

| Local file | Original pack file | Bytes | SHA-256 | Structural check | Candidate role / limitation |
|---|---|---:|---|---|---|
| `kenney-city-kit-industrial/building-c.glb` | `Models/GLB format/building-c.glb` | 175,844 | `94eb05acef8d8e4c1d817eb12e1c2a1287ffed625879170663a8c4f48786b465` | GLB 2.0; 1 mesh; 6,748 vertices; 1,928 triangles; external image URI `Textures/colormap.png` | Generic industrial building shell for a compact mill-yard silhouette; not a process-specific mill building. |
| `kenney-city-kit-industrial/chimney-large.glb` | `Models/GLB format/chimney-large.glb` | 20,932 | `fd88d6c971ffb27f5ee5b0df9f7c23ac82f9b6d32e85d3e2066f90a62f92f59f` | GLB 2.0; 1 mesh; 372 vertices; 218 triangles; external image URI `Textures/colormap.png` | Generic stack silhouette; not a boiler, emissions-control, or safety specification. |
| `kenney-city-kit-industrial/detail-tank-large.glb` | `Models/GLB format/detail-tank-large.glb` | 47,452 | `2fbf65dfbae114235dec65cc8730a870cf7d29dd76f9473218e96ee83e9f5f43` | GLB 2.0; 1 mesh; 880 vertices; 566 triangles; external image URI `Textures/colormap.png` | Generic storage-tank cue; does not define CPO, water, or POME vessel requirements. |
| `kenney-city-kit-industrial/Textures/colormap.png` | `Models/GLB format/Textures/colormap.png` | 11,986 | `950f4f891ebd05a2affac810e6eeb0fea1511bc39039b65a3cbf2e17d17bc6a2` | PNG; required dependency for the three selected GLBs | Shared Kenney color map. |

## Kenney Factory Kit 3.0 — CC0 1.0

- **Creator:** Kenney (Kenney Vleugels); official pack page: [Factory Kit](https://kenney.nl/assets/factory-kit). The [Kenney OpenGameArt listing](https://opengameart.org/content/factory-kit) also identifies the pack as CC0.
- **Pinned source archive mirror:** [`Paumen/Taalei`](https://github.com/Paumen/Taalei), merged PR #482 commit `603f835aeeef997e41ab4b2575885870ce206f19`, file `kits/sources/kenney_factory-kit_3.0/kenney_factory-kit_3.0.zip`.
- **Archive verification:** 4,511,890 bytes; SHA-256 `7e31fb2308e90304672bd15cd18fa9d9f02c03731a8cbc57a8e3e1c181dfb0a7`. The archive's own `License.txt` identifies Factory Kit 3.0, Kenney, and CC0 1.0 and permits personal, educational, and commercial use. The source notice is retained with whitespace normalized as [`LICENSE.txt`](kenney-factory-kit/LICENSE.txt).
- **Acquisition:** `hopper-high-round.glb` and `pipe-large-valve.glb` were extracted byte-for-byte from the pinned original-pack archive. The existing `conveyor-v1.glb` was first obtained through [`mauriciosoyastor/ModoOps`](https://github.com/mauriciosoyastor/ModoOps), commit `37d2c8b16b7754fbef97b3e9019c815924c0d4dd`; its SHA-256 was then verified to exactly match original pack file `Models/GLB format/conveyor-long.glb`. The existing texture likewise matches the original archive's `colormap.png`. The ModoOps manifest corroborates the original file and CC0 license.

| Local file | Original pack file | Bytes | SHA-256 | Structural check | Candidate role / limitation |
|---|---|---:|---|---|---|
| `kenney-factory-kit/conveyor-v1.glb` | `Models/GLB format/conveyor-long.glb` | 18,688 | `9087ec11d9dcc85ada9d14a66910244bfbb5df57c64b2647956a32525935dee3` | GLB 2.0; 1 mesh; 328 vertices; 196 triangles; external image URI `Textures/colormap.png` | Generic conveyor/material-flow cue only; not a process node. Local filename preserves the already-downloaded candidate path. |
| `kenney-factory-kit/hopper-high-round.glb` | `Models/GLB format/hopper-high-round.glb` | 16,644 | `b07d0f43ce8e2c007cc298abcefd577672625edd3323ef3a99c6d8dec6521975` | GLB 2.0; 1 mesh; 288 vertices; 176 triangles; external image URI `Textures/colormap.png` | Generic elevated feed hopper; not a sterilizer, thresher, or fruit-separation model. |
| `kenney-factory-kit/pipe-large-valve.glb` | `Models/GLB format/pipe-large-valve.glb` | 42,604 | `57126374dce5b172e06d5d6f8cbaab97c9cffe3e5e726060eb14c50a5bd519b6` | GLB 2.0; 1 mesh; 792 vertices; 456 triangles; external image URI `Textures/colormap.png` | Generic pipe/valve cue; not a palm-oil process-flow or engineering specification. |
| `kenney-factory-kit/Textures/colormap.png` | `Models/GLB format/Textures/colormap.png` | 11,813 | `35d7bd6900dde0208429eeaec87fa17fbf024ed59f3f4eab54bc92802eba9dd7` | PNG; required dependency for all three selected GLBs | Shared Kenney color map. |

## Runtime placement and importer settings

- `scripts/world/world_builder.gd` places the generic tractor at `(19.6, 0, 13.4)`, the generic pickup at the FFB collection route `(26, 0, 13.8)`, and the single static mill-yard preview at `(30, 0, -14)`. A collection spur and a mill spur connect these sites to the existing access road; they do not implement vehicle pathing or a second outlet.
- `scripts/world/visual_factory.gd` scales the mill shell 3.0×, stack 2.2×, tank 2.2×, hopper 2.1×, conveyor 2.0×, and pipe/valve 2.0×. The car-kit models remain at 1.0×. These are provisional map-art scales, not measured real-equipment dimensions.
- Every GLB import sidecar sets `meshes/generate_lods=false`: the selected low-poly meshes need no generated LOD at the current instance count, and some source meshes contain zero-area triangles that made Godot 4.3's default LOD generation report a non-finite-normal warning. This import setting avoids the warning without changing source geometry or hashes.

## Integration and review boundaries

- Source archive licenses were inspected before extraction. GLB magic/version/declared length, local file size, SHA-256, mesh/accessor counts, and referenced texture presence were checked for every retained model. The production copies retain their original bytes; the two bundled license notices have whitespace normalized for readable diffs.
- Godot 4.3 imports the selected GLBs and textures from `assets/environment/operations/`. The full native acceptance runner passes: 109 simulation assertions, 65 crop-model checks, and 109 main-scene structural assertions; the scene smoke verifies all eight source paths and non-empty mesh resources. Several source meshes contain zero-area triangles; Godot's default LOD generator emitted a non-finite-normal warning, so LOD generation is disabled in the eight `.glb.import` sidecars. GLB source bytes remain unchanged. This is structural/import validation only; rendered appearance, camera framing, color/readability, target-device performance, and final-art acceptance remain **UNVERIFIED**.
- The tractor and pickup are generic transport silhouettes, not verified plantation machinery or a purpose-built FFB lorry. The City Kit building, chimney, and tank and the Factory Kit conveyor, hopper, and valve are generic environmental props, not evidence of local engineering practice. Their scales and composition are provisional visual tuning, not measured equipment dimensions.
- The in-world mill sign and node metadata explicitly identify the yard as a visual concept with no simulated process flow. These props do **not** model or replace FFB weighing/receipt, sterilization, threshing, digestion, pressing, clarification/drying, kernel recovery, utilities, POME treatment, EFB/residue handling, or traceability. Preserve the complete A–Z process order, dependencies, inputs/outputs, and material flows; accelerate only elapsed calendar time.
- No full source archives, previews, or unrelated pack contents are retained in the project; only the shortlisted files and license notices are kept.
- Sketchfab's [Oil Fruit Palm](https://sketchfab.com/3d-models/oil-fruit-palm-6afff2461fba466e8cfb735661ddf93f) was not downloaded. Its page reports CC BY 4.0 and 74.3k triangles, but does not independently verify *Elaeis guineensis* identity. The official Sketchfab download workflow requires an authorized user request; no third-party ripping or permission bypass was used. Treat it as an unverified, relatively heavy candidate, not approved oil-palm art.
- No asset was purchased or commissioned. The selected subset is integrated only as static world presentation; it does not change the production simulation or satisfy process-specific machinery, PPE/tooling, traceability, by-product, or verified *E. guineensis* art gaps.
