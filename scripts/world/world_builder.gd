extends Node3D
class_name PlantationWorld

## Builds the compact game map and owns view-only scene nodes for terrain and vegetation.
const VisualFactory = preload("res://scripts/world/visual_factory.gd")

const MAP_SIZE := Vector2(82.0, 68.0)
const FIELD_CENTER := Vector3(8.0, 0.0, 10.0)
const FIELD_SIZE := Vector2(24.0, 18.0)

var clearing_trees: Array[Node3D] = []
var planting_markers: Array[MeshInstance3D] = []
var row_lines: Array[MeshInstance3D] = []
var palm_views: Dictionary = {}
var shelter_parts: Dictionary = {}
var shelter_root: Node3D
var field_soil: MeshInstance3D
var preview_root: Node3D
var _slot_materials: Dictionary = {}
var _preview_material: StandardMaterial3D
var preparation_progress: float = 0.0
var _preview_valid: Variant = null
var _built := false


func build_world(planting_slots: Array[Vector3]) -> void:
	if _built:
		return
	_built = true
	_build_terrain()
	_build_background_forest()
	_build_paths_and_clearings()
	_build_clearable_block()
	_build_props()
	_build_planting_markers(planting_slots)
	_build_placement_preview()


func _build_terrain() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 721
	var columns := 22
	var rows := 18
	var cell_x := MAP_SIZE.x / float(columns)
	var cell_z := MAP_SIZE.y / float(rows)
	for z in range(rows):
		for x in range(columns):
			var x0 := -MAP_SIZE.x * 0.5 + float(x) * cell_x
			var z0 := -MAP_SIZE.y * 0.5 + float(z) * cell_z
			var base := Color(0.25, 0.34, 0.22)
			var shift := rng.randf_range(-0.027, 0.027)
			var tile_color := Color(base.r + shift, base.g + shift, base.b + shift * 0.7)
			var a := Vector3(x0, -0.12, z0)
			var b := Vector3(x0 + cell_x, -0.12, z0)
			var c := Vector3(x0 + cell_x, -0.12, z0 + cell_z)
			var d := Vector3(x0, -0.12, z0 + cell_z)
			surface.set_color(tile_color)
			surface.add_vertex(a)
			surface.add_vertex(c)
			surface.add_vertex(b)
			surface.add_vertex(a)
			surface.add_vertex(d)
			surface.add_vertex(c)
	surface.generate_normals()
	var ground_mesh := surface.commit()
	var ground := MeshInstance3D.new()
	ground.name = "SubtleGroundTiles"
	ground.mesh = ground_mesh
	var ground_material := StandardMaterial3D.new()
	ground_material.vertex_color_use_as_albedo = true
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	add_child(ground)

	# A soft base slab extends beyond the subtle color grid to define the playable island.
	var edge := MeshInstance3D.new()
	edge.name = "MapEdge"
	var edge_mesh := PlaneMesh.new()
	edge_mesh.size = Vector2(MAP_SIZE.x + 4.0, MAP_SIZE.y + 4.0)
	edge.mesh = edge_mesh
	edge.position.y = -0.19
	edge.material_override = VisualFactory.material(Color(0.20, 0.27, 0.19))
	add_child(edge)


func _build_background_forest() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 90317
	var tree_positions: Array[Vector3] = []
	var heights: Array[float] = []
	var spreads: Array[float] = []
	var colors: Array[Color] = []
	for z_index in range(15):
		for x_index in range(18):
			var x := -40.0 + float(x_index) * 4.75 + rng.randf_range(-1.4, 1.4)
			var z := -33.0 + float(z_index) * 4.65 + rng.randf_range(-1.4, 1.4)
			if absf(z) < 2.5:
				continue  # keep the road corridor readable
			if x > -5.0 and x < 21.0 and z > -1.0 and z < 21.0:
				continue  # the designated plantation block
			if x > -31.0 and x < -10.0 and z > 5.0 and z < 23.5:
				continue  # starting camp and shelter-placement clearing
			if Vector2(x - 8.0, z - 10.0).length() < 17.0:
				continue
			if x < -36.0 or x > 39.0 or z < -31.0 or z > 32.0:
				continue
			tree_positions.append(Vector3(x, 0.0, z))
			heights.append(rng.randf_range(4.5, 7.7))
			spreads.append(rng.randf_range(1.05, 1.65))
			var tone := rng.randf_range(-0.055, 0.055)
			colors.append(Color(0.17 + tone, 0.31 + tone, 0.17 + tone * 0.55))

	var trunks := _make_tree_multimesh(tree_positions, heights, spreads, colors, 0)
	trunks.name = "ForestTrunks"
	add_child(trunks)
	var crowns := _make_tree_multimesh(tree_positions, heights, spreads, colors, 1)
	crowns.name = "ForestCanopies"
	add_child(crowns)
	var side_crowns := _make_tree_multimesh(tree_positions, heights, spreads, colors, 2)
	side_crowns.name = "ForestCanopyVariation"
	add_child(side_crowns)

	# A few mature palms sit on the distant forest edge as environmental landmarks.
	for item in [Vector3(-35, 0, -24), Vector3(31, 0, -26), Vector3(35, 0, 22)]:
		var palm := VisualFactory.create_palm(2)
		palm.position = item
		palm.scale = Vector3(0.86, 0.86, 0.86)
		add_child(palm)


