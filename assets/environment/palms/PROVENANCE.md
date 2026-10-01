# Curated Nature Kit palm models — provenance and integration record

## Source and rights

- **Creator:** Kenney (Kenney Vleugels).
- **Original pack:** [Nature Kit](https://kenney.nl/assets/nature-kit), the official pack page lists CC0 1.0.
- **Pinned converted source:** [`Hidencod/tge-assets`](https://github.com/Hidencod/tge-assets), commit `ec2281c5239b9e78e4ff06cdd6618a3dfbcb3b73`, directory `packs/nature-kit/`.
- **Retrieved:** 2026-10-01.
- **License:** Creative Commons Zero 1.0 Universal (CC0 1.0), as stated by the pinned source's [`LICENSE.txt`](LICENSE.txt). The notice says Kenney created the models; the converted GLBs are also CC0. Attribution is appreciated, not required. Personal, educational, and commercial use is permitted by the notice. Keep the license file with the models and include it in any distribution's third-party notices.
- **Source endpoint pattern:** `https://api.github.com/repos/Hidencod/tge-assets/contents/packs/nature-kit/<filename>?ref=ec2281c5239b9e78e4ff06cdd6618a3dfbcb3b73` (GitHub Contents API raw representation).

## Curated files

These four GLB 2.0 files are copied unchanged from the pinned mirror. SHA-256 values below are for the checked-in bytes.

| File | Bytes | SHA-256 | In-game use |
|---|---:|---|---|
| `tree-palmdetailedshort.glb` | 28,212 | `bc1013aaacca3bdd116ad1cded4f9499f008fe3056e760f3238be05aa21ff9f2` | Young crop-palm form; uniform scale 1.8×. |
| `tree-palmdetailedtall.glb` | 28,204 | `2cbea0f9621cde884c63a7b4ad787bda1d051fa27ef3c66b9f2b65328dc53683` | Mature crop-palm form; uniform scale 3.7×. |
| `tree-palm.glb` | 13,616 | `27bbb23d26ed788d84de6df2f7fab0acc3fe0ff16c7d08cdcfa1fffcb11de324` | One background landmark variant; uniform model scale 3.3×, then world scale 0.86×. |
| `tree-palmbend.glb` | 14,820 | `8af9dae16ce3c03183f9457996ebdd135167199514e8f4f944ee2bd82828d5c9` | One background landmark variant; uniform model scale 3.6×, then world scale 0.86×. |

Total model payload: **84,852 bytes**. The pack also has other models, but they were not added because this small subset covers the game-view needs; no thumbnails or full source archive are bundled into production assets.

## Integration and modifications

- Godot target: **Godot 4.3**, Mobile renderer project. The per-model `*.glb.import` sidecars retain the engine import settings: scene importer/PackedScene, root scale applied at 1.0, generated LODs and shadow meshes enabled, tangent generation and animation import disabled, compression left at the importer default. The source GLBs contain no images, textures, or animations.
- The young and mature GLBs replace only the old procedural palm body/fronds at those stages. The seedling remains procedural.
- Three distant environmental landmarks select the tall, standard, and bent forms in `scripts/world/world_builder.gd`.
- `scripts/world/visual_factory.gd` scales the models and duplicates their `StandardMaterial3D` surfaces before tinting leaves to muted plantation green and bark to brown. The original GLB files are not edited.
- The pack contains no FFB bunch model and does not identify its generic palms as *Elaeis guineensis*. The game's three orange, state-driven FFB cues remain procedural and retain a ready-state emission highlight. Do not describe the downloaded palms as species-verified oil-palm art or the fruit cues as a botanical model.
- Model-scale estimates use the GLB geometry/accessor bounds and configured node scale; they are not a substitute for checking rendered in-game dimensions.

## Validation and acceptance

- GLB v2 magic, declared length, JSON header, mesh/material metadata, and the local SHA-256 values were checked at retrieval.
- Supplied Godot **4.3.stable.official.77dcf97d8** editor import/GDScript parse passed. The native structural smoke passes **79 assertions**, including imported young/mature/background resources and retained procedural FFB cues.
- Those checks are headless/structural only. Rendered silhouette, material appearance, visual accessibility, mobile draw cost/FPS, package impact on a device, and target-device compatibility remain **UNVERIFIED**. No visual or performance acceptance is claimed.
- **Review status:** curated source/license and engine integration recorded; final art, botanical specificity, visual acceptance, and device performance are not accepted.

Keep this record and [`LICENSE.txt`](LICENSE.txt) beside the GLBs. Update them if source bytes, license, engine settings, or use changes.
