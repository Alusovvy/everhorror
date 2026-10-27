extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_camp.gd
## Generates res://scene/levels/camp.tscn: the expedition camp in a natural cave (task_08; it used
## to be the boarded hall of the pack's test level), about 32 × 16 m and 6 m high, with its areas
## (spec 04_tresc/miejsca.md, "Obóz") in the old order, west to east:
## - west: Anzelm's infirmary (north-west), the sleeping place (south-west), Mirosław's bedroll,
## - middle: the fire with the cook's corner (the heart of the camp), the common table,
## - storage under a timber scaffold with the one old track and its ore carts, the powder store in
##   the far north corner,
## - east: Racibor's pen (a roofless palisade with the map table), Tekla's stall by the east door,
##   Hagiwara's corner,
## plus the barricades with exits, the west segment (grandfather's key, broken supports, blast
## debris, a vein), the fuse box in the east chamber, and markers for spawning, travel, the NPC
## schedule (script/camp_schedule.gd) and meeting spots in the east and west tunnels (FieldSchedule).
## WARNING: overwrites the scene. Edit this generator, not the scene.

const K := "res://assets/props/kenney_survival/"
const P := "res://assets/prop_pack/Exports/glTF/"
const M := "res://assets/LoafbrrAssets/MineAndCavesSet/scenes/"
var OUT := _out_path("res://scene/levels/camp.tscn")
const Y_WEST_LOW := -2.0     # floor of the west tunnel below the first ramp
const Y_CHAMBER := -2.116    # floor of the east cave chamber
const TABLE_TOP := 0.81      # Table_Large height
const WALL_SCALE := 1.3      # cave wall pieces: 6.4 m wide, up to ~6 m high
const WALL_Y := 0.2
const VAULT_Y := 6.55        # the vault pieces hang down to ~5.7 m
const RAIL_Z := 2.6          # the old track, from the east door to the storage
const FIRE := Vector3(14.0, 0.0, 0.2)
const TABLE := Vector3(17.2, 0.0, -4.2)
const MAP := Vector3(25.1, 0.0, -5.0)
const STALL := Vector3(26.6, 0.0, 5.0)
const PEN_WEST := 21.8
const PEN_EAST := 28.4
const PEN_SOUTH := -2.5
const TEKLA_SEAT := Vector3(23.0, 0.0, -3.6)
const SICK_SEAT := Vector3(3.6, 0.0, -5.9)
const SCRIBE_STOOL := Vector3(29.7, 0.0, -6.9)
const SCRIBE_DESK := Vector3(30.5, 0.0, -6.3)
const SABINA_EVENING := Vector3(3.2, 0.0, 1.0)

var root3d: Node3D
var cache := {}
var counter := {}


## Where the scene is written: `--out=<file>` after `--` (tools/check_generated.js regenerates into a
## temporary folder this way), otherwise the real scene.
func _out_path(default_path: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			return arg.trim_prefix("--out=")
	return default_path

func scene(path: String) -> PackedScene:
	if not cache.has(path):
		cache[path] = load(path)
	return cache[path]

func own(n: Node, parent: Node) -> Node:
	parent.add_child(n)
	n.owner = root3d
	return n

func group(parent: Node, group_name: String) -> Node3D:
	var g := Node3D.new()
	g.name = group_name
	return own(g, parent)

func add(parent: Node, path: String, pos: Vector3, yaw_deg := 0.0, scale := 1.0, node_name := "") -> Node3D:
	var n: Node3D = scene(path).instantiate()
	var base := node_name if node_name != "" else path.get_file().get_basename().replace("-", "_")
	counter[base] = counter.get(base, 0) + 1
	n.name = base if node_name != "" else "%s_%d" % [base, counter[base]]
	n.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)).scaled(Vector3.ONE * scale), pos)
	return own(n, parent)

## A group whose meshes get `material_path` as override (re-skins flat Kenney props).
func skinned(parent: Node, group_name: String, material_path: String) -> Node3D:
	var g := Node3D.new()
	g.name = group_name
	g.set_script(load("res://script/material_applier.gd"))
	g.set("material", load(material_path))
	return own(g, parent)

func marker(parent: Node, marker_name: String, pos: Vector3, yaw_deg: float) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)), pos)
	own(m, parent)

func interactable(parent: Node, node_name: String, props: Dictionary) -> Area3D:
	var area := Area3D.new()
	area.name = node_name
	area.set_script(load("res://script/interactable.gd"))
	for key in props:
		area.set(key, props[key])
	own(area, parent)
	if props.get("action", 0) == 2:
		area.add_to_group(&"story_use", true)
	return area

## Short flavour text on a prop (DESCRIBE), not solid unless asked.
func look(parent: Node, display_name: String, description: String, solid := false, padding := 0.05) -> Area3D:
	return interactable(parent, "Look", {"display_name": display_name, "description": description, "solid": solid, "padding": padding})

func box_body(parent: Node, node_name: String, size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	own(body, parent)
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = pos
	own(shape, body)

func flicker_light(parent: Node, node_name: String, pos: Vector3, color: Color, energy: float, light_range: float, strength := 0.18, speed := 6.0, shadows := true) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.name = node_name
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.omni_attenuation = 1.3
	light.shadow_enabled = shadows
	light.set_script(load("res://script/light_flicker.gd"))
	light.set("strength", strength)
	light.set("speed", speed)
	return own(light, parent)

## Wall lantern (prop pack) with its flame light; yaw points the bracket away from the wall.
func wall_lantern(parent: Node, node_name: String, pos: Vector3, yaw_deg: float, energy := 1.2, light_range := 6.5, shadows := true) -> void:
	var lamp := add(parent, P + "Lantern_Wall.gltf", pos, yaw_deg, 1.0, node_name)
	var light := flicker_light(lamp, "Light", Vector3(0, 0.6, 0.95), Color(1.0, 0.62, 0.32), energy, light_range, 0.18, 6.0, shadows)
	light.set("housing_casts_shadow", false)

## A candle standing on a table, with a small warm light (no shadows: cheap and soft).
func candle(parent: Node, path: String, pos: Vector3, energy := 0.8, light_range := 3.5) -> void:
	add(parent, path, pos, randf() * 360.0)
	flicker_light(parent, "CandleLight", pos + Vector3(0, 0.3, 0), Color(1.0, 0.7, 0.4), energy, light_range, 0.25, 7.0, false)

func sound(parent: Node, node_name: String, stream_path: String, pos: Vector3, volume: float, max_distance: float) -> void:
	var s := AudioStreamPlayer3D.new()
	s.name = node_name
	s.position = pos
	s.stream = load(stream_path)
	s.volume_db = volume
	s.unit_size = 2.0
	s.max_distance = max_distance
	s.autoplay = true
	s.bus = &"SFX"
	own(s, parent)

func flames(parent: Node, pos: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "Flames"
	particles.position = pos
	particles.amount = 36
	particles.lifetime = 0.9
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.22
	process.direction = Vector3.UP
	process.spread = 12.0
	process.initial_velocity_min = 0.4
	process.initial_velocity_max = 0.9
	process.gravity = Vector3(0, 0.6, 0)
	process.scale_min = 0.5
	process.scale_max = 1.0
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0, 0.6))
	scale_curve.add_point(Vector2(0.3, 1.0))
	scale_curve.add_point(Vector2(1, 0.1))
	var scale_tex := CurveTexture.new()
	scale_tex.curve = scale_curve
	process.scale_curve = scale_tex
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.7, 0.28, 0.75))
	ramp.set_color(1, Color(0.8, 0.15, 0.02, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	process.color_ramp = ramp_tex
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.28, 0.38)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.vertex_color_use_as_albedo = true
	var dot := GradientTexture2D.new()
	var dot_gradient := Gradient.new()
	dot_gradient.set_color(0, Color(1, 1, 1, 1))
	dot_gradient.set_color(1, Color(1, 1, 1, 0))
	dot.gradient = dot_gradient
	dot.fill = GradientTexture2D.FILL_RADIAL
	dot.fill_from = Vector2(0.5, 0.5)
	dot.fill_to = Vector2(1.0, 0.5)
	mat.albedo_texture = dot
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.5, 0.15)
	mat.emission_energy_multiplier = 0.9
	quad.material = mat
	particles.draw_pass_1 = quad
	own(particles, parent)

