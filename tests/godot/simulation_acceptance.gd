extends SceneTree

const PlantationSimulation = preload("res://scripts/simulation/plantation_simulation.gd")
const COMPLETED_STATUS := "COMPLETED"
const STEP_SECONDS := 0.05

var _failures: int = 0
var _checks: int = 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_test_fresh_state_and_establishment()
	_test_planting_grid_and_inventory()
	_test_first_harvest_delivery_sale_and_repeat()
	if _failures == 0:
		print("PASS: %d native simulation assertions" % _checks)
		quit(0)
	else:
		push_error("FAIL: %d of %d native simulation assertions failed" % [_failures, _checks])
		quit(1)


func _test_fresh_state_and_establishment() -> void:
	var simulation = PlantationSimulation.new()
	simulation._ready()
	_expect(simulation.resources.money == 1800, "fresh funds start at the fixture balance")
	_expect(simulation.resources.seedlings == 16, "fresh inventory contains sixteen seedlings")
	_expect(simulation.start_land_clearing(Vector3(8.0, 0.0, 10.0)) == false, "clearing requires a completed shelter")
	_expect(
		simulation.start_shelter_construction(Vector3(80.0, 0.0, 80.0)) == false,
		"shelter placement outside the camp is rejected",
	)
	_expect(simulation.resources.money == 1800, "invalid shelter placement does not charge funds")
	_expect(simulation.resources.wood == 28, "invalid shelter placement does not consume timber")
	_expect(
		simulation.start_shelter_construction(Vector3(-20.0, 0.0, 11.0)),
		"valid shelter placement is accepted",
	)
	_expect(simulation.resources.money == 1500, "shelter cost is charged once")
	_expect(simulation.resources.wood == 18, "shelter consumes ten timber")
	_expect(
		simulation.start_shelter_construction(Vector3(-20.0, 0.0, 11.0)) == false,
		"duplicate shelter placement is rejected",
	)
	_expect(simulation.resources.money == 1500, "duplicate shelter placement does not charge again")
	_expect(
		_advance_until(
			simulation,
			func() -> bool: return simulation.shelter != null and simulation.shelter.is_complete,
			"shelter completion",
		),
		"shelter task completes",
	)
	_expect(
		simulation.start_land_clearing(Vector3(80.0, 0.0, 80.0)) == false,
		"clearing outside the surveyed block is rejected",
	)
	_expect(
		simulation.start_land_clearing(Vector3(8.0, 0.0, 10.0)),
		"clearing the surveyed block is accepted",
	)
	_expect(simulation.resources.money == 1350, "clearing cost is charged once")
	_expect(
		simulation.start_land_clearing(Vector3(8.0, 0.0, 10.0)) == false,
		"duplicate clearing is rejected",
	)
	_expect(simulation.resources.money == 1350, "duplicate clearing does not charge again")
	_expect(
		_advance_until(simulation, func() -> bool: return simulation.land_state == 2, "prepared land"),
		"clearing reaches PREPARED",
	)
	simulation.free()


func _test_planting_grid_and_inventory() -> void:
	var simulation = PlantationSimulation.new()
	simulation._ready()
	simulation.land_state = 2
	simulation.land_zone.state = 2
	_expect(simulation.get_planting_slots().size() == 16, "prepared block exposes sixteen planting slots")
	for slot_index in range(simulation.planting_slots.size()):
		_expect(simulation.request_plant(slot_index), "planting slot %d can be queued" % slot_index)
	_expect(simulation.request_plant(0) == false, "duplicate occupied/reserved slot is rejected")
	_expect(simulation.request_plant(16) == false, "out-of-range slot is rejected")
	_expect(simulation.reserved_slots.size() == 16, "all sixteen queued slots are reserved")
	_expect(simulation.resources.seedlings == 16, "seedlings are consumed on completion, not queue")
	_expect(
		_advance_until(simulation, func() -> bool: return simulation.palms.size() == 16, "all planting tasks"),
		"all sixteen planting tasks complete",
	)
	_expect(simulation.resources.seedlings == 0, "sixteen completed plantings consume sixteen seedlings")
	_expect(simulation.reserved_slots.is_empty(), "completed planting tasks release reservations")
	var palm_ids: Dictionary = {}
	var slot_ids: Dictionary = {}
	var position_ids: Dictionary = {}
	for palm in simulation.palms:
		palm_ids[palm.id] = true
		slot_ids[palm.slot_index] = true
		position_ids[Vector2(palm.position.x, palm.position.z)] = true
	_expect(palm_ids.size() == 16, "planted palm IDs are unique")
	_expect(slot_ids.size() == 16, "planted slot indices are unique")
	_expect(position_ids.size() == 16, "planted world positions are unique")
	simulation.free()


