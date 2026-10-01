extends Node
class_name PlantationSimulation

## Accelerated, data-only gameplay simulation. Visual nodes are maintained by Main/WorldBuilder.
const WorkerData = preload("res://scripts/simulation/worker_record.gd")
const PalmData = preload("res://scripts/simulation/palm_record.gd")
const BuildingData = preload("res://scripts/simulation/building_record.gd")
const LandZoneData = preload("res://scripts/simulation/land_zone_record.gd")
const TaskData = preload("res://scripts/simulation/task_record.gd")
const CollectionData = preload("res://scripts/simulation/ffb_collection_record.gd")

const FIELD_CENTER := Vector3(8.0, 0.0, 10.0)
const BASE_FFB_YIELD_KG := 180.0
const PROTOTYPE_FFB_PRICE_PER_KG := 1.0
const INITIAL_FRUIT_DEVELOPING_DAYS := 4.0
const INITIAL_FRUIT_READY_DAYS := 15.0
const RECOVERY_DEVELOPING_DAYS := 8.0
const RECOVERY_READY_DAYS := 20.0
const FIELD_SIZE := Vector2(24.0, 18.0)
const DAY_LENGTH_SECONDS := 3.0
const CLEARING_DURATION := 12.0
const SHELTER_DURATION := 8.0
const PLANTING_DURATION := 3.0
const HARVEST_DURATION := 5.0
const DELIVERY_DURATION := 2.0
const CLEARING_COST := 150

signal resources_changed
signal phase_changed
signal land_changed
signal job_changed
signal job_progress_changed(task_type: String, progress: float)
signal shelter_started(building)
signal shelter_completed(building)
signal palm_planted(palm)
signal palm_changed(palm)
signal collection_changed
signal transaction_completed(transaction: Dictionary)
signal toast(message: String, kind: String)

## Land-zone states are independent of their visual representation.
enum LandState { FOREST, CLEARING, PREPARED }

var land_zone = LandZoneData.new()
var land_state: int:
	get:
		return int(land_zone.state)
	set(value):
		land_zone.state = value
var land_progress: float:
	get:
		return land_zone.clearing_progress
	set(value):
		land_zone.clearing_progress = value
var preparation_progress: float:
	get:
		return land_zone.preparation_progress
	set(value):
		land_zone.preparation_progress = value

var player_position := Vector3(-22.0, 0.0, 18.0)
var player_destination := player_position
var player_state: String = "IDLE"

var worker = null
var shelter = null
var collection_point = null
var palms: Array = []
var tasks: Array = []
var transactions: Array[Dictionary] = []
var latest_transaction: Dictionary = {}
var harvest_reservations: Dictionary = {}
var planting_slots: Array[Vector3] = []
var reserved_slots: Dictionary = {}
var planted_slots: Dictionary = {}
var resources: Dictionary = {
	"money": 1800, "wood": 28, "seedlings": 16, "fertilizer": 30, "pesticide": 12,
	"harvested_ffb_kg": 0
}
var harvested_ffb_kg: int:
	get:
		return int(resources.get("harvested_ffb_kg", 0))
	set(value):
		resources["harvested_ffb_kg"] = maxi(0, value)

var game_speed: float = 2.0
var game_days_elapsed: float = 0.0
var day_number: int = 1
var _task_sequence: int = 0
var _transaction_sequence: int = 0
var _last_progress_milestone: int = -1


func _ready() -> void:
	land_zone.position = FIELD_CENTER
	land_zone.size = FIELD_SIZE
	collection_point = CollectionData.new()
	worker = WorkerData.new()
	worker.position = Vector3(-22.0, 0.0, 13.0)
	worker.destination = worker.position
	_create_planting_slots()


func _process(delta: float) -> void:
	if worker == null:
		return
	var scaled_delta := delta * game_speed
	game_days_elapsed += scaled_delta / DAY_LENGTH_SECONDS
	var new_day := int(floor(game_days_elapsed)) + 1
	if new_day != day_number:
		day_number = new_day
		resources_changed.emit()

	_advance_growth(scaled_delta / DAY_LENGTH_SECONDS)
	_update_worker(delta, scaled_delta)
	_update_player(delta)


func _create_planting_slots() -> void:
	planting_slots.clear()
	# Four orderly rows of four palms, with room for the crown at maturity.
	for row in range(4):
		for column in range(4):
			var x := FIELD_CENTER.x + (float(column) - 1.5) * 5.4
			var z := FIELD_CENTER.z + (float(row) - 1.5) * 4.3
			planting_slots.append(Vector3(x, 0.0, z))