## Rocks with the glowing blue-iron overlay (the ore in the carts).
func blue_ore(parent: Node, group_name: String) -> Node3D:
	var g := Node3D.new()
	g.name = group_name
	g.set_script(load("res://script/overlay_applier.gd"))
	var vein_mat := ShaderMaterial.new()
	vein_mat.shader = load("res://shader/blue_iron_vein.gdshader")
	g.set("overlay", vein_mat)
	return own(g, parent)


func _initialize() -> void:
	seed(11)
	root3d = Node3D.new()
	root3d.name = "Camp"
	_cave()
	var camp := group(root3d, "CampProps")
	var wood := skinned(camp, "Wood", "res://material/kenney_wood.tres")
	var cloth := skinned(camp, "Cloth", "res://material/kenney_cloth.tres")
	_sleeping(camp, cloth)
	_kitchen(camp, wood)
	_storage(camp)
	_command(camp)
	_supply(camp)
	_infirmary(camp, cloth)
	_scribe_corner(camp)
	_barricades()
	_west_segment()
	_east_segment()
	_markers()

	var packed := PackedScene.new()
	var err := packed.pack(root3d)
	if err == OK:
		err = ResourceSaver.save(packed, OUT)
		_strip_meshes()
	print("saved ", OUT, " err=", err)
	root3d.free()
	quit()

## Yaw (degrees) that turns an NPC standing at `from` to face `to` (yaw 0 = facing +Z).
func face(from: Vector3, to: Vector3) -> float:
	return rad_to_deg(atan2(to.x - from.x, to.z - from.z))

## A box of rock: visible mesh plus the same box as collision.
func slab(parent: Node, slab_name: String, size: Vector3, pos: Vector3, material: Material, collide := true) -> void:
	var mi := MeshInstance3D.new()
	mi.name = slab_name
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = material
	mi.position = pos
	own(mi, parent)
	if collide:
		box_body(parent, slab_name + "Body", size, pos)

## A cave wall piece. Its rock face looks -Z at yaw 0 (so: south wall 0, north 180, west -90, east 90).
func cave_wall(parent: Node, piece: String, pos: Vector3, yaw_deg: float, scale := WALL_SCALE) -> Node3D:
	return add(parent, M + "Wall/Wall_Cave/wall_caves_%s.tscn" % piece, pos, yaw_deg + randf_range(-2.0, 2.0), scale)

## A post of the pack (post_a is a plain 3.8 m square timber) scaled to `height`.
func post(parent: Node, pos: Vector3, height: float) -> Node3D:
	return add(parent, M + "Posts/post_a.tscn", pos, 0.0, height / 3.8)

## A wall lantern hung on a timber post (the cave walls are too lumpy to hang it on).
func post_lantern(parent: Node, node_name: String, pos: Vector3, yaw_deg: float, energy := 1.2, light_range := 6.5, shadows := true) -> void:
	var dir := Basis(Vector3.UP, deg_to_rad(yaw_deg)) * Vector3.BACK
	post(parent, Vector3(pos.x, 0.0, pos.z) - dir * 0.12, 2.3)
	wall_lantern(parent, node_name, pos, yaw_deg, energy, light_range, shadows)

#region The cave

