# Product Roadmap

## Purpose and authority

This roadmap defines the bounded product scope, M0–M10 sequence, and the evidence required to accept each milestone. It is the scope-change authority for gameplay. An idea not in an accepted milestone belongs under [`FUTURE_BACKLOG`](#future_backlog); it must not be implemented automatically.

No calendar dates or delivery estimates are assigned. Milestones are gates, not promises. The task-level execution plan is [DEV_PLAN.md](DEV_PLAN.md); current evidence is [PROJECT_STATUS.md](../PROJECT_STATUS.md).

## Product direction

Build a compact, single-player **strategy/management** game about operating an oil-palm estate. The player plans land use and investment, schedules work, reads delayed crop outcomes, moves FFB through the local supply chain, and balances cash with long-term stewardship. The camera stays at an elevated miniature-world scale. This is not a first-person farming simulator, a clicker/idle game, or a vehicle-driving game.

The production target is Godot 4.x, Mobile renderer, and modest/mobile hardware. The browser/Three.js implementation is a separate prototype and test surface—not a Godot importer, production runtime, or source of native acceptance.

### The eight gameplay layers

All eight are part of the intended strategy-management loop. Current implementation state is recorded separately in [PROJECT_STATUS.md](../PROJECT_STATUS.md).

1. **Estate strategy and land portfolio** — choose what to develop, defer, or protect; understand tenure, block layout, and opportunity cost.
2. **Field establishment and infrastructure** — survey and prepare land; choose establishment priorities and essential access/drainage/base infrastructure.
3. **Crop lifecycle and agronomy** — plan planting cohorts, maturity, routine inputs, health, and yield over an accelerated multi-year horizon.
4. **Labour and operational planning** — assign work, manage crew capacity, productivity, safety, welfare, and schedules.
5. **Harvest and field logistics** — decide harvest timing and move FFB from block to collection without losing track of quantity or timing.
6. **Processing and market chain** — route deliveries through a bounded local mill/processing outlet and make sales under transparent capacity and price rules.
7. **Finance and business strategy** — compare capital and operating costs, revenue, liquidity, and expansion choices using an auditable ledger.
8. **Stewardship, risk, and community** — make land, soil/water, habitat, fire/pest, worker, and community trade-offs visible and consequential.

### Accelerated-but-believable realism

Acceleration is a presentation and session-length choice, not permission to make biological or commercial claims from arbitrary values. Preserve cause and effect, season/year ordering, resource constraints, lead times, harvest windows, and trade-offs. Compress elapsed time transparently. The native Godot M3 working slice now has a 30-day model month, named scenario periods, field-age stages, a first commercial window near model year three, an age-based yield curve, condition/input effects, and a month-keyed per-palm harvest-window outlook; see [`CROP_MODEL.md`](CROP_MODEL.md). Those coefficients remain scenario assumptions pending qualified review and must not be presented as local agronomic advice. Browser prototype values remain separate. **`$1/kg` is a prototype fixture value unless explicitly promoted to a sourced market-price assumption.** Market-price simulation belongs to M6; M3 must not silently acquire it merely because the prototype has a fixed price. Show the game calendar and communicate that the model is simplified.

## Milestone status snapshot

`COMPLETE` is reserved for milestones whose acceptance criteria and test gates all pass. Existing code, a successful browser-only test, or a parsed script is not enough. The user authorized a curated palm subset and later a bounded generic operation-visual subset; neither changes M2 visual/input acceptance or M3 qualified-review gates. Operation assets are static placeholders and do not replace process stages. M0/M1 validation debt is not waived.

| ID | Milestone | Status | Exit condition in one line |
|---|---|---|---|
| M0 | Direction, scope, and production validation foundation | **IN PROGRESS** | Documents are accepted, Godot baseline is reproducible, test commands and target device are agreed. |
| M1 | Estate establishment | **IN PROGRESS — validation debt** | Native fresh-state shelter → clearing → planting flow passes all resource, slot, and restart-free acceptance cases. |
| M2 | First Harvest | **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS** | Godot 4.3 import, 109 simulation assertions, and 110 structural assertions pass; first harvest is tested at the 36-model-month boundary. Native visible-renderer and physical-input acceptance remains UNVERIFIED, so M2 is not COMPLETE. |
| M3 | Credible Crop and Agronomy Model | **IN PROGRESS** | Calendar/cohort behavior, scenario assumptions, maturity-boundary timing, and deterministic eight-model-year baseline/limited-input/stress trajectories are covered by 65 focused checks; named owner and qualified review remain open. |
| M4 | Workforce and field operations | **NOT STARTED** | Planned crews can be assigned work and move/complete/deliver tasks without deadlocks or lost work. |
| M5 | Estate strategy and finance | **NOT STARTED** | The player can compare bounded development choices using a complete, auditable operating ledger. |
| M6 | Mill, processing, and markets | **NOT STARTED** | FFB flows through a capacity-limited local outlet to a transparent, testable sale result. |
| M7 | Stewardship and operating risk | **NOT STARTED** | Land, environmental, worker, and community constraints affect decisions and have reviewed model definitions. |
| M8 | Onboarding, content, and presentation | **NOT STARTED** | A new player can complete the campaign’s core loop with legible, accessible mobile UI and clear feedback. |
| M9 | Persistence, reliability, and mobile performance | **NOT STARTED** | Save/load, performance budgets, compatibility, and recovery gates pass on the agreed baseline device. |
| M10 | Release candidate and launch | **NOT STARTED** | All release criteria, legal/licensing checks, builds, and final-device acceptance are complete. |

**Execution note:** the user authorized the curated four-model Nature Kit palm subset and later a small CC0 operation-visual subset documented in [`ASSET_PLAN.md`](ASSET_PLAN.md). The operation assets are static generic placeholders; they do not implement or replace any process stage, and FFB cues remain procedural. Neither asset slice waives M2's native rendered/input gate or M3's qualified-review gate. The browser/Three.js build remains a separate prototype, and the five existing HUD action icons are retained.

## Milestones and acceptance gates

### M0 — Direction, scope, and production validation foundation

**Scope:** approve the design documents; retain Godot as production; explicitly label browser prototype boundaries; choose the supported device/OS baseline; add reproducible project import and test instructions. Do not add gameplay during document review.

**Acceptance:**
- User reviews and accepts the planning baseline or explicitly records changes.
- Godot 4.3+ can import the project and launch `scenes/main/main.tscn` with exit code 0 and no script/runtime errors in the captured log.
- A repository-backed test command is documented and produces the same result from a clean checkout.
- Minimum supported mobile device/OS, test resolution/orientation, and profiling procedure are recorded.
- Browser and native checks are listed and reported separately.

### M1 — Estate establishment

**Scope:** validate the existing starter shelter, one surveyed block, land clearing/preparation, and 4 × 4 planting grid. Preserve the present prototype unless tests reveal defects; do not expand estate scope yet.

**Acceptance:**
- On a fresh native session, a player can place one valid shelter, pay exactly the displayed cost once, and complete construction.
- Clearing is unavailable before shelter completion; valid clearing costs exactly `$150` once in the current prototype, and invalid/repeated requests do not charge funds.
- Clearing produces exactly sixteen distinct planting slots. Queueing then completing a planting consumes one seedling once, creates one palm at the selected slot, and prevents duplicate occupancy.
- All sixteen slots can be filled without duplicate IDs/positions or negative inventory; invalid/out-of-range actions change no resources.
- The same sequence is replayable in the Godot test harness and has no engine errors. Values are test-fixture values, not launch economy.

### M2 — First Harvest (**current**)

**Scope:** close the first complete crop cycle already present in the prototype: mature fruit, valid harvest reservation, worker task, FFB collection, sale record, and a repeat cycle. Browser evidence is useful but not a substitute for native validation.

**Acceptance:**
- A fresh native test scenario reaches one harvest-ready palm using the current accelerated test fixture.
- A non-ready or already-reserved palm cannot be harvested; a valid request creates exactly one task/reservation.
- Completion moves exactly the computed FFB quantity from palm to worker, then to collection; no quantity appears in sold stock before delivery.
- Sale creates exactly one transaction, clears exactly the sold stock, and applies the fixture price once. The current `$1/kg` is a placeholder rule, not a launch-market acceptance.
- After the recovery/regrowth interval, the same palm can produce and complete another harvest without being removed, double-counted, or sold twice.
- Browser and Godot acceptance suites are separately reproducible and reported separately. M2 remains **FUNCTIONALLY IMPLEMENTED / NATIVE ACCEPTANCE IN PROGRESS** until the native suite and all native acceptance gates, including the main-scene interaction/rendering gate below, pass; evidence must be checked in or reproducible from documented repository commands.
- The actual native main-scene harvest → delivery → sale → repeat interaction is accepted on a usable non-Dummy renderer: world, palms, shelter, worker, and HUD are visibly verified, and the supported input path works. A headless scene-graph smoke does not satisfy this visual/input gate.

### M3 — Credible Crop and Agronomy Model

**Scope:** replace placeholder time/yield/health assumptions with a compact, transparent model. Model only variables needed to make estate decisions, not a research-grade agronomy simulator.

**Boundary:** M3 owns crop/calendar/agronomy assumptions. `$1/kg` is a prototype fixture value unless explicitly promoted to a sourced market-price assumption; market-price simulation remains within M6 — Mill, Processing, and Markets.

**Acceptance:**
- Every production parameter (growth/maturity timing, yield range, input effects, pest/season effects) has a source or an explicitly labeled scenario assumption, units, range, and review owner in the design/data notes.
- The calendar advances through named seasons/years while preserving causal order; display makes compression explicit.
- At least three deterministic fixtures (baseline, constrained input/health, and stress case) show expected directional results, with no negative age, health, or resource values and no impossible state transition.
- Re-running the same seed and inputs reproduces the same outputs; changing one input changes only documented dependent outputs.
- A subject-matter review signs off before any value is described as representative of real operations.

### M4 — Workforce and field operations

**Scope:** move beyond the single-worker demonstration into bounded crew assignment, task priority, route/travel cost, work capacity, and basic worker safety/welfare feedback. Use abstraction where detailed path simulation does not improve a strategic decision.

**Acceptance:**
- At least two independently assignable work units can receive, queue, start, pause/cancel where designed, and complete tasks without assigning one task twice.
- A deterministic workload fixture of 100 queued tasks completes or reports a visible blocking condition; no task or inventory is silently lost.
- Harvested FFB stays within defined carrying/collection capacity; overload and blocked routes produce actionable UI feedback.
- Productivity, schedule, and safety/welfare effects are exposed in the UI and covered by tests; no real-world worker-safety advice is implied by unreviewed coefficients.

### M5 — Estate strategy and finance

**Scope:** add bounded land-development choices and a transparent ledger so decisions have opportunity cost over time. Keep the launch map finite.

**Acceptance:**
- The launch scenario contains one estate map and four developable/managed blocks, with at least two materially different development sequences that can be compared.
- Every cash/resource change has a ledger entry, source, game date, and category; a scenario replay reconciles opening balance + inflows − outflows = closing balance exactly.
- Capital, operating inputs, labour, and revenue are visible separately; no hidden price mutation or free duplicate transaction exists.
- A deterministic short-horizon comparison shows a measurable trade-off (for example, earlier revenue versus liquidity/land stewardship), and the player can inspect assumptions before committing.

### M6 — Mill, processing, and markets

**Scope:** model one bounded local mill/outlet, delivery throughput and basic FFB quality/price factors. No global commodity exchange or complex downstream refinery simulation in launch scope.

**Acceptance:**
- Each delivery is identified once; delivered kilograms equal accepted + rejected/held quantities, with no mass duplication.
- Mill/outlet capacity and a queue have deterministic behavior at normal and overloaded throughput.
- Sale price/revenue is derived from visible, testable inputs and recorded transaction data; same inputs produce same results.
- A player can trace a batch from field harvest to accepted/rejected amount to cash ledger entry.

### M7 — Stewardship and operating risk

**Scope:** make land-use boundaries, soil/water pressure, habitat, fire/pest risk, worker welfare, and community-facing constraints visible enough to affect strategy. Avoid presenting the game as a certification, legal, or agronomic authority.

**Acceptance:**
- The scenario defines protected/no-go areas and at least two measurable stewardship indicators before development choices are made.
- A prohibited action is blocked or produces a clearly explained consequence; the player can inspect the rule and affected area.
- At least two mitigation/management choices have different costs and measurable outcomes in deterministic fixtures.
- Every real-world rule or coefficient shown as factual has a traceable jurisdiction-specific source and domain review; otherwise it is labeled fictional/illustrative.

### M8 — Onboarding, content, and presentation

**Scope:** explain the eight layers through a guided but skippable first campaign, accessible information hierarchy, clear consequence feedback, and final art/audio polish justified by the asset plan.

**Acceptance:**
- A first-time tester can start a new game, complete the first harvest-to-sale loop, and identify the next objective without developer help in at least 4 of 5 observed test sessions.
- All important actions are discoverable by touch, never communicated by color alone, and have readable labels at the supported baseline resolution.
- Time controls include pause, normal, and fast-forward; pausing advances no logical day, task, growth, or ledger state, and repeated runs at each speed preserve deterministic outcomes.
- Tutorial prompts can be dismissed/revisited; settings and interruption/pause behavior are consistent.
- Art/audio credits and licenses are complete; no placeholder or missing asset is present in the launch path.

### M9 — Persistence, reliability, and mobile performance

**Scope:** versioned local save/load, performance profiling and optimization, device compatibility, recovery from app interruption, and release-candidate stability.

**Acceptance:**
- Save/load round-trip preserves calendar, land, palms/cohorts, tasks, inventory, ledger, and settings exactly in a deterministic fixture; old/invalid saves fail safely with a recoverable message.
- A 30-minute stress run on the agreed minimum device meets the provisional budgets in [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md) and [QA_PLAN.md](QA_PLAN.md).
- No blocker/high-severity crash or data-loss defect is open; performance captures and device/build IDs are attached to the release evidence.
- App suspend/resume and low-storage save failure are tested without corrupting the previous valid save.

### M10 — Release candidate and launch

**Scope:** package only the accepted bounded launch product. No new system may enter M10 without a formal roadmap change and re-test budget.

**Acceptance:**
- M0–M9 gates are COMPLETE; all Must-Ship items in [LAUNCH_CHECKLIST.md](LAUNCH_CHECKLIST.md) pass.
- The signed release build installs, starts offline, loads/saves a campaign, and completes the first-harvest loop on every supported device/OS class.
- No open critical/high-severity defect, no unlicensed asset, and no unreviewed factual agricultural/legal claim remains.
- Store/package metadata, privacy disclosure, support/rollback plan, and final credits are reviewed and approved.

## Bounded launch scope

The planning target is a small offline product, not a scalable live-service simulation:

- One single-player campaign/scenario on one compact estate map; **four managed blocks**.
- Oil palm as the sole launch crop, with one reviewed baseline production model and a clearly accelerated multi-year calendar.
- A complete loop across all eight layers at a deliberately bounded depth: land/block choices; establishment; crop care; crew planning; harvest and FFB delivery; one local mill/outlet; transparent finance; and visible stewardship constraints.
- One local processing/sales route, a limited number of crew types, deterministic scenario fixtures, local save/load, and an onboarding path.
- Godot 4.x production build, landscape/mobile-first presentation, with the minimum supported device defined in M0. Android is the proposed first mobile platform, pending M0 confirmation. Desktop may be used for development and test; iOS and browser shipping are not promised.
- No multiplayer, cloud service, player trading, mod support, global commodity exchange, multi-crop catalogue, unlimited map generation, detailed vehicle driving, or post-mill industrial chain in launch scope.

Counts and regional/economic parameters in this target are planning boundaries. Confirm or revise them during document acceptance before implementation; do not silently widen them.

## Browser-to-Godot policy

`web-preview/` remains a separately authored prototype. It can be used for interaction exploration and browser-only simulation tests, but its results must be labeled **Browser**. Production rules, save data, engine interactions, device performance, and release acceptance belong to Godot. The staged transition is defined in [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md); no automatic importer or code conversion is planned.

## FUTURE_BACKLOG

These ideas are explicitly outside the bounded launch scope and are **not authorized for implementation**. Reconsider only through a user-approved roadmap change with cost, risk, and test gates:

- Additional crops, cultivars, regions, estates, and generated/infinite maps.
- Multiplayer, asynchronous competition, online prices, cloud saves, accounts, backend services, or live operations.
- Detailed vehicle driving, full road/pathfinding simulation, refinery/downstream product chains, and global commodity markets.
- Modding, user-generated content, community marketplace, and workshop support.
- Post-launch scenarios, advanced research/technology trees, and high-fidelity agronomy or certification auditing.
- Additional platforms (including iOS and browser shipping) beyond the agreed Godot mobile-first release target.
