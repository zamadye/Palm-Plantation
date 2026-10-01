# Native Crop Model — M3 working slice

**Status: IN PROGRESS.** This is the first data-driven calendar, palm development, and yield-forecast slice for the Godot project. It is a game scenario, not an agronomic prescription or regional production forecast. The browser preview remains separately authored and does not use this model.

## Calendar and crop stages

| Variable | Current model | Unit / status |
|---|---|---|
| Calendar | 30 days per model month; 12 model months per 360-day model year | Game-time convention; scenario assumption |
| Scenario periods | Four 90-day labels: wet period, wet-to-drier transition, drier period, drier-to-wet transition | Coarse scenario cycle, not a Samarinda/East Kalimantan weather calendar |
| Field age origin | Day the seedling is planted in the game field | Nursery time is outside this playable slice |
| Cohort key | Model year/month of field planting (`Yxx-Mxx`) | Derived grouping; each palm keeps its exact planting day and age |
| Cohort outlook horizon | Next 30 model days (one model month) | Decision-support window, not a field-visit schedule |
| Seedling | 0–12 model months after field planting | Scenario stage boundary |
| Young palm | 12–30 model months | Scenario stage boundary |
| Mature/fruit-onset stage | From 30 model months | External material places fruit onset around 30 months after field establishment; see sources |
| First commercial harvest window | Around 36 model months | Model uses 30 months to fruit onset plus a 180-day lot-development interval; approximate and pending domain review |
| Representative bunch/lot development | 180 model days for the first lot; 150 model days for later lots | A simplified single visible lot per palm, not the actual field-visit interval or a full palm cohort model |

The calendar compresses crop timing into playable time but preserves a multi-year establishment lead. Fruit development counts only time after the maturity threshold; crossing into the mature stage no longer credits the preceding immature part of a simulation step. The first modeled harvest-ready lot therefore occurs at 1,080 game-days (36 model months), subject to simulation-step precision. A targeted regression and the integrated first-harvest test cover this boundary.

The Estate Overview groups palms by planting model month while retaining each palm's exact age. Its cohort outlook separates actual ready fruit from unready palms projected to reach a window in the next 30 model days, dates each cohort's earliest positive-yield window, and forecasts short-horizon lot weight after deterministic modeled condition drift. The outlook uses each palm's own age and cycle rather than treating all palms in one planting month as synchronized. The summary also shows per-cohort average health percentage, fertilizer-reserve points, and pest-index points; the pest index is not an infestation percentage. A single visible bunch is the simulation's representative harvest lot. Other bunches that would overlap on a real palm are not separately simulated in this slice.

## Yield and condition rules

The model estimates a representative lot from an annual per-palm scenario amount, age profile, health, pest-pressure index, and fertilizer reserve:

`lot kg = peak annual kg/palm × age fraction × (150 / 360) × health factor × pest factor × fertilizer factor`

| Parameter | Current value/curve | Status |
|---|---|---|
| Peak annual FFB | 180 kg per palm-year | Scenario point, not a regional recommendation. It is within a rough derived range of 129–234 kg/palm-year from the cited 18–30 t/ha and 128–140 palms/ha values; that conversion is approximate. |
| Age curve | 0 before year 3; 25% at year 3; linear rise to 100% at year 7; peak plateau through year 18; linear decline to 0 by year 25 | Broad ages are informed by the cited references; intermediate curve and endpoints are scenario assumptions |
| Health factor | `clamp(health / 100, 0, 1.0)` | Scenario relationship; zero health gives zero yield |
| Pest factor | Up to a 20% reduction at a 100-point pest-pressure index | Scenario relationship; the index is not an observed infestation rate |
| Fertilizer factor | Up to a 5% lot increase while fertilizer reserve remains | Scenario relationship |
| Seasonal health loss | 0.004 / 0.007 / 0.018 / 0.008 health points per game day in the four periods | Scenario-only coefficients |
| Seasonal pest pressure | 0.035 / 0.020 / 0.005 / 0.025 index points per game day in the four periods | Scenario-only coefficients; no location-specific pest calendar is implied |
| Fertilizer reserve | Starts at 100; decays by 0.25 reserve points per game day; reduces the health-loss rate to 70% while available | Scenario-only input abstraction |
| Maintenance | Fertilizer adds 10 health points and refills the reserve; pest treatment removes 25 pest-index points and adds 10 health points | Existing actions, now routed through named model parameters; effects remain scenario assumptions |

