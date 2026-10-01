extends SceneTree

const CropModel = preload("res://scripts/simulation/crop_model.gd")
const PalmRecord = preload("res://scripts/simulation/palm_record.gd")
const PlantationSimulation = preload("res://scripts/simulation/plantation_simulation.gd")

var _failures := 0
var _checks := 0


func _initialize() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	_test_calendar_and_stages()
	_test_first_harvest_maturity_boundary()
	_test_three_yield_fixtures()
	_test_multi_year_scenario_trajectories()
	_test_season_and_input_direction()
	_test_cohort_rollup()
	if _failures == 0:
		print("PASS: %d targeted crop-model checks" % _checks)
		quit(0)
	else:
		push_error("FAIL: %d of %d crop-model checks failed" % [_failures, _checks])
		quit(1)


func _test_calendar_and_stages() -> void:
	var start := CropModel.calendar_from_elapsed_days(0.0)
	var new_year := CropModel.calendar_from_elapsed_days(CropModel.DAYS_PER_YEAR)
	_expect(start.year == 1 and start.month == 1 and start.day == 1, "calendar starts at year 1, month 1, day 1")
	_expect(new_year.year == 2 and new_year.month == 1 and new_year.day == 1, "360 game days advance to the next model year")
	_expect(CropModel.season_index_at(89.9) == 0, "first scenario period covers the first quarter")
	_expect(CropModel.season_index_at(90.0) == 1, "scenario period changes at the quarter boundary")
	_expect(CropModel.cohort_id_at(90.0) == "Y01-M04", "planting cohort IDs follow the accelerated calendar")
	_expect(
		CropModel.growth_stage_for_age(CropModel.MATURE_STAGE_START_DAYS - 0.1) == CropModel.GrowthStage.YOUNG,
		"palm remains young immediately before the mature-stage threshold",
	)
	_expect(
		CropModel.growth_stage_for_age(CropModel.MATURE_STAGE_START_DAYS) == CropModel.GrowthStage.MATURE,
		"palm enters the mature stage at the model threshold",
	)


func _test_first_harvest_maturity_boundary() -> void:
	var simulation = PlantationSimulation.new()
	simulation._ready()
	var palm = PalmRecord.new()
	palm.id = "timing_regression_palm"
	palm.age = CropModel.MATURE_STAGE_START_DAYS - CropModel.DAYS_PER_MONTH
	palm.growth_stage = CropModel.growth_stage_for_age(palm.age)
	palm.health = 100.0
	palm.pest_risk = 0.0
	palm.fertilizer = 0.0
	simulation.palms.append(palm)

	simulation._advance_growth(CropModel.DAYS_PER_MONTH, 0.0)
	_expect(
		is_equal_approx(palm.age, CropModel.MATURE_STAGE_START_DAYS)
			and is_equal_approx(palm.fruit_cycle_days, 0.0),
		"maturity-crossing time does not count pre-mature days toward the first fruit lot",
	)
	_expect(
		palm.fruit_state == PalmRecord.FruitState.NONE and not palm.harvest_ready,
		"first fruit development does not start before the maturity boundary",
	)

	simulation._advance_growth(
		CropModel.FIRST_LOT_READY_DAYS - 1.0, CropModel.DAYS_PER_MONTH
	)
	_expect(
		is_equal_approx(palm.fruit_cycle_days, CropModel.FIRST_LOT_READY_DAYS - 1.0)
			and not palm.harvest_ready,
		"first lot remains unready one full model day before the 180-day development threshold",
	)

	simulation._advance_growth(1.0, CropModel.MATURE_STAGE_START_DAYS + CropModel.FIRST_LOT_READY_DAYS - 1.0)
	_expect(
		is_equal_approx(
			palm.age,
			CropModel.MATURE_STAGE_START_DAYS + CropModel.FIRST_LOT_READY_DAYS
		)
			and palm.harvest_ready
			and palm.fruit_quantity > 0.0,
		"first positive-yield lot becomes ready at the documented 36-model-month window",
	)
	simulation.free()


