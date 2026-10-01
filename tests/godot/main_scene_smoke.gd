extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"
const VisualFactory = preload("res://scripts/world/visual_factory.gd")
const PalmRecord = preload("res://scripts/simulation/palm_record.gd")
const SIMULATION_STEP_SECONDS := 0.05
const MAX_SIMULATION_TICKS := 60000

var _checks: int = 0
var _failures: int = 0
var _main_scene: Node
var _simulation: Node
var _world: Node


func _initialize() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	print("Native main-scene structural smoke; display driver: %s" % DisplayServer.get_name())
	_expect(
		str(ProjectSettings.get_setting("application/run/main_scene", "")) == MAIN_SCENE_PATH,
		"project config points to the expected Godot main scene",
	)
	var packed_scene: PackedScene = ResourceLoader.load(MAIN_SCENE_PATH) as PackedScene
	_expect(packed_scene != null, "main scene resource loads as PackedScene")
	if packed_scene == null:
		_finish()
		return

	_main_scene = packed_scene.instantiate()
	_expect(_main_scene is Node3D, "main scene instantiates as a 3D root")
	if _main_scene == null:
		_finish()
		return
	root.add_child(_main_scene)
	await process_frame
	await process_frame

	var world_node: Node = _main_scene.get_node_or_null("PlantationWorld")
	var simulation_node: Node = _main_scene.get_node_or_null("PlantationSimulation")
	var actors_node: Node = _main_scene.get_node_or_null("Actors")
	var camera_node: Node = _main_scene.get_node_or_null("StrategyCamera")
	var ui_node: Node = _main_scene.get_node_or_null("GameUI")
	_simulation = simulation_node
	_world = world_node

	_expect(world_node is Node3D, "PlantationWorld node exists")
	_expect(simulation_node != null, "PlantationSimulation node exists")
	_expect(actors_node is Node3D, "Actors container exists")
	_expect(camera_node is Camera3D, "StrategyCamera node exists")
	_expect(ui_node is CanvasLayer, "GameUI CanvasLayer exists")
	if world_node == null or simulation_node == null or actors_node == null or camera_node == null or ui_node == null:
		_finish()
		return

	_check_world_initialization()
	_check_camera_initialization(camera_node as Camera3D)
	_check_actor_initialization(actors_node as Node3D)
	_check_ui_initialization(ui_node as CanvasLayer)
	_check_simulation_initialization(simulation_node)
	_check_button_signal_dispatch(ui_node as CanvasLayer)
	await _exercise_existing_establishment_path()
	await process_frame
	_check_contextual_ui(ui_node as CanvasLayer)

	print("UNVERIFIED | Camera framing and actual world visibility cannot be judged from node transforms alone.")
	print("UNVERIFIED | Rasterized terrain, characters, worker, plantation palms, and shelter appearance/culling are not checked in Dummy/headless mode.")
	print("UNVERIFIED | Rendered HUD/context-panel layout, legibility, and overlap are not checked in Dummy/headless mode.")
	print("UNVERIFIED | Mouse/touch hit-testing and physical device input were not exercised; the action signal was tested programmatically only.")
	_finish()


