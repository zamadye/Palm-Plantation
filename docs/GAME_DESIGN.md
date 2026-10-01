# Game Design

## Design intent

**Palm Plantation** is a compact, elevated-view strategy/management game about building and operating a tropical oil-palm estate. The player makes connected land, crop, labour, logistics, finance, and stewardship decisions and sees delayed consequences over an accelerated multi-year campaign.

The game is not first-person manual farming, a real-world operations planner, a clicker, or an infinite-map tycoon. The strategic unit is primarily the **block and crop cohort**. Individual palms may be inspectable visual proxies for clarity, but launch economics and agronomy should not require a separate live entity for every real-world tree.

The production target is Godot 4.x on modest/mobile hardware. The current browser build is a distinct prototype, not the production game.

## Player promise and pillars

1. **Plan the estate, not just tap actions.** Every block competes for time, labour, inputs, infrastructure, and cash.
2. **Understand delayed outcomes.** Establishment, maintenance, harvest, delivery, and revenue have visible lead times and cause/effect.
3. **Be accelerated, not arbitrary.** Compress the calendar for playability while preserving sequence, constraints, season/year context, and uncertainty. Do not present test values as fact.
4. **Manage the whole chain.** Land and crop choices connect to available crews, FFB quality/throughput, mill capacity, sales, and cash flow.
5. **Make trade-offs legible.** Forecasts show assumptions and risks; the game does not hide costs or prescribe real agronomy.
6. **Respect the landscape and people.** Land, habitat, soil/water, worker conditions, and community constraints are visible systems, not decoration or marketing claims.
7. **Readable at mobile scale.** A glanceable estate map, clear state labels, touch-safe controls, and concise reports take priority over tiny simulation detail.

## Eight gameplay layers

### 1. Estate strategy and land portfolio

The player decides which finite blocks to develop, maintain, defer, or keep protected. Each decision should expose the affected area, up-front and recurring requirements, lead time, expected production window, and constraint/risk. Launch uses one compact estate with four managed blocks; there is no infinite terrain or open-ended land acquisition in the initial product.

### 2. Field establishment and infrastructure

Survey/land state, preparation, access, drainage/base infrastructure, and establishment compete for limited cash and crew capacity. The current starter shelter and clearing flow are a prototype tutorial scaffold, not a complete infrastructure strategy. Land-development actions must be explainable and reversible only where the design says so.

### 3. Crop lifecycle and agronomy

Planting cohorts move through reviewed development and production stages; health, inputs, risk, and timing affect yield. The target is an explainable, simplified model that supports choices—not a tree-by-tree scientific simulator. The exact crop/calendar/yield ranges require traceable sources and domain review in M3.

### 4. Labour and operational planning

The player assigns a bounded number of work crews and schedules tasks. Capacity, travel/route abstraction, productivity, safety, and welfare create operational trade-offs. Workers should be represented as people, not disposable counters. The current one-worker queue is only a proof of task flow.

### 5. Harvest and field logistics

Harvest timing, available labour, carrying/collection capacity, distance, and delivery timing determine what happens to ready FFB. Harvest readiness, reserved work, harvested quantity, carried stock, and delivered stock must be distinct, visible states with conserved quantities.

### 6. Processing and market chain

One local outlet/mill receives finite deliveries, processes bounded throughput, and exposes quality/acceptance and price rules. The player can trace each batch to a result. Launch does not simulate global commodity exchange or an industrial refinery chain.

### 7. Finance and business strategy

The player compares capital, operating inputs, labour, logistics, sales, liquidity, and expansion. Every balance change must be auditable in a ledger. The current `$1/kg` sale is strictly a placeholder; no prototype price or yield should be described as a realistic budget.

### 8. Stewardship, risk, and community

Development and operations interact with protected areas, land/soil/water condition, habitat, fire/pest pressure, worker welfare, and community-facing constraints. Keep launch depth finite and comprehensible. Any factual legal or environmental rule must be tied to a stated jurisdiction and reviewed; otherwise label it as a fictional scenario rule.

## Core play cycle

1. **Inspect:** review estate map, calendar, cash, crop cohorts, labour capacity, risks, and recent results.
2. **Choose:** develop/defer a block, select an operation, buy/allocate an input, or set a priority.
3. **Commit:** see costs, prerequisites, expected timing, and affected blocks before confirming.
4. **Schedule:** work enters a visible queue with owner, target, progress, and possible blockers.
5. **Advance time:** pause/normal/fast-forward controls let the player observe growth and work at a chosen pace. Fast-forward never skips a decision silently; important thresholds can notify the player.
6. **Resolve:** crop, work, season, logistics, processing, and finance update in a deterministic order for the selected scenario.
7. **Review:** compare forecast with outcome, inspect ledger and exceptions, then re-plan.
8. **Repeat:** harvest → deliver → process/sell → reinvest, while balancing the long-term condition of the estate.

