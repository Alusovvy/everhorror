extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_mine_deep.gd
## WARNING: overwrites scene/levels/mine_deep.tscn. Edit this generator, not the scene, or stop using it once the scene is hand-edited.
## Generates res://scene/levels/mine_deep.tscn: east extension of the mine.
## Corridor continues east from the old doorway (x≈43, z 1..5), slopes down 10°, ends in a cave chamber.

const M := "res://assets/LoafbrrAssets/MineAndCavesSet/scenes/"
const P := "res://assets/prop_pack/Exports/glTF/"
const OUT := "res://scene/levels/mine_deep.tscn"

const Z_MID := 3.0          # corridor centre line
const TILT_DEG := -10.0     # slope: east end lower
const SLOPE_START := 52.0
const SLOPE_END := 64.0

var root3d: Node3D
var cache := {}
var counter := {}

func scene(path: String) -> PackedScene:
	if not cache.has(path):
		cache[path] = load(path)
	return cache[path]

func add(parent: Node, path: String, pos: Vector3, basis := Basis.IDENTITY, node_name := "") -> Node3D:
	var n: Node3D = scene(path).instantiate()
	var base := node_name if node_name != "" else path.get_file().get_basename()
	counter[base] = counter.get(base, 0) + 1
	n.name = "%s_%d" % [base, counter[base]]
	n.transform = Transform3D(basis, pos)
	parent.add_child(n)
	n.owner = root3d
	return n

func group(parent: Node, group_name: String) -> Node3D:
	var g := Node3D.new()
	g.name = group_name
	parent.add_child(g)
	g.owner = root3d
	return g

func own(n: Node, parent: Node) -> Node:
	parent.add_child(n)
	n.owner = root3d
	return n

func rot_y(deg: float) -> Basis:
	return Basis(Vector3.UP, deg_to_rad(deg))

func floor_y(x: float) -> float:
	if x <= SLOPE_START:
		return 0.0
	var drop := tan(deg_to_rad(-TILT_DEG))
	return -drop * (min(x, SLOPE_END) - SLOPE_START)

func tilt_at(x: float) -> Basis:
	if x > SLOPE_START and x < SLOPE_END:
		return Basis(Vector3(0, 0, 1), deg_to_rad(TILT_DEG))
	return Basis.IDENTITY

## One 4 m corridor tile centred at x (tile spans x-2..x+2).
func corridor_tile(g: Node3D, x: float, with_floor := true) -> void:
	var y := floor_y(x)
	var t := tilt_at(x)
	if with_floor:
		add(g, M + "Ground/Ground_Mines/ground_mines_a.tscn", Vector3(x, y, Z_MID), t * rot_y(-90))
	add(g, M + "Ground/Ground_Mines/ground_mines_a.tscn", Vector3(x, y + 4.0, Z_MID), t * rot_y(-90), "ceiling_mines_a")
	add(g, M + "Wall/Wall_Mines/wall_mines_b.tscn", Vector3(x, y, Z_MID + 2.0), t * rot_y(0))
	add(g, M + "Wall/Wall_Mines/wall_mines_b.tscn", Vector3(x, y, Z_MID - 2.0), t * rot_y(180))
	add(g, M + "Panel_Wood/panel_wood_a.tscn", Vector3(x, y, Z_MID + 1.5), t)
	add(g, M + "Panel_Wood/panel_wood_a.tscn", Vector3(x, y, Z_MID - 1.6), t)

## Timber frame (two posts + cross beam + side beams) at x.
func frame(g: Node3D, x: float) -> void:
	var y := floor_y(x)
	add(g, M + "Posts/post_f.tscn", Vector3(x, y, Z_MID + 1.5), rot_y(0))
	add(g, M + "Posts/post_f.tscn", Vector3(x, y, Z_MID - 1.6), rot_y(180))
	add(g, M + "Posts/beam_a.tscn", Vector3(x, y + 3.9, Z_MID - 0.5), rot_y(90))
	var t := tilt_at(x - 0.01) if x > SLOPE_START else tilt_at(x + 0.01)
	add(g, M + "Posts/beam_a.tscn", Vector3(x, y + 3.9, Z_MID + 1.5), t * rot_y(180))
	add(g, M + "Posts/beam_a.tscn", Vector3(x, y + 3.9, Z_MID - 1.6), t * rot_y(180))

