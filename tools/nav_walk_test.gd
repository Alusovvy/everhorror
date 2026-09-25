extends SceneTree
## Usage: godot --headless --path . --script res://tools/nav_walk_test.gd [-- gx gy gz]
## Bakes a player-sized navmesh (radius 0.35 m) from level colliders, finds a path from the spawn to the goal
## (default: deep chamber) and walks it with real physics. Prints DONE or STUCK.
## Bakes a navmesh (player-sized) from level colliders, finds a path spawn -> goal, then walks it with physics.
## Args: -- gx gy gz   (goal)
var world: Node3D
var player
var f := 0
var path: PackedVector3Array
var idx := 0
var last_pos := Vector3.ZERO
var goal := Vector3(76, -2.1, 3)

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() >= 3:
		goal = Vector3(float(a[0]), float(a[1]), float(a[2]))

func _physics_process(_d: float) -> bool:
	f += 1
	if f == 1:
		world = load("res://scene/world.tscn").instantiate()
		root.add_child(world)
		player = world.get_node("Player")
		return false
	if f == 3:
		var nm := NavigationMesh.new()
		nm.agent_radius = 0.35
		nm.agent_height = 2.0
		nm.agent_max_climb = 0.3
		nm.agent_max_slope = 40.0
		nm.cell_size = 0.05
		nm.cell_height = 0.05
		nm.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
		var src := NavigationMeshSourceGeometryData3D.new()
		nm.geometry_collision_mask = 1
		NavigationServer3D.parse_source_geometry_data(nm, src, world)
		print("source vertices: ", src.get_vertices().size() / 3, " has_data=", src.has_data())
		NavigationServer3D.bake_from_source_geometry_data(nm, src)
		print("navmesh polygons: ", nm.get_polygon_count())
		var nav_map := world.get_world_3d().navigation_map
		NavigationServer3D.map_set_cell_size(nav_map, nm.cell_size)
		NavigationServer3D.map_set_cell_height(nav_map, nm.cell_height)
		var region := NavigationRegion3D.new()
		region.navigation_mesh = nm
		world.add_child(region)
		return false
	if f == 40:
		var map := world.get_world_3d().navigation_map
		NavigationServer3D.map_force_update(map)
		var start := Vector3(-4.06, 1.2, -34.07)
		path = NavigationServer3D.map_get_path(map, start, goal, true)
		print("closest start: ", NavigationServer3D.map_get_closest_point(map, start), "  closest goal: ", NavigationServer3D.map_get_closest_point(map, goal), " regions: ", NavigationServer3D.map_get_regions(map).size())
		for probe in [Vector3(-4, 1.2, -30), Vector3(-1, 1.2, -26), Vector3(-0.5, 1.0, -15), Vector3(10, 0, 0), Vector3(40, 0, 3), Vector3(60, -1, 3), Vector3(70, -2.1, 3)]:
			print("   probe ", probe, " -> ", NavigationServer3D.map_get_closest_point(map, probe).snapped(Vector3(0.01, 0.01, 0.01)))
		var end := path[path.size() - 1] if path.size() > 0 else Vector3.INF
		print("path points: %d  end=%s  goal=%s  reaches_goal=%s" % [path.size(), end, goal, end.distance_to(goal) < 1.5])
		if path.is_empty():
			return true
		player.global_position = Vector3(-4.06, 2.4, -34.07)
		player.rotation = Vector3.ZERO
		Input.action_press("move_forward")
		last_pos = player.global_position
		return false
	if f < 40:
		return false
	var p: Vector3 = player.global_position
	while idx < path.size() and Vector2(path[idx].x - p.x, path[idx].z - p.z).length() < 0.5:
		idx += 1
	if idx >= path.size():
		print("DONE: walked the whole path to %s in %.1fs" % [p.snapped(Vector3(0.01, 0.01, 0.01)), f / 60.0])
		return true
	var to := Vector2(path[idx].x - p.x, path[idx].z - p.z)
	player.head.rotation.y = atan2(-to.x, -to.y)
	if f % 90 == 0:
		if p.distance_to(last_pos) < 0.3:
			print("STUCK at %s (path point %d/%d: %s)" % [p.snapped(Vector3(0.01, 0.01, 0.01)), idx, path.size(), path[idx]])
			return true
		last_pos = p
		if f % 600 == 0:
			print("  progress t=%.0fs pos=%s point %d/%d" % [f / 60.0, p.snapped(Vector3(0.1, 0.1, 0.1)), idx, path.size()])
	return f > 60 * 120