func get_planting_slots() -> Array[Vector3]:
	return planting_slots.duplicate()


func is_valid_shelter_location(point: Vector3) -> bool:
	# Leave the temporary lean-to, rain barrel, and timber pile undisturbed.
	var in_camp_clearing := (
		point.x >= -30.0 and point.x <= -11.0 and point.z >= 6.0 and point.z <= 23.0
	)
	var near_temporary_camp := Vector2(point.x, point.z).distance_to(Vector2(-26.0, 17.0)) < 4.4
	var near_timber_stack := Vector2(point.x, point.z).distance_to(Vector2(-14.0, 19.5)) < 2.6
	return in_camp_clearing and not near_temporary_camp and not near_timber_stack


func is_inside_clearing(point: Vector3) -> bool:
	return land_zone.contains(point)


func start_shelter_construction(point: Vector3) -> bool:
	if shelter != null:
		toast.emit("The starter shelter is already built.", "info")
		return false
	if not is_valid_shelter_location(point):
		toast.emit("Choose a site inside the marked camp clearing.", "warning")
		return false
	if resources.money < 300 or resources.wood < 10:
		toast.emit("The shelter needs $300 and 10 timber.", "warning")
		return false

	resources.money -= 300
	resources.wood -= 10
	shelter = BuildingData.new()
	shelter.position = Vector3(point.x, 0.0, point.z)
	resources_changed.emit()
	shelter_started.emit(shelter)
	_enqueue_task(_make_task("BUILDING", shelter.position, SHELTER_DURATION, {"building_id": shelter.id}))
	toast.emit("Shelter site selected. Your crew is on the way.", "success")
	return true


func start_land_clearing(point: Vector3) -> bool:
	if shelter == null or not shelter.is_complete:
		toast.emit("Build the starter shelter before opening plantation land.", "warning")
		return false
	if land_state != LandState.FOREST:
		toast.emit("This land is already being worked.", "info")
		return false
	if not is_inside_clearing(point):
		toast.emit("Select the marked forest block to clear it.", "warning")
		return false
	if int(resources.money) < CLEARING_COST:
		toast.emit("Land clearing needs $%d for crew and equipment." % CLEARING_COST, "warning")
		return false

	resources.money -= CLEARING_COST
	land_state = LandState.CLEARING
	land_progress = 0.0
	preparation_progress = 0.0
	resources_changed.emit()
	land_changed.emit()
	_enqueue_task(_make_task("CLEARING", FIELD_CENTER, CLEARING_DURATION, {"zone_id": land_zone.id}))
	toast.emit("Land clearing started. Vegetation will recede as the crew works.", "success")
	return true


func request_plant(slot_index: int) -> bool:
	if land_state != LandState.PREPARED:
		toast.emit("Clear the block before planting.", "warning")
		return false
	if slot_index < 0 or slot_index >= planting_slots.size():
		return false
	if planted_slots.has(slot_index) or reserved_slots.has(slot_index):
		toast.emit("That planting point is already occupied or queued.", "info")
		return false
	if _available_resource("seedlings") < 1:
		toast.emit("No free seedlings remain.", "warning")
		return false

	reserved_slots[slot_index] = true
	var target: Vector3 = planting_slots[slot_index]
	_enqueue_task(
		_make_task(
			"PLANTING", target, PLANTING_DURATION,
			{"slot_index": slot_index, "resource": "seedlings", "cost": 1}
		)
	)
	toast.emit(
		(
			"Planting order queued for row %d, position %d."
			% [int(slot_index / 4) + 1, (slot_index % 4) + 1]
		),
		"success"
	)
	return true


func perform_maintenance(action: String, target_id: String) -> bool:
	var task_type := ""
	var resource_key := ""
	var resource_cost := 0
	if action == "FERTILIZE":
		task_type = "FERTILIZING"
		resource_key = "fertilizer"
		resource_cost = 5
	elif action == "TREAT":
		task_type = "TREATING"
		resource_key = "pesticide"
		resource_cost = 2
	else:
		return false

	var target_type := "palm"
	var target_position := Vector3.ZERO
	if target_id == land_zone.id:
		if land_state != LandState.PREPARED or palms.is_empty():
			toast.emit("Plant a palm before maintaining the block.", "warning")
			return false
		target_type = "block"
		target_position = FIELD_CENTER
	else:
		var palm = get_palm(target_id)
		if palm == null:
			return false
		target_position = palm.position

	if _available_resource(resource_key) < resource_cost:
		toast.emit("Not enough %s. Need %d units." % [resource_key, resource_cost], "warning")
		return false

	var payload := {
		"target_type": target_type,
		"target_id": target_id,
		"resource": resource_key,
		"cost": resource_cost
	}
	_enqueue_task(_make_task(task_type, target_position, 2.5, payload))
	toast.emit(
		"%s assigned to Rafi." % ("Fertilizing" if task_type == "FERTILIZING" else "Pest treatment"),
		"success"
	)
	return true