## task_08: the camp is a natural cave x 0..32, z -9..7, about 6 m high, in place of the old boarded
## hall. The doors stay where the hall had them: the west tunnel (x 0, z 1..5), the corridor to the
## old entrance (x 0, z -5..-2.7) and the east corridor (x 32, z 1..5); their plank frames live in
## mine.tscn. Wall pieces are only ever pushed outwards at random, so the usable floor is about
## x 0.9..31.1, z -8.1..6.1. Wood is only used for structures: the leader's pen, the scaffold over the
## storage, door frames, lantern posts.
func _cave() -> void:
	var cave := group(root3d, "Cave")
	var rock: Material = load("res://material/cave_rock.tres")
	var ground := group(cave, "Floor")
	for ix in 8:
		for iz in 4:
			add(ground, M + "Ground/Ground_Mines/ground_mines_a.tscn", Vector3(2.0 + ix * 4.0, 0.0, -7.0 + iz * 4.0), 90.0 * (randi() % 4))
	var walls := group(cave, "Walls")
	for i in 6:
		cave_wall(walls, "ab"[i % 2], Vector3(3.0 + i * 6.0, WALL_Y, 7.0 + randf() * 0.3), 0.0)
		cave_wall(walls, "ba"[i % 2], Vector3(3.0 + i * 5.7, WALL_Y, -9.0 - randf() * 0.3), 180.0)
	# west: north of the old-entrance door, between the two doors, south of the west tunnel
	cave_wall(walls, "a", Vector3(-randf() * 0.2, WALL_Y, -8.1), -90.0)
	cave_wall(walls, "c", Vector3(-randf() * 0.2, WALL_Y, -1.02), -90.0, 1.28)
	cave_wall(walls, "c", Vector3(-randf() * 0.2, WALL_Y, 6.95), -90.0)
	# east: north of the east door, south of it
	cave_wall(walls, "b", Vector3(32.0 + randf() * 0.3, WALL_Y, -8.6), 90.0)
	cave_wall(walls, "a", Vector3(32.0 + randf() * 0.3, WALL_Y, -2.6), 90.0)
	cave_wall(walls, "c", Vector3(32.0 + randf() * 0.3, WALL_Y, 7.1), 90.0)
	# rock behind the pieces (no gaps to the void), over the doors and above the vault
	var backing := group(cave, "Backing")
	slab(backing, "South", Vector3(34.0, 7.6, 0.6), Vector3(16.0, 3.3, 7.8), rock)
	slab(backing, "North", Vector3(34.0, 7.6, 0.6), Vector3(16.0, 3.3, -9.8), rock)
	slab(backing, "EastNorth", Vector3(0.6, 7.6, 10.7), Vector3(32.8, 3.3, -4.55), rock)
	slab(backing, "EastSouth", Vector3(0.6, 7.6, 2.6), Vector3(32.8, 3.3, 6.6), rock)
	slab(backing, "EastDoorTop", Vector3(0.8, 2.6, 4.8), Vector3(32.2, 5.4, 3.0), rock)
	slab(backing, "WestTop", Vector3(0.8, 2.8, 16.4), Vector3(0.1, 5.5, -1.0), rock)
	slab(backing, "Vault", Vector3(34.0, 0.5, 18.4), Vector3(16.0, 7.0, -1.0), rock, false)
	# the vault: wall pieces laid face down, so the ceiling is as lumpy as the walls
	var vault := group(cave, "Vault")
	for ix in 6:
		for iz in 3:
			var n := add(vault, M + "Wall/Wall_Cave/wall_caves_%s.tscn" % "ab"[(ix + iz) % 2], Vector3(3.4 + ix * 6.0, VAULT_Y, -3.4 + iz * 6.1))
			var b := Basis(Vector3.UP, deg_to_rad(randf_range(-4.0, 4.0))) * Basis(Vector3.RIGHT, -PI / 2)
			n.basis = b.scaled(Vector3.ONE * WALL_SCALE)
	# a rock pillar from floor to vault between the sleepers and the infirmary, rock in the corners
	var rocks := group(cave, "Rocks")
	add(rocks, M + "Rocks/Cave_Rocks/cave_pillar_a.tscn", Vector3(7.0, 0.0, -3.0), 35.0, 1.3, "Pillar")
	for c in [Vector3(0.9, 2.4, -8.4), Vector3(31.2, 2.4, -8.4), Vector3(1.0, 2.4, 6.4)]:
		add(rocks, M + "Rocks/Cave_Rocks/cave_pillar_c.tscn", c, randf() * 360.0, 0.9)
	# ledges high on the walls, over everyone's heads: [piece, position, yaw]; yaw 0 faces +Z
	for r in [["a", Vector3(3.0, 4.3, -8.3), 0.0], ["f", Vector3(12.5, 4.5, -8.3), 0.0], ["g", Vector3(29.5, 4.0, -8.2), 0.0],
			["e", Vector3(13.5, 4.4, 6.3), 180.0], ["b", Vector3(22.0, 4.6, 6.3), 180.0], ["d", Vector3(5.5, 4.2, 6.3), 180.0],
			["c", Vector3(31.2, 4.2, -2.0), -90.0], ["g", Vector3(0.7, 4.4, -1.0), 90.0]]:
		add(rocks, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % r[0], r[1], r[2], 1.2)
	for r in [["b", Vector3(15.2, 0.1, 5.9), 0.6]]:
		add(rocks, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[0], r[1], randf() * 360.0, r[2])
	# door frames on the cave side: [post a, post b, beam centre, beam length]
	var frames := group(cave, "DoorFrames")
	for d in [[Vector3(0.6, 0, 0.95), Vector3(0.6, 0, 5.05), Vector3(0.6, 3.9, 3.0), 4.0],
			[Vector3(0.6, 0, -5.05), Vector3(0.6, 0, -2.7), Vector3(0.6, 3.9, -3.875), 2.55],
			[Vector3(31.4, 0, 0.95), Vector3(31.4, 0, 5.05), Vector3(31.4, 3.9, 3.0), 4.0]]:
		post(frames, d[0], 3.8)
		post(frames, d[1], 3.8)
		add(frames, M + "Posts/beam_a.tscn", d[2], 90.0).scale = Vector3(d[3] / 4.0, 1.0, 1.0)

#endregion

#region West: sleeping, kitchen by the fire in the middle, storage, powder

func _sleeping(camp: Node3D, cloth: Node3D) -> void:
	var bed := add(cloth, K + "bedroll.glb", Vector3(7.2, 0.0, 5.3), 90.0, 3.2, "Bedroll")
	interactable(bed, "BedUse", {"display_name": "Posłanie", "prompt_text": "Połóż się spać", "action": 2})
	add(cloth, K + "bedroll.glb", Vector3(4.6, 0.0, 5.3), 90.0, 3.2, "BolkoBedroll")
	add(cloth, K + "bedroll.glb", Vector3(8.6, 0.0, -7.4), 90.0, 3.2, "MiroslawBedroll")
	add(cloth, K + "tent-canvas.glb", Vector3(11.4, 0.0, 5.2), 180.0, 4.5, "Tent")
	box_body(camp, "TentBlock", Vector3(2.3, 2.0, 2.3), Vector3(11.4, 1.0, 5.2))
	add(camp, P + "Bag.gltf", Vector3(5.9, 0.0, 5.75), 60.0)
	add(camp, P + "Bag.gltf", Vector3(3.3, 0.0, 5.65), -20.0)
	var water := add(camp, P + "Barrel.gltf", Vector3(9.0, 0.0, 5.65), 0.0, 1.0, "WaterBarrel")
	look(water, "Beczka z wodą", "Woda spuszczona z góry w bukłakach. Pachnie żelazem. Tekla pilnuje, żeby nikt się w niej nie mył.", true)
	# the west half is far from the fire: a lantern on a post between the sleepers and the pillar
	post_lantern(camp, "SleepLantern", Vector3(6.5, 1.45, -0.5), 0.0, 1.1, 7.5)

