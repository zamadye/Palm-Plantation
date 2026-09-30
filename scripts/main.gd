extends Node3D

## Input and rendering coordinator. Simulation state remains in PlantationSimulation records.
const VisualFactory = preload("res://scripts/world/visual_factory.gd")
enum LandState { FOREST, CLEARING, CLEARED, PREPARING, PREPARED }

@onready var world: PlantationWorld = $PlantationWorld
@onready var simulation: PlantationSimulation = $PlantationSimulation
@onready var camera: StrategyCamera = $StrategyCamera
@onready var actors: Node3D = $Actors
@onready var ui: PlantationGameUI = $GameUI

var player_view: Node3D
var worker_view: Node3D
var current_action: String = ""
var _animation_clock: float = 0.0
var _last_worker_position := Vector3.ZERO
var _last_player_position := Vector3.ZERO
var _hud_detail_clock: float = 0.0


func _ready() -> void:
	world.build_world(simulation.get_planting_slots())
	player_view = VisualFactory.create_person(true)
	worker_view = VisualFactory.create_person(false)
	actors.add_child(player_view)
	actors.add_child(worker_view)
	player_view.position = simulation.player_position
	worker_view.position = simulation.worker.position
	_last_worker_position = worker_view.position
	_last_player_position = player_view.position
	camera.set_focus(Vector3(-8.0, 0.0, 5.0), 33.0)

	ui.setup(simulation, self)
	ui.action_selected.connect(_on_action_selected)
	ui.speed_selected.connect(simulation.set_game_speed)
	ui.maintenance_requested.connect(_on_maintenance_requested)
	ui.selection_closed.connect(_on_selection_closed)
	simulation.shelter_started.connect(_on_shelter_started)
	simulation.shelter_completed.connect(_on_shelter_completed)
	simulation.palm_planted.connect(_on_palm_planted)
	simulation.palm_changed.connect(_on_palm_changed)
	simulation.land_changed.connect(_sync_world_state)
	simulation.phase_changed.connect(_sync_world_state)
	simulation.job_changed.connect(_on_job_changed)
	_sync_world_state()
	ui.show_toast(
		"Begin with the camp: BUILD a starter shelter, then open the marked forest block.", "info"
	)


func _process(delta: float) -> void:
	if simulation.worker == null:
		return
	_animation_clock += delta
	_hud_detail_clock += delta

	player_view.position = simulation.player_position
	worker_view.position = simulation.worker.position
	_update_character_facing(
		player_view,
		simulation.player_state,
		simulation.player_destination,
		simulation.player_position,
		delta
	)
	_update_character_facing(
		worker_view,
		simulation.worker.state_name(),
		simulation.worker.destination,
		simulation.worker.position,
		delta
	)
	VisualFactory.animate_person(player_view, simulation.player_state, _animation_clock)
	VisualFactory.animate_person(
		worker_view, simulation.worker.state_name(), _animation_clock + 0.8
	)
	_last_player_position = simulation.player_position
	_last_worker_position = simulation.worker.position

	if simulation.shelter != null:
		world.update_shelter_progress(simulation.shelter.construction_progress)
	world.set_land_progress(simulation.land_progress, int(simulation.land_state))
	world.set_preparation_progress(simulation.preparation_progress, int(simulation.land_state))
	world.set_planting_state(
		simulation.reserved_slots, simulation.planted_slots, int(simulation.land_state)
	)
	_update_build_preview()

	if _hud_detail_clock >= 0.5:
		_hud_detail_clock = 0.0
		_sync_palm_views()
		if ui.selected_kind == "palm":
			var selected_palm = simulation.get_palm(ui.selected_id)
			if selected_palm != null:
				ui.refresh_palm_detail(selected_palm)
		ui.refresh_hud()


func _update_character_facing(
	character: Node3D, state_name: String, destination: Vector3, position: Vector3, delta: float
) -> void:
	if state_name == "WALKING":
		var direction := destination - position
		direction.y = 0.0
		if direction.length_squared() > 0.01:
			var target_angle := atan2(-direction.x, -direction.z)
			character.rotation.y = lerp_angle(character.rotation.y, target_angle, 9.0 * delta)


func _unhandled_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		if not camera.consume_drag_flag():
			_handle_world_click(event.position)
	elif event is InputEventScreenTouch and not event.pressed:
		if not camera.consume_drag_flag():
			_handle_world_click(event.position)


func _handle_world_click(screen_position: Vector2) -> void:
	var point := camera.ground_point(screen_position)
	if point.x < -1000.0 or absf(point.x) > 45.0 or absf(point.z) > 38.0:
		return
	point.y = 0.0

	match current_action:
		"BUILD":
			if simulation.start_shelter_construction(point):
				current_action = ""
				ui.set_active_action("")
			world.set_build_preview(point, simulation.is_valid_shelter_location(point), false)
			return
		"LAND":
			if simulation.start_land_clearing(point):
				current_action = ""
				ui.set_active_action("")
			return
		"PLANT":
			var slot_index := _nearest_open_slot(point)
			if slot_index >= 0:
				if simulation.request_plant(slot_index):
					world.set_slot_state(slot_index, "queued")
				return
				return
			ui.show_toast("Tap one of the marked planting positions.", "warning")
			return

	_select_world_object(point)


