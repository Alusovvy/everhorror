extends SceneTree
## Usage: godot --headless --path . --script res://tools/interact_test.gd
## Aims the player at every interactable and checks highlight, prompt and description panel.

var world: Node3D
var frame := 0
var targets := ["Bag2", "Barrel2", "Crate", "Note", "Bucket", "MineDeep/Rails/mine_cart_aa_1", "MineDeep/Props/Pickaxe_Bronze_1", "MineDeep/Props/Scroll_2_1", "MineDeep/BlueIronVeins/cave_wall_rocks_c_1"]
var idx := -1
var player
var hud

func _initialize() -> void:
	pass

func _aim_at(node_name: String) -> void:
	var area = world.get_node(node_name + "/Interactable")
	var shape
	for c in area.get_children():
		if c is CollisionShape3D:
			shape = c
	var goal: Vector3 = shape.global_position
	# stand 1.6 m away from the target horizontally, facing it
	var stands := {"MineDeep/Rails/mine_cart_aa_1": Vector3(59.6, -0.3, 2.2), "MineDeep/Props/Pickaxe_Bronze_1": Vector3(71.8, -1.05, 4.4), "MineDeep/Props/Scroll_2_1": Vector3(76.2, -1.05, 1.8)}
	var from: Vector3 = goal + (player.global_position - goal).normalized() * 1.6
	from.y = player.global_position.y
	if stands.has(node_name):
		from = stands[node_name]
	player.global_position = from
	player.velocity = Vector3.ZERO
	var eye: Vector3 = player.eye_camera.global_position
	player.head.look_at(Vector3(goal.x, player.head.global_position.y, goal.z))
	var flat: float = Vector2(goal.x - eye.x, goal.z - eye.z).length()
	player.eye_camera.rotation.x = atan2(goal.y - eye.y, flat)

func _physics_process(_d: float) -> bool:
	frame += 1
	if frame == 1:
		world = load("res://scene/world.tscn").instantiate()
		root.add_child(world)
		player = world.get_node("Player")
		hud = world.get_node("HUD")
		return false
	if frame == 5:
		var s := (world.get_node("Barrel2/Interactable") as Node).get_child_count()
		print("barrel interactable children: ", s)
	if frame >= 10 and frame % 6 == 4:
		if idx >= 0:
			var name: String = targets[idx]
			var f = player.focused
			var hl := false
			if f:
				for m in f._meshes:
					hl = hl or m.material_overlay != null
			var col = player.interact_ray.get_collider()
			print("   ray hit: ", col.get_path() if col else null, " at ", player.interact_ray.get_collision_point(), " player=", player.global_position, " eye=", player.eye_camera.global_position)
			print("%-8s focused=%s highlighted=%s prompt='%s' visible=%s" % [name, f.display_name if f else "null", hl, hud.prompt.text, hud.prompt.visible])
			if f:
				player.interacted.emit(f)
				print("         panel=%s title='%s' body_len=%d" % [hud.description_panel.visible, hud.description_title.text, hud.description_body.text.length()])
				player.interacted.emit(f)
				print("         after 2nd E: panel=%s prompt=%s" % [hud.description_panel.visible, hud.prompt.visible])
		idx += 1
		if idx >= targets.size():
			return true
		_aim_at(targets[idx])
	return false