func _kitchen(camp: Node3D, wood: Node3D) -> void:
	var fire := group(camp, "Campfire")
	fire.position = FIRE
	var stones := skinned(fire, "Stones", "res://material/cave_rock.tres")
	add(stones, K + "campfire-pit.glb", Vector3.ZERO, 0.0, 4.0, "Pit")
	flames(fire, Vector3(0, 0.2, 0))
	# The light sits above the kettle so the pot doesn't throw its shadow over the whole camp.
	flicker_light(fire, "FireLight", Vector3(0.0, 1.35, -0.45), Color(1.0, 0.55, 0.22), 3.2, 11.0, 0.3, 9.0)
	sound(fire, "FireCrackle", "res://assets/sounds/generated/lantern_crackle.wav", Vector3(0, 0.3, 0), -4.0, 12.0)
	var stand := skinned(fire, "Stand", "res://material/kenney_wood.tres")
	add(stand, K + "campfire-stand.glb", Vector3.ZERO, 0.0, 4.0, "Spit")
	var kettle := add(fire, P + "Cauldron.gltf", Vector3(0.0, 0.46, 0.0), 20.0, 0.46, "Kettle")
	interactable(kettle, "FireLook", {"display_name": "Ognisko z kociołkiem", "description": "Tekla gotuje tu dwa razy dziennie: rano kaszę, wieczorem to samo z tym, co zostało. Pali się połamanymi stemplami. Mirosław siada tak, żeby mieć do ognia jak najdalej.", "solid": true, "padding": 0.1})
	box_body(fire, "PitBlock", Vector3(1.2, 0.5, 1.2), Vector3(0, 0.25, 0))
	# Evening group scene at the fire (dialogue/ognisko.dialogue). The StoryDirector enables
	# it from 20:00, once a day; see apply_world_state().
	interactable(fire, "SeatUse", {
		"display_name": "Usiądź przy ogniu",
		"action": 1, "dialogue": load("res://dialogue/ognisko.dialogue"), "dialogue_cue": "start",
		"time_cost_hours": 1.0, "time_reason": "Wieczór przy ogniu",
		"keep_parent_visible": true, "padding": 0.45})
	# logs around the fire (it stands in the open now, so there are seats on every side)
	add(wood, K + "tree-log-small.glb", FIRE + Vector3(1.75, 0.0, 0.55), -17.0, 1.6, "MiroslawLog")
	add(wood, K + "tree-log-small.glb", FIRE + Vector3(-0.2, 0.0, 1.25), 98.0, 1.5, "FireLog")
	add(wood, K + "tree-log-small.glb", FIRE + Vector3(0.3, 0.0, -1.45), 95.0, 1.5, "FireLogNorth")
	add(wood, K + "tree-log-small.glb", FIRE + Vector3(1.5, 0.0, -1.05), 40.0, 1.4, "FireLogEast")
	# the cook's corner
	add(camp, P + "Barrel_Apples.gltf", FIRE + Vector3(-1.75, 0.0, 1.15), 30.0)
	add(camp, P + "FarmCrate_Carrot.gltf", FIRE + Vector3(-1.55, 0.0, -1.2), -10.0)
	add(camp, P + "Bucket_Wooden_1.gltf", FIRE + Vector3(-2.05, 0.0, -0.6), 0.0)
	add(camp, P + "Pot_1.gltf", FIRE + Vector3(-1.1, 0.0, 0.75), 30.0)
	add(camp, P + "Pot_1_Lid.gltf", FIRE + Vector3(-0.85, 0.0, 1.05), 0.0)
	# common table with benches (breakfast before 8, supper 18–20)
	var table := add(camp, P + "Table_Large.gltf", TABLE, 0.0, 1.0, "CommonTable")
	look(table, "Wspólny stół", "Tu się je, gra w kości i kłóci o to, kto dziś zjeżdża pierwszy. Deski lepią się od kaszy.", true)
	add(camp, P + "Bench.gltf", TABLE + Vector3(0.0, 0.0, -0.83), 0.0, 0.9, "BenchNorth")
	add(camp, P + "Bench.gltf", TABLE + Vector3(0.0, 0.0, 0.85), 0.0, 0.9, "BenchSouth")
	add(camp, P + "Stool.gltf", TABLE + Vector3(1.75, 0.0, 0.0), 0.0, 1.0, "HeadStool")
	for p in [Vector3(-0.8, TABLE_TOP, -0.3), Vector3(0.6, TABLE_TOP, -0.27), Vector3(-0.7, TABLE_TOP, 0.3), Vector3(1.1, TABLE_TOP, 0.0)]:
		add(camp, P + "Table_Plate.gltf", TABLE + p, randf() * 360.0)
	for p in [Vector3(-0.45, TABLE_TOP, -0.43), Vector3(0.9, TABLE_TOP, -0.35), Vector3(-1.1, TABLE_TOP, 0.15)]:
		add(camp, P + "Mug.gltf", TABLE + p, randf() * 360.0)
	add(camp, P + "Table_Spoon.gltf", TABLE + Vector3(-0.75, TABLE_TOP + 0.01, -0.3), 30.0)
	add(camp, P + "Pot_1.gltf", TABLE + Vector3(0.1, TABLE_TOP, 0.05), 0.0)
	candle(camp, P + "CandleStick.gltf", TABLE + Vector3(0.75, TABLE_TOP, 0.25), 0.7, 3.2)

