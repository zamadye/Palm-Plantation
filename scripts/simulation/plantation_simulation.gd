extends Node
class_name PlantationSimulation

## Accelerated, data-only gameplay simulation. Visual nodes are maintained by Main/WorldBuilder.
const WorkerData = preload("res://scripts/simulation/worker_record.gd")
const PalmData = preload("res://scripts/simulation/palm_record.gd")
const BuildingData = preload("res://scripts/simulation/building_record.gd")
const LandZoneData = preload("res://scripts/simulation/land_zone_record.gd")

const FIELD_CENTER := Vector3(8.0, 0.0, 10.0)
const FIELD_SIZE := Vector2(24.0, 18.0)
const DAY_LENGTH_SECONDS := 3.0
const CLEARING_DURATION := 12.0
const PREPARATION_DURATION := 5.0
const SHELTER_DURATION := 8.0
const PLANTING_DURATION := 3.0

signal resources_changed
signal phase_changed
signal land_changed
signal job_changed
signal job_progress_changed(job_type: String, progress: float)
signal shelter_started(building)
signal shelter_completed(building)
signal palm_planted(palm)
signal palm_changed(palm)
signal toast(message: String, kind: String)

## Land-zone states are independent of their visual representation.
enum LandState { FOREST, CLEARING, CLEARED, PREPARING, PREPARED }

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
var palms: Array = []
var planting_slots: Array[Vector3] = []
var reserved_slots: Dictionary = {}
var planted_slots: Dictionary = {}
var resources: Dictionary = {
	"money": 1800, "wood": 28, "seedlings": 16, "fertilizer": 30, "pesticide": 12
}

var game_speed: float = 2.0
var game_days_elapsed: float = 0.0
var day_number: int = 1
var _job_sequence: int = 0
var _last_progress_milestone: int = -1


func _ready() -> void:
	land_zone.position = FIELD_CENTER
	land_zone.size = FIELD_SIZE
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
	_enqueue_job(_make_job("BUILDING", shelter.position, SHELTER_DURATION, {"building": shelter}))
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

	land_state = LandState.CLEARING
	land_progress = 0.0
	land_changed.emit()
	_enqueue_job(_make_job("CLEARING", FIELD_CENTER, CLEARING_DURATION, {}))
	toast.emit("Land clearing started. Vegetation will recede as the crew works.", "success")
	return true


func start_row_preparation() -> bool:
	if land_state != LandState.CLEARED:
		toast.emit("Clear the forest block before preparing planting rows.", "warning")
		return false
	land_state = LandState.PREPARING
	preparation_progress = 0.0
	land_changed.emit()
	_enqueue_job(_make_job("PREPARATION", FIELD_CENTER, PREPARATION_DURATION, {}))
	toast.emit("Preparing the block and laying out planting rows.", "success")
	return true


func request_plant(slot_index: int) -> bool:
	if land_state != LandState.PREPARED:
		toast.emit("Clear and prepare the block before planting.", "warning")
		return false
	if slot_index < 0 or slot_index >= planting_slots.size():
		return false
	if planted_slots.has(slot_index) or reserved_slots.has(slot_index):
		toast.emit("That planting point is already occupied or queued.", "info")
		return false
	if int(resources.seedlings) <= 0:
		toast.emit("No seedlings remain.", "warning")
		return false

	resources.seedlings -= 1
	reserved_slots[slot_index] = true
	resources_changed.emit()
	var target: Vector3 = planting_slots[slot_index]
	_enqueue_job(_make_job("PLANTING", target, PLANTING_DURATION, {"slot_index": slot_index}))
	toast.emit(
		(
			"Planting order queued for row %d, position %d."
			% [int(slot_index / 4) + 1, (slot_index % 4) + 1]
		),
		"success"
	)
	return true


func perform_maintenance(action: String, palm_id: String) -> bool:
	var palm = get_palm(palm_id)
	if palm == null:
		return false
	if action == "FERTILIZE":
		if int(resources.fertilizer) < 5:
			toast.emit("Not enough fertilizer. Need 5 units.", "warning")
			return false
		resources.fertilizer -= 5
	elif action == "TREAT":
		if int(resources.pesticide) < 2:
			toast.emit("Not enough pest treatment. Need 2 units.", "warning")
			return false
		resources.pesticide -= 2
	elif action != "INSPECT":
		return false

	resources_changed.emit()
	var job_duration := 2.5 if action != "INSPECT" else 1.5
	_enqueue_job(_make_job(action, palm.position, job_duration, {"palm_id": palm_id}))
	return true


func get_palm(palm_id: String):
	for palm in palms:
		if palm.id == palm_id:
			return palm
	return null


func set_game_speed(speed: float) -> void:
	game_speed = clampf(speed, 1.0, 6.0)
	resources_changed.emit()


