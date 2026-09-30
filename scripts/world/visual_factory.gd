extends RefCounted
class_name VisualFactory

## Lightweight procedural models made from a small set of reusable primitive meshes.
## No external assets or large textures are required.


static func material(
	color: Color, roughness: float = 0.88, metallic: float = 0.0
) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	result.metallic = metallic
	return result


static func box(
	parent: Node3D, label: String, size: Vector3, at: Vector3, color: Color
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.material_override = material(color)
	instance.position = at
	parent.add_child(instance)
	return instance


static func sphere(
	parent: Node3D,
	label: String,
	radius: float,
	at: Vector3,
	color: Color,
	scale_value: Vector3 = Vector3.ONE,
	low_poly: bool = false
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12 if low_poly else 20
	mesh.rings = 8 if low_poly else 12
	instance.mesh = mesh
	instance.material_override = material(color)
	instance.position = at
	instance.scale = scale_value
	parent.add_child(instance)
	return instance


static func cylinder(
	parent: Node3D,
	label: String,
	height: float,
	bottom_radius: float,
	top_radius: float,
	at: Vector3,
	color: Color,
	radial_segments: int = 10
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.bottom_radius = bottom_radius
	mesh.top_radius = top_radius
	mesh.radial_segments = radial_segments
	instance.mesh = mesh
	instance.material_override = material(color)
	instance.position = at
	parent.add_child(instance)
	return instance


static func create_forest_tree(
	height: float = 5.4, spread: float = 1.4, tint: Color = Color(0.19, 0.34, 0.19)
) -> Node3D:
	var root := Node3D.new()
	root.name = "ForestTree"
	var trunk_height := height * 0.61
	cylinder(
		root,
		"Trunk",
		trunk_height,
		spread * 0.15,
		spread * 0.11,
		Vector3(0, trunk_height * 0.5, 0),
		Color(0.31, 0.235, 0.16),
		8
	)
	var crown_y := trunk_height + height * 0.19
	sphere(root, "Crown", spread, Vector3(0, crown_y, 0), tint, Vector3(1.12, 0.88, 0.98), true)
	sphere(
		root,
		"CrownEast",
		spread * 0.69,
		Vector3(spread * 0.52, crown_y - 0.26, 0.05),
		tint.lightened(0.07),
		Vector3(1.0, 0.85, 1.0),
		true
	)
	sphere(
		root,
		"CrownWest",
		spread * 0.66,
		Vector3(-spread * 0.48, crown_y - 0.18, -0.08),
		tint.darkened(0.06),
		Vector3(1.0, 0.87, 1.0),
		true
	)
	return root


static func create_palm(growth_stage: int) -> Node3D:
	var root := Node3D.new()
	root.name = "OilPalm"
	var trunk_height: float
	var trunk_radius: float
	var crown_radius: float
	var leaf_count: int
	match growth_stage:
		0:
			trunk_height = 0.33
			trunk_radius = 0.055
			crown_radius = 0.48
			leaf_count = 5
		1:
			trunk_height = 0.78
			trunk_radius = 0.085
			crown_radius = 0.88
			leaf_count = 6
		2:
			trunk_height = 1.65
			trunk_radius = 0.13
			crown_radius = 1.38
			leaf_count = 7
		_:
			trunk_height = 2.8
			trunk_radius = 0.18
			crown_radius = 1.95
			leaf_count = 8

	cylinder(
		root,
		"Trunk",
		trunk_height,
		trunk_radius,
		trunk_radius * 0.78,
		Vector3(0, trunk_height * 0.5, 0),
		Color(0.43, 0.31, 0.19),
		10
	)
	var crown := Vector3(0, trunk_height + 0.02, 0)
	sphere(
		root,
		"CrownBase",
		crown_radius * 0.18,
		crown,
		Color(0.36, 0.43, 0.19),
		Vector3(1.0, 0.68, 1.0),
		true
	)
	for index in range(leaf_count):
		var angle := TAU * float(index) / float(leaf_count) + 0.17
		var length := crown_radius * (1.12 if index % 2 == 0 else 0.96)
		var frond := MeshInstance3D.new()
		frond.name = "Frond_%02d" % index
		frond.mesh = _make_frond_mesh(
			length,
			crown_radius * 0.42,
			Color(0.23, 0.38, 0.13) if index % 2 == 0 else Color(0.29, 0.43, 0.16)
		)
		frond.position = crown
		frond.rotation.y = -angle
		root.add_child(frond)
	return root


static func _make_frond_mesh(length: float, drop: float, leaf_color: Color) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 10
	for side in [-1.0, 1.0]:
		for index in range(segments):
			var t := (float(index) + 0.45) / float(segments)
			var spine := Vector3(length * t, -drop * t * t, 0.0)
			var leaflet_length := length * (0.40 - 0.16 * t)
			var tip := (
				spine
				+ Vector3(-leaflet_length * 0.48, -leaflet_length * 0.24, side * leaflet_length)
			)
			var edge_a := (
				spine
				+ Vector3(
					-leaflet_length * 0.42, -leaflet_length * 0.12, side * leaflet_length * 0.42
				)
			)
			var edge_b := (
				spine
				+ Vector3(
					-leaflet_length * 0.12, -leaflet_length * 0.14, side * leaflet_length * 0.78
				)
			)
			tool.set_color(leaf_color)
			tool.add_vertex(spine)
			tool.add_vertex(edge_a)
			tool.add_vertex(tip)
			tool.add_vertex(spine)
			tool.add_vertex(tip)
			tool.add_vertex(edge_b)
			# Reverse the winding as well, making the thin leaves visible from below too.
			tool.add_vertex(tip)
			tool.add_vertex(edge_a)
			tool.add_vertex(spine)
			tool.add_vertex(edge_b)
			tool.add_vertex(tip)
			tool.add_vertex(spine)
	tool.generate_normals()
	var mesh := tool.commit() as ArrayMesh
	if mesh != null and mesh.get_surface_count() > 0:
		var leaf_material := material(leaf_color, 0.92)
		leaf_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh.surface_set_material(0, leaf_material)
	return mesh


static func create_person(is_player: bool) -> Node3D:
	var root := Node3D.new()
	root.name = "PlayerCharacter" if is_player else "PlantationWorker"
	var pants_color := Color(0.24, 0.28, 0.25) if is_player else Color(0.22, 0.25, 0.22)
	var shirt_color := Color(0.20, 0.36, 0.39) if is_player else Color(0.76, 0.36, 0.13)
	var skin := Color(0.62, 0.42, 0.29)
	var headwear := Color(0.32, 0.38, 0.28) if is_player else Color(0.83, 0.66, 0.22)
	box(root, "Torso", Vector3(0.46, 0.62, 0.31), Vector3(0, 1.18, 0), shirt_color)
	box(root, "Waist", Vector3(0.38, 0.2, 0.29), Vector3(0, 0.77, 0), pants_color)
	if not is_player:
		box(
			root,
			"ReflectiveStripe",
			Vector3(0.48, 0.055, 0.325),
			Vector3(0, 1.16, 0.0),
			Color(0.88, 0.72, 0.32)
		)
	sphere(root, "Head", 0.205, Vector3(0, 1.69, 0), skin, Vector3(0.92, 1.0, 0.88))
	var helmet := cylinder(root, "HardHat", 0.12, 0.24, 0.20, Vector3(0, 1.88, 0), headwear, 10)
	box(root, "HatBrim", Vector3(0.48, 0.045, 0.44), Vector3(0, 1.85, 0), headwear)

	var left_leg := Node3D.new()
	left_leg.name = "LeftLeg"
	left_leg.position = Vector3(-0.13, 0.74, 0)
	root.add_child(left_leg)
	var right_leg := Node3D.new()
	right_leg.name = "RightLeg"
	right_leg.position = Vector3(0.13, 0.74, 0)
	root.add_child(right_leg)
	for leg in [left_leg, right_leg]:
		var leg_mesh := cylinder(
			leg, "Leg", 0.64, 0.105, 0.13, Vector3(0, -0.34, 0), pants_color, 8
		)
		box(
			leg, "Boot", Vector3(0.2, 0.12, 0.31), Vector3(0, -0.68, 0.045), Color(0.18, 0.17, 0.14)
		)

	var left_arm := Node3D.new()
	left_arm.name = "LeftArm"
	left_arm.position = Vector3(-0.29, 1.42, 0)
	root.add_child(left_arm)
	var right_arm := Node3D.new()
	right_arm.name = "RightArm"
	right_arm.position = Vector3(0.29, 1.42, 0)
	root.add_child(right_arm)
	for arm in [left_arm, right_arm]:
		cylinder(arm, "Sleeve", 0.61, 0.09, 0.115, Vector3(0, -0.32, 0), shirt_color, 8)
		sphere(arm, "Hand", 0.09, Vector3(0, -0.66, 0), skin, Vector3(0.9, 1.0, 0.9), true)

	# A small shovel is carried by the worker and moves with the working arm.
	var tool := Node3D.new()
	tool.name = "Tool"
	tool.position = Vector3(0.11, -0.55, 0.13)
	right_arm.add_child(tool)
	cylinder(tool, "Handle", 0.7, 0.025, 0.025, Vector3(0, -0.12, 0), Color(0.39, 0.27, 0.17), 6)
	var blade := box(
		tool, "Blade", Vector3(0.12, 0.20, 0.045), Vector3(0, -0.48, 0), Color(0.42, 0.46, 0.43)
	)
	blade.rotation.x = -0.15
	return root


static func animate_person(root: Node3D, state_name: String, clock: float) -> void:
	var left_arm := root.get_node_or_null("LeftArm") as Node3D
	var right_arm := root.get_node_or_null("RightArm") as Node3D
	var left_leg := root.get_node_or_null("LeftLeg") as Node3D
	var right_leg := root.get_node_or_null("RightLeg") as Node3D
	var torso := root.get_node_or_null("Torso") as Node3D
	var tool := root.get_node_or_null("RightArm/Tool") as Node3D
	if tool != null:
		tool.visible = state_name in ["CLEARING", "PLANTING", "BUILDING", "FERTILIZING", "TREATING"]
	var swing := sin(clock * 8.0) * 0.48
	if state_name == "WALKING":
		if left_arm != null:
			left_arm.rotation.x = -swing
		if right_arm != null:
			right_arm.rotation.x = swing
		if left_leg != null:
			left_leg.rotation.x = swing
		if right_leg != null:
			right_leg.rotation.x = -swing
	elif state_name in ["CLEARING", "PLANTING", "BUILDING", "FERTILIZING", "TREATING"]:
		if right_arm != null:
			right_arm.rotation.x = -0.55 + sin(clock * 5.8) * 0.48
		if left_arm != null:
			left_arm.rotation.x = 0.14 + sin(clock * 5.8 + 0.6) * 0.18
		if left_leg != null:
			left_leg.rotation.x = 0.0
		if right_leg != null:
			right_leg.rotation.x = 0.0
	else:
		if left_arm != null:
			left_arm.rotation.x = sin(clock * 1.7) * 0.035
		if right_arm != null:
			right_arm.rotation.x = -sin(clock * 1.5) * 0.035
		if left_leg != null:
			left_leg.rotation.x = 0.0
		if right_leg != null:
			right_leg.rotation.x = 0.0
	if torso != null:
		torso.position.y = 1.18 + (0.025 * sin(clock * 8.0) if state_name == "WALKING" else 0.0)


static func create_shelter(position: Vector3) -> Dictionary:
	var root := Node3D.new()
	root.name = "StarterShelter"
	root.position = position
	var base_color := Color(0.46, 0.39, 0.28)
	box(root, "Foundation", Vector3(5.0, 0.20, 4.0), Vector3(0, 0.12, 0), base_color)
	box(
		root, "Threshold", Vector3(0.8, 0.11, 0.35), Vector3(0, 0.28, 2.08), Color(0.31, 0.25, 0.18)
	)

	var frame := Node3D.new()
	frame.name = "Frame"
	root.add_child(frame)
	var timber := Color(0.40, 0.28, 0.17)
	for x in [-2.28, 2.28]:
		for z in [-1.75, 1.75]:
			box(frame, "Post", Vector3(0.17, 2.55, 0.17), Vector3(x, 1.48, z), timber)
	for z in [-1.75, 1.75]:
		box(frame, "Beam", Vector3(4.75, 0.17, 0.17), Vector3(0, 2.72, z), timber)
	for x in [-2.28, 2.28]:
		box(frame, "Beam", Vector3(0.17, 0.17, 3.65), Vector3(x, 2.72, 0), timber)

	var walls := Node3D.new()
	walls.name = "Walls"
	root.add_child(walls)
	var wall_color := Color(0.62, 0.52, 0.37)
	# Front wall leaves a clear doorway; rear and sides are intact.
	box(walls, "RearWall", Vector3(4.45, 2.02, 0.12), Vector3(0, 1.30, -1.72), wall_color)
	box(walls, "FrontLeft", Vector3(1.58, 2.02, 0.12), Vector3(-1.44, 1.30, 1.72), wall_color)
	box(walls, "FrontRight", Vector3(1.58, 2.02, 0.12), Vector3(1.44, 1.30, 1.72), wall_color)
	box(walls, "SideLeft", Vector3(0.12, 2.02, 3.42), Vector3(-2.25, 1.30, 0), wall_color)
	box(walls, "SideRight", Vector3(0.12, 2.02, 3.42), Vector3(2.25, 1.30, 0), wall_color)

	var roof_frame := Node3D.new()
	roof_frame.name = "RoofFrame"
	root.add_child(roof_frame)
	for z in [-1.4, 0.0, 1.4]:
		box(roof_frame, "Rafter", Vector3(4.9, 0.12, 0.13), Vector3(0, 3.03, z), timber)
	var roof := Node3D.new()
	roof.name = "Roof"
	root.add_child(roof)
	var roof_color := Color(0.30, 0.32, 0.24)
	var left_roof := box(
		roof, "RoofSlope", Vector3(5.5, 0.18, 2.45), Vector3(0, 3.34, -0.79), roof_color
	)
	left_roof.rotation.x = -0.40
	var right_roof := box(
		roof,
		"RoofSlope",
		Vector3(5.5, 0.18, 2.45),
		Vector3(0, 3.34, 0.79),
		roof_color.lightened(0.04)
	)
	right_roof.rotation.x = 0.40
	box(roof, "RidgeCap", Vector3(5.7, 0.19, 0.20), Vector3(0, 3.85, 0), Color(0.34, 0.34, 0.25))
	var window_frame := box(
		walls,
		"Window",
		Vector3(0.62, 0.58, 0.08),
		Vector3(-1.18, 1.53, -1.64),
		Color(0.21, 0.31, 0.29)
	)
	window_frame.material_override = material(Color(0.22, 0.34, 0.32), 0.3)

	frame.visible = false
	walls.visible = false
	roof_frame.visible = false
	roof.visible = false
	return {"root": root, "frame": frame, "walls": walls, "roof_frame": roof_frame, "roof": roof}


static func create_temporary_camp() -> Node3D:
	var root := Node3D.new()
	root.name = "TemporaryCamp"
	box(
		root,
		"SleepingPlatform",
		Vector3(2.1, 0.18, 1.45),
		Vector3(0, 0.18, 0),
		Color(0.41, 0.31, 0.21)
	)
	var tarp := box(
		root, "Tarp", Vector3(2.65, 0.12, 1.8), Vector3(0, 1.78, -0.05), Color(0.38, 0.40, 0.28)
	)
	tarp.rotation.x = -0.13
	for x in [-1.18, 1.18]:
		cylinder(
			root, "TentPole", 1.68, 0.045, 0.045, Vector3(x, 0.91, 0.0), Color(0.36, 0.27, 0.17), 6
		)
	box(
		root,
		"StorageCrate",
		Vector3(0.7, 0.62, 0.62),
		Vector3(1.35, 0.32, 0.7),
		Color(0.46, 0.34, 0.22)
	)
	return root


static func create_utility_vehicle() -> Node3D:
	var root := Node3D.new()
	root.name = "UtilityPickup"
	box(root, "Chassis", Vector3(3.5, 0.62, 1.68), Vector3(0, 0.86, 0), Color(0.27, 0.34, 0.27))
	box(root, "Hood", Vector3(1.18, 0.35, 1.58), Vector3(-1.12, 1.24, 0), Color(0.31, 0.38, 0.30))
	box(root, "Cab", Vector3(1.43, 0.90, 1.48), Vector3(0.35, 1.49, 0), Color(0.29, 0.37, 0.30))
	box(
		root,
		"Windshield",
		Vector3(0.055, 0.65, 1.20),
		Vector3(-0.30, 1.52, 0),
		Color(0.18, 0.28, 0.28)
	)
	box(root, "Bed", Vector3(0.95, 0.20, 1.52), Vector3(1.55, 1.27, 0), Color(0.23, 0.29, 0.23))
	for x in [-1.12, 1.12]:
		for z in [-0.90, 0.90]:
			var wheel := cylinder(
				root, "Wheel", 0.22, 0.39, 0.39, Vector3(x, 0.39, z), Color(0.12, 0.13, 0.12), 10
			)
			wheel.rotation.x = PI * 0.5
	return root