func _test_three_yield_fixtures() -> void:
	var peak_age_days := CropModel.PEAK_YIELD_START_YEARS * CropModel.DAYS_PER_YEAR
	var baseline := CropModel.estimate_harvest_lot_kg(peak_age_days, 100.0, 0.0, 0.0)
	var constrained := CropModel.estimate_harvest_lot_kg(peak_age_days, 70.0, 25.0, 0.0)
	var stress := CropModel.estimate_harvest_lot_kg(peak_age_days, 45.0, 65.0, 0.0)
	var nourished := CropModel.estimate_harvest_lot_kg(peak_age_days, 100.0, 0.0, 100.0)
	_expect(
		baseline > constrained and constrained > stress,
		"baseline, constrained, and stress fixtures have directional yields",
	)
	_expect(nourished > baseline, "fertilizer reserve improves the scenario yield estimate")
	_expect(
		baseline == CropModel.estimate_harvest_lot_kg(peak_age_days, 100.0, 0.0, 0.0),
		"identical scenario inputs reproduce the same yield output",
	)
	var maximum_pest_yield := CropModel.estimate_harvest_lot_kg(peak_age_days, 100.0, 100.0, 0.0)
	var zero_health_yield := CropModel.estimate_harvest_lot_kg(peak_age_days, 0.0, 0.0, 0.0)
	_expect(maximum_pest_yield >= 0, "maximum pest pressure never produces negative FFB")
	_expect(maximum_pest_yield < baseline, "pest pressure reduces yield with age, health, and reserve held constant")
	_expect(zero_health_yield == 0, "zero health removes yield without producing negative kilograms")


func _test_multi_year_scenario_trajectories() -> void:
	# These are deliberately simplified, test-only schedules—not factual field prescriptions.
	# Fertilizer reserve is reset at each model-year boundary to expose directional contrasts.
	var baseline := _build_scenario_trajectory(100.0, 0.0, 100.0)
	var constrained := _build_scenario_trajectory(100.0, 20.0, 25.0)
	var stress := _build_scenario_trajectory(60.0, 70.0, 0.0)
	var baseline_replay := _build_scenario_trajectory(100.0, 0.0, 100.0)

	_expect(baseline == baseline_replay, "eight-year baseline trajectory is deterministic on replay")
	_expect(
		int(baseline[0].first_lot_kg) == 0 and int(baseline[1].first_lot_kg) == 0,
		"baseline fixture produces no FFB before the model's three-year first-harvest boundary",
	)
	_expect(
		int(baseline[2].first_lot_kg) > 0,
		"baseline fixture produces a positive first lot at the three-year model boundary",
	)
	_expect(
		int(baseline[6].first_lot_kg) > int(baseline[2].first_lot_kg),
		"baseline age trajectory rises from first production toward the seven-year peak",
	)
	for sample_year in [2, 4, 7]:
		var row := int(sample_year)
		_expect(
			float(baseline[row].health) > float(constrained[row].health)
				and float(constrained[row].health) > float(stress[row].health),
			"scenario health remains directionally ordered in model year %d" % (row + 1),
		)
		_expect(
			int(baseline[row].first_lot_kg) > int(constrained[row].first_lot_kg)
				and int(constrained[row].first_lot_kg) > int(stress[row].first_lot_kg),
			"scenario lot output remains directionally ordered in model year %d" % (row + 1),
		)

	var all_scenarios: Array = [baseline, constrained, stress]
	for trajectory in all_scenarios:
		for sample in trajectory:
			_expect(
				float(sample.health) >= 0.0
					and float(sample.health) <= 100.0
					and float(sample.pest_risk) >= 0.0
					and float(sample.pest_risk) <= 100.0
				and float(sample.fertilizer) >= 0.0
				and int(sample.first_lot_kg) >= 0,
				"scenario trajectory values stay within documented model bounds",
			)


func _build_scenario_trajectory(
	initial_health: float, initial_pest: float, annual_fertilizer_reserve: float
) -> Array[Dictionary]:
	var health := initial_health
	var pest_risk := initial_pest
	var fertilizer := 0.0
	var trajectory: Array[Dictionary] = []
	for year in range(1, 9):
		# A test-fixture reserve refill at each model-year start is not an in-game policy.
		var condition := CropModel.advance_condition(
			health,
			pest_risk,
			annual_fertilizer_reserve,
			float(year - 1) * CropModel.DAYS_PER_YEAR,
			CropModel.DAYS_PER_YEAR
		)
		health = float(condition.health)
		pest_risk = float(condition.pest_risk)
		fertilizer = float(condition.fertilizer)
		var age_days := float(year) * CropModel.DAYS_PER_YEAR
		trajectory.append(
			{
				"year": year,
				"health": health,
				"pest_risk": pest_risk,
				"fertilizer": fertilizer,
				"first_lot_kg": CropModel.estimate_harvest_lot_kg(
					age_days, health, pest_risk, fertilizer
				)
			}
		)
	return trajectory