func _make_tree_multimesh(
	positions: Array[Vector3],
	heights: Array[float],
	spreads: Array[float],
	colors: Array[Color],
	part: int
) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	var source_mesh: Mesh
	if part == 0:
		var trunk := CylinderMesh.new()
		trunk.height = 2.0
		trunk.bottom_radius = 0.12
		trunk.top_radius = 0.09
		trunk.radial_segments = 7
		source_mesh = trunk
	elif part == 1:
		var crown := SphereMesh.new()
		crown.radius = 1.0
		crown.height = 2.0
		crown.radial_segments = 9
		crown.rings = 6
		source_mesh = crown
	else:
		var crown_side := SphereMesh.new()
		crown_side.radius = 1.0
		crown_side.height = 2.0
		crown_side.radial_segments = 8
		crown_side.rings = 5
		source_mesh = crown_side
	multimesh.mesh = source_mesh
	multimesh.instance_count = positions.size()
	for index in range(positions.size()):
		var position := positions[index]
		var height := heights[index]
		var spread := spreads[index]
		var transform := Transform3D.IDENTITY
		if part == 0:
			var trunk_h := height * 0.59
			transform.basis = Basis().scaled(Vector3(spread * 0.13, trunk_h * 0.5, spread * 0.13))
			transform.origin = Vector3(position.x, trunk_h * 0.5, position.z)
		elif part == 1:
			var trunk_h := height * 0.59
			transform.basis = Basis().scaled(Vector3(spread, spread * 0.78, spread * 0.91))
			transform.origin = Vector3(position.x, trunk_h + spread * 0.48, position.z)
		else:
			var trunk_h := height * 0.59
			var offset_x := spread * (0.38 if index % 2 == 0 else -0.37)
			transform.basis = Basis().scaled(Vector3(spread * 0.62, spread * 0.59, spread * 0.66))
			transform.origin = Vector3(
				position.x + offset_x, trunk_h + spread * 0.38, position.z + spread * 0.17
			)
		multimesh.set_instance_transform(index, transform)
		multimesh.set_instance_color(index, colors[index] if part > 0 else Color(0.41, 0.30, 0.20))
	var view := MultiMeshInstance3D.new()
	view.multimesh = multimesh
	var tree_material := StandardMaterial3D.new()
	tree_material.vertex_color_use_as_albedo = true
	tree_material.roughness = 0.96
	view.material_override = tree_material
	return view


func _build_paths_and_clearings() -> void:
	var road := MeshInstance3D.new()
	road.name = "PlantationAccessRoad"
	var road_mesh := PlaneMesh.new()
	road_mesh.size = Vector2(83.0, 4.0)
	road.mesh = road_mesh
	road.position = Vector3(0, -0.035, 0)
	road.material_override = VisualFactory.material(Color(0.34, 0.31, 0.25), 1.0)
	add_child(road)
	# Faint wheel-worn shoulder and an access spur lead toward the field.
	var spur := MeshInstance3D.new()
	spur.name = "FieldTrack"
	var spur_mesh := PlaneMesh.new()
	spur_mesh.size = Vector2(3.2, 12.0)
	spur.mesh = spur_mesh
	spur.position = Vector3(-1.5, -0.025, 7.8)
	spur.material_override = VisualFactory.material(Color(0.31, 0.30, 0.23), 1.0)
	add_child(spur)
	var camp_clear := MeshInstance3D.new()
	camp_clear.name = "CampClearing"
	var camp_mesh := PlaneMesh.new()
	camp_mesh.size = Vector2(21.0, 15.0)
	camp_clear.mesh = camp_mesh
	camp_clear.position = Vector3(-21.0, -0.055, 14.0)
	camp_clear.material_override = VisualFactory.material(Color(0.31, 0.34, 0.24), 1.0)
	add_child(camp_clear)

	# Wet-season pond gives the compact map a natural landmark.
	var pond := MeshInstance3D.new()
	pond.name = "SmallPond"
	var pond_mesh := PlaneMesh.new()
	pond_mesh.size = Vector2(9.0, 5.5)
	pond.mesh = pond_mesh
	pond.position = Vector3(29.0, -0.025, -25.0)
	pond.material_override = VisualFactory.material(Color(0.13, 0.25, 0.26), 0.3)
	add_child(pond)


