extends "res://tools/tests/test_base.gd"
## task_08: every camp marker is a sane place to stand. For each marker under Camp/Markers inside
## the camp cave: there is flat floor under it at its height, a person fits there without touching
## a wall or a solid prop (seated markers: only the upper body is checked, the legs go under the
## table), nobody stands with their nose in the rock, and every marker is inside the cave.
## Also: the player's spawn and return points fit the player's capsule.

## Seated or crouching markers (CampSchedule poses): the legs may overlap the bench or log.
const LOW := ["MiroslawFire", "MiroslawCorner", "MiroslawPowder", "BolkoEat", "BolkoStorage", "RaciborEat", "TeklaGuarded",
	"WszeborEat", "WszeborFire", "NasirEat", "NasirSick", "NasirWater", "NasirEvening", "HagiwaraEat", "HagiwaraTea",
	"SobekDice", "AnzelmPray"]
## Markers that face the rock on purpose (praying, sulking).
const FACING_ROCK_OK := ["AnzelmPray", "BolkoAway"]
const CAVE := Rect2(0.9, -8.1, 30.2, 14.2)   # x, z of the usable cave floor

func scenario() -> void:
	step("boot the world")
	await start_world(func(): gs.set_flag("intro_done"))
	await physics_frames(3)
	var space: PhysicsDirectSpaceState3D = world.get_viewport().world_3d.direct_space_state
	# People and the player are not part of the level.
	var exclude: Array[RID] = []
	for body in world.find_children("*", "CollisionObject3D", true, false):
		var path := String(world.get_path_to(body))
		if path.begins_with("NPCs") or path.begins_with("Player"):
			exclude.append((body as CollisionObject3D).get_rid())

	# Rock pieces are hollow trimeshes: a body wholly inside one touches no triangle and rays from
	# inside see no faces. So also test against the core (middle half) of each rock's mesh box.
	var cores: Array = []
	for rock in world.get_node("Camp/Cave/Rocks").get_children():
		var box := mesh_box(rock)
		var margin := Vector3(box.size.x * 0.25, 0.0, box.size.z * 0.25)
		cores.append([String(rock.name), AABB(box.position + margin, box.size - margin * 2.0)])

	step("camp markers")
	var markers: Array = world.get_node("Camp/Markers").get_children()
	var bad := 0
	var count := 0
	for m in markers:
		var mk := m as Node3D
		var n := String(mk.name)
		if n.ends_with("Entry") or n.contains("Spot"):
			continue   # outside the cave (corridors, tunnels)
		count += 1
		var p := mk.global_position
		var problems: PackedStringArray = []
		if not CAVE.has_point(Vector2(p.x, p.z)):
			problems.append("poza jaskinią")
		# floor
		var down := PhysicsRayQueryParameters3D.create(p + Vector3(0, 0.6, 0), p + Vector3(0, -0.6, 0), 1, exclude)
		var hit := space.intersect_ray(down)
		if hit.is_empty():
			problems.append("brak podłogi")
		else:
			if absf(hit.position.y - p.y) > 0.12:
				problems.append("podłoga na %.2f, znacznik na %.2f" % [hit.position.y, p.y])
			if hit.normal.y < 0.95:
				problems.append("podłoga krzywa (normal.y %.2f)" % hit.normal.y)
		# body clearance
		var player := n == "SpawnBed" or n == "CampReturn"
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.35 if player else 0.26
		var y0 := 0.15
		if n in LOW:
			y0 = 0.95
		capsule.height = maxf((2.0 if player else 1.75) - y0, capsule.radius * 2.0)
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = capsule
		q.collision_mask = 1
		q.exclude = exclude
		q.transform = Transform3D(Basis.IDENTITY, p + Vector3(0, y0 + capsule.height * 0.5, 0))
		var touching: PackedStringArray = []
		for r in space.intersect_shape(q, 8):
			var hit_node: Node = r.collider
			touching.append(String(world.get_path_to(hit_node)).get_slice("/", 0) + "…" + String(hit_node.get_parent().name) + "/" + String(hit_node.name))
		for core in cores:
			var c: AABB = core[1]
			if c.has_point(Vector3(p.x, c.get_center().y, p.z)):
				touching.append("wnętrze " + String(core[0]))
		if not touching.is_empty():
			problems.append("koliduje z: " + ", ".join(touching))
		# nose in the rock
		if not player and n not in FACING_ROCK_OK:
			var fwd := mk.global_basis * Vector3.BACK
			var eye := p + Vector3(0, 1.45 if n not in LOW else 0.9, 0)
			var look := PhysicsRayQueryParameters3D.create(eye, eye + fwd * 0.7, 1, exclude)
			var front := space.intersect_ray(look)
			# only rock and walls count: facing the barrel or cart you work at is the point
			var wall_path := "" if front.is_empty() else String(world.get_path_to(front.collider))
			if wall_path.begins_with("Mine") or wall_path.begins_with("Camp/Cave") or wall_path.contains("/Pen/"):
				problems.append("twarzą w %s (%.2f m)" % [String(front.collider.get_parent().name), eye.distance_to(front.position)])
		if problems.is_empty():
			print("   %-16s (%5.1f, %5.1f)  ok" % [n, p.x, p.z])
		else:
			bad += 1
			print("   %-16s (%5.1f, %5.1f)  %s" % [n, p.x, p.z, "; ".join(problems)])
	# control: the same queries must see the rock pillar and the north wall
	var probe := PhysicsShapeQueryParameters3D.new()
	var probe_capsule := CapsuleShape3D.new()
	probe_capsule.radius = 0.26
	probe_capsule.height = 1.6
	probe.shape = probe_capsule
	probe.collision_mask = 1
	probe.exclude = exclude
	var pillar: Vector3 = world.get_node("Camp/Cave/Rocks/Pillar").global_position
	probe.transform = Transform3D(Basis.IDENTITY, pillar + Vector3(0, 0.95, 0))
	var in_core := false
	for core in cores:
		in_core = in_core or (core[1] as AABB).has_point(Vector3(pillar.x, (core[1] as AABB).get_center().y, pillar.z))
	check(in_core, "control: a person inside the rock pillar is caught")
	probe.transform = Transform3D(Basis.IDENTITY, pillar + Vector3(0.9, 0.95, 0))
	check(not space.intersect_shape(probe, 1).is_empty(), "control: a person half in the pillar touches it")
	var wall_ray := PhysicsRayQueryParameters3D.create(Vector3(12.0, 1.45, -7.0), Vector3(12.0, 1.45, -10.0), 1, exclude)
	check(not space.intersect_ray(wall_ray).is_empty(), "control: the north wall is hit by a ray")
	check(count > 30, "checked %d camp markers" % count)
	check(bad == 0, "every camp marker is a sane place to stand (%d with problems)" % bad)

## World AABB of all meshes under a node.
func mesh_box(node: Node) -> AABB:
	var result := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false) + ([node] if node is MeshInstance3D else []):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		var box: AABB = m.global_transform * m.mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result

func physics_frames(n: int) -> void:
	for i in n:
		await physics_frame