func _check_world_initialization() -> void:
	_expect(bool(_world.get("_built")), "world builder completed its one-time build")
	var ground := _world.get_node_or_null("SubtleGroundTiles") as MeshInstance3D
	_expect(
		ground != null and ground.mesh != null and ground.mesh.get_surface_count() > 0,
		"terrain ArrayMesh is constructed and has a surface",
	)
	var map_edge := _world.get_node_or_null("MapEdge") as MeshInstance3D
	_expect(map_edge != null and map_edge.mesh != null, "map-edge mesh is assigned")
	var forest := _world.get_node_or_null("ForestTrunks") as MultiMeshInstance3D
	_expect(
		forest != null
		and forest.multimesh != null
		and forest.multimesh.mesh != null
		and forest.multimesh.instance_count > 0,
		"procedural plantation-edge forest MultiMesh is populated",
	)
	var markers: Array = _world.get("planting_markers")
	var guides: Array = _world.get("row_lines")
	_expect(markers.size() == 16, "all sixteen existing planting marker meshes are initialized")
	_expect(guides.size() == 4, "four plantation row-guide meshes are initialized")
	var background_palm_count: int = 0
	var background_palms_have_meshes: bool = true
	var background_asset_paths: Dictionary = {}
	for child in _world.get_children():
		var imported_model := child.get_node_or_null("ImportedPalmModel")
		if imported_model is Node3D:
			background_palm_count += 1
			background_palms_have_meshes = (
				background_palms_have_meshes and _mesh_instance_count(imported_model) > 0
			)
			background_asset_paths[str(imported_model.get_meta("source_glb", ""))] = true
	_expect(background_palm_count == 3, "three generic imported palm landmarks are instantiated")
	_expect(background_palms_have_meshes, "background GLB palms contain assigned mesh resources")
	_expect(
		background_asset_paths.size() == 3
			and background_asset_paths.has("res://assets/environment/palms/tree-palmdetailedtall.glb")
			and background_asset_paths.has("res://assets/environment/palms/tree-palm.glb")
			and background_asset_paths.has("res://assets/environment/palms/tree-palmbend.glb"),
		"background landmarks use the three selected palm source variants",
	)
	_check_imported_crop_palm_assets()
	_check_operations_asset_preview()


func _check_imported_crop_palm_assets() -> void:
	var young_palm := VisualFactory.create_palm(PalmRecord.GrowthStage.YOUNG)
	var young_model := young_palm.get_node_or_null("ImportedPalmModel")
	_expect(
		young_model is Node3D
			and str(young_model.get_meta("source_glb", ""))
			== "res://assets/environment/palms/tree-palmdetailedshort.glb"
			and _mesh_instance_count(young_model) > 0,
		"young crop palm instantiates the imported short-form GLB",
	)
	_expect(
		young_model is Node3D and (young_model as Node3D).scale.is_equal_approx(Vector3.ONE * 1.8),
		"young palm model uses its documented uniform scale",
	)
	var young_has_fruit := false
	for child in young_palm.get_children():
		if str(child.name).begins_with("FruitBunch_"):
			young_has_fruit = true
	_expect(not young_has_fruit, "young crop palm does not display mature FFB bunches")

	var ready_palm := VisualFactory.create_palm(
		PalmRecord.GrowthStage.MATURE, PalmRecord.FruitState.READY, true
	)
	var mature_model := ready_palm.get_node_or_null("ImportedPalmModel")
	_expect(
		mature_model is Node3D
			and str(mature_model.get_meta("source_glb", ""))
			== "res://assets/environment/palms/tree-palmdetailedtall.glb"
			and _mesh_instance_count(mature_model) > 0,
		"mature crop palm instantiates the imported tall-form GLB",
	)
	_expect(
		mature_model is Node3D and (mature_model as Node3D).scale.is_equal_approx(Vector3.ONE * 3.7),
		"mature palm model uses its documented uniform scale",
	)
	var palette_colors: Array[Color] = []
	_collect_palm_palette_colors(mature_model, palette_colors)
	var has_leaf_tint := false
	var has_bark_tint := false
	for color in palette_colors:
		has_leaf_tint = has_leaf_tint or color.is_equal_approx(Color(0.29, 0.43, 0.16))
		has_bark_tint = has_bark_tint or color.is_equal_approx(Color(0.43, 0.31, 0.19))
	_expect(
		has_leaf_tint and has_bark_tint,
		"imported palm surfaces receive the muted gameplay leaf/bark palette",
	)
	var fruit_bunch_count := 0
	var all_ready_bunches_glow := true
	for child in ready_palm.get_children():
		if not str(child.name).begins_with("FruitBunch_"):
			continue
		fruit_bunch_count += 1
		var bunch_material := child.get("material_override") as StandardMaterial3D
		all_ready_bunches_glow = all_ready_bunches_glow and bunch_material != null and bunch_material.emission_enabled
	_expect(fruit_bunch_count == 3, "ready mature crop palm retains three procedural FFB cues")
	_expect(all_ready_bunches_glow, "harvest-ready procedural FFB cues retain their emission highlight")
	young_palm.free()
	ready_palm.free()