func _build_clearable_block() -> void:
	field_soil = MeshInstance3D.new()
	field_soil.name = "PreparedSoil"
	var soil_mesh := PlaneMesh.new()
	soil_mesh.size = FIELD_SIZE
	field_soil.mesh = soil_mesh
	field_soil.position = Vector3(FIELD_CENTER.x, -0.005, FIELD_CENTER.z)
	field_soil.material_override = VisualFactory.material(Color(0.35, 0.29, 0.20), 1.0)
	field_soil.visible = false
	add_child(field_soil)

	var border_color := Color(0.49, 0.44, 0.31)
	for side in [-1.0, 1.0]:
		var horizontal := MeshInstance3D.new()
		var horizontal_mesh := BoxMesh.new()
		horizontal_mesh.size = Vector3(FIELD_SIZE.x, 0.045, 0.07)
		horizontal.mesh = horizontal_mesh
		horizontal.position = Vector3(
			FIELD_CENTER.x, 0.02, FIELD_CENTER.z + side * FIELD_SIZE.y * 0.5
		)
		horizontal.material_override = VisualFactory.material(border_color)
		add_child(horizontal)
		var vertical := MeshInstance3D.new()
		var vertical_mesh := BoxMesh.new()
		vertical_mesh.size = Vector3(0.07, 0.045, FIELD_SIZE.y)
		vertical.mesh = vertical_mesh
		vertical.position = Vector3(
			FIELD_CENTER.x + side * FIELD_SIZE.x * 0.5, 0.02, FIELD_CENTER.z
		)
		vertical.material_override = VisualFactory.material(border_color)
		add_child(vertical)
	for x_side in [-1.0, 1.0]:
		for z_side in [-1.0, 1.0]:
			var stake := VisualFactory.cylinder(
				self,
				"SurveyStake",
				1.05,
				0.065,
				0.052,
				Vector3(
					FIELD_CENTER.x + x_side * (FIELD_SIZE.x * 0.5 - 0.1),
					0.52,
					FIELD_CENTER.z + z_side * (FIELD_SIZE.y * 0.5 - 0.1)
				),
				Color(0.43, 0.34, 0.22),
				6
			)
			VisualFactory.box(
				stake,
				"SurveyFlag",
				Vector3(0.32, 0.20, 0.045),
				Vector3(0.15, 0.28, 0.0),
				Color(0.68, 0.49, 0.25)
			)

	var rng := RandomNumberGenerator.new()
	rng.seed = 1882
	for z in range(5):
		for x in range(7):
			var tree := VisualFactory.create_forest_tree(
				rng.randf_range(4.1, 6.3),
				rng.randf_range(0.93, 1.45),
				Color(0.18, 0.32, 0.18).lerp(Color(0.24, 0.39, 0.21), rng.randf())
			)
			tree.position = Vector3(
				FIELD_CENTER.x - 10.0 + float(x) * 3.25 + rng.randf_range(-0.7, 0.7),
				0.0,
				FIELD_CENTER.z - 6.8 + float(z) * 3.4 + rng.randf_range(-0.65, 0.65)
			)
			clearing_trees.append(tree)
			add_child(tree)
	clearing_trees.sort_custom(
		func(left: Node3D, right: Node3D) -> bool:
			return (
				left.position.distance_squared_to(FIELD_CENTER)
				< right.position.distance_squared_to(FIELD_CENTER)
			)
	)