## Storage under a timber scaffold on the south wall, the one old track from the east door ending
## at it with the ore carts, and the powder store in the far north corner, away from the fire.
func _storage(camp: Node3D) -> void:
	var store := group(camp, "Storage")
	var scaffold := group(store, "Scaffold")
	for p in [Vector3(16.3, 0.0, 3.3), Vector3(20.1, 0.0, 3.3), Vector3(16.3, 0.0, 5.9), Vector3(20.1, 0.0, 5.9)]:
		post(scaffold, p, 2.66)
	add(scaffold, M + "Wood_Platform/wood_platform_a.tscn", Vector3(18.2, 2.92, 4.7), 0.0, 1.0, "Platform")
	add(scaffold, P + "Crate_Wooden.gltf", Vector3(17.2, 3.18, 5.5), 15.0, 0.8)
	add(scaffold, P + "Bag.gltf", Vector3(19.2, 3.18, 5.2), 80.0)
	add(scaffold, P + "Rope_3.gltf", Vector3(18.3, 3.18, 4.2), 10.0)
	for c in [[17.1, 5.3, 5.0], [18.0, 5.35, -8.0]]:
		add(store, P + "Crate_Wooden.gltf", Vector3(c[0], 0.0, c[1]), c[2])
	add(store, P + "Crate_Wooden.gltf", Vector3(17.55, 0.88, 5.35), 22.0, 0.85)
	var boxes := skinned(store, "Boxes", "res://material/kenney_wood.tres")
	add(boxes, K + "box.glb", Vector3(19.3, 0.0, 5.3), 12.0, 2.4)
	add(boxes, K + "box.glb", Vector3(19.25, 0.6, 5.25), 40.0, 2.0)
	add(store, P + "Barrel.gltf", Vector3(16.8, 0.0, 4.3), 0.0)
	add(store, P + "Bag.gltf", Vector3(17.7, 0.0, 4.2), 110.0)
	# tools on a workbench against the rock, next to the scaffold
	var bench := add(store, P + "Workbench.gltf", Vector3(21.8, 0.0, 5.45), 180.0, 1.0, "ToolBench")
	look(bench, "Narzędzia", "Kilofy, łopaty, kliny, zapasowe trzonki. Bolko ostrzy je co wieczór, a Wszebor co rano mówi, że to miękkie jaksarskie żelazo i szkoda osełki.", true)
	var pick := add(store, P + "Pickaxe_Bronze.gltf", Vector3(21.45, 0.9, 5.45), 0.0, 1.0)
	pick.basis = Basis(Vector3.UP, 0.4 + PI / 2) * Basis(Vector3.RIGHT, PI / 2)
	var axe := add(store, P + "Axe_Bronze.gltf", Vector3(22.35, 0.9, 5.4), 0.0, 1.0)
	axe.basis = Basis(Vector3.UP, 1.2 + PI / 2) * Basis(Vector3.RIGHT, PI / 2)
	add(store, P + "Whetstone.gltf", Vector3(23.2, 0.0, 5.6), 90.0, 0.8)
	# the old track: from the east door to the storage, with two carts at its end
	var rails := group(store, "Rails")
	for x in [20.5, 24.5, 28.5, 32.5]:
		add(rails, M + "Mine_Rails/rail_a.tscn", Vector3(x, 0.02, RAIL_Z), 0.0)
	add(rails, M + "Mine_Rails/rail_end.tscn", Vector3(18.4, 0.02, RAIL_Z), 0.0)
	add(rails, M + "Mine_Carts/mine_cart_bb_grp.tscn", Vector3(20.3, 0.02, RAIL_Z), 0.0, 1.0, "OreCart")
	add(rails, M + "Mine_Carts/mine_cart_ab_grp.tscn", Vector3(22.5, 0.02, RAIL_Z), 0.0, 1.0, "EmptyCart")
	# old ore left in the cart at the end of the track
	var ore := blue_ore(store, "CartOre")
	for r in [[20.05, 0.95, 2.5, "b", 0.32], [20.4, 0.93, 2.7, "a", 0.28], [20.6, 0.98, 2.5, "c", 0.25]]:
		add(ore, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[3], Vector3(r[0], r[1], r[2]), randf() * 360.0, r[4])
	interactable(ore.get_child(0), "Look", {"display_name": "Wózek z urobkiem", "description": "Urobek po starej ekipie. Stał tu czterdzieści lat i dalej świeci. Bolko przebiera go kamień po kamieniu i odkłada najlepsze kawałki na bok.", "solid": false, "padding": 0.2})
	# a dim lantern on the scaffold over the carts
	wall_lantern(store, "CartsLantern", Vector3(20.1, 1.45, 3.2), 180.0, 0.8, 6.0, false)
	var powder := group(camp, "Powder")
	for b in [[19.4, -7.5], [20.2, -7.55], [19.8, -6.85]]:
		add(powder, P + "Barrel.gltf", Vector3(b[0], 0.0, b[1]), randf() * 360.0)
	var fuse_chest := add(powder, P + "Chest_Wood.gltf", Vector3(18.5, 0.0, -7.55), 0.0, 0.8, "FuseChest")
	look(fuse_chest, "Skrzynia z lontami", "Zamknięta na kłódkę. Klucz Mirosław nosi na szyi.", true)
	look(powder.get_child(0), "Beczki z prochem", "Proch Mirosława. Trzyma go jak najdalej od ogniska i od ludzi. Na wieku jednej beczki ktoś wydrapał nożem: NIE PALIĆ.", true)

#endregion

#region East: the leader's pen, supply

## Racibor's pen: a roofless palisade about 2 m high against the north wall, with a gate facing
## the camp (the intro calls it "zagroda Racibora", a palisade without a roof). The map table,
## his bed and chest inside.
func _command(camp: Node3D) -> void:
	var pen := group(camp, "Pen")
	var panel := M + "Panel_Wood/panel_wood_a.tscn"
	for x in [PEN_WEST + 1.1, PEN_EAST - 1.1]:
		add(pen, panel, Vector3(x, 0.0, PEN_SOUTH), 0.0, 0.55)
	for z in [PEN_SOUTH - 1.1, PEN_SOUTH - 3.3, PEN_SOUTH - 5.5]:
		add(pen, panel, Vector3(PEN_WEST, 0.0, z), 90.0, 0.55)
		add(pen, panel, Vector3(PEN_EAST, 0.0, z), 90.0, 0.55)
	for p in [Vector3(PEN_WEST, 0, PEN_SOUTH), Vector3(PEN_EAST, 0, PEN_SOUTH), Vector3(PEN_WEST, 0, PEN_SOUTH - 2.2),
			Vector3(PEN_WEST, 0, PEN_SOUTH - 4.4), Vector3(PEN_EAST, 0, PEN_SOUTH - 2.2), Vector3(PEN_EAST, 0, PEN_SOUTH - 4.4)]:
		post(pen, p, 2.35)
	# the gate: two taller posts and a beam across
	post(pen, Vector3(MAP.x - 1.1, 0, PEN_SOUTH), 3.04)
	post(pen, Vector3(MAP.x + 1.1, 0, PEN_SOUTH), 3.04)
	add(pen, M + "Posts/beam_a.tscn", Vector3(MAP.x, 2.94, PEN_SOUTH), 0.0, 1.0).scale = Vector3(0.55, 1.0, 1.0)
	# Racibor stands behind the map table, facing the gate
	var table := add(camp, P + "Table_Large.gltf", MAP, 0.0, 1.0, "MapTable")
	interactable(table, "MapTableUse", {"display_name": "Stół z mapą", "prompt_text": "Zaplanuj wyprawę", "action": 2})
	add(camp, P + "Scroll_1.gltf", MAP + Vector3(-0.2, TABLE_TOP, 0.05), 80.0, 1.6)
	add(camp, P + "Scroll_2.gltf", MAP + Vector3(0.7, TABLE_TOP, -0.1), 10.0, 1.2)
	add(camp, P + "Book_Stack_1.gltf", MAP + Vector3(1.15, TABLE_TOP, -0.3), 20.0)
	add(camp, P + "Coin_Pile.gltf", MAP + Vector3(-0.9, TABLE_TOP, 0.3), 0.0)
	candle(camp, P + "CandleStick_Triple.gltf", MAP + Vector3(-1.05, TABLE_TOP, -0.25), 1.4, 5.0)
	add(camp, P + "Chair_1.gltf", MAP + Vector3(0.95, 0.0, -1.45), 0.0)
	var ledger := add(camp, P + "BookStand.gltf", Vector3(27.5, 0.0, -4.3), -60.0, 1.0, "Ledger")
	look(ledger, "Księga zarządcy", "Równe rubryki, pisane drobnym, starannym pismem Hagiwary: ludzie, zapasy, urobek, żyły. Przy urobku na razie same zera. Na ostatniej stronie, ręką Racibora: „Kniaź czeka”.", true)
	# the banner hangs from a crossbar behind him
	post(pen, Vector3(MAP.x - 0.8, 0, -7.5), 3.6)
	post(pen, Vector3(MAP.x + 0.8, 0, -7.5), 3.6)
	add(pen, M + "Posts/beam_a.tscn", Vector3(MAP.x, 3.5, -7.5), 0.0, 1.0).scale = Vector3(0.45, 1.0, 1.0)
	var banner := add(camp, P + "Banner_1.gltf", Vector3(MAP.x - 0.8, 2.66, -7.4), 0.0, 1.0, "KniazBanner")
	look(banner, "Chorągiew Kniazia", "Herb Jacyntów: srebrny gród na czerwonym polu. Racibor powiesił ją pierwszego dnia, zanim ktokolwiek rozpakował swoje rzeczy.")
	var bed := add(camp, P + "Bed_Twin1.gltf", Vector3(22.9, 0.0, -6.75), 0.0, 1.0, "LeaderBed")
	look(bed, "Łóżko zarządcy", "Prawdziwe łóżko, zniesione z góry w częściach. Jedyne w obozie.", true)
	add(camp, P + "Chest_Wood.gltf", Vector3(27.6, 0.0, -7.55), 0.0, 0.9, "PayChest")
	var seat := skinned(camp, "GuardSeat", "res://material/kenney_wood.tres")
	add(seat, K + "box.glb", TEKLA_SEAT, 25.0, 2.1)
	wall_lantern(pen, "CommandLantern", Vector3(PEN_WEST + 0.06, 1.45, -5.2), 90.0, 1.6, 8.0)
	wall_lantern(pen, "CommandLantern2", Vector3(PEN_EAST - 0.06, 1.45, -6.2), -90.0, 1.3, 7.0, false)