func _check_operations_asset_preview() -> void:
	var mill_preview := _world.get_node_or_null("LocalMillVisualPreview") as Node3D
	_expect(mill_preview != null, "one static local-mill visual-preview yard is instantiated")
	if mill_preview == null:
		return
	_expect(
		str(mill_preview.get_meta("process_chain_status", "")) == "not_simulated",
		"generic mill assets remain explicitly outside process-stage simulation",
	)
	var sign_label := mill_preview.get_node_or_null(
		"MillVisualStatusSign/VisualConceptLabel"
	) as Label3D
	_expect(
		sign_label != null and sign_label.text.contains("VISUAL CONCEPT")
			and sign_label.text.contains("PROCESS FLOW NOT SIMULATED"),
		"mill sign discloses that the visual proxy is not an operational process model",
	)

	var expected_sources := [
		"res://assets/environment/operations/kenney-car-kit/tractor.glb",
		"res://assets/environment/operations/kenney-car-kit/truck.glb",
		"res://assets/environment/operations/kenney-city-kit-industrial/building-c.glb",
		"res://assets/environment/operations/kenney-city-kit-industrial/chimney-large.glb",
		"res://assets/environment/operations/kenney-city-kit-industrial/detail-tank-large.glb",
		"res://assets/environment/operations/kenney-factory-kit/conveyor-v1.glb",
		"res://assets/environment/operations/kenney-factory-kit/hopper-high-round.glb",
		"res://assets/environment/operations/kenney-factory-kit/pipe-large-valve.glb",
	]
	var proxy_nodes: Array[Node] = [
		_world.get_node_or_null("FieldTractorVisualProxy"),
		_world.get_node_or_null("GenericCollectionPickupVisualProxy"),
		mill_preview.get_node_or_null("GenericMillShellProxy"),
		mill_preview.get_node_or_null("GenericStackProxy"),
		mill_preview.get_node_or_null("GenericTankProxy"),
		mill_preview.get_node_or_null("GenericConveyorProxy"),
		mill_preview.get_node_or_null("GenericHopperProxy"),
		mill_preview.get_node_or_null("GenericPipeAndValveProxy"),
	]
	var integrated_sources: Dictionary = {}
	var all_assets_have_textured_materials := true
	for index in range(expected_sources.size()):
		var proxy := proxy_nodes[index]
		var expected_source: String = expected_sources[index]
		_expect(proxy is Node3D, "operation visual proxy exists: %s" % expected_source.get_file())
		if proxy == null:
			continue
		var imported_model := proxy.get_node_or_null("ImportedModel") as Node3D
		_expect(
			str(proxy.get_meta("source_glb", "")) == expected_source,
			"operation visual proxy references its reviewed GLB: %s" % expected_source.get_file(),
		)
		_expect(
			imported_model != null and _mesh_instance_count(imported_model) > 0,
			"reviewed GLB has initialized mesh resources: %s" % expected_source.get_file(),
		)
		all_assets_have_textured_materials = (
			all_assets_have_textured_materials and _has_textured_material(imported_model)
		)
		integrated_sources[expected_source] = true
	_expect(integrated_sources.size() == 8, "all eight downloaded GLBs are used once in the static preview")
	_expect(
		all_assets_have_textured_materials,
		"all eight operation GLBs retain their embedded or external color-map materials",
	)
	_expect(
		_world.get_node_or_null("CollectionAccessTrack") is MeshInstance3D
			and _world.get_node_or_null("LocalMillAccessTrack") is MeshInstance3D,
		"one static collection-to-road-to-mill route is represented with the existing access road",
	)
	_expect(
		_world.get_node_or_null("FieldTractorVisualProxy") is Node3D
			and _world.get_node_or_null("GenericCollectionPickupVisualProxy") is Node3D,
		"one generic field tractor and one generic collection-route pickup are placed",
	)