func request_harvest(palm_id: String, show_toast: bool = true) -> bool:
	var palm = get_palm(palm_id)
	if palm == null or not palm.harvest_ready or palm.fruit_state != PalmData.FruitState.READY:
		if show_toast:
			toast.emit("This palm is not ready to harvest.", "warning")
		return false
	if harvest_reservations.has(palm_id):
		if show_toast:
			toast.emit("A harvest task is already assigned to this palm.", "info")
		return false
	harvest_reservations[palm_id] = true
	var work_position := palm.position + Vector3(0.0, 0.0, 1.1)
	_enqueue_task(
		_make_task(
			"HARVESTING", work_position, HARVEST_DURATION,
			{"palm_id": palm_id, "fruit_quantity": palm.fruit_quantity}
		)
	)
	if show_toast:
		toast.emit("Harvest assigned. Rafi is walking to the ready palm.", "success")
	return true


func request_harvest_block() -> int:
	var queued := 0
	for palm in palms:
		if palm.harvest_ready and not harvest_reservations.has(palm.id):
			if request_harvest(palm.id, false):
				queued += 1
	if queued == 0:
		toast.emit("No unreserved palms are ready to harvest.", "info")
	else:
		toast.emit("%d harvest task(s) queued for the ready block." % queued, "success")
	return queued


func get_ready_harvest_count() -> int:
	var ready_count := 0
	for palm in palms:
		if palm.harvest_ready and not harvest_reservations.has(palm.id):
			ready_count += 1
	return ready_count


func estimate_ffb_yield(palm) -> int:
	if palm == null or int(palm.growth_stage) != int(PalmData.GrowthStage.MATURE):
		return 0
	var maturity_factor := 1.0
	var health_factor := clampf(palm.health / 100.0, 0.25, 1.0)
	return int(round(BASE_FFB_YIELD_KG * maturity_factor * health_factor))


func sell_ffb() -> bool:
	if harvested_ffb_kg <= 0:
		toast.emit("There is no FFB in the collection point to sell.", "warning")
		return false
	var kilograms := harvested_ffb_kg
	var revenue := int(round(float(kilograms) * PROTOTYPE_FFB_PRICE_PER_KG))
	resources.money = int(resources.money) + revenue
	harvested_ffb_kg = 0
	_transaction_sequence += 1
	var transaction := {
		"id": "sale_%03d" % _transaction_sequence,
		"day": day_number,
		"ffb_kg": kilograms,
		"price_per_kg": PROTOTYPE_FFB_PRICE_PER_KG,
		"revenue": revenue,
		"funds_after": int(resources.money)
	}
	transactions.append(transaction)
	latest_transaction = transaction.duplicate(true)
	resources_changed.emit()
	collection_changed.emit()
	transaction_completed.emit(latest_transaction)
	phase_changed.emit()
	toast.emit(
		"HARVEST SOLD · %d kg FFB · Revenue +$%d · Funds $%d"
		% [kilograms, revenue, int(resources.money)],
		"success"
	)
	return true


func get_palm(palm_id: String):
	for palm in palms:
		if palm.id == palm_id:
			return palm
	return null


func get_task(task_id: String):
	for task in tasks:
		if task.id == task_id:
			return task
	return null


func _available_resource(resource_key: String) -> int:
	return int(resources.get(resource_key, 0)) - _reserved_resource_count(resource_key)


func _reserved_resource_count(resource_key: String) -> int:
	var reserved := 0
	for task in tasks:
		if task.status == TaskData.Status.COMPLETED or task.status == TaskData.Status.CANCELLED:
			continue
		if str(task.payload.get("resource", "")) == resource_key:
			reserved += int(task.payload.get("cost", 0))
	return reserved


func set_game_speed(speed: float) -> void:
	game_speed = clampf(speed, 1.0, 6.0)
	resources_changed.emit()


