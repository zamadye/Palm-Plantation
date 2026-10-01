extends SceneTree

func _initialize() -> void:
	call_deferred("_attach_box_mesh")


func _attach_box_mesh() -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "ProbeBoxMeshInstance"
	mesh_instance.mesh = BoxMesh.new()
	print("Standalone probe attached BoxMesh to node: %s" % mesh_instance.name)
	root.add_child(mesh_instance)
	await process_frame
	print("Probe completed; see renderer diagnostics above. The process exit code alone does not indicate rendered output.")
	quit(0)
