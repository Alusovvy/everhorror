extends SceneTree
## Usage: godot --headless --path . --script res://tools/level_probe.gd -- <scene.tscn> [group_depth]
## Prints every instanced piece of a level with its global position, yaw and world AABB, one per
## line (TSV): path, source scene, x, y, z, yaw, aabb min, aabb max. For planning geometry edits
## (which pieces form a room, where the openings are). Also: -- measure <piece.tscn>... prints the
## local AABB of each given piece scene.

func _initialize() -> void:
	# Global transforms are only valid once the tree has run a frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1 and args[0] == "measure":
		for path in args.slice(1):
			# A failed load would break into the debugger and hang a headless run.
			var packed := load(path) as PackedScene if ResourceLoader.exists(path) else null
			if packed == null:
				print("MEASURE\t%s\tMISSING" % path)
				continue
			var inst: Node3D = packed.instantiate()
			root.add_child(inst)
			var box := _aabb(inst)
			print("MEASURE\t%s\tsize %s\tpos %s" % [path, box.size, box.position])
			inst.queue_free()
		quit()
		return
	var scene: Node3D = load(args[0]).instantiate()
	root.add_child(scene)
	_walk(scene, scene)
	quit()

func _walk(node: Node, scene: Node) -> void:
	for child in node.get_children():
		if child is Node3D and child.scene_file_path != "":
			var n := child as Node3D
			var box := _aabb(n)
			var yaw := rad_to_deg(n.global_transform.basis.get_euler().y)
			print("PIECE\t%s\t%s\t%.2f\t%.2f\t%.2f\t%.0f\t%.2f,%.2f,%.2f\t%.2f,%.2f,%.2f" % [
				scene.get_path_to(n), n.scene_file_path.get_file(), n.global_position.x, n.global_position.y, n.global_position.z, yaw,
				box.position.x, box.position.y, box.position.z, box.end.x, box.end.y, box.end.z])
		else:
			_walk(child, scene)

## World-space AABB of all meshes under a node.
func _aabb(node: Node) -> AABB:
	var result := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		var box: AABB = m.global_transform * m.mesh.get_aabb()
		if first:
			result = box
			first = false
		else:
			result = result.merge(box)
	if node is MeshInstance3D and (node as MeshInstance3D).mesh:
		var own: AABB = (node as MeshInstance3D).global_transform * (node as MeshInstance3D).mesh.get_aabb()
		result = own if first else result.merge(own)
	return result