func add_box(body: Node, node_name: String, size: Vector3, pos: Vector3) -> void:
	var shape := CollisionShape3D.new()
	shape.name = node_name
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = pos
	own(shape, body)

## Wall lantern at an explicit position/orientation (the light and crackle are children).
func lantern_at(g: Node3D, pos: Vector3, basis: Basis) -> void:
	var lamp := add(g, P + "Lantern_Wall.gltf", pos, basis, "Lantern")
	_light_and_crackle(lamp)

func lantern(g: Node3D, x: float, side: int, height := 2.1) -> void:
	# side +1: on the z+ wall facing -z; side -1: on the z- wall facing +z
	var z := Z_MID + (1.45 if side > 0 else -1.55)
	var basis := rot_y(180 if side > 0 else 0)
	var y := floor_y(x) + height
	var lamp := add(g, P + "Lantern_Wall.gltf", Vector3(x, y - 0.75, z), basis, "Lantern")
	_light_and_crackle(lamp)

func _light_and_crackle(lamp: Node3D) -> void:
	var light := OmniLight3D.new()
	light.name = "Light"
	light.position = Vector3(0, 0.6, 0.95)
	light.light_color = Color(1.0, 0.62, 0.32)
	light.light_energy = 1.6
	light.omni_range = 8.0
	light.omni_attenuation = 1.4
	light.shadow_enabled = true
	light.set_script(load("res://script/light_flicker.gd"))
	light.set("housing_casts_shadow", false)
	own(light, lamp)
	var crackle := AudioStreamPlayer3D.new()
	crackle.name = "Crackle"
	crackle.position = light.position
	crackle.stream = load("res://assets/sounds/generated/lantern_crackle.wav")
	crackle.volume_db = -12.0
	crackle.unit_size = 1.5
	crackle.max_distance = 7.0
	crackle.autoplay = true
	crackle.bus = &"SFX"
	own(crackle, lamp)

func emitter(parent: Node3D, node_name: String, sound: String, pos: Vector3, min_i: float, max_i: float, vol: float, max_dist: float, pitch: float) -> void:
	var e := AudioStreamPlayer3D.new()
	e.name = node_name
	e.position = pos
	e.stream = load("res://assets/sounds/generated/%s.wav" % sound)
	e.volume_db = vol
	e.unit_size = 3.0
	e.max_distance = max_dist
	e.bus = &"Ambience"
	e.set_script(load("res://script/random_sound_emitter.gd"))
	e.set("min_interval", min_i)
	e.set("max_interval", max_i)
	e.set("pitch_variation", pitch)
	own(e, parent)

func interactable(parent: Node3D, display_name: String, description: String, solid := true, padding := 0.05, extra := {}) -> void:
	var area := Area3D.new()
	area.name = "Interactable"
	area.set_script(load("res://script/interactable.gd"))
	area.set("display_name", display_name)
	area.set("description", description)
	area.set("solid", solid)
	area.set("padding", padding)
	for key in extra:
		area.set(key, extra[key])
	own(area, parent)