func get_phase_title() -> String:
	if shelter == null or not shelter.is_complete:
		return "01  ·  ESTABLISH A BASE"
	if land_state == LandState.FOREST or land_state == LandState.CLEARING:
		return "02  ·  OPEN THE LAND"
	if palms.is_empty():
		return "03  ·  PLANT THE FIRST ROWS"
	if harvested_ffb_kg > 0:
		return "06  ·  FFB COLLECTION & SALE"
	if get_ready_harvest_count() > 0:
		return "05  ·  FIRST HARVEST"
	for palm in palms:
		if palm.harvest_ready:
			return "05  ·  FIRST HARVEST"
	for palm in palms:
		if int(palm.growth_stage) == int(PalmData.GrowthStage.MATURE):
			return "04  ·  FRUIT DEVELOPMENT"
	return "04  ·  GROW & MAINTAIN THE BLOCK"


func get_instruction() -> String:
	if shelter == null:
		return "BUILD: choose a site in the camp clearing."
	if not shelter.is_complete:
		return "Your worker is building the starter shelter…"
	match land_state:
		LandState.FOREST:
			return "LAND: select the forest plot east of camp. Clearing uses $%d." % CLEARING_COST
		LandState.CLEARING:
			return "Your worker is clearing vegetation…"
		LandState.PREPARED:
			if palms.is_empty():
				return "PLANT: tap an open marker in the prepared grid."
			if harvested_ffb_kg > 0:
				return "FFB is stored. Select the collection point and SELL to record revenue."
			for palm in palms:
				if palm.harvest_ready:
					return "Select a READY TO HARVEST palm or block to assign the harvest crew."
			for palm in palms:
				if int(palm.growth_stage) == int(PalmData.GrowthStage.MATURE):
					return "Mature palms develop fruit over accelerated time; maintain health to support yield."
			return "Select a palm to send the worker to fertilize or treat pests."
	return "Watch the plantation grow."


func get_progress_text() -> String:
	if shelter != null and not shelter.is_complete:
		return "SHELTER  ·  %d%%" % _milestone_percent(shelter.construction_progress)
	if land_state == LandState.CLEARING:
		return "CLEARING  ·  %d%%" % _milestone_percent(land_progress)
	if (
		worker != null
		and worker.state != WorkerData.State.IDLE
		and worker.state != WorkerData.State.WALKING
	):
		var task_label := worker.job_type.replace("_", " ").capitalize()
		return "%s  ·  %d%%" % [task_label, _milestone_percent(worker.job_progress)]
	return "DAY %02d  ·  GAME SPEED x%.0f" % [day_number, game_speed]


func _milestone_percent(progress: float) -> int:
	if progress >= 1.0:
		return 100
	return int(floor(progress * 4.0)) * 25


func _make_task(task_type: String, target: Vector3, duration: float, payload: Dictionary):
	_task_sequence += 1
	var task = TaskData.new()
	task.id = "task_%03d" % _task_sequence
	task.task_type = task_type
	task.target = Vector3(target.x, 0.0, target.z)
	task.assigned_worker = ""
	task.duration = duration
	task.progress = 0.0
	task.status = TaskData.Status.QUEUED
	task.elapsed = 0.0
	task.payload = payload.duplicate(true)
	return task


func _enqueue_task(task, high_priority: bool = false) -> void:
	tasks.append(task)
	if worker.current_task == null and worker.state == WorkerData.State.IDLE:
		_assign_task(task)
	elif high_priority:
		worker.task_queue.push_front(task)
	else:
		worker.task_queue.append(task)
	job_changed.emit()


func _assign_task(task) -> void:
	worker.current_task = task
	task.assigned_worker = worker.id
	task.duration = maxf(0.1, task.duration / maxf(0.1, worker.productivity))
	task.status = TaskData.Status.ASSIGNED
	worker.destination = task.target
	worker.job_type = task.task_type
	worker.job_progress = 0.0
	worker.time_in_state = 0.0
	worker.state = WorkerData.State.WALKING
	player_destination = task.target
	player_state = "WALKING"
	_last_progress_milestone = -1
	job_changed.emit()