func _nearest_open_slot(point: Vector3) -> int:
	var nearest := -1
	var nearest_distance := 2.1
	for index in range(simulation.planting_slots.size()):
		if simulation.planted_slots.has(index) or simulation.reserved_slots.has(index):
			continue
		var distance := Vector2(point.x, point.z).distance_to(
			Vector2(simulation.planting_slots[index].x, simulation.planting_slots[index].z)
		)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = index
	return nearest


func _select_world_object(point: Vector3) -> void:
	var worker_distance := Vector2(point.x, point.z).distance_to(
		Vector2(simulation.worker.position.x, simulation.worker.position.z)
	)
	if worker_distance < 1.65:
		current_action = "WORKERS"
		ui.set_active_action("WORKERS")
		ui.set_selected_worker()
		return

	var closest_palm = null
	var closest_distance := 1.8
	for palm in simulation.palms:
		var distance := Vector2(point.x, point.z).distance_to(
			Vector2(palm.position.x, palm.position.z)
		)
		if distance < closest_distance:
			closest_distance = distance
			closest_palm = palm
	if closest_palm != null:
		current_action = ""
		ui.set_active_action("")
		ui.show_palm_detail(closest_palm)
		return

	if simulation.shelter != null:
		var shelter_distance := Vector2(point.x, point.z).distance_to(
			Vector2(simulation.shelter.position.x, simulation.shelter.position.z)
		)
		if shelter_distance < 4.0:
			current_action = ""
			ui.set_active_action("")
			ui.show_shelter_detail()
			return
	ui.dismiss_details()


func _on_action_selected(action: String) -> void:
	ui.dismiss_details()
	match action:
		"BUILD":
			if simulation.shelter != null:
				ui.show_toast("Your starter shelter is already in place.", "info")
				current_action = ""
				ui.set_active_action("")
				return
			current_action = "BUILD"
			ui.show_toast("Place the shelter inside the camp clearing west of the road.", "info")
		"LAND":
			if simulation.land_state == LandState.CLEARED:
				simulation.start_row_preparation()
				current_action = ""
				ui.set_active_action("")
				return
			if simulation.land_state == LandState.FOREST:
				current_action = "LAND"
				ui.show_toast("Tap inside the survey stakes to clear this forest block.", "info")
			else:
				current_action = ""
				ui.set_active_action("")
		"PLANT":
			if simulation.land_state == LandState.PREPARED:
				current_action = "PLANT"
				ui.show_toast("Tap the row markers to send the worker to plant.", "info")
			else:
				current_action = ""
				ui.set_active_action("")
		"WORKERS":
			current_action = "WORKERS"
			ui.set_selected_worker()
			camera.set_focus(simulation.worker.position, 18.0)
		"MANAGEMENT":
			current_action = "MANAGEMENT"
			ui.show_management()


func _on_maintenance_requested(action: String, palm_id: String) -> void:
	simulation.perform_maintenance(action, palm_id)


func _on_selection_closed() -> void:
	current_action = ""
	ui.set_active_action("")


func _on_shelter_started(building) -> void:
	world.spawn_shelter(building.position)
	_sync_world_state()


func _on_shelter_completed(_building) -> void:
	world.update_shelter_progress(1.0)
	_sync_world_state()


func _on_palm_planted(palm) -> void:
	world.add_palm_visual(palm)
	world.set_slot_state(palm.slot_index, "planted")
	_sync_world_state()


func _on_palm_changed(palm) -> void:
	world.update_palm_visual(palm)
	if ui.selected_kind == "palm" and ui.selected_id == palm.id:
		ui.refresh_palm_detail(palm)


func _on_job_changed() -> void:
	if ui.selected_kind == "worker":
		ui._update_worker_detail_values()
	ui.refresh_hud()


func _sync_palm_views() -> void:
	for palm in simulation.palms:
		world.update_palm_visual(palm)


func _sync_world_state() -> void:
	if not is_node_ready():
		return
	if simulation.shelter != null and world.shelter_root == null:
		world.spawn_shelter(simulation.shelter.position)
	world.set_land_progress(simulation.land_progress, int(simulation.land_state))
	world.set_preparation_progress(simulation.preparation_progress, int(simulation.land_state))
	world.set_planting_state(
		simulation.reserved_slots, simulation.planted_slots, int(simulation.land_state)
	)
	_sync_palm_views()
	if ui != null:
		ui.refresh_hud()


func _update_build_preview() -> void:
	if current_action != "BUILD" or simulation.shelter != null:
		world.set_build_preview(Vector3.ZERO, false, false)
		return
	var point := camera.ground_point(get_viewport().get_mouse_position())
	if point.x < -1000.0:
		world.set_build_preview(Vector3.ZERO, false, false)
		return
	world.set_build_preview(point, simulation.is_valid_shelter_location(point), true)
