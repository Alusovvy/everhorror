extends "res://tools/tests/test_base.gd"
## task_08: the player can walk around the new camp cave with real physics and the real input
## action (move_forward), steering along a navmesh baked from the level: from the bed to the
## fire, the map table in Racibor's pen, Tekla's stall, Hagiwara's corner, out through the east
## door to the barricade, up the corridor to the old entrance, to the boarded west tunnel and back
## to bed. A leg fails if the player gets stuck or doesn't arrive in time.

## [name, goal]; goals are points on the floor.
const LEGS := [
	["ognisko", Vector3(12.0, 0.0, 1.8)],
	["stół z mapą (w zagrodzie)", Vector3(25.1, 0.0, -3.6)],
	["stragan Tekli", Vector3(26.6, 0.0, 3.9)],
	["kącik Hagiwary", Vector3(29.8, 0.0, -5.0)],
	["wschodnie wyjście, do barykady", Vector3(34.3, 0.0, 3.0)],
	["korytarz do starego wejścia", Vector3(-2.0, 0.0, -11.0)],
	["zachodni chodnik, do desek", Vector3(-0.9, 0.0, 3.0)],
	["z powrotem do posłania", Vector3(8.2, 0.0, 3.9)],
]

var player

func scenario() -> void:
	timeout_s = 170.0
	step("boot the world (day 2, 10:00)")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 2
		gs.hour = 10.0)
	player = world.get_node("Player")
	var spawn: Node3D = world.get_node("Camp/Markers/SpawnBed")
	player.global_position = spawn.global_position + Vector3(0, 1.05, 0)
	# steering sets the head's yaw, so the body must not add its own
	player.rotation = Vector3.ZERO

	step("bake a player-sized navmesh of the camp")
	var nm := NavigationMesh.new()
	nm.agent_radius = 0.4
	nm.agent_height = 2.0
	nm.agent_max_climb = 0.3
	nm.agent_max_slope = 40.0
	nm.cell_size = 0.1
	nm.cell_height = 0.05
	nm.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nm.geometry_collision_mask = 1
	nm.filter_baking_aabb = AABB(Vector3(-6.0, -3.0, -22.0), Vector3(44.0, 12.0, 32.0))
	var src := NavigationMeshSourceGeometryData3D.new()
	for part in ["Mine", "Camp", "NPCs"]:
		var one := NavigationMeshSourceGeometryData3D.new()
		NavigationServer3D.parse_source_geometry_data(nm, one, world.get_node(part))
		src.merge(one)
	NavigationServer3D.bake_from_source_geometry_data(nm, src)
	check(nm.get_polygon_count() > 50, "navmesh baked (%d polygons)" % nm.get_polygon_count())
	var region := NavigationRegion3D.new()
	region.navigation_mesh = nm
	world.add_child(region)
	var map: RID = world.get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(map, nm.cell_size)
	NavigationServer3D.map_set_cell_height(map, nm.cell_height)
	# the region joins the map on a later physics iteration
	await physics_frames(30)
	check(NavigationServer3D.map_get_regions(map).size() > 0, "navmesh region is on the map")

	var only := OS.get_cmdline_user_args()
	for leg in LEGS:
		if not only.is_empty() and LEGS.find(leg) >= int(only[0]):
			break
		step("walk: " + leg[0])
		await walk_to(map, leg[1], leg[0])
	Input.action_release("move_forward")

## Walks the player along a navmesh path to `goal`; checks arrival within 0.8 m.
func walk_to(map: RID, goal: Vector3, what: String) -> void:
	var from: Vector3 = player.global_position
	var path := NavigationServer3D.map_get_path(map, from, goal, true)
	if path.is_empty() or path[path.size() - 1].distance_to(goal) > 1.0:
		check(false, "path to %s (ends at %s)" % [what, path[path.size() - 1] if not path.is_empty() else "nowhere"])
		return
	print("   path: %s" % [Array(path).map(func(v: Vector3) -> Vector3: return v.snapped(Vector3(0.1, 0.1, 0.1)))])
	var idx := 0
	var last := from
	var frames_on_leg := 0
	Input.action_press("move_forward")
	while true:
		await physics_frame
		frames_on_leg += 1
		var p: Vector3 = player.global_position
		while idx < path.size() and Vector2(path[idx].x - p.x, path[idx].z - p.z).length() < 0.45:
			idx += 1
		if idx >= path.size():
			break
		var to := Vector2(path[idx].x - p.x, path[idx].z - p.z)
		player.head.rotation.y = atan2(-to.x, -to.y)
		if frames_on_leg % 120 == 0:
			print("   … %.0f s at %s, point %d/%d %s" % [frames_on_leg / 60.0, p.snapped(Vector3(0.1, 0.1, 0.1)), idx, path.size(), path[idx].snapped(Vector3(0.1, 0.1, 0.1))])
		if frames_on_leg % 90 == 0:
			if p.distance_to(last) < 0.3:
				Input.action_release("move_forward")
				check(false, "reached %s (stuck at %s, next point %s)" % [what, p.snapped(Vector3(0.01, 0.01, 0.01)), path[idx].snapped(Vector3(0.01, 0.01, 0.01))])
				return
			last = p
		if frames_on_leg > 60 * 40:
			Input.action_release("move_forward")
			check(false, "reached %s within 40 s" % what)
			return
	Input.action_release("move_forward")
	await physics_frames(10)
	var end: Vector3 = player.global_position
	check(Vector2(end.x - goal.x, end.z - goal.z).length() < 0.8, "reached %s in %.1f s (at %s)" % [what, frames_on_leg / 60.0, end.snapped(Vector3(0.1, 0.1, 0.1))])

func physics_frames(n: int) -> void:
	for i in n:
		await physics_frame
