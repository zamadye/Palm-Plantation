extends RefCounted
class_name CropModel

## Small data-driven crop/calendar model. Numeric rates are scenario assumptions unless noted in docs/CROP_MODEL.md.
const DAYS_PER_MONTH := 30.0
const MONTHS_PER_YEAR := 12
const DAYS_PER_YEAR := 360.0
const DAYS_PER_SEASON := 90.0
## Decision-support horizon in game-days; one model month, not a real field-round schedule.
const COHORT_OUTLOOK_HORIZON_DAYS := DAYS_PER_MONTH

const YOUNG_STAGE_START_DAYS := DAYS_PER_YEAR
const MATURE_STAGE_START_DAYS := 30.0 * DAYS_PER_MONTH
const FIRST_COMMERCIAL_HARVEST_DAYS := 36.0 * DAYS_PER_MONTH
const PEAK_YIELD_START_YEARS := 7.0
const PEAK_YIELD_END_YEARS := 18.0
const PRODUCTION_END_YEARS := 25.0

## Scenario yield point derived from an approximate per-palm mature annual range; not a forecast.
const PEAK_ANNUAL_FFB_KG_PER_PALM := 180.0
const HARVEST_WINDOW_DAYS := 150.0
const FIRST_YIELD_FRACTION := 0.25
const LATE_LIFE_YIELD_FRACTION := 0.0
const MAX_PEST_YIELD_PENALTY := 0.20
const MAX_FERTILIZER_YIELD_BONUS := 0.05

## Quarterly scenario periods, not a location-specific climate calendar.
const SEASON_NAMES := [
	"WET PERIOD",
	"WET-TO-DRIER TRANSITION",
	"DRIER PERIOD",
	"DRIER-TO-WET TRANSITION"
]

## Scenario-only pressure rates in percentage points per game day, indexed by SEASON_NAMES.
const HEALTH_LOSS_POINTS_PER_DAY := [0.004, 0.007, 0.018, 0.008]
const PEST_PRESSURE_POINTS_PER_DAY := [0.035, 0.020, 0.005, 0.025]
const FERTILIZER_DECAY_PER_DAY := 0.25
const FERTILIZER_HEALTH_LOSS_MULTIPLIER := 0.70
const FERTILIZER_HEALTH_BONUS := 10.0
const PEST_TREATMENT_HEALTH_BONUS := 10.0
const PEST_TREATMENT_RISK_REDUCTION := 25.0

## A single visual bunch represents a simplified harvest lot. Development is centered on
## the cited 140–180 day range; repeated lots are still an abstraction of palm-level output.
const FIRST_LOT_DEVELOPING_DAYS := 1.0
const FIRST_LOT_READY_DAYS := 180.0
const RECOVERY_START_DAYS := 1.0
const RECOVERY_DEVELOPING_DAYS := 30.0
const REPEAT_LOT_READY_DAYS := 150.0


enum GrowthStage { SEEDLING, YOUNG, MATURE }


static func calendar_from_elapsed_days(elapsed_days: float) -> Dictionary:
	var whole_day := maxi(0, int(floor(elapsed_days)))
	var year_index := int(floor(float(whole_day) / DAYS_PER_YEAR))
	var day_of_year := whole_day % int(DAYS_PER_YEAR)
	var month := int(floor(float(day_of_year) / DAYS_PER_MONTH)) + 1
	var day_of_month := day_of_year % int(DAYS_PER_MONTH) + 1
	var season_index := clampi(int(floor(float(month - 1) / 3.0)), 0, SEASON_NAMES.size() - 1)
	return {
		"year": year_index + 1,
		"month": month,
		"day": day_of_month,
		"season_index": season_index,
		"season": str(SEASON_NAMES[season_index])
	}


static func calendar_label(elapsed_days: float) -> String:
	var calendar := calendar_from_elapsed_days(elapsed_days)
	return "Y%02d/M%02d/D%02d" % [calendar.year, calendar.month, calendar.day]


static func season_name_at(elapsed_days: float) -> String:
	var calendar := calendar_from_elapsed_days(elapsed_days)
	return str(calendar.season)


static func season_index_at(elapsed_days: float) -> int:
	var calendar := calendar_from_elapsed_days(elapsed_days)
	return int(calendar.season_index)


static func cohort_id_at(planting_day: float) -> String:
	var calendar := calendar_from_elapsed_days(planting_day)
	return "Y%02d-M%02d" % [calendar.year, calendar.month]


static func growth_stage_for_age(age_days: float) -> int:
	if age_days >= MATURE_STAGE_START_DAYS:
		return GrowthStage.MATURE
	if age_days >= YOUNG_STAGE_START_DAYS:
		return GrowthStage.YOUNG
	return GrowthStage.SEEDLING


static func growth_progress_to_next_stage(age_days: float) -> float:
	if age_days >= MATURE_STAGE_START_DAYS:
		return 1.0
	var stage_start := 0.0
	var stage_end := YOUNG_STAGE_START_DAYS
	if age_days >= YOUNG_STAGE_START_DAYS:
		stage_start = YOUNG_STAGE_START_DAYS
		stage_end = MATURE_STAGE_START_DAYS
	return clampf((age_days - stage_start) / (stage_end - stage_start), 0.0, 1.0)


