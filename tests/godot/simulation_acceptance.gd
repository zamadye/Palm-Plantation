extends SceneTree

const PlantationSimulation = preload("res://scripts/simulation/plantation_simulation.gd")
const CropModel = preload("res://scripts/simulation/crop_model.gd")
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
	var tasks_before_immature_request: int = simulation.tasks.size()
	var reservations_before_immature_request: int = simulation.harvest_reservations.size()
	_expect(simulation.request_harvest(palm.id) == false, "immature palm cannot be harvested")
	_expect(simulation.tasks.size() == tasks_before_immature_request, "non-ready request creates no harvest task")
	_expect(
		simulation.harvest_reservations.size() == reservations_before_immature_request,
		"non-ready request creates no harvest reservation",
	)
	_expect(_count_harvest_tasks_for_palm(simulation, palm.id) == 0, "non-ready palm has no harvest task")
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
	_expect(
		palm.age >= CropModel.FIRST_COMMERCIAL_HARVEST_DAYS
			and palm.age < CropModel.FIRST_COMMERCIAL_HARVEST_DAYS + 0.04,
		"integrated first harvest opens at the 36-model-month window without early maturity credit",
	)
	var expected_kg: int = simulation.estimate_ffb_yield(palm)
	_expect(expected_kg > 0, "ready palm has a positive computed yield")
	_expect(
		int(round(palm.fruit_quantity)) == expected_kg,
		"captured expected quantity equals the ready palm yield before harvest",
	)
	var tasks_before_harvest_request: int = simulation.tasks.size()
	var reservations_before_harvest_request: int = simulation.harvest_reservations.size()
	_expect(
		reservations_before_harvest_request == 0,
		"fresh first-harvest scenario begins without a reservation",
	)
	_expect(simulation.request_harvest(palm.id), "ready palm accepts a harvest task")
	_expect(
		simulation.tasks.size() == tasks_before_harvest_request + 1,
		"valid ready-palm request creates exactly one task",
	)
	_expect(
		simulation.harvest_reservations.size() == reservations_before_harvest_request + 1,
		"valid ready-palm request creates exactly one reservation",
	)
	_expect(simulation.harvest_reservations.size() == 1, "exactly one reservation exists for this fresh harvest")
	_expect(simulation.harvest_reservations.has(palm.id), "ready palm is reserved by the request")
	_expect(
		_count_harvest_tasks_for_palm(simulation, palm.id) == 1,
		"ready palm has exactly one harvest task",
	)
	var tasks_after_harvest_request: int = simulation.tasks.size()
	var reservations_after_harvest_request: int = simulation.harvest_reservations.size()
	_expect(simulation.request_harvest(palm.id) == false, "duplicate harvest request is rejected")
	_expect(
		simulation.tasks.size() == tasks_after_harvest_request,
		"duplicate request does not increase task count",
	)
	_expect(
		simulation.harvest_reservations.size() == reservations_after_harvest_request,
		"duplicate request does not increase reservation count",
	)
	_expect(
		_count_harvest_tasks_for_palm(simulation, palm.id) == 1,
		"duplicate request cannot create another task for the palm",
	)
	_expect(simulation.request_harvest(palm.id) == false, "already-reserved palm is rejected")
	_expect(
		simulation.tasks.size() == tasks_after_harvest_request,
		"already-reserved rejection does not increase task count",
	)
	_expect(
		simulation.harvest_reservations.size() == reservations_after_harvest_request,
		"already-reserved rejection does not increase reservation count",
	)
	_expect(
		_count_harvest_tasks_for_palm(simulation, palm.id) == 1,
		"no duplicate task exists for the already-reserved palm",
	)
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
		is_equal_approx(simulation.worker.carried_ffb_kg, float(expected_kg)),
		"worker carries the exact computed FFB quantity after harvest",
	)
	_expect(
		simulation.harvested_ffb_kg == 0,
		"collection stock remains zero before delivery",
	)
	_expect(
		simulation.transactions.is_empty() and simulation.latest_transaction.is_empty(),
		"no quantity is recorded as sold before SELL",
	)
	_expect(
		int(round(palm.fruit_quantity)) == 0,
		"harvested palm no longer carries the harvested fruit quantity",
	)
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
	_expect(
		simulation.harvested_ffb_kg == expected_kg,
		"collection point contains the exact computed quantity after delivery",
	)
	_expect(simulation.worker.carried_ffb_kg == 0.0, "worker load is zero after delivery")
	_expect(
		int(round(palm.fruit_quantity)) == 0,
		"palm remains empty after the harvested quantity reaches collection",
	)
	_expect(
		simulation.transactions.is_empty() and simulation.latest_transaction.is_empty(),
		"delivered quantity remains unsold until SELL",
	)
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


func _count_harvest_tasks_for_palm(simulation, palm_id: String) -> int:
	var count := 0
	for task in simulation.tasks:
		if task.task_type == "HARVESTING" and str(task.payload.get("palm_id", "")) == palm_id:
			count += 1
	return count


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