func _build_props() -> void:
	var camp := VisualFactory.create_temporary_camp()
	camp.position = Vector3(-27.0, 0.0, 17.0)
	add_child(camp)
	var pickup := VisualFactory.create_utility_vehicle()
	pickup.position = Vector3(-31.0, 0.0, -0.8)
	add_child(pickup)

	# Barrels, stacked timber and field stones make the land feel occupied, without clutter.
	var barrel := MeshInstance3D.new()
	barrel.name = "RainBarrel"
	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.height = 0.9
	barrel_mesh.bottom_radius = 0.38
	barrel_mesh.top_radius = 0.35
	barrel_mesh.radial_segments = 10
	barrel.mesh = barrel_mesh
	barrel.position = Vector3(-24.9, 0.45, 17.0)
	barrel.material_override = VisualFactory.material(Color(0.31, 0.35, 0.28))
	add_child(barrel)
	for index in range(3):
		var log := MeshInstance3D.new()
		log.name = "TimberLog"
		var log_mesh := CylinderMesh.new()
		log_mesh.height = 2.4
		log_mesh.bottom_radius = 0.16
		log_mesh.top_radius = 0.16
		log_mesh.radial_segments = 8
		log.mesh = log_mesh
		log.position = Vector3(-14.0 + float(index) * 0.12, 0.18 + float(index % 2) * 0.30, 19.5)
		log.rotation.z = PI * 0.5
		log.material_override = VisualFactory.material(Color(0.39, 0.29, 0.19))
		add_child(log)

	var rng := RandomNumberGenerator.new()
	rng.seed = 332
	for index in range(18):
		var rock := MeshInstance3D.new()
		rock.name = "FieldStone"
		var rock_mesh := SphereMesh.new()
		rock_mesh.radius = 0.5
		rock_mesh.height = 0.78
		rock_mesh.radial_segments = 8
		rock_mesh.rings = 5
		rock.mesh = rock_mesh
		rock.scale = Vector3(
			rng.randf_range(0.45, 1.15), rng.randf_range(0.36, 0.75), rng.randf_range(0.55, 1.0)
		)
		var rock_x := rng.randf_range(-38.0, 38.0)
		var rock_z := rng.randf_range(-31.0, 31.0)
		if (
			absf(rock_z) < 4.0
			or (rock_x > -6.0 and rock_x < 21.0 and rock_z > -1.0 and rock_z < 21.0)
		):
			rock_x = -37.0 if index % 2 == 0 else 37.0
		rock.position = Vector3(rock_x, 0.12, rock_z)
		rock.material_override = VisualFactory.material(
			Color(0.39, 0.39, 0.34).lerp(Color(0.27, 0.29, 0.27), rng.randf()), 0.98
		)
		add_child(rock)


func _build_planting_markers(slots: Array[Vector3]) -> void:
	for row in range(4):
		var line := MeshInstance3D.new()
		line.name = "RowGuide_%d" % row
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(18.5, 0.035, 0.055)
		line.mesh = line_mesh
		line.position = Vector3(FIELD_CENTER.x, 0.025, FIELD_CENTER.z + (float(row) - 1.5) * 4.3)
		line.material_override = VisualFactory.material(Color(0.63, 0.59, 0.39))
		line.visible = false
		row_lines.append(line)
		add_child(line)

	var open_material := VisualFactory.material(Color(0.76, 0.71, 0.47), 0.76)
	var queued_material := VisualFactory.material(Color(0.89, 0.63, 0.20), 0.68)
	_slot_materials["open"] = open_material
	_slot_materials["queued"] = queued_material
	for index in range(slots.size()):
		var marker := MeshInstance3D.new()
		marker.name = "PlantingPoint_%02d" % index
		var ring := TorusMesh.new()
		ring.inner_radius = 0.22
		ring.outer_radius = 0.29
		ring.rings = 6
		ring.ring_segments = 12
		marker.mesh = ring
		marker.position = Vector3(slots[index].x, 0.075, slots[index].z)
		marker.material_override = open_material
		marker.visible = false
		planting_markers.append(marker)
		add_child(marker)