func _test_first_harvest_delivery_sale_and_repeat() -> void:
	var simulation = PlantationSimulation.new()
	simulation._ready()
	_expect(
		simulation.start_shelter_construction(Vector3(-20.0, 0.0, 11.0)),
		"E2E: shelter placement succeeds",
	)
	_expect(
		_advance_until(
			simulation,
			func() -> bool: return simulation.shelter != null and simulation.shelter.is_complete,
			"E2E shelter completion",
		),
		"E2E: shelter completes",
	)
	_expect(simulation.start_land_clearing(Vector3(8.0, 0.0, 10.0)), "E2E: land clearing starts")
	_expect(
		_advance_until(simulation, func() -> bool: return simulation.land_state == 2, "E2E prepared land"),
		"E2E: land becomes prepared",
	)
	_expect(simulation.request_plant(0), "E2E: first seedling is queued")
	_expect(
		_advance_until(simulation, func() -> bool: return simulation.palms.size() == 1, "E2E planted palm"),
		"E2E: first palm is planted",
	)
	var palm = simulation.palms[0]
	_expect(simulation.request_harvest(palm.id) == false, "immature palm cannot be harvested")
	_expect(simulation.perform_maintenance("FERTILIZE", palm.id), "fertilizing task is accepted")
	_expect(
		_advance_until(
			simulation,
			func() -> bool: return _has_completed_task(simulation, "FERTILIZING"),
			"fertilizer completion",
		),
		"fertilizing task completes",
	)
	_expect(simulation.perform_maintenance("TREAT", palm.id), "pest-treatment task is accepted")
	_expect(
		_advance_until(
			simulation,
			func() -> bool: return _has_completed_task(simulation, "TREATING"),
			"treatment completion",
		),
		"pest-treatment task completes",
	)
	_expect(
		_advance_until(simulation, func() -> bool: return palm.harvest_ready, "first harvest readiness"),
		"mature palm reaches harvest-ready state",
	)
	var expected_kg: int = int(round(palm.fruit_quantity))
	_expect(simulation.request_harvest(palm.id), "ready palm accepts a harvest task")
	_expect(simulation.request_harvest(palm.id) == false, "duplicate harvest reservation is rejected")
	_expect(simulation.resources.harvested_ffb_kg == 0, "FFB is not stored before harvest and delivery")
	_expect(
		_advance_until(
			simulation,
			func() -> bool: return _has_completed_task(simulation, "HARVESTING"),
			"harvest completion",
		),
		"harvest task completes",
	)
	_expect(simulation.worker.carrying_ffb, "completed harvest transfers FFB to the worker")
	_expect(
		simulation.worker.current_task != null and simulation.worker.current_task.task_type == "FFB_DELIVERY",
		"delivery follows harvest",
	)
	_expect(
		_advance_until(
			simulation,
			func() -> bool:
				return simulation.harvested_ffb_kg == expected_kg and simulation.worker.state_name() == "IDLE",
			"FFB delivery completion",
		),
		"worker deposits the exact harvested quantity",
	)
	_expect(simulation.worker.carried_ffb_kg == 0.0, "worker load is empty after delivery")
	var funds_before_sale: int = int(simulation.resources.money)
	_expect(simulation.sell_ffb(), "stored FFB can be sold")
	_expect(simulation.harvested_ffb_kg == 0, "sale clears stored FFB once")
	_expect(simulation.resources.money == funds_before_sale + expected_kg, "sale credits the fixture price exactly")
	_expect(simulation.transactions.size() == 1, "sale creates exactly one transaction")
	_expect(simulation.sell_ffb() == false, "empty stock cannot be sold twice")
	_expect(simulation.transactions.size() == 1, "repeated empty sale creates no transaction")
	_expect(
		_advance_until(simulation, func() -> bool: return palm.harvest_ready, "repeat harvest readiness"),
		"palm recovers and reaches harvest-ready state again",
	)
	_expect(palm.harvest_count == 1, "first repeat cycle preserves harvest count")
	_expect(simulation.palms.size() == 1, "harvesting does not remove the palm")
	var second_yield_kg: int = int(round(palm.fruit_quantity))
	var funds_before_second_sale: int = int(simulation.resources.money)
	_expect(simulation.request_harvest(palm.id), "recovered palm accepts a second harvest")
	_expect(
		_advance_until(
			simulation,
			func() -> bool: return palm.harvest_count == 2,
			"second harvest completion",
		),
		"second harvest increments the palm cycle count once",
	)
	_expect(simulation.worker.carrying_ffb, "second harvest transfers FFB to the worker")
	_expect(
		simulation.worker.current_task != null and simulation.worker.current_task.task_type == "FFB_DELIVERY",
		"second delivery follows the repeat harvest",
	)
	_expect(
		_advance_until(
			simulation,
			func() -> bool:
				return simulation.harvested_ffb_kg == second_yield_kg and simulation.worker.state_name() == "IDLE",
			"second delivery completion",
		),
		"second delivery preserves the exact yield",
	)
	_expect(simulation.sell_ffb(), "second delivered batch can be sold")
	_expect(simulation.transactions.size() == 2, "second sale creates one additional transaction")
	_expect(
		simulation.resources.money == funds_before_second_sale + second_yield_kg,
		"second sale credits revenue exactly once",
	)
	_expect(simulation.harvested_ffb_kg == 0, "second sale clears the collection stock")
	simulation.free()


func _has_completed_task(simulation, task_type: String) -> bool:
	for task in simulation.tasks:
		if task.task_type == task_type and task.status_name() == COMPLETED_STATUS:
			return true
	return false


func _advance_until(simulation, condition: Callable, label: String, max_ticks: int = 60000) -> bool:
	for tick in range(max_ticks):
		if condition.call():
			return true
		simulation._process(STEP_SECONDS)
	push_error("Timed out waiting for %s (day %d, worker %s)." % [label, simulation.day_number, simulation.worker.state_name()])
	return false


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error(label)