func _initialize() -> void:
	seed(7)
	root3d = Node3D.new()
	root3d.name = "MineDeep"

	# --- Corridor: flat continuation, then 10° slope, then flat landing ---
	var corridor := group(root3d, "Corridor")
	corridor_tile(corridor, 46.0, false)   # existing level already has this floor tile
	corridor_tile(corridor, 50.0)
	for x in [54.0, 58.0, 62.0]:
		corridor_tile(corridor, x)
	corridor_tile(corridor, 66.0)
	for x in [48.0, 52.0, 56.0, 60.0, 64.0]:
		frame(corridor, x)
	# doorway into the cave chamber
	var yb := floor_y(66.0)
	add(corridor, M + "Wall/Wall_Mines/wall_mines_entrance_a.tscn", Vector3(67.7, yb, Z_MID), rot_y(90))
	add(corridor, M + "Panel_Wood/panel_wood_entrance_a.tscn", Vector3(67.1, yb, Z_MID), rot_y(90))
	# rails along the corridor floor and an abandoned cart
	var rails := group(root3d, "Rails")
	for x in [46.0, 50.0]:
		add(rails, M + "Mine_Rails/rail_a.tscn", Vector3(x, 0.02, Z_MID))
	for x in [54.0, 58.0, 62.0]:
		add(rails, M + "Mine_Rails/rail_a.tscn", Vector3(x, floor_y(x) + 0.02, Z_MID), tilt_at(x))
	var cart := add(rails, M + "Mine_Carts/mine_cart_aa.tscn", Vector3(61.6, floor_y(61.6) + 0.47, Z_MID), tilt_at(61.6) * rot_y(4))
	interactable(cart, "Wózek górniczy", "Wózek stanął na pochylni, do połowy pełen urobku. Kamienie połyskują w świetle lampy na niebiesko. Nikt ich nie wywiózł na górę.")

	var lights := group(root3d, "Lanterns")
	lantern(lights, 50.0, 1)
	lantern(lights, 58.0, -1)
	lantern(lights, 66.0, 1)

	# --- Cave chamber: x 68..82, z -4..10, floor at landing height ---
	var y0 := yb
	var chamber := group(root3d, "Chamber")
	# One continuous floor (visible + solid). Loose cave ground tiles left gaps over the void.
	var floor_body := StaticBody3D.new()
	floor_body.name = "ChamberFloor"
	own(floor_body, chamber)
	var floor_mesh := MeshInstance3D.new()
	floor_mesh.name = "Mesh"
	var plane := PlaneMesh.new()
	plane.size = Vector2(15.0, 15.0)
	plane.subdivide_width = 8
	plane.subdivide_depth = 8
	floor_mesh.mesh = plane
	floor_mesh.material_override = load("res://material/cave_floor.tres")
	floor_mesh.position = Vector3(75.3, y0, 3.0)
	own(floor_mesh, floor_body)
	add_box(floor_body, "Shape", Vector3(15.0, 0.4, 15.0), Vector3(75.3, y0 - 0.2, 3.0))
	# Ceiling: flipped cave tiles for relief, and a rock plane above them to close the gaps.
	var grounds := ["ground_cave_a", "ground_cave_b", "ground_cave_c", "ground_cave_d", "ground_cave_e", "ground_cave_f"]
	var i := 0
	for gx in [70.2, 74.6, 79.0, 81.2]:
		for gz in [-1.6, 3.2, 8.0]:
			add(chamber, M + "Ground/Ground_Cave/%s.tscn" % grounds[(i + 3) % grounds.size()], Vector3(gx, y0 + 4.9, gz), Basis(Vector3.RIGHT, PI) * rot_y(90 * (i % 4)), "cave_ceiling")
			i += 1
	var ceiling := MeshInstance3D.new()
	ceiling.name = "CeilingPlane"
	var ceiling_plane := PlaneMesh.new()
	ceiling_plane.size = Vector2(15.0, 15.0)
	ceiling_plane.flip_faces = true
	ceiling.mesh = ceiling_plane
	ceiling.material_override = load("res://material/cave_rock.tres")
	ceiling.position = Vector3(75.3, y0 + 5.3, 3.0)
	own(ceiling, chamber)
	# Uneven edges: a few low cave ground pieces along the walls (not in the walking area).
	for r in [[70.0, -2.8, 0], [79.5, -3.0, 1], [81.2, 1.0, 2], [80.6, 8.8, 3], [72.5, 9.0, 4]]:
		add(chamber, M + "Ground/Ground_Cave/%s.tscn" % grounds[r[2]], Vector3(r[0], y0 - 0.25, r[1]), rot_y(randf() * 360), "floor_patch")
	var walls := ["wall_caves_a", "wall_caves_b", "wall_caves_c", "wall_caves_d"]
	i = 0
	for wz in [-1.5, 7.5]:            # west wall, doorway gap at z 1..5
		add(chamber, M + "Wall/Wall_Cave/%s.tscn" % walls[i % 4], Vector3(68.3, y0, wz), rot_y(90)); i += 1
	for wz in [-1.6, 3.0, 7.6]:       # east wall
		add(chamber, M + "Wall/Wall_Cave/%s.tscn" % walls[i % 4], Vector3(82.4, y0, wz), rot_y(-90)); i += 1
	for wx in [70.4, 75.0, 79.6]:     # north and south walls
		add(chamber, M + "Wall/Wall_Cave/%s.tscn" % walls[i % 4], Vector3(wx, y0, -4.3), rot_y(0)); i += 1
		add(chamber, M + "Wall/Wall_Cave/%s.tscn" % walls[i % 4], Vector3(wx, y0, 10.3), rot_y(180)); i += 1
	for c in [Vector3(68.3, 0, -4.3), Vector3(82.4, 0, -4.3), Vector3(68.3, 0, 10.3), Vector3(82.4, 0, 10.3)]:
		add(chamber, M + "Rocks/Cave_Rocks/cave_pillar_a.tscn", Vector3(c.x, y0, c.z), rot_y(randf() * 360))
	# plug the gaps next to the doorway
	add(chamber, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_a.tscn", Vector3(68.4, y0 + 2.5, 0.9), rot_y(90))
	add(chamber, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_b.tscn", Vector3(68.4, y0 + 2.5, 5.1), rot_y(90))
	# loose rocks inside
	for r in [[71.0, -3.0, "a"], [80.8, -2.6, "b"], [81.0, 8.9, "c"], [70.2, 9.0, "d"], [77.0, 3.4, "b"]]:
		add(chamber, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[2], Vector3(r[0], y0 + 0.2, r[1]), rot_y(randf() * 360))
	# Invisible walls: the pack's cave walls collide from one side only, so the player
	# could walk through them from inside. Inner faces sit just inside the visible rock.
	var bounds := StaticBody3D.new()
	bounds.name = "ChamberBounds"
	own(bounds, chamber)
	add_box(bounds, "West1", Vector3(1.0, 6.0, 5.4), Vector3(67.7, y0 + 3.0, -1.6))
	add_box(bounds, "West2", Vector3(1.0, 6.0, 5.4), Vector3(67.7, y0 + 3.0, 7.6))
	add_box(bounds, "East", Vector3(1.0, 6.0, 15.0), Vector3(82.6, y0 + 3.0, 3.0))
	add_box(bounds, "North", Vector3(15.0, 6.0, 1.0), Vector3(75.3, y0 + 3.0, -4.6))
	add_box(bounds, "South", Vector3(15.0, 6.0, 1.0), Vector3(75.3, y0 + 3.0, 10.6))
	# a warm lantern just inside the doorway so the floor reads under the blue glow
	lantern_at(chamber, Vector3(68.75, y0 + 1.35, 7.0), rot_y(90))

	# --- Blue iron veins: rocks against the walls with a glowing overlay ---
	var veins := group(root3d, "BlueIronVeins")
	veins.set_script(load("res://script/overlay_applier.gd"))
	var vein_mat := ShaderMaterial.new()
	vein_mat.shader = load("res://shader/blue_iron_vein.gdshader")
	veins.set("overlay", vein_mat)
	var vein_rocks := [
		["c", Vector3(81.7, y0 + 1.4, 1.2), -90.0],
		["e", Vector3(81.7, y0 + 1.6, 5.4), -90.0],
		["d", Vector3(76.4, y0 + 1.3, -3.6), 0.0],
		["f", Vector3(72.0, y0 + 1.5, 9.6), 180.0],
	]
	add(veins, M + "Rocks/Cave_Rocks/cave_pillar_b.tscn", Vector3(75.5, y0, 0.2), rot_y(35))
	add(veins, M + "Rocks/Cave_Rocks/cave_pillar_c.tscn", Vector3(78.2, y0, 7.2), rot_y(120))
	for v in vein_rocks:
		add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % v[0], v[1], rot_y(v[2]))
	interactable(veins.get_child(2), "Żyła błękitnego żelaza", "Przez skałę biegną cienkie żyłki, świecące na niebiesko. Metal jest ciepły, choć dookoła ziąb. Jak się dłużej przyjrzeć, światło rośnie i słabnie. Jakby ktoś oddychał.")
	var vein_lights := group(root3d, "VeinLights")
	for p in [Vector3(80.4, y0 + 1.6, 3.2), Vector3(76.4, y0 + 1.4, -2.2), Vector3(72.0, y0 + 1.5, 8.2), Vector3(76.8, y0 + 2.2, 3.8)]:
		var l := OmniLight3D.new()
		l.name = "VeinLight"
		l.position = p
		l.light_color = Color(0.35, 0.6, 1.0)
		l.light_energy = 2.4
		l.omni_range = 7.5
		l.shadow_enabled = true
		l.set_script(load("res://script/light_flicker.gd"))
		l.set("mode", 1)
		l.set("strength", 0.35)
		l.set("speed", 0.7)
		own(l, vein_lights)

	# --- Sounds: drips, creaking timber, rumble, and pick taps from behind the far wall ---
	var sounds := group(root3d, "Sounds")
	emitter(sounds, "DripSlope", "drip", Vector3(58, 2.6, 3.5), 4.0, 10.0, -6.0, 18.0, 0.2)
	emitter(sounds, "DripChamber1", "drip", Vector3(74, y0 + 4.0, -2.0), 2.5, 7.0, -3.0, 20.0, 0.25)
	emitter(sounds, "DripChamber2", "drip", Vector3(80, y0 + 4.0, 8.0), 3.5, 9.0, -5.0, 20.0, 0.25)
	emitter(sounds, "CreakNew1", "creak", Vector3(54, 3.4, 3), 12.0, 26.0, -8.0, 20.0, 0.12)
	emitter(sounds, "CreakNew2", "creak", Vector3(62, 2.0, 3), 14.0, 32.0, -7.0, 20.0, 0.12)
	emitter(sounds, "RumbleDeep", "rumble", Vector3(78, y0 + 1.0, 3), 30.0, 60.0, 0.0, 60.0, 0.15)
	emitter(sounds, "PickTaps", "pick_taps", Vector3(85.5, y0 + 1.0, 3), 35.0, 80.0, -2.0, 45.0, 0.05)

	# --- Story props in the chamber ---
	var props := group(root3d, "Props")
	var pick := add(props, P + "Pickaxe_Bronze.gltf", Vector3(73.2, y0 + 0.07, 5.6), Basis(Vector3.UP, 0.6) * Basis(Vector3.RIGHT, PI / 2))
	interactable(pick, "Porzucony kilof", "Stary kilof z pękniętym trzonkiem. Na żeleźcu ktoś wyrył dwie skrzyżowane kreski i kropkę. Ten sam znak dziadek stawiał na swoich mapach.")
	var note := add(props, P + "Scroll_2.gltf", Vector3(77.6, y0 + 0.01, 2.9), rot_y(40))
	interactable(note, "Kartka z szyfrem", "Kartka zapisana rzędami liter bez ładu i składu. Dziadek tak pisał, kiedy nie chciał, żeby ktoś obcy to przeczytał. Na dole jedno zwykłe zdanie: „Nie idźcie za błękitem.”\n\nPrzepisujesz wszystko do notesu.", false, 0.15, {"on_use_flag": "found_cipher", "on_use_note": &"szyfr", "on_use_quest": &"slady", "on_use_quest_entry": "szyfr"})

	var packed := PackedScene.new()
	var err := packed.pack(root3d)
	if err != OK:
		push_error("pack failed: %s" % err)
	else:
		err = ResourceSaver.save(packed, OUT)
		_strip_meshes()
		print("saved ", OUT, " err=", err, " nodes=", _count(root3d))
	root3d.free()
	quit()

func _count(n: Node) -> int:
	var c := 1
	for ch in n.get_children():
		if ch.owner == root3d or ch == root3d:
			c += _count(ch)
	return c

func _strip_meshes() -> void:
	# Keep module meshes referenced from their own scenes instead of copied into this one.
	var path := ProjectSettings.globalize_path(OUT)
	var out := PackedStringArray()
	var skipping := false
	var in_instance := false
	for line in FileAccess.get_file_as_string(path).split("
"):
		if line.begins_with("["):
			skipping = line.begins_with("[sub_resource type=\"ArrayMesh\"")
			in_instance = line.begins_with("[node") and line.contains("instance=")
		if skipping:
			continue
		if in_instance and line.begins_with("mesh = SubResource("):
			continue
		out.append(line)
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("
".join(out))