func _supply(camp: Node3D) -> void:
	# no look on the stall: Tekla stands right behind it and has to stay easy to talk to
	add(camp, P + "Stall_Empty.gltf", STALL, 180.0, 1.0, "SupplyStall")
	box_body(camp, "StallBlock", Vector3(1.84, 1.0, 0.93), STALL + Vector3(0, 0.5, 0))
	add(camp, P + "Rope_1.gltf", STALL + Vector3(-0.5, 0.93, -0.05), 30.0)
	add(camp, P + "SmallBottles_1.gltf", STALL + Vector3(0.4, 0.93, -0.15), 0.0)
	add(camp, P + "Pouch_Large.gltf", STALL + Vector3(0.75, 0.93, 0.05), 40.0)
	candle(camp, P + "CandleStick.gltf", STALL + Vector3(0.05, 0.93, 0.1), 0.7, 3.5)
	add(camp, P + "Rope_3.gltf", STALL + Vector3(-1.9, 0.0, 0.6), 10.0)
	add(camp, P + "Rope_2.gltf", STALL + Vector3(-2.0, 0.1, 0.55), 70.0)
	add(camp, P + "Barrel.gltf", STALL + Vector3(1.95, 0.0, 0.6), 0.0)
	add(camp, P + "Barrel.gltf", STALL + Vector3(2.7, 0.0, 0.65), 40.0)
	add(camp, P + "Crate_Wooden.gltf", STALL + Vector3(3.5, 0.0, 0.5), -12.0)
	add(camp, P + "FarmCrate_Empty.gltf", STALL + Vector3(3.45, 0.93, 0.5), 5.0)
	add(camp, P + "Bag.gltf", STALL + Vector3(-1.55, 0.0, 0.0), 200.0)
	post_lantern(camp, "SupplyLantern", Vector3(STALL.x - 2.4, 1.45, STALL.z + 0.75), 180.0, 1.0, 6.5)

#endregion

#region task_05: the infirmary and the scribe's corner

## Brat Anzelm's corner in the north-west: a bedroll for the sick, a crate with his herbs and
## bandages, a candle. Nasir lies here when the fever takes him.
func _infirmary(camp: Node3D, cloth: Node3D) -> void:
	var room := group(camp, "Infirmary")
	add(cloth, K + "bedroll.glb", Vector3(3.6, 0.0, -7.3), 90.0, 3.2, "SickBedroll")
	var chest := add(room, P + "Crate_Wooden.gltf", Vector3(5.45, 0.0, -7.55), 10.0, 0.85, "HerbCrate")
	look(chest, "Skrzynka Anzelma", "Zioła w płóciennych woreczkach, każdy podpisany drobnym pismem. Bandaże wygotowane i zwinięte w równe rolki. Na wieku wyryty płomień, a przez płomień ktoś przeciągnął nożem krechę.", true)
	add(room, P + "SmallBottles_1.gltf", Vector3(5.45, 0.72, -7.55), 20.0)
	add(room, P + "Potion_2.gltf", Vector3(5.8, 0.72, -7.35), 0.0)
	add(room, P + "Bucket_Wooden_1.gltf", Vector3(6.2, 0.0, -6.9), 0.0)
	var seat := skinned(room, "SickSeat", "res://material/kenney_wood.tres")
	add(seat, K + "box.glb", SICK_SEAT, 10.0, 2.0)
	candle(room, P + "CandleStick.gltf", Vector3(5.2, 0.72, -7.75), 0.8, 4.0)

## Hagiwara's corner east of the pen: a stool, a crate for a table, tea and his book.
func _scribe_corner(camp: Node3D) -> void:
	var corner := group(camp, "ScribeCorner")
	add(corner, P + "Stool.gltf", SCRIBE_STOOL, 0.0)
	var desk := add(corner, P + "Crate_Wooden.gltf", SCRIBE_DESK, -8.0, 0.8, "TeaCrate")
	look(desk, "Kącik Hagiwary", "Skrzynia zamiast stołu. Na niej kubek z naparem, który Hagiwara nazywa herbatą, pędzelek, kamień do rozcierania tuszu i zeszyt z wierszami. Wiersze są krótkie. Każdy o ciemności.", true)
	add(corner, P + "Mug.gltf", SCRIBE_DESK + Vector3(-0.1, 0.7, 0.15), 0.0)
	add(corner, P + "Book_5.gltf", SCRIBE_DESK + Vector3(0.15, 0.7, -0.15), 60.0)
	candle(corner, P + "CandleStick.gltf", SCRIBE_DESK + Vector3(0.1, 0.7, 0.3), 0.7, 3.5)
	post_lantern(corner, "ScribeLantern", Vector3(30.75, 1.45, -4.8), -90.0, 0.7, 5.0, false)

#endregion

#region Barricades, segments, markers