static func game_days_to_years(game_days: float) -> float:
	return maxf(0.0, game_days) / DAYS_PER_YEAR


static func annual_yield_fraction(age_days: float) -> float:
	var age_years := game_days_to_years(age_days)
	if age_years < FIRST_COMMERCIAL_HARVEST_DAYS / DAYS_PER_YEAR:
		return 0.0
	if age_years < PEAK_YIELD_START_YEARS:
		var ramp := inverse_lerp(FIRST_COMMERCIAL_HARVEST_DAYS / DAYS_PER_YEAR, PEAK_YIELD_START_YEARS, age_years)
		return lerpf(FIRST_YIELD_FRACTION, 1.0, clampf(ramp, 0.0, 1.0))
	if age_years <= PEAK_YIELD_END_YEARS:
		return 1.0
	if age_years < PRODUCTION_END_YEARS:
		var decline := inverse_lerp(PEAK_YIELD_END_YEARS, PRODUCTION_END_YEARS, age_years)
		return lerpf(1.0, LATE_LIFE_YIELD_FRACTION, clampf(decline, 0.0, 1.0))
	return 0.0


static func days_to_next_harvest_window(age_days: float, fruit_cycle_days: float, harvest_count: int, harvest_ready: bool) -> float:
	if harvest_ready:
		return 0.0
	if harvest_count == 0:
		return maxf(0.0, FIRST_COMMERCIAL_HARVEST_DAYS - maxf(0.0, age_days))
	return maxf(0.0, REPEAT_LOT_READY_DAYS - maxf(0.0, fruit_cycle_days))


static func estimate_harvest_lot_kg(
	age_days: float, health: float, pest_risk: float, fertilizer_reserve: float
) -> int:
	var annual_fraction := annual_yield_fraction(age_days)
	if annual_fraction <= 0.0:
		return 0
	var health_factor := clampf(health / 100.0, 0.0, 1.0)
	var pest_factor := 1.0 - clampf(pest_risk / 100.0, 0.0, 1.0) * MAX_PEST_YIELD_PENALTY
	var nutrition_factor := 1.0 + clampf(fertilizer_reserve / 100.0, 0.0, 1.0) * MAX_FERTILIZER_YIELD_BONUS
	var lot_yield := (
		PEAK_ANNUAL_FFB_KG_PER_PALM
		* annual_fraction
		* (HARVEST_WINDOW_DAYS / DAYS_PER_YEAR)
		* health_factor
		* pest_factor
		* nutrition_factor
	)
	return maxi(0, int(round(lot_yield)))


static func project_harvest_lot_kg(
	age_days: float,
	health: float,
	pest_risk: float,
	fertilizer_reserve: float,
	current_day: float,
	days_until_window: float
) -> int:
	var forecast_days := maxf(0.0, days_until_window)
	var projected_condition := advance_condition(
		health, pest_risk, fertilizer_reserve, current_day, forecast_days
	)
	return estimate_harvest_lot_kg(
		age_days + forecast_days,
		float(projected_condition.health),
		float(projected_condition.pest_risk),
		float(projected_condition.fertilizer)
	)


static func advance_condition(
	health: float, pest_risk: float, fertilizer_reserve: float, from_day: float, day_delta: float
) -> Dictionary:
	var remaining_days := maxf(0.0, day_delta)
	var cursor := maxf(0.0, from_day)
	var next_health := clampf(health, 0.0, 100.0)
	var next_pest_risk := clampf(pest_risk, 0.0, 100.0)
	var next_fertilizer := maxf(0.0, fertilizer_reserve)

	while remaining_days > 0.000001:
		var day_in_year := fposmod(cursor, DAYS_PER_YEAR)
		var season_index := clampi(int(floor(day_in_year / DAYS_PER_SEASON)), 0, SEASON_NAMES.size() - 1)
		var days_in_season := fposmod(day_in_year, DAYS_PER_SEASON)
		var days_to_boundary := DAYS_PER_SEASON - days_in_season
		if days_to_boundary <= 0.000001:
			days_to_boundary = DAYS_PER_SEASON
		var segment_days := minf(remaining_days, days_to_boundary)
		var fertilized_days := 0.0
		if FERTILIZER_DECAY_PER_DAY > 0.0:
			fertilized_days = minf(segment_days, next_fertilizer / FERTILIZER_DECAY_PER_DAY)
		var unfertilized_days := maxf(0.0, segment_days - fertilized_days)
		var health_loss_rate: float = float(HEALTH_LOSS_POINTS_PER_DAY[season_index])
		var pest_pressure_rate: float = float(PEST_PRESSURE_POINTS_PER_DAY[season_index])
		var total_health_loss := health_loss_rate * (
			fertilized_days * FERTILIZER_HEALTH_LOSS_MULTIPLIER + unfertilized_days
		)
		next_health = clampf(next_health - total_health_loss, 0.0, 100.0)
		next_pest_risk = clampf(next_pest_risk + pest_pressure_rate * segment_days, 0.0, 100.0)
		next_fertilizer = maxf(0.0, next_fertilizer - FERTILIZER_DECAY_PER_DAY * segment_days)
		cursor += segment_days
		remaining_days -= segment_days

	return {
		"health": next_health,
		"pest_risk": next_pest_risk,
		"fertilizer": next_fertilizer
	}