func get_phase_title() -> String:
	if shelter == null:
		return "01  ·  ESTABLISH A BASE"
	match land_state:
		LandState.FOREST, LandState.CLEARING:
			return "02  ·  OPEN THE LAND"
		LandState.CLEARED, LandState.PREPARING:
			return "03  ·  PREPARE PLANTING ROWS"
		LandState.PREPARED:
			if palms.is_empty():
				return "04  ·  PLANT THE FIRST ROWS"
			return "05  ·  GROW & MAINTAIN THE BLOCK"
	return "PLANTATION"


func get_instruction() -> String:
	if shelter == null:
		return "BUILD: choose a site in the camp clearing."
	match land_state:
		LandState.FOREST:
			return "LAND: select the forest plot east of the camp."
		LandState.CLEARING:
			return "Your worker is clearing vegetation…"
		LandState.CLEARED:
			return "LAND: prepare the block to reveal orderly planting rows."
		LandState.PREPARING:
			return "Your worker is marking planting positions…"
		LandState.PREPARED:
			if palms.size() < 4:
				return "PLANT: tap an open marker to queue a seedling."
			return "Select a palm to inspect, fertilize, or treat pests."
	return "Watch the plantation grow."


func get_progress_text() -> String:
	if shelter != null and not shelter.is_complete:
		return "SHELTER  ·  %d%%" % _milestone_percent(shelter.construction_progress)
	if land_state == LandState.CLEARING:
		return "CLEARING  ·  %d%%" % _milestone_percent(land_progress)
	if land_state == LandState.PREPARING:
		return "ROWS  ·  %d%%" % _milestone_percent(preparation_progress)
	if (
		worker != null
		and worker.state != WorkerData.State.IDLE
		and worker.state != WorkerData.State.WALKING
	):
		return (
			"%s  ·  %d%%" % [worker.job_type.capitalize(), _milestone_percent(worker.job_progress)]
		)
	return "DAY %02d  ·  GAME SPEED x%.0f" % [day_number, game_speed]


func _milestone_percent(progress: float) -> int:
	if progress >= 1.0:
		return 100
	return int(floor(progress * 4.0)) * 25


func _make_job(
	job_type: String, target: Vector3, duration: float, payload: Dictionary
) -> Dictionary:
	_job_sequence += 1
	return {
		"id": "job_%03d" % _job_sequence,
		"type": job_type,
		"target": Vector3(target.x, 0.0, target.z),
		"duration": duration,
		"elapsed": 0.0,
		"progress": 0.0,
		"payload": payload
	}


func _enqueue_job(job: Dictionary) -> void:
	if worker.active_job.is_empty():
		_assign_job(job)
	else:
		worker.job_queue.append(job)
	job_changed.emit()


func _assign_job(job: Dictionary) -> void:
	worker.active_job = job
	worker.destination = job.target
	worker.job_type = job.type
	worker.job_progress = 0.0
	worker.time_in_state = 0.0
	worker.state = WorkerData.State.WALKING
	player_destination = job.target
	player_state = "WALKING"
	_last_progress_milestone = -1
	job_changed.emit()


func _update_worker(delta: float, scaled_delta: float) -> void:
	worker.time_in_state += delta
	if worker.active_job.is_empty():
		if not worker.job_queue.is_empty():
			var next_job: Dictionary = worker.job_queue.pop_front()
			_assign_job(next_job)
		else:
			worker.state = WorkerData.State.IDLE
			worker.job_type = ""
			worker.job_progress = 0.0
		return

	if worker.state == WorkerData.State.WALKING:
		var offset: Vector3 = worker.destination - worker.position
		offset.y = 0.0
		if offset.length() <= 0.24:
			worker.position = worker.destination
			worker.state = _state_for_job(worker.active_job.type)
			worker.time_in_state = 0.0
			player_state = worker.active_job.type
			job_changed.emit()
		else:
			worker.position += (
				offset.normalized() * minf(worker.walk_speed * delta, offset.length())
			)
			worker.position.y = 0.0
		return

	worker.active_job.elapsed += scaled_delta
	var duration: float = maxf(0.01, float(worker.active_job.duration))
	worker.active_job.progress = clampf(worker.active_job.elapsed / duration, 0.0, 1.0)
	worker.job_progress = worker.active_job.progress
	var job_type: String = worker.active_job.type
	if job_type == "BUILDING" and shelter != null:
		shelter.construction_progress = worker.job_progress
	elif job_type == "CLEARING":
		land_progress = worker.job_progress
	elif job_type == "PREPARATION":
		preparation_progress = worker.job_progress

	var milestone := int(floor(worker.job_progress * 4.0))
	if milestone != _last_progress_milestone:
		_last_progress_milestone = milestone
		job_progress_changed.emit(job_type, worker.job_progress)
		if job_type == "BUILDING" or job_type == "CLEARING" or job_type == "PREPARATION":
			land_changed.emit()

	if worker.job_progress >= 1.0:
		_finish_job(worker.active_job)