func _check_camera_initialization(camera: Camera3D) -> void:
	_expect(camera.current, "strategy camera is selected as the current Camera3D")
	_expect(camera.has_method("set_focus") and camera.has_method("ground_point"), "strategy-camera script methods are loaded")
	_expect(camera.global_position.y > 0.0, "strategy camera applies an elevated transform")


func _check_actor_initialization(actors: Node3D) -> void:
	var player := actors.get_node_or_null("PlayerCharacter")
	var worker := actors.get_node_or_null("PlantationWorker")
	_expect(player is Node3D, "player character scene node is created")
	_expect(worker is Node3D, "plantation worker scene node is created")
	_expect(_mesh_instance_count(player) >= 8, "player character has procedural mesh resources assigned")
	_expect(_mesh_instance_count(worker) >= 10, "worker has procedural mesh resources assigned")
	_expect(worker.get_node_or_null("FFBLoad") != null, "worker load visual node is initialized")


func _check_ui_initialization(ui: CanvasLayer) -> void:
	var screen := ui.get("screen") as Control
	_expect(screen != null, "UI creates its root HUD Control")
	if screen == null:
		return
	for panel_name in ["StatusCard", "Resources", "TimeAndSpeed", "Objective", "ActionBar", "DetailsPanel", "Toast"]:
		_expect(screen.get_node_or_null(panel_name) is Control, "HUD panel exists: %s" % panel_name)
	var action_buttons: Dictionary = ui.get("action_buttons")
	var expected_actions := ["BUILD", "LAND", "PLANT", "WORKERS", "MANAGEMENT"]
	_expect(action_buttons.size() == expected_actions.size(), "all five existing HUD action buttons are created")
	for action_name in expected_actions:
		var action_button := action_buttons.get(action_name) as Button
		var action_icon: TextureRect = null
		if action_button != null:
			action_icon = action_button.get_node_or_null("IconContent/ActionIcon") as TextureRect
		_expect(
			action_button != null and action_icon != null and action_icon.texture != null,
			"HUD action button has a native SVG icon: %s" % action_name,
		)
	_expect(ui.get("objective_title") is Label, "objective title label is initialized")
	_expect(ui.get("objective_hint") is Label, "objective hint label is initialized")
	_expect(ui.get("objective_bar") is ProgressBar, "objective progress bar is initialized")
	var resource_labels: Dictionary = ui.get("resource_labels")
	_expect(resource_labels.size() == 6, "HUD creates all six resource labels")


func _check_simulation_initialization(simulation: Node) -> void:
	var worker_record: Variant = simulation.get("worker")
	var collection_point: Variant = simulation.get("collection_point")
	var slots: Array = simulation.get("planting_slots")
	var resources: Dictionary = simulation.get("resources")
	_expect(worker_record != null, "fresh simulation creates a worker record")
	_expect(collection_point != null, "fresh simulation creates an FFB collection point")
	_expect(slots.size() == 16, "fresh simulation creates sixteen planting positions")
	_expect(resources.get("money", 0) == 1800, "fresh simulation state initializes its starting funds")
	_expect(simulation.has_method("request_plant") and simulation.has_method("start_shelter_construction"), "existing gameplay methods are callable")


func _check_button_signal_dispatch(ui: CanvasLayer) -> void:
	var action_buttons: Dictionary = ui.get("action_buttons")
	var build_button := action_buttons.get("BUILD") as Button
	if build_button == null:
		_expect(false, "programmatic BUILD action signal reaches main controller")
		return
	build_button.emit_signal("pressed")
	_expect(
		str(_main_scene.get("current_action")) == "BUILD" and str(ui.get("active_action")) == "BUILD",
		"programmatic BUILD action signal reaches main controller",
	)