The present prototype does not yet implement all these steps. In particular it lacks pausing, seasons, a multi-block strategy layer, the mill, a real ledger, and stewardship systems.

## Accelerated agricultural realism policy

- **Compress elapsed time, preserve ordering.** A playable session can represent years, but a seedling must not appear commercially mature after a few literal in-game days without an explicit compression/scenario label.
- **Keep units and calendars explicit.** Display game day/month/year and clarify when a value is per palm, cohort, area, work shift, or delivered tonne.
- **Use ranges and uncertainty where appropriate.** Do not imply precision beyond the model or source data.
- **Separate model fact from scenario convenience.** Every parameter carries source, range, uncertainty, and a `factual`, `illustrative`, or `test-only` label in the data/design record.
- **Preserve meaningful constraints.** Labour, tools/inputs, terrain/route time, processing capacity, cash flow, and stewardship limits must be represented where they change a decision.
- **Avoid operational advice claims.** The game is entertainment/education, not a substitute for agronomic, legal, financial, or safety guidance.
- **Review the current prototype numbers.** The 8/45-day stage thresholds, 4/15/20-day fruit thresholds, 180 kg base yield, $1/kg sale, starting inventory, and fixed action costs are test values until reviewed and replaced or kept only in a labeled tutorial fixture.

## Player information and controls

- Primary view: elevated 3D estate map, compact and readable on a landscape mobile screen.
- Default management operates on block/cohort selections; individual visual palms are used for inspection and teaching.
- A persistent summary shows game calendar, cash/stock, active objective, time controls, and high-priority warnings.
- Context panels explain selected block, crew, crop cohort, collection point, or outlet, with prerequisites and costs before action.
- Touch is the primary input. Camera pan/zoom, selection, placement, and panel actions need distinct hit areas and clear feedback. Desktop mouse/keyboard remains useful for development.
- Status cannot be communicated by color alone. Use text/icon/pattern as well as color; support readable text at the minimum agreed resolution.
- Pause, normal, and fast-forward are target controls for launch. Current prototype has 1×/2×/4×/6× only; pause and the final time semantics are not yet implemented or validated.

## Bounded launch scope

The launch planning baseline is one offline single-player campaign, one compact estate map with four managed blocks, oil palm as the only crop, one reviewed accelerated multi-year baseline model, a limited crew roster, one local mill/outlet, a transparent ledger, a bounded set of stewardship constraints, local save/load, and a guided first campaign. The target build is Godot 4.x, mobile-first in landscape; Android is the proposed first mobile platform, pending confirmation in M0. PC may be used for development and QA. iOS and browser shipping are not promised.

This is intentionally finite: no multiplayer, cloud accounts, player market, infinite map, broad crop catalogue, complex driving, or post-mill refinery simulation. Counts and regional/economic parameters are planning boundaries for review—not completed or validated features. See [ROADMAP.md](ROADMAP.md) for the full scope and acceptance gates.

## Current prototype vs. target

| Topic | Current audited prototype | Target design |
|---|---|---|
| Camera/game mode | Elevated strategy view; one compact test map | Same strategy/management identity, expanded through a finite estate campaign |
| Land | One fixed forest block | Four managed blocks with strategic develop/defer/protect choices |
| Crop | Sixteen planting slots; individual palm records | Reviewed cohort/block model with inspectable representative visuals |
| Agronomy | Simplified age/health/fertilizer/pest counters | Sourced, transparent, accelerated multi-year model with uncertainty |
| Labour | One worker and task queue | Bounded crew allocation and capacity-aware schedules |
| Logistics | Worker carries harvest to one collection point | Traceable harvest-to-outlet flow with capacity and quality rules |
| Market | Fixed `$1/kg` sale placeholder | One transparent local outlet/mill and reviewed pricing assumptions |
| Finance | Starting cash and a few fixed costs | Auditable operating ledger and bounded expansion choices |
| Stewardship | None | Visible constraints, indicators, and mitigation choices |
| Persistence | None | Versioned local save/load |
| Runtime | Separate browser preview can run; native Godot is unverified | Godot is the production source and acceptance target |

## Explicit non-goals and scope control

Ideas outside the bounded launch scope are tracked in the roadmap's `FUTURE_BACKLOG`. They do not enter production work without user approval and a written milestone, acceptance criteria, and displaced-scope decision. A realistic-sounding idea is not automatically in scope.