func _test_season_and_input_direction() -> void:
	var wet := CropModel.advance_condition(100.0, 0.0, 0.0, 0.0, CropModel.DAYS_PER_SEASON)
	var drier_start := CropModel.DAYS_PER_SEASON * 2.0
	var drier := CropModel.advance_condition(100.0, 0.0, 0.0, drier_start, CropModel.DAYS_PER_SEASON)
	var fertilized := CropModel.advance_condition(
		100.0, 0.0, 100.0, 0.0, CropModel.DAYS_PER_SEASON
	)
	var pest_stress := CropModel.advance_condition(
		100.0, 30.0, 0.0, 0.0, CropModel.DAYS_PER_SEASON
	)
	_expect(wet.pest_risk > drier.pest_risk, "scenario wet period creates more pest pressure than the drier period")
	_expect(drier.health < wet.health, "scenario drier period creates greater health stress")
	_expect(fertilized.health > wet.health, "fertilizer reserve moderates scenario health loss")
	_expect(fertilized.fertilizer < 100.0, "fertilizer reserve declines over game time")
	_expect(
		is_equal_approx(float(fertilized.pest_risk), float(wet.pest_risk)),
		"changing fertilizer reserve does not change the separately modeled pest-pressure output",
	)
	_expect(
		is_equal_approx(float(pest_stress.health), float(wet.health))
			and is_equal_approx(float(pest_stress.fertilizer), float(wet.fertilizer))
			and float(pest_stress.pest_risk) > float(wet.pest_risk),
		"changing initial pest pressure changes the pest-index trajectory without altering other condition outputs",
	)


func _test_cohort_rollup() -> void:
	var simulation = PlantationSimulation.new()
	simulation._ready()
	simulation.game_days_elapsed = 1090.0
	var ready_palm = PalmRecord.new()
	ready_palm.id = "palm_ready"
	ready_palm.cohort_id = "Y01-M01"
	ready_palm.planted_day = 0.0
	ready_palm.age = 1090.0
	ready_palm.growth_stage = PalmRecord.GrowthStage.MATURE
	ready_palm.fruit_state = PalmRecord.FruitState.READY
	ready_palm.harvest_ready = true
	ready_palm.fruit_quantity = 37.0

	var due_in_five_days = PalmRecord.new()
	due_in_five_days.id = "palm_due_soon"
	due_in_five_days.cohort_id = "Y01-M01"
	due_in_five_days.planted_day = 15.0
	due_in_five_days.age = 1075.0
	due_in_five_days.growth_stage = PalmRecord.GrowthStage.MATURE
	due_in_five_days.health = 80.0
	due_in_five_days.fertilizer = 20.0
	due_in_five_days.pest_risk = 10.0

	var due_in_twenty_days = PalmRecord.new()
	due_in_twenty_days.id = "palm_due_later"
	due_in_twenty_days.cohort_id = "Y01-M02"
	due_in_twenty_days.planted_day = 30.0
	due_in_twenty_days.age = 1060.0
	due_in_twenty_days.growth_stage = PalmRecord.GrowthStage.MATURE

	var due_after_horizon = PalmRecord.new()
	due_after_horizon.id = "palm_due_after_horizon"
	due_after_horizon.cohort_id = "Y01-M03"
	due_after_horizon.planted_day = 60.0
	due_after_horizon.age = 1030.0
	due_after_horizon.growth_stage = PalmRecord.GrowthStage.MATURE

	simulation.palms.append_array(
		[ready_palm, due_in_five_days, due_in_twenty_days, due_after_horizon]
	)
	var cohorts := simulation.get_cohort_summaries()
	_expect(cohorts.size() == 3, "planting month groups palms into separate cohorts")
	_expect(
		int(cohorts[0].palm_count) + int(cohorts[1].palm_count) + int(cohorts[2].palm_count) == 4,
		"cohort roll-up accounts for every planted palm exactly once",
	)
	_expect(
		int(cohorts[0].seedling_count)
			+ int(cohorts[0].young_count)
			+ int(cohorts[0].mature_count)
			== int(cohorts[0].palm_count),
		"cohort stage counts reconcile to its palm count",
	)
	_expect(
		is_equal_approx(float(cohorts[0].average_health_percent), 90.0)
			and is_equal_approx(float(cohorts[0].average_fertilizer_reserve), 10.0)
			and is_equal_approx(float(cohorts[0].average_pest_index), 5.0),
		"cohort condition roll-up preserves health, reserve, and pest-index units",
	)
	_expect(
		str(cohorts[0].id) == "Y01-M01"
			and int(cohorts[0].ready_count) == 1
			and int(cohorts[0].ready_kg) == 37,
		"ready-now cohort outlook reports only the existing lot",
	)
	_expect(
		int(cohorts[0].within_model_month_count) == 1
			and int(cohorts[0].within_model_month_kg) > 0,
		"individual palm age puts the first harvest into the next model-month outlook",
	)
	_expect(
		str(cohorts[1].earliest_window_calendar) == "Y04/M02/D01"
			and int(cohorts[1].within_model_month_count) == 1,
		"later cohort date reflects its individual harvest-window timing",
	)
	_expect(
		str(cohorts[2].earliest_window_calendar) == "Y04/M03/D01"
			and int(cohorts[2].within_model_month_count) == 0,
		"windows beyond 30 model days are dated but not counted in the short outlook",
	)
	simulation.free()


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(label)