func _build_placement_preview() -> void:
	preview_root = Node3D.new()
	preview_root.name = "ShelterPlacementPreview"
	_preview_material = VisualFactory.material(Color(0.54, 0.76, 0.47, 0.68), 0.6)
	_preview_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var edge_thickness := 0.12
	var edges := [
		{"size": Vector3(5.4, 0.08, edge_thickness), "pos": Vector3(0, 0.08, -2.3)},
		{"size": Vector3(5.4, 0.08, edge_thickness), "pos": Vector3(0, 0.08, 2.3)},
		{"size": Vector3(edge_thickness, 0.08, 4.7), "pos": Vector3(-2.65, 0.08, 0)},
		{"size": Vector3(edge_thickness, 0.08, 4.7), "pos": Vector3(2.65, 0.08, 0)}
	]
	for edge in edges:
		var segment := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = edge.size
		segment.mesh = mesh
		segment.position = edge.pos
		segment.material_override = _preview_material
		preview_root.add_child(segment)
	preview_root.visible = false
	add_child(preview_root)


func spawn_shelter(position: Vector3) -> void:
	if shelter_root != null and is_instance_valid(shelter_root):
		shelter_root.queue_free()
	shelter_parts = VisualFactory.create_shelter(position)
	shelter_root = shelter_parts.root
	add_child(shelter_root)
	update_shelter_progress(0.0)


func update_shelter_progress(progress: float) -> void:
	if shelter_parts.is_empty():
		return
	shelter_parts.frame.visible = progress >= 0.25
	shelter_parts.walls.visible = progress >= 0.50
	shelter_parts.roof_frame.visible = progress >= 0.75
	shelter_parts.roof.visible = progress >= 1.0


func set_land_progress(progress: float, land_state: int) -> void:
	field_soil.visible = land_state >= 2 or (land_state == 1 and progress >= 0.24)
	var hidden_count := 0
	if land_state == 1:
		hidden_count = int(floor(clampf(progress, 0.0, 1.0) * float(clearing_trees.size())))
	elif land_state >= 2:
		hidden_count = clearing_trees.size()
	for index in range(clearing_trees.size()):
		clearing_trees[index].visible = index >= hidden_count


func set_preparation_progress(progress: float, land_state: int) -> void:
	preparation_progress = progress
	var preparing := land_state == 3 or land_state == 4
	for row in range(row_lines.size()):
		row_lines[row].visible = (
			land_state == 4
			or (preparing and progress >= float(row + 1) / float(row_lines.size() + 1))
		)
	for marker in planting_markers:
		marker.visible = land_state == 4 or (preparing and progress >= 0.45)


func set_slot_state(slot_index: int, state: String) -> void:
	if slot_index < 0 or slot_index >= planting_markers.size():
		return
	var marker := planting_markers[slot_index]
	match state:
		"queued":
			marker.visible = true
			marker.material_override = _slot_materials.queued
		"open":
			marker.visible = true
			marker.material_override = _slot_materials.open
		"planted":
			marker.visible = false


func set_planting_state(reserved: Dictionary, planted: Dictionary, land_state: int) -> void:
	for index in range(planting_markers.size()):
		if planted.has(index):
			set_slot_state(index, "planted")
		elif reserved.has(index):
			set_slot_state(index, "queued")
		elif land_state == 4:
			set_slot_state(index, "open")
		else:
			planting_markers[index].visible = land_state == 3 and preparation_progress >= 0.45


func set_build_preview(point: Vector3, valid: bool, enabled: bool) -> void:
	preview_root.visible = enabled
	if not enabled:
		return
	preview_root.position = Vector3(point.x, 0.0, point.z)
	if _preview_valid == valid:
		return
	_preview_valid = valid
	_preview_material.albedo_color = (
		Color(0.53, 0.80, 0.43, 0.76) if valid else Color(0.84, 0.31, 0.20, 0.76)
	)


func add_palm_visual(palm) -> void:
	var visual := VisualFactory.create_palm(int(palm.growth_stage))
	visual.position = palm.position
	visual.name = palm.id
	add_child(visual)
	palm_views[palm.id] = {"node": visual, "stage": int(palm.growth_stage)}


func update_palm_visual(palm) -> void:
	if not palm_views.has(palm.id):
		add_palm_visual(palm)
		return
	var entry: Dictionary = palm_views[palm.id]
	if int(entry.stage) == int(palm.growth_stage):
		return
	var previous := entry.node as Node3D
	var replacement := VisualFactory.create_palm(int(palm.growth_stage))
	replacement.position = palm.position
	replacement.name = palm.id
	add_child(replacement)
	previous.queue_free()
	palm_views[palm.id] = {"node": replacement, "stage": int(palm.growth_stage)}


func get_palm_position(palm_id: String) -> Vector3:
	if palm_views.has(palm_id):
		return (palm_views[palm_id].node as Node3D).position
	return Vector3.ZERO