func _exercise_existing_establishment_path() -> void:
	var shelter_accepted: bool = bool(
		_simulation.call("start_shelter_construction", Vector3(-20.0, 0.0, 11.0))
	)
	_expect(shelter_accepted, "existing shelter construction action accepts its valid test site")
	if not shelter_accepted:
		return
	var shelter_root := _world.get("shelter_root") as Node3D
	_expect(shelter_root != null, "simulation signal creates the existing shelter scene")
	if shelter_root == null:
		return
	_expect(shelter_root.name == "StarterShelter", "shelter root has the expected scene identity")
	_expect(_mesh_instance_count(shelter_root) >= 15, "shelter construction creates its existing mesh parts")
	var shelter_ready := _advance_until(
		func() -> bool:
			var building: Variant = _simulation.get("shelter")
			return building != null and bool(building.is_complete),
		"shelter completion",
	)
	_expect(shelter_ready, "shelter task completes in the main-scene simulation")
	var shelter_parts: Dictionary = _world.get("shelter_parts")
	if shelter_parts.has("frame"):
		_expect((shelter_parts.frame as Node3D).visible, "completed shelter frame is enabled")
		_expect((shelter_parts.walls as Node3D).visible, "completed shelter walls are enabled")
		_expect((shelter_parts.roof_frame as Node3D).visible, "completed shelter roof frame is enabled")
		_expect((shelter_parts.roof as Node3D).visible, "completed shelter roof is enabled")
	else:
		_expect(false, "shelter visual parts are registered")

	var land_zone: Variant = _simulation.get("land_zone")
	var land_position: Vector3 = land_zone.position
	var clearing_started: bool = bool(_simulation.call("start_land_clearing", land_position))
	_expect(clearing_started, "existing clearing action accepts the prepared test prerequisite")
	if not clearing_started:
		return
	var land_prepared := _advance_until(
		func() -> bool: return int(_simulation.get("land_state")) == 2,
		"land preparation",
	)
	_expect(land_prepared, "existing clearing task reaches PREPARED")
	if not land_prepared:
		return
	var field_soil := _world.get("field_soil") as MeshInstance3D
	_expect(field_soil != null and field_soil.visible and field_soil.mesh != null, "prepared terrain view is enabled with its mesh")
	var row_markers: Array = _world.get("planting_markers")
	var visible_markers: int = 0
	for marker in row_markers:
		if (marker as MeshInstance3D).visible:
			visible_markers += 1
	_expect(visible_markers == 16, "all sixteen planting grid markers become visible on prepared land")

	var planting_accepted: bool = bool(_simulation.call("request_plant", 0))
	_expect(planting_accepted, "existing planting action queues the first palm")
	if not planting_accepted:
		return
	var palm_planted := _advance_until(
		func() -> bool:
			var palms: Array = _simulation.get("palms")
			return palms.size() == 1,
		"first palm planting",
	)
	_expect(palm_planted, "planting task creates one crop palm in the main scene")
	if not palm_planted:
		return
	var palms: Array = _simulation.get("palms")
	var palm: Variant = palms[0]
	var palm_views: Dictionary = _world.get("palm_views")
	var palm_entry: Dictionary = palm_views.get(str(palm.id), {})
	var palm_view := palm_entry.get("node") as Node3D
	_expect(palm_view != null, "simulation palm-planted signal registers the crop palm view")
	_expect(_mesh_instance_count(palm_view) >= 5, "crop palm scene has procedural mesh resources assigned")