Seasonal coefficients are intentionally small and deterministic so the calendar creates a legible management pressure without claiming to predict real weather or pest outbreaks. Water balance, soil nutrients, planting material differences, disease, pollination, and yield uncertainty are not yet represented. Values and directional behavior require qualified review before any factual interpretation.

## Deterministic multi-year test fixtures

`tests/godot/crop_model_smoke.gd` runs three eight-model-year trajectories through the production condition and yield functions. Health is in scenario points on a 0–100 scale, pest pressure is an index on a 0–100 scale (not infestation percent), and fertilizer is a 0–100 reserve-point abstraction—not kg/ha or a field application rate.

| Test fixture | Initial health points | Initial pest-index points | Test-only reserve at each model-year boundary |
|---|---:|---:|---:|
| Baseline | 100 | 0 | 100 |
| Limited-input | 100 | 20 | 25 |
| Stress | 60 | 70 | 0 |

Each sample year runs `advance_condition` for 360 model days and records one representative lot estimate at that year's ending palm age. There are no pest-treatment events or maintenance-health bonuses in these tests. Refilling reserve at each model-year boundary is an explicit harness simplification used to compare direction; it is not an automatic gameplay policy, agronomic schedule, or recommendation. The test asserts determinism, no pre-year-three yield, positive first-window yield at year three, improved baseline vs. limited-input vs. stress health/output at sampled years, and bounds across all eight years. These fixture outputs are software regression evidence only; they do not validate parameter realism.

## Sources and ownership

These references inform only broad timing, life-cycle, and yield-factor choices; they do not validate the scenario coefficients above:

1. FAO, [*Modern Oil Palm Cultivation*](https://www.fao.org/4/t0309e/t0309e01.htm) — describes first production roughly 3–4 years after field planting and the young-palm establishment period.
2. Wilmar International, [Oil Palm Plantation & Milling](https://www.wilmar-international.com/our-businesses/plantation/oil-palm-plantation-milling) — reports fruit production around 30 months after planting, commercial harvest about six months later, peak production during years 7–18, an approximately 25-year commercial life, and mature-plantation output/density ranges used only for a rough per-palm scenario conversion.
3. Woittiez et al. (2017), [“Yield gaps in oil palm: A quantitative review of contributing factors”](https://doi.org/10.1016/j.eja.2016.11.002), *European Journal of Agronomy* 83, 57–77 — reviews water, nutrient, pest/disease and other yield factors; it also describes substantial bunch-development timing variation. The native model does not implement the paper's full physiology or yield-gap calculations.

**Model owner:** product owner/reviewer to be assigned. **Qualified agronomic reviewer:** pending. No numeric coefficient in this implementation is approved as operational advice or a locally representative value.

## M3 boundaries and next development

- `$1/kg` remains a prototype sale fixture; market-price simulation remains in M6.
- The current native slice adds an accelerated calendar, age/stage transitions, first/repeat harvest-window estimates, seasonal condition pressure, and an individual-age-based cohort outlook.
- The short outlook distinguishes ready-now kilograms from unready palms projected to become ready within one 30-day model month. Future lot estimates advance health, pest pressure, and fertilizer reserve through the deterministic scenario calendar; they exclude already-ready palms and do not include player maintenance that has not occurred.
- The earliest cohort window date is the first positive-yield lot under current modeled conditions. `—` means no positive-yield window is projected under the current age/condition assumptions, not that a palm is biologically incapable of future production.
- The current browser simulation is a separate prototype and may still use its earlier simplified values; do not compare it as native crop-model evidence.
- Cohort-level harvest-window decision feedback uses per-palm ages and a one-model-month forecast horizon. Eight-year baseline/limited-input/stress software fixtures are now covered, but remain illustrative test schedules. Keep numeric assumptions scenario-labeled and M3 acceptance open until a named owner and qualified reviewer assess the sources, ranges, fixtures, and cohort/calendar behavior.