func _update_worker(delta: float, scaled_delta: float) -> void:
	worker.time_in_state += delta
	if worker.current_task == null:
		if not worker.task_queue.is_empty():
			var next_task = worker.task_queue.pop_front()
			_assign_task(next_task)
		else:
			worker.state = WorkerData.State.IDLE
			worker.job_type = ""
			worker.job_progress = 0.0
		return

	var task = worker.current_task
	if worker.state == WorkerData.State.WALKING:
		var offset: Vector3 = worker.destination - worker.position
		offset.y = 0.0
		if offset.length() <= 0.24:
			worker.position = worker.destination
			worker.state = _state_for_task(task.task_type)
			worker.time_in_state = 0.0
			task.status = TaskData.Status.IN_PROGRESS
			player_state = worker.state_name()
			job_changed.emit()
		else:
			worker.position += offset.normalized() * minf(worker.walk_speed * delta, offset.length())
			worker.position.y = 0.0
		return

	task.elapsed += scaled_delta
	task.progress = clampf(task.elapsed / maxf(0.01, task.duration), 0.0, 1.0)
	worker.job_progress = task.progress
	if task.task_type == "BUILDING" and shelter != null:
		shelter.construction_progress = task.progress
	elif task.task_type == "CLEARING":
		land_progress = task.progress

	var milestone := int(floor(task.progress * 4.0))
	if milestone != _last_progress_milestone:
		_last_progress_milestone = milestone
		job_progress_changed.emit(task.task_type, task.progress)
		if task.task_type == "BUILDING" or task.task_type == "CLEARING":
			land_changed.emit()

	if task.progress >= 1.0:
		_finish_task(task)


func _update_player(delta: float) -> void:
	var offset: Vector3 = player_destination - player_position
	offset.y = 0.0
	if offset.length() <= 0.2:
		player_position = player_destination
		if worker.current_task == null or worker.state == WorkerData.State.WALKING:
			player_state = "IDLE"
		return
	player_position += offset.normalized() * minf(4.4 * delta, offset.length())
	player_position.y = 0.0


func _state_for_task(task_type: String):
	match task_type:
		"BUILDING":
			return WorkerData.State.BUILDING
		"CLEARING":
			return WorkerData.State.CLEARING
		"PLANTING":
			return WorkerData.State.PLANTING
		"FERTILIZING":
			return WorkerData.State.FERTILIZING
		"TREATING":
			return WorkerData.State.TREATING
		"HARVESTING":
			return WorkerData.State.HARVESTING
		"FFB_DELIVERY":
			return WorkerData.State.DELIVERING
	return WorkerData.State.IDLE


func _finish_task(task) -> void:
	var task_type: String = task.task_type
	var payload: Dictionary = task.payload
	var harvested_kg := 0
	match task_type:
		"BUILDING":
			if shelter != null:
				shelter.construction_progress = 1.0
				shelter.is_complete = true
				shelter_completed.emit(shelter)
				toast.emit("Starter shelter complete. The plantation can now expand.", "success")
		"CLEARING":
			land_state = LandState.PREPARED
			land_progress = 1.0
			preparation_progress = 1.0
			toast.emit("Land prepared. Four orderly planting rows are now marked.", "success")
		"PLANTING":
			var slot_index := int(payload.get("slot_index", -1))
			reserved_slots.erase(slot_index)
			planted_slots[slot_index] = true
			resources.seedlings = max(0, int(resources.seedlings) - 1)
			var palm = PalmData.new()
			palm.id = "palm_%02d" % (slot_index + 1)
			palm.slot_index = slot_index
			palm.position = planting_slots[slot_index]
			palms.append(palm)
			palm_planted.emit(palm)
			toast.emit(
				"Seedling planted in row %d, position %d." % [int(slot_index / 4) + 1, (slot_index % 4) + 1],
				"success"
			)
		"FERTILIZING", "TREATING":
			var resource_key: String = str(payload.get("resource", ""))
			var cost := int(payload.get("cost", 0))
			resources[resource_key] = max(0, int(resources.get(resource_key, 0)) - cost)
			var target_palms: Array = []
			if str(payload.get("target_type", "palm")) == "block":
				for palm in palms:
					if land_zone.contains(palm.position):
						target_palms.append(palm)
			else:
				var target_palm = get_palm(str(payload.get("target_id", "")))
				if target_palm != null:
					target_palms.append(target_palm)
			for palm in target_palms:
				if task_type == "FERTILIZING":
					palm.fertilizer = 100.0
					palm.health = minf(100.0, palm.health + 10.0)
				else:
					palm.pest_risk = maxf(0.0, palm.pest_risk - 25.0)
					palm.health = minf(100.0, palm.health + 10.0)
				palm_changed.emit(palm)
			toast.emit(
				"Fertilizing complete. Health +10." if task_type == "FERTILIZING" else "Pest treatment complete. Health +10.",
				"success"
			)
		"HARVESTING":
			var palm_id: String = str(payload.get("palm_id", ""))
			var palm = get_palm(palm_id)
			harvest_reservations.erase(palm_id)
			if palm != null:
				harvested_kg = maxi(0, int(round(float(payload.get("fruit_quantity", palm.fruit_quantity)))))
				palm.harvest_ready = false
				palm.fruit_state = PalmData.FruitState.HARVESTED
				palm.fruit_quantity = 0.0
				palm.last_harvest = game_days_elapsed
				palm.harvest_count += 1
				palm.fruit_cycle_days = 0.0
				worker.carried_ffb_kg += float(harvested_kg)
				worker.carrying_ffb = worker.carried_ffb_kg > 0.0
				palm_changed.emit(palm)
				toast.emit("Harvested %d kg FFB. Rafi is carrying it to collection." % harvested_kg, "success")
		"FFB_DELIVERY":
			var deposit_kg := int(payload.get("kg", round(worker.carried_ffb_kg)))
			deposit_kg = mini(deposit_kg, int(round(worker.carried_ffb_kg)))
			if deposit_kg > 0:
				harvested_ffb_kg += deposit_kg
				worker.carried_ffb_kg = maxf(0.0, worker.carried_ffb_kg - float(deposit_kg))
				worker.carrying_ffb = worker.carried_ffb_kg > 0.0
				collection_changed.emit()
				resources_changed.emit()
				toast.emit("Rafi deposited %d kg FFB at the collection point." % deposit_kg, "success")

	task.progress = 1.0
	task.status = TaskData.Status.COMPLETED
	worker.experience += 1.0
	worker.current_task = null
	worker.job_type = ""
	worker.job_progress = 0.0
	worker.state = WorkerData.State.IDLE
	worker.time_in_state = 0.0
	player_state = "IDLE"
	if task_type == "HARVESTING" and harvested_kg > 0:
		var delivery_task = _make_task(
			"FFB_DELIVERY", collection_point.position, DELIVERY_DURATION, {"kg": harvested_kg}
		)
		_enqueue_task(delivery_task, true)
	elif worker.task_queue.is_empty():
		player_destination = player_position
	if task_type == "PLANTING" or task_type == "FERTILIZING" or task_type == "TREATING":
		resources_changed.emit()
	if task_type == "BUILDING" or task_type == "CLEARING":
		land_changed.emit()
	phase_changed.emit()
	job_changed.emit()


