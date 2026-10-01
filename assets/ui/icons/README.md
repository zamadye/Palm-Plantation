# Native UI action icons

Five first-party SVGs for the native Godot action bar: `build.svg`, `land.svg`, `plant.svg`, `workers.svg`, and `management.svg`.

- Authored in-repository with a 64 × 64 viewBox and transparent background; no external image pack or font is required.
- Shared visual palette: forest green `#263C2B`, warm ivory `#F0EAD7`, leaf green `#98B875`, and harvest gold `#D9B56E`.
- Shapes remain distinct without relying on color, and Godot keeps the action text beside each icon.
- Loaded from `res://assets/ui/icons/` by `scripts/ui/game_ui.gd`. These are native assets; the separately authored browser preview does not import them.

Visual legibility, button composition, touch sizing, and contrast still need direct inspection in a visible Godot build at the agreed mobile resolution. The headless scene smoke proves import and node wiring only.