func _check_contextual_ui(ui: CanvasLayer) -> void:
	var details_panel := ui.get("details_panel") as PanelContainer
	if details_panel == null:
		_expect(false, "contextual UI details panel is initialized")
		return
	var palms: Array = _simulation.get("palms")
	if not palms.is_empty():
		ui.call("show_palm_detail", palms[0])
		_expect(details_panel.visible, "existing palm detail panel opens from scene UI logic")
		_expect(str(ui.get("selected_kind")) == "palm", "palm detail state is reflected in the UI controller")
		var detail_content := ui.get("details_content") as VBoxContainer
		var pest_index_unit_correct := false
		if detail_content != null:
			for child in detail_content.get_children():
				if not (child is HBoxContainer):
					continue
				var row_labels: Array[String] = []
				for row_child in child.get_children():
					if row_child is Label:
						row_labels.append(str((row_child as Label).text))
				if (
					row_labels.size() >= 2
					and row_labels[0] == "PEST INDEX"
					and row_labels[1].ends_with("/ 100")
					and not row_labels[1].contains("%")
				):
					pest_index_unit_correct = true
		_expect(
			pest_index_unit_correct,
			"pest index uses a 0-100 scenario scale instead of a percent label",
		)
		ui.call("show_management")
		var cohort_summary_visible := false
		var outlook_rows_visible := {
			"AVG HEALTH": false,
			"AVG FERTILIZER": false,
			"AVG PEST INDEX": false,
			"READY NOW": false,
			"NEXT 30 MODEL DAYS": false,
			"EARLIEST WINDOW": false
		}
		if detail_content != null:
			for child in detail_content.get_children():
				if child is Label and str((child as Label).text).contains("Y01-M01"):
					cohort_summary_visible = true
				if child is HBoxContainer:
					for row_child in child.get_children():
						if row_child is Label and outlook_rows_visible.has((row_child as Label).text):
							outlook_rows_visible[(row_child as Label).text] = true
		_expect(cohort_summary_visible, "estate overview displays the planted palm's crop cohort")
		_expect(
			bool(outlook_rows_visible["READY NOW"])
				and bool(outlook_rows_visible["NEXT 30 MODEL DAYS"])
				and bool(outlook_rows_visible["EARLIEST WINDOW"]),
			"estate overview displays condition averages and harvest-window feedback",
		)


func _advance_until(condition: Callable, label: String, max_ticks: int = MAX_SIMULATION_TICKS) -> bool:
	for _tick in range(max_ticks):
		if bool(condition.call()):
			return true
		_simulation.call("_process", SIMULATION_STEP_SECONDS)
	return bool(condition.call())


func _collect_palm_palette_colors(node: Node, colors: Array[Color]) -> void:
	if node == null:
		return
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				var surface_material := mesh_instance.get_surface_override_material(surface_index)
				if surface_material is StandardMaterial3D:
					colors.append((surface_material as StandardMaterial3D).albedo_color)
	for child in node.get_children():
		_collect_palm_palette_colors(child, colors)


func _has_textured_material(node: Node) -> bool:
	if node == null:
		return false
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		if instance.mesh != null:
			for surface_index in range(instance.mesh.get_surface_count()):
				var active_material := instance.get_active_material(surface_index) as BaseMaterial3D
				if active_material != null and active_material.albedo_texture != null:
					return true
	for child in node.get_children():
		if _has_textured_material(child):
			return true
	return false


func _mesh_instance_count(node: Node) -> int:
	if node == null:
		return 0
	var count: int = 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		count += 1
	for child in node.get_children():
		count += _mesh_instance_count(child)
	return count


func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("PASS | %s" % label)
	else:
		_failures += 1
		push_error("FAIL | %s" % label)


func _finish() -> void:
	print("Smoke assertions: %d passed, %d failed." % [_checks - _failures, _failures])
	if _failures == 0:
		print("RESULT: PASS for project/scene/runtime structure; visual rendering remains UNVERIFIED.")
		quit(0)
	else:
		print("RESULT: FAIL for main-scene smoke assertions.")
		quit(1)