func _barricades() -> void:
	var barricades := group(root3d, "Barricades")
	var signs := skinned(barricades, "Signs", "res://material/kenney_wood.tres")
	var east_panel := add(barricades, M + "Panel_Wood/panel_wood_a.tscn", Vector3(35.2, 0.0, 3.0), 90.0, 1.0, "EastBoards")
	interactable(east_panel, "EastBoardsLook", {"display_name": "Zabite deskami zejście", "description": "Chodnik zabity deskami. Ktoś napisał na nich kredą: „STARA SZTOLNIA”.\n\nNa wyprawę wyruszasz od stołu z mapą w obozie.", "solid": false})
	var lamp := add(barricades, P + "Lantern_Wall.gltf", Vector3(34.0, 1.35, 4.45), 180.0, 1.0, "EastLantern")
	flicker_light(lamp, "Light", Vector3(0, 0.6, 0.95), Color(1.0, 0.62, 0.32), 1.2, 6.0).set("housing_casts_shadow", false)
	box_body(barricades, "EastBlock", Vector3(0.4, 4.0, 4.2), Vector3(35.2, 2.0, 3.0))
	var east_sign := add(signs, K + "signpost-single.glb", Vector3(36.1, 0.0, 1.5), -90.0, 3.5, "EastSign")
	interactable(east_sign, "EastExitUse", {"display_name": "Drogowskaz", "prompt_text": "Dokąd dalej? (albo [M])", "action": 2})
	var west_panel := add(barricades, M + "Panel_Wood/panel_wood_a.tscn", Vector3(-1.8, 0.0, 3.0), 90.0, 1.0, "WestBoards")
	interactable(west_panel, "WestBoardsLook", {"display_name": "Zabity deskami chodnik", "description": "Zachodni chodnik zabity deskami. Zza nich słychać, jak co jakiś czas osypuje się żwir.\n\nNa wyprawę wyruszasz od stołu z mapą w obozie.", "solid": false})
	box_body(barricades, "WestBlock", Vector3(0.4, 4.0, 4.2), Vector3(-1.8, 2.0, 3.0))
	var west_sign := add(signs, K + "signpost-single.glb", Vector3(-2.7, 0.0, 1.5), 90.0, 3.5, "WestSign")
	interactable(west_sign, "WestExitUse", {"display_name": "Drogowskaz", "prompt_text": "Dokąd dalej? (albo [M])", "action": 2})

func _west_segment() -> void:
	var west := group(root3d, "WestSegment")
	var key_wood := skinned(west, "KeyWood", "res://material/kenney_wood.tres")
	var key_board := add(key_wood, K + "signpost-single.glb", Vector3(-14.5, Y_WEST_LOW, 1.45), 0.0, 3.0, "KeyBoard")
	interactable(key_board, "KeyBoardLook", {
		"display_name": "Deska z wyrytymi znakami",
		"description": "Deska przybita do stempla. Ktoś wyrył na niej alfabet w dwóch rzędach, dolny przesunięty o siedem liter. W rogu znak dziadka: dwie skrzyżowane kreski i kropka.\n\nPrzerysowujesz to do notesu.",
		"on_use_flag": "found_key", "on_use_note": &"klucz", "on_use_quest": &"slady", "on_use_quest_entry": "klucz",
	})
	flicker_light(west, "KeyGlow", Vector3(-14.5, Y_WEST_LOW + 2.2, 2.4), Color(0.55, 0.65, 1.0), 0.5, 3.5, 0.3, 0.8, false)
	var barrier := group(west, "FarBarrier")
	for r in [[-17.4, 1.5, "b", 1.2], [-17.6, 2.8, "c", 1.4], [-17.3, 4.3, "a", 1.1], [-17.9, 3.6, "d", 1.0]]:
		add(barrier, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[2], Vector3(r[0], Y_WEST_LOW + 0.3, r[1]), randf() * 360.0, r[3])
	var beam := add(barrier, M + "Posts/beam_a.tscn", Vector3(-17.0, Y_WEST_LOW + 0.9, 3.0), 90.0, 1.0, "BrokenBeam")
	beam.rotate_object_local(Vector3.FORWARD, deg_to_rad(18.0))
	interactable(beam, "BarrierLook", {"display_name": "Połamane stemple", "description": "Dalej chodnik stromo opada w ciemność: to upadowa z mapy dziadka. Stemple połamało jak zapałki. Bez liny nie ma tu czego szukać.\n\nZejście zaplanujesz przy stole z mapą.", "solid": false, "padding": 0.3})
	box_body(barrier, "BarrierBlock", Vector3(1.2, 3.0, 4.4), Vector3(-17.5, Y_WEST_LOW + 1.5, 3.0))
	# Racibor's vein in the west tunnel (task_05)
	var veins := blue_ore(west, "Vein")
	var vein_rock := add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_c.tscn", Vector3(-12.2, Y_WEST_LOW + 1.2, 4.75), 180.0, 1.2)
	flicker_light(west, "VeinGlow", Vector3(-12.2, Y_WEST_LOW + 1.6, 3.6), Color(0.35, 0.6, 1.0), 1.4, 5.5, 0.35, 0.7, false).set("mode", 1)
	interactable(west, "VeinMark_west_1", {
		"display_name": "Żyła błękitnego żelaza", "prompt_text": "Zaznacz żyłę na mapie", "time_cost_hours": 1.0, "time_reason": "Znaczenie żyły",
		"description": "Tuż za zawałem, na wysokości oczu. Dziadek musiał ją mijać setki razy, idąc swoją ulubioną drogą. Na jego mapie w tym miejscu jest kropka. Zaznaczasz ją po raz drugi.",
		"on_use_flag": "vein_west_1", "hidden_by_flag": "vein_west_1", "highlight_target": vein_rock, "solid": false, "padding": 0.1,
	})
	var stakes := skinned(west, "Stake_west_1", "res://material/kenney_wood.tres")
	var stake := add(stakes, K + "signpost-single.glb", Vector3(-12.0, Y_WEST_LOW, 4.0), 25.0, 1.6, "VeinStake")
	interactable(stake, "Look", {"display_name": "Twój palik", "description": "Tu zaznaczyłeś żyłę dla Racibora. Na palu wyciąłeś nożem kreskę.", "required_flag": "vein_west_1", "solid": false, "padding": 0.08})
	var debris := group(west, "BlastDebris")
	for r in [[-6.4, 1.4, "a", 0.8], [-7.2, 4.6, "c", 0.9], [-8.3, 1.6, "b", 0.7], [-5.8, 4.4, "d", 0.6], [-9.2, 4.5, "a", 0.6]]:
		add(debris, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[2], Vector3(r[0], lerpf(0.0, Y_WEST_LOW, clampf((-r[0] - 5.0) / 4.0, 0.0, 1.0)) + 0.1, r[1]), randf() * 360.0, r[3])

func _east_segment() -> void:
	var east := group(root3d, "EastSegment")
	var chest := add(east, P + "Chest_Wood.gltf", Vector3(70.4, Y_CHAMBER, 7.4), 90.0, 0.6, "FuseBox")
	interactable(chest, "FuseBoxPickup", {
		"display_name": "Skrzynka z lontami",
		"description": "Skrzynka po starej ekipie. W środku, w natłuszczonym płótnie, leżą lonty. Suche. Ktoś się postarał, żeby przetrwały.\n\nZabierasz je.",
		"on_use_item": "lonty", "on_use_flag": "took_fuses", "on_use_quest": &"lonty", "on_use_quest_entry": "znalezione",
		"quest_only_if_active": true, "remove_after_use": true,
	})