func _update_player(delta: float) -> void:
	var offset: Vector3 = player_destination - player_position
	offset.y = 0.0
	if offset.length() <= 0.2:
		player_position = player_destination
		if worker.active_job.is_empty() or worker.state == WorkerData.State.WALKING:
			player_state = "IDLE"
		return
	player_position += offset.normalized() * minf(4.4 * delta, offset.length())
	player_position.y = 0.0


func _state_for_job(job_type: String):
	match job_type:
		"BUILDING":
			return WorkerData.State.BUILDING
		"CLEARING":
			return WorkerData.State.CLEARING
		"PREPARATION":
			return WorkerData.State.CLEARING
		"PLANTING":
			return WorkerData.State.PLANTING
		"FERTILIZE":
			return WorkerData.State.FERTILIZING
		"INSPECT":
			return WorkerData.State.INSPECTING
		"TREAT":
			return WorkerData.State.TREATING
	return WorkerData.State.IDLE


func _finish_job(job: Dictionary) -> void:
	var job_type: String = job.type
	var payload: Dictionary = job.payload
	match job_type:
		"BUILDING":
			if shelter != null:
				shelter.construction_progress = 1.0
				shelter.is_complete = true
				shelter_completed.emit(shelter)
				toast.emit("Starter shelter complete. The plantation can now expand.", "success")
		"CLEARING":
			land_state = LandState.CLEARED
			land_progress = 1.0
			toast.emit("Forest cleared. Prepare the block to lay out planting rows.", "success")
		"PREPARATION":
			land_state = LandState.PREPARED
			preparation_progress = 1.0
			toast.emit("Planting rows are ready. Select PLANT to place seedlings.", "success")
		"PLANTING":
			var slot_index: int = int(payload.slot_index)
			reserved_slots.erase(slot_index)
			planted_slots[slot_index] = true
			var palm = PalmData.new()
			palm.id = "palm_%02d" % (slot_index + 1)
			palm.slot_index = slot_index
			palm.position = planting_slots[slot_index]
			palms.append(palm)
			palm_planted.emit(palm)
			toast.emit(
				(
					"Seedling planted in row %d, position %d."
					% [int(slot_index / 4) + 1, (slot_index % 4) + 1]
				),
				"success"
			)
		"FERTILIZE", "TREAT", "INSPECT":
			var palm = get_palm(str(payload.palm_id))
			if palm != null:
				if job_type == "FERTILIZE":
					palm.fertilizer_state = 100.0
					palm.health = minf(100.0, palm.health + 10.0)
					toast.emit("Palm fertilized. Health +10.", "success")
				elif job_type == "TREAT":
					palm.pest_state = maxf(0.0, palm.pest_state - 25.0)
					palm.health = minf(100.0, palm.health + 10.0)
					toast.emit("Pest treatment complete. Health +10.", "success")
				else:
				palm.inspected = true
				palm.last_inspected_day = day_number
				toast.emit(
					"Inspection complete: %s, %.0f%% health." % [palm.stage_name(), palm.health],
					"success"
				)
				palm_changed.emit(palm)

	worker.experience += 1.0
	worker.active_job = {}
	worker.job_type = ""
	worker.job_progress = 0.0
	worker.state = WorkerData.State.IDLE
	worker.time_in_state = 0.0
	player_state = "IDLE"
	if worker.job_queue.is_empty():
		player_destination = player_position
	if job_type == "BUILDING" or job_type == "CLEARING" or job_type == "PREPARATION":
		land_changed.emit()
	phase_changed.emit()
	job_changed.emit()


func _advance_growth(day_delta: float) -> void:
	if day_delta <= 0.0:
		return
	for palm in palms:
		var previous_stage: int = palm.growth_stage
		palm.planting_age_days += day_delta
		palm.fertilizer_state = maxf(0.0, palm.fertilizer_state - 0.55 * day_delta)
		palm.health = maxf(0.0, palm.health - 0.28 * day_delta)
		palm.pest_state = minf(100.0, palm.pest_state + 0.40 * day_delta)
		if palm.planting_age_days >= 45.0:
			palm.growth_stage = PalmData.GrowthStage.MATURE
		elif palm.planting_age_days >= 22.0:
			palm.growth_stage = PalmData.GrowthStage.DEVELOPING
		elif palm.planting_age_days >= 8.0:
			palm.growth_stage = PalmData.GrowthStage.YOUNG
		else:
			palm.growth_stage = PalmData.GrowthStage.SEEDLING
		if palm.growth_stage != previous_stage:
			palm_changed.emit(palm)