func _advance_growth(day_delta: float) -> void:
	if day_delta <= 0.0:
		return
	for palm in palms:
		var previous_stage: int = palm.growth_stage
		var previous_fruit_state: int = palm.fruit_state
		palm.age += day_delta
		palm.fertilizer = maxf(0.0, palm.fertilizer - 0.55 * day_delta)
		palm.health = maxf(0.0, palm.health - 0.28 * day_delta)
		palm.pest_risk = minf(100.0, palm.pest_risk + 0.40 * day_delta)
		if palm.age >= 45.0:
			palm.growth_stage = PalmData.GrowthStage.MATURE
		elif palm.age >= 8.0:
			palm.growth_stage = PalmData.GrowthStage.YOUNG
		else:
			palm.growth_stage = PalmData.GrowthStage.SEEDLING

		if palm.growth_stage == PalmData.GrowthStage.MATURE and not palm.harvest_ready:
			palm.fruit_cycle_days += day_delta
			match palm.fruit_state:
				PalmData.FruitState.NONE:
					if palm.fruit_cycle_days >= INITIAL_FRUIT_DEVELOPING_DAYS:
						palm.fruit_state = PalmData.FruitState.DEVELOPING
				PalmData.FruitState.HARVESTED:
					if palm.fruit_cycle_days >= 1.0:
						palm.fruit_state = PalmData.FruitState.RECOVERING
				PalmData.FruitState.RECOVERING:
					if palm.fruit_cycle_days >= RECOVERY_DEVELOPING_DAYS:
						palm.fruit_state = PalmData.FruitState.DEVELOPING
				PalmData.FruitState.DEVELOPING:
					var ready_day := INITIAL_FRUIT_READY_DAYS if palm.harvest_count == 0 else RECOVERY_READY_DAYS
					if palm.fruit_cycle_days >= ready_day:
						palm.fruit_quantity = float(estimate_ffb_yield(palm))
						palm.harvest_ready = palm.fruit_quantity > 0.0
						if palm.harvest_ready:
							palm.fruit_state = PalmData.FruitState.READY
		if palm.growth_stage != previous_stage or palm.fruit_state != previous_fruit_state:
			palm_changed.emit(palm)