## Spawn, travel and NPC places (yaw 0 = facing +Z for NPCs, -Z for the player). NPCs working at
## something face it (face()), so nobody stands turned to the rock by accident.
func _markers() -> void:
	var markers := group(root3d, "Markers")
	marker(markers, "SpawnBed", Vector3(7.2, 0.0, 4.35), -90.0)
	marker(markers, "CampReturn", Vector3(29.3, 0.0, 3.9), 90.0)
	marker(markers, "EastEntry", Vector3(37.2, 0.0, 3.0), -90.0)
	marker(markers, "WestEntry", Vector3(-3.4, 0.0, 3.0), 90.0)
	var ore_cart := Vector3(20.3, 0.0, RAIL_Z)
	var map_racibor := MAP + Vector3(0.0, 0.0, -1.05)
	# Mirosław: fire (morning, evening), powder store (day), dark corner (when he breaks)
	npc_marker(markers, "MiroslawFire", FIRE + Vector3(1.6, 0.0, 0.5), FIRE)
	npc_marker(markers, "MiroslawPowder", Vector3(19.8, 0.0, -6.0), Vector3(19.8, 0.0, -7.3))
	marker(markers, "MiroslawCorner", Vector3(10.6, 0.0, -7.6), 20.0)
	# Bolko: common table, ore cart, his bedroll, by the player's bed, turned away (to the pillar)
	marker(markers, "BolkoEat", TABLE + Vector3(-0.7, 0.0, -0.83), 0.0)
	npc_marker(markers, "BolkoStorage", ore_cart + Vector3(0.0, 0.0, -1.05), ore_cart)
	marker(markers, "BolkoEvening", Vector3(4.6, 0.0, 4.2), 60.0)
	npc_marker(markers, "BolkoBed", Vector3(8.5, 0.0, 3.6), Vector3(7.2, 0.0, 4.35))
	marker(markers, "BolkoAway", Vector3(4.9, 0.0, -3.0), 90.0)
	# Racibor: head of the common table, behind the map table in his pen
	marker(markers, "RaciborEat", TABLE + Vector3(1.75, 0.0, 0.0), -90.0)
	marker(markers, "RaciborTable", map_racibor, 0.0)
	# Tekla: kettle, stall, on a crate in the pen when under watch
	marker(markers, "TeklaCook", FIRE + Vector3(-1.25, 0.0, -0.35), 70.0)
	marker(markers, "TeklaCounter", STALL + Vector3(0.0, 0.0, 0.78), 180.0)
	npc_marker(markers, "TeklaGuarded", TEKLA_SEAT, MAP)
	# Dobrawa: with Racibor, at the old carts, alone by the dark doors in the west
	npc_marker(markers, "DobrawaLeader", Vector3(26.6, 0.0, -3.5), map_racibor)
	npc_marker(markers, "DobrawaCarts", Vector3(22.5, 0.0, RAIL_Z + 0.95), Vector3(22.5, 0.0, RAIL_Z))
	marker(markers, "DobrawaApart", Vector3(1.6, 0.0, -0.9), -90.0)
	# task_05. Wszebor: breakfast, the fire in the evening (by day he hews in the old working)
	marker(markers, "WszeborEat", TABLE + Vector3(0.6, 0.0, 0.85), 180.0)
	npc_marker(markers, "WszeborFire", FIRE + Vector3(-0.2, 0.0, 1.15), FIRE)
	# Nasir: breakfast and supper, the water barrel by day, by the sleepers at night, sick
	marker(markers, "NasirEat", TABLE + Vector3(-0.6, 0.0, 0.85), 180.0)
	npc_marker(markers, "NasirWater", Vector3(9.0, 0.0, 4.75), Vector3(9.0, 0.0, 5.65))
	npc_marker(markers, "NasirEvening", Vector3(5.8, 0.0, 2.4), SABINA_EVENING)
	npc_marker(markers, "NasirSick", SICK_SEAT, Vector3(3.6, 0.0, -7.3))
	# Hagiwara: breakfast and supper, the ledger by day, tea in his corner at night
	marker(markers, "HagiwaraEat", TABLE + Vector3(0.6, 0.0, -0.83), 0.0)
	npc_marker(markers, "HagiwaraLedger", Vector3(27.85, 0.0, -3.4), Vector3(27.5, 0.0, -4.3))
	npc_marker(markers, "HagiwaraTea", SCRIBE_STOOL, SCRIBE_DESK)
	# Sobek: on guard by the east door, dice at the common table at supper
	marker(markers, "SobekGuard", Vector3(30.4, 0.0, -0.2), -90.0)
	marker(markers, "SobekDice", TABLE + Vector3(0.6, 0.0, 0.85), 180.0)
	# Anzelm: morning prayer facing the rock, the infirmary
	marker(markers, "AnzelmPray", Vector3(1.8, 0.0, -6.2), -90.0)
	npc_marker(markers, "AnzelmInfirmary", Vector3(4.6, 0.0, -6.2), Vector3(3.6, 0.0, -7.3))
	# Sabina (from day 3): apart by the east wall, at the ore cart, with the sick, in the evening
	marker(markers, "SabinaApart", Vector3(30.2, 0.0, -3.6), -90.0)
	npc_marker(markers, "SabinaCart", Vector3(19.1, 0.0, 1.8), ore_cart)
	npc_marker(markers, "SabinaSick", Vector3(4.6, 0.0, -4.9), SICK_SEAT)
	npc_marker(markers, "SabinaEvening", SABINA_EVENING, Vector3(1.6, 0.0, -0.9))
	# People met in the east corridor and the west tunnel (FieldSchedule), facing the way in
	for i in 4:
		marker(markers, "EastSpot%d" % (i + 1), Vector3(40.6 + i * 0.9, 0.0, 2.1 if i % 2 == 0 else 3.9), -90.0)
		var x := -6.6 - i * 0.8
		marker(markers, "WestSpot%d" % (i + 1), Vector3(x, lerpf(0.0, Y_WEST_LOW, clampf((-x - 5.0) / 4.0, 0.0, 1.0)), 2.1 if i % 2 == 0 else 3.9), 90.0)

## A marker for an NPC standing at `pos` and facing `target`.
func npc_marker(parent: Node, marker_name: String, pos: Vector3, target: Vector3) -> void:
	marker(parent, marker_name, pos, face(pos, target))

#endregion

## Keep pack meshes referenced from their own scenes instead of copied into this one.
func _strip_meshes() -> void:
	var path := ProjectSettings.globalize_path(OUT)
	var out := PackedStringArray()
	var skipping := false
	var in_instance := false
	for line in FileAccess.get_file_as_string(path).split("\n"):
		if line.begins_with("["):
			skipping = line.begins_with("[sub_resource type=\"ArrayMesh\"")
			in_instance = line.begins_with("[node") and line.contains("instance=")
		if skipping:
			continue
		if in_instance and line.begins_with("mesh = SubResource("):
			continue
		out.append(line)
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("\n".join(out))
