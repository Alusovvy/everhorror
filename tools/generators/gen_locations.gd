extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_locations.gd
## (run gen_sanctin_textures.gd and import first).
## Generates res://scene/levels/locations.tscn: the three expedition places reached from the map
## table (docs_v2/03_poziomy.md). Each is a closed space far away from the main level; travel
## places the player at its entry marker and the signpost takes them back to the camp.
## - Rzapie: the flooded bottom of the old shaft (Tekla's bundle, a vein, scratches on the wall),
## - Upadowa: the steep decline behind the broken supports, ending at the old collapse (a vein,
##   grandfather's mark, soot and barrel staves: the collapse was a charge),
## - Kaplica: the chapel below the east cave: the carved wall with the riddle (VN), the niche.
## WARNING: overwrites the scene. Edit this generator, not the scene.

const P := "res://assets/prop_pack/Exports/glTF/"
const K := "res://assets/props/kenney_survival/"
const M := "res://assets/LoafbrrAssets/MineAndCavesSet/scenes/"
const OUT := "res://scene/levels/locations.tscn"

const RZAPIE := Vector3(-60.0, 0.0, 70.0)
const UPADOWA := Vector3(-60.0, 0.0, 110.0)
const KAPLICA := Vector3(60.0, 0.0, 110.0)
## Upadowa: 20° decline between x 4 and 20 (local).
const SLOPE_DEG := 20.0
const SLOPE_X := Vector2(4.0, 20.0)
## Kaplica: chamber floor below the entry.
const CHAPEL_Y := -2.4

var root3d: Node3D
var cache := {}
var counter := {}
var rock: Material
var floor_mat: Material
var wood: Material
var soot_mat: StandardMaterial3D
var charred: StandardMaterial3D

func scene(path: String) -> PackedScene:
	if not cache.has(path):
		cache[path] = load(path)
	return cache[path]

func own(n: Node, parent: Node) -> Node:
	parent.add_child(n)
	n.owner = root3d
	return n

func group(parent: Node, group_name: String, pos := Vector3.ZERO) -> Node3D:
	var g := Node3D.new()
	g.name = group_name
	g.position = pos
	return own(g, parent)

func add(parent: Node, path: String, pos: Vector3, yaw_deg := 0.0, scale := 1.0, node_name := "") -> Node3D:
	return add_b(parent, path, Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)).scaled(Vector3.ONE * scale), pos), node_name)

func add_b(parent: Node, path: String, xform: Transform3D, node_name := "") -> Node3D:
	var n: Node3D = scene(path).instantiate()
	var base := node_name if node_name != "" else path.get_file().get_basename().replace("-", "_")
	counter[base] = counter.get(base, 0) + 1
	n.name = base if node_name != "" else "%s_%d" % [base, counter[base]]
	n.transform = xform
	return own(n, parent)

## A box of rock/floor/wood: visible mesh plus (optionally) the same box as collision.
func slab(parent: Node, slab_name: String, size: Vector3, pos: Vector3, material: Material, collide := true, basis := Basis.IDENTITY) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = slab_name
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = material
	mi.transform = Transform3D(basis, pos)
	own(mi, parent)
	if collide:
		solid(parent, slab_name + "Body", size, pos, basis)
	return mi

## Invisible collision box.
func solid(parent: Node, body_name: String, size: Vector3, pos: Vector3, basis := Basis.IDENTITY) -> void:
	var body := StaticBody3D.new()
	body.name = body_name
	body.transform = Transform3D(basis, pos)
	own(body, parent)
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	own(shape, body)

func marker(marker_name: String, world_pos: Vector3, yaw_deg: float) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)), world_pos)
	own(m, root3d.get_node("Markers"))

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

func look(parent: Node, display_name: String, description: String, extra := {}) -> Area3D:
	var props := {"display_name": display_name, "description": description, "solid": false, "padding": 0.08}
	props.merge(extra, true)
	return interactable(parent, "Look", props)

func light(parent: Node, light_name: String, pos: Vector3, color: Color, energy: float, light_range: float, shadows := true, flicker := 0.18, speed := 6.0, mode := 0) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.name = light_name
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = light_range
	l.omni_attenuation = 1.3
	l.shadow_enabled = shadows
	l.set_script(load("res://script/light_flicker.gd"))
	l.set("strength", flicker)
	l.set("speed", speed)
	l.set("mode", mode)
	return own(l, parent)

func blue_light(parent: Node, pos: Vector3, energy := 2.4, light_range := 7.0) -> void:
	light(parent, "VeinLight", pos, Color(0.35, 0.6, 1.0), energy, light_range, true, 0.35, 0.7, 1)

## Wall lantern (prop pack) with its flame light; yaw points the bracket away from the wall.
func lantern(parent: Node, pos: Vector3, yaw_deg: float, energy := 1.3, light_range := 7.0) -> void:
	var lamp := add(parent, P + "Lantern_Wall.gltf", pos, yaw_deg, 1.0, "Lantern")
	var l := light(lamp, "Light", Vector3(0, 0.6, 0.95), Color(1.0, 0.62, 0.32), energy, light_range)
	l.set("housing_casts_shadow", false)

func emitter(parent: Node, node_name: String, sound: String, pos: Vector3, min_i: float, max_i: float, vol: float, max_dist: float, pitch: float) -> void:
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

## Rocks with the glowing blue-iron overlay.
func vein_group(parent: Node, group_name: String) -> Node3D:
	var g := Node3D.new()
	g.name = group_name
	g.set_script(load("res://script/overlay_applier.gd"))
	var vein_mat := ShaderMaterial.new()
	vein_mat.shader = load("res://shader/blue_iron_vein.gdshader")
	g.set("overlay", vein_mat)
	return own(g, parent)

## Racibor's quest: marking the vein costs an hour; afterwards a stake shows it is done.
func vein_mark(parent: Node, rock_node: Node3D, vein_id: String, description: String, stake_pos: Vector3) -> void:
	interactable(parent, "VeinMark", {
		"display_name": "Żyła błękitnego żelaza", "prompt_text": "Zaznacz żyłę na mapie",
		"description": description, "time_cost_hours": 1.0, "time_reason": "Znaczenie żyły",
		"on_use_flag": "vein_" + vein_id, "on_use_quest": &"zloza", "on_use_quest_entry": vein_id,
		"quest_only_if_active": true, "hidden_by_flag": "vein_" + vein_id,
		"highlight_target": rock_node, "solid": false, "padding": 0.1,
	})
	var stakes := Node3D.new()
	stakes.name = "Stake"
	stakes.set_script(load("res://script/material_applier.gd"))
	stakes.set("material", wood)
	own(stakes, parent)
	var stake := add(stakes, K + "signpost-single.glb", stake_pos, randf() * 360.0, 1.6, "VeinStake")
	look(stake, "Twój palik", "Tu zaznaczyłeś żyłę dla Racibora. Na palu wyciąłeś nożem kreskę.", {"required_flag": "vein_" + vein_id})

func exit_sign(parent: Node, place_id: String, pos: Vector3, yaw_deg: float, hours: int) -> void:
	var signs := Node3D.new()
	signs.name = "Sign"
	signs.set_script(load("res://script/material_applier.gd"))
	signs.set("material", wood)
	own(signs, parent)
	var post := add(signs, K + "signpost-single.glb", pos, yaw_deg, 3.2, "ExitSign")
	interactable(post, "%sExitUse" % place_id.capitalize(), {"display_name": "Droga powrotna", "prompt_text": "Wróć do obozu · %d h" % hours, "action": 2})

func rope(parent: Node, rope_name: String, from: Vector3, to: Vector3, radius := 0.025) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = rope_name
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = from.distance_to(to)
	cyl.radial_segments = 8
	mi.mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.36, 0.27, 0.17)
	mat.roughness = 0.95
	mi.material_override = mat
	var dir := (to - from).normalized()
	var side := dir.cross(Vector3.FORWARD if absf(dir.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT).normalized()
	mi.transform = Transform3D(Basis(side, dir, side.cross(dir)).orthonormalized(), (from + to) * 0.5)
	own(mi, parent)
	return mi

func quad(parent: Node, quad_name: String, size: Vector2, xform: Transform3D, material: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = quad_name
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	mi.material_override = material
	mi.transform = xform
	own(mi, parent)
	return mi

func _initialize() -> void:
	seed(21)
	root3d = Node3D.new()
	root3d.name = "Locations"
	group(root3d, "Markers")
	rock = load("res://material/cave_rock.tres")
	floor_mat = load("res://material/cave_floor.tres")
	wood = load("res://material/kenney_wood.tres")
	charred = StandardMaterial3D.new()
	charred.albedo_color = Color(0.06, 0.05, 0.045)
	charred.roughness = 1.0
	soot_mat = StandardMaterial3D.new()
	soot_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	soot_mat.albedo_color = Color(0.02, 0.02, 0.02, 0.85)
	var soot_tex := GradientTexture2D.new()
	var soot_grad := Gradient.new()
	soot_grad.set_color(0, Color(1, 1, 1, 1))
	soot_grad.set_color(1, Color(1, 1, 1, 0))
	soot_tex.gradient = soot_grad
	soot_tex.fill = GradientTexture2D.FILL_RADIAL
	soot_tex.fill_from = Vector2(0.5, 0.5)
	soot_tex.fill_to = Vector2(1.0, 0.5)
	soot_mat.albedo_texture = soot_tex
	_rzapie()
	_upadowa()
	_kaplica()
	var packed := PackedScene.new()
	var err := packed.pack(root3d)
	if err == OK:
		err = ResourceSaver.save(packed, OUT)
		_strip_meshes()
	print("saved ", OUT, " err=", err)
	root3d.free()
	quit()

#region Rząpie: the flooded bottom of the old shaft

func _rzapie() -> void:
	var g := group(root3d, "Rzapie", RZAPIE)
	# chamber x 0..10, z -4..4; the shaft opens in the ceiling above the landing at x 7.6
	slab(g, "Floor", Vector3(10.6, 0.4, 8.6), Vector3(5.0, -0.2, 0.0), floor_mat)
	slab(g, "WallNorth", Vector3(10.8, 4.9, 0.4), Vector3(5.0, 2.25, -4.2), rock)
	slab(g, "WallSouth", Vector3(10.8, 4.9, 0.4), Vector3(5.0, 2.25, 4.2), rock)
	slab(g, "WallEast", Vector3(0.4, 4.9, 8.8), Vector3(10.2, 2.25, 0.0), rock)
	slab(g, "WallWestN", Vector3(0.4, 4.9, 3.1), Vector3(-0.2, 2.25, -2.75), rock)
	slab(g, "WallWestS", Vector3(0.4, 4.9, 3.1), Vector3(-0.2, 2.25, 2.75), rock)
	slab(g, "WallWestTop", Vector3(0.4, 1.6, 2.4), Vector3(-0.2, 3.9, 0.0), rock)
	slab(g, "CeilingWest", Vector3(6.7, 0.4, 8.8), Vector3(2.95, 4.7, 0.0), rock)
	slab(g, "CeilingEast", Vector3(1.5, 0.4, 8.8), Vector3(9.65, 4.7, 0.0), rock)
	slab(g, "CeilingNorth", Vector3(2.6, 0.4, 3.1), Vector3(7.6, 4.7, -2.85), rock)
	slab(g, "CeilingSouth", Vector3(2.6, 0.4, 3.1), Vector3(7.6, 4.7, 2.85), rock)
	# the shaft: a square tube up into the dark, a pale light far above
	slab(g, "ShaftWest", Vector3(0.4, 10.0, 3.4), Vector3(6.1, 9.5, 0.0), rock, false)
	slab(g, "ShaftEast", Vector3(0.4, 10.0, 3.4), Vector3(9.1, 9.5, 0.0), rock, false)
	slab(g, "ShaftNorth", Vector3(2.6, 10.0, 0.4), Vector3(7.6, 9.5, -1.5), rock, false)
	slab(g, "ShaftSouth", Vector3(2.6, 10.0, 0.4), Vector3(7.6, 9.5, 1.5), rock, false)
	var sky := SpotLight3D.new()
	sky.name = "ShaftLight"
	sky.position = Vector3(7.6, 14.2, 0.0)
	sky.rotation_degrees = Vector3(-90, 0, 0)
	sky.light_color = Color(0.72, 0.8, 0.92)
	sky.light_energy = 9.0
	sky.spot_range = 18.0
	sky.spot_angle = 17.0
	sky.spot_attenuation = 0.6
	sky.shadow_enabled = true
	own(sky, g)
	# relief on the walls
	for r in [["a", Vector3(1.4, 1.0, -3.95), 0.0, 1.1], ["d", Vector3(6.2, 1.3, -3.95), 0.0, 1.2], ["b", Vector3(9.9, 1.2, -2.2), -90.0, 1.1],
			["f", Vector3(9.9, 1.0, 2.6), -90.0, 1.2], ["e", Vector3(3.2, 1.1, 3.95), 180.0, 1.1], ["g", Vector3(7.8, 1.0, 3.95), 180.0, 1.0]]:
		add(g, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % r[0], r[1], r[2], r[3])
	# water over most of the floor; the walkway and the landing stick out of it
	var water_mat := ShaderMaterial.new()
	water_mat.shader = load("res://shader/water.gdshader")
	for key in ["ripples_a", "ripples_b"]:
		var noise_tex := NoiseTexture2D.new()
		noise_tex.seamless = true
		noise_tex.as_normal_map = true
		noise_tex.bump_strength = 6.0
		noise_tex.width = 256
		noise_tex.height = 256
		var noise := FastNoiseLite.new()
		noise.frequency = 0.02 if key == "ripples_a" else 0.035
		noise.seed = 3 if key == "ripples_a" else 9
		noise_tex.noise = noise
		water_mat.set_shader_parameter(key, noise_tex)
	var water := MeshInstance3D.new()
	water.name = "Water"
	var plane := PlaneMesh.new()
	plane.size = Vector2(10.4, 8.4)
	water.mesh = plane
	water.material_override = water_mat
	water.position = Vector3(5.0, 0.06, 0.0)
	own(water, g)
	slab(g, "Walkway", Vector3(6.6, 0.1, 1.3), Vector3(3.0, 0.07, 0.0), wood)
	slab(g, "Landing", Vector3(3.0, 0.1, 3.0), Vector3(7.6, 0.07, 0.0), wood)
	for x in [0.6, 2.2, 3.8, 5.4]:
		for z in [-0.6, 0.6]:
			slab(g, "Post", Vector3(0.12, 0.35, 0.12), Vector3(x, -0.1, z), wood, false)
	add(g, M + "Ladder/ladder_tall.tscn", Vector3(7.6, 0.12, -1.2), 0.0, 1.0, "BrokenLadder")
	look(g.get_node("BrokenLadder"), "Drabina", "Drabina w szybie urywa się w połowie. Wyżej już tylko mokra skała i daleki, szary kwadrat nieba.")
	var old_rope := rope(g, "OldRope", Vector3(8.7, 13.2, 1.05), Vector3(8.75, 0.15, 1.05))
	look(old_rope, "Urwana lina", "Lina, na której spuszczano zapasy. Tekla mówi, że przetarła się o krawędź szybu. Tylko że koniec jest równy, jakby ktoś go przeciął nożem.", {"padding": 0.15})
	# the entry: a short tunnel stub from the west, the way back
	var tunnel := group(g, "Tunnel")
	slab(tunnel, "Floor", Vector3(3.6, 0.4, 2.6), Vector3(-1.9, -0.08, 0.0), floor_mat)
	slab(tunnel, "WallN", Vector3(3.6, 3.4, 0.4), Vector3(-1.9, 1.6, -1.4), rock)
	slab(tunnel, "WallS", Vector3(3.6, 3.4, 0.4), Vector3(-1.9, 1.6, 1.4), rock)
	slab(tunnel, "Ceiling", Vector3(3.6, 0.4, 3.2), Vector3(-1.9, 3.3, 0.0), rock)
	slab(tunnel, "End", Vector3(0.4, 3.4, 2.8), Vector3(-3.7, 1.6, 0.0), rock)
	for r in [["a", Vector3(-3.2, 0.3, -0.6), 1.1], ["c", Vector3(-3.3, 0.3, 0.7), 1.0]]:
		add(tunnel, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[0], r[1], randf() * 360.0, r[2])
	add(tunnel, M + "Posts/post_f.tscn", Vector3(-0.35, 0.12, -1.1), 0.0)
	add(tunnel, M + "Posts/post_f.tscn", Vector3(-0.35, 0.12, 1.1), 180.0)
	lantern(tunnel, Vector3(-0.9, 1.35, 1.2), 180.0, 1.1, 6.0)
	exit_sign(g, "rzapie", Vector3(-1.2, 0.12, -0.95), 90.0, 2)
	marker("RzapieEntry", RZAPIE + Vector3(-2.3, 0.12, 0.0), -90.0)
	# Tekla's bundle on the landing, right under the shaft
	var bundle := add(g, P + "Bag.gltf", Vector3(8.35, 0.12, 0.8), 30.0, 0.7, "Bundle")
	interactable(bundle, "BundlePickup", {
		"display_name": "Tobołek",
		"description": "Tobołek z grubego płótna, zawiązany na podwójny węzeł. Na szmatce wyszyte: T. Całkiem suchy, choć leżał tuż nad wodą.\n\nW środku ciężka sakiewka srebra i list z pieczęcią. Zabierasz wszystko.",
		"on_use_item": "tobolek", "on_use_flag": "took_bundle", "on_use_note": &"list_konfraterni",
		"on_use_quest": &"towar", "on_use_quest_entry": "znaleziony", "quest_only_if_active": true,
		"remove_after_use": true, "padding": 0.15,
	})
	add(g, P + "Rope_2.gltf", Vector3(6.9, 0.12, 1.0), 40.0)
	# flotsam from the supplies that went down with it
	var crate := add(g, P + "Crate_Wooden.gltf", Vector3(5.2, -0.25, 3.3), 30.0, 0.9)
	crate.rotate_object_local(Vector3.RIGHT, deg_to_rad(18.0))
	var barrel := add(g, P + "Barrel.gltf", Vector3(8.9, 0.1, -3.0), 0.0, 0.9)
	barrel.basis = Basis(Vector3.UP, 0.6) * Basis(Vector3.RIGHT, PI / 2) * Basis.from_scale(Vector3.ONE * 0.9)
	# scratches: someone counted days down here
	var tally_mat := StandardMaterial3D.new()
	tally_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tally_mat.albedo_texture = load("res://assets/textures/tally_marks.png")
	tally_mat.roughness = 1.0
	var tally := quad(g, "Tally", Vector2(0.8, 0.4), Transform3D(Basis(Vector3.UP, PI), Vector3(1.4, 1.5, 3.98)), tally_mat)
	look(tally, "Kreski na skale", "Ktoś wydrapał w skale kreski, grupami po pięć. Czternaście. Pod spodem zaczęte słowo, może imię. Urywa się po trzech literach.", {"padding": 0.12})
	# the vein for Racibor
	var veins := vein_group(g, "Vein")
	var vein_rock := add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_c.tscn", Vector3(3.3, 1.2, -3.85), 0.0, 1.2)
	add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_e.tscn", Vector3(4.6, 0.6, -3.9), 0.0, 0.9)
	blue_light(g, Vector3(3.7, 1.6, -2.3), 1.2, 5.5)
	vein_mark(g, vein_rock, "rzapie", "Wąska żyła biegnie ukosem przez skałę i znika pod wodą. Odmierzasz ją krokami i wrysowujesz na mapę dla Racibora.", Vector3(2.9, 0.0, -3.3))
	light(g, "LandingGlow", Vector3(7.6, 1.4, 0.0), Color(0.7, 0.78, 0.9), 0.7, 5.0, false, 0.05, 0.5)
	emitter(g, "DripShaft", "drip", Vector3(7.6, 4.2, 0.4), 1.8, 5.0, -4.0, 16.0, 0.25)
	emitter(g, "DripCorner", "drip", Vector3(1.5, 4.0, -3.0), 3.0, 8.0, -7.0, 14.0, 0.3)
	emitter(g, "Rumble", "rumble", Vector3(5.0, 2.0, 0.0), 30.0, 70.0, -6.0, 40.0, 0.15)

#endregion

#region Upadowa: the steep decline behind the broken supports

func _slope_y(x: float) -> float:
	var t := tan(deg_to_rad(SLOPE_DEG))
	return -t * (clampf(x, SLOPE_X.x, SLOPE_X.y) - SLOPE_X.x)

func _upadowa() -> void:
	var g := group(root3d, "Upadowa", UPADOWA)
	var tilt := Basis(Vector3.BACK, deg_to_rad(-SLOPE_DEG))
	var normal := tilt * Vector3.UP
	var slope_len := (SLOPE_X.y - SLOPE_X.x) / cos(deg_to_rad(SLOPE_DEG))
	var mid := Vector3((SLOPE_X.x + SLOPE_X.y) * 0.5, _slope_y((SLOPE_X.x + SLOPE_X.y) * 0.5), 0.0)
	var bottom := _slope_y(SLOPE_X.y)
	# floor: top landing, the slope, the bottom landing
	slab(g, "FloorTop", Vector3(4.4, 0.4, 4.4), Vector3(2.0, -0.2, 0.0), floor_mat)
	slab(g, "FloorSlope", Vector3(slope_len, 0.4, 4.4), mid - normal * 0.2, floor_mat, true, tilt)
	slab(g, "FloorBottom", Vector3(8.6, 0.4, 4.4), Vector3(24.3, bottom - 0.2, 0.0), floor_mat)
	# ceiling 4 m above the floor
	slab(g, "CeilingTop", Vector3(4.4, 0.4, 4.8), Vector3(2.0, 4.2, 0.0), rock, false)
	slab(g, "CeilingSlope", Vector3(slope_len, 0.4, 4.8), mid + normal * 4.2, rock, false, tilt)
	slab(g, "CeilingBottom", Vector3(8.6, 0.4, 4.8), Vector3(24.3, bottom + 4.2, 0.0), rock, false)
	# side walls, the back wall at the top and the far wall behind the collapse
	for side in [-1.0, 1.0]:
		slab(g, "Wall", Vector3(29.2, 11.5, 0.4), Vector3(14.2, -1.4, 2.3 * side), rock)
	slab(g, "WallTop", Vector3(0.4, 4.6, 4.8), Vector3(-0.2, 2.0, 0.0), rock)
	slab(g, "WallEnd", Vector3(0.4, 5.0, 4.8), Vector3(28.6, bottom + 2.2, 0.0), rock)
	# timber frames every 3.5 m (posts stand vertical on the slope)
	var frames := group(g, "Frames")
	var frame_xs := [1.6, 5.2, 8.7, 12.2, 15.7, 19.2, 22.7, 26.0]
	for x in frame_xs:
		var y := _slope_y(x)
		add(frames, M + "Posts/post_f.tscn", Vector3(x, y, -1.95), 0.0)
		add(frames, M + "Posts/post_f.tscn", Vector3(x, y, 1.95), 180.0)
		add(frames, M + "Posts/beam_a.tscn", Vector3(x, y + 3.75, 0.0), 90.0)
	# rails on the flat parts
	add(g, M + "Mine_Rails/rail_a.tscn", Vector3(2.0, 0.02, 0.0), 90.0)
	add(g, M + "Mine_Rails/rail_a.tscn", Vector3(22.0, bottom + 0.02, 0.0), 90.0)
	add(g, M + "Mine_Rails/rail_falloff_a.tscn", Vector3(25.6, bottom + 0.02, 0.0), 90.0)
	# the rope the player came down on: tied to the first post, down to the bottom
	var anchor := Vector3(3.3, 0.95, -1.75)
	rope(g, "DescentRope", anchor, Vector3(20.4, bottom + 0.35, -1.6), 0.03)
	add(g, P + "Rope_3.gltf", Vector3(2.6, 0.0, -1.3), 20.0)
	lantern(g, Vector3(1.6, 1.4, -2.05), 0.0, 1.3, 7.5)
	# two lanterns the old crew left on the way down, barely burning
	for x in [8.7, 15.7]:
		lantern(g, Vector3(x, _slope_y(x) + 1.5, -2.05), 0.0, 0.7, 5.5)
	exit_sign(g, "upadowa", Vector3(0.8, 0.0, 1.4), 90.0, 3)
	marker("UpadowaEntry", UPADOWA + Vector3(1.2, 0.0, 0.0), -90.0)
	# the collapse: rocks from floor to roof, soot, barrel staves, charred timber
	var collapse := group(g, "Collapse")
	for r in [["a", Vector3(27.2, bottom + 0.6, -1.3), 2.2], ["c", Vector3(27.5, bottom + 0.7, 1.2), 2.4], ["b", Vector3(26.7, bottom + 0.3, 0.1), 1.6],
			["d", Vector3(27.8, bottom + 2.2, 0.2), 2.0], ["a", Vector3(26.4, bottom + 0.2, 1.7), 1.1], ["c", Vector3(27.9, bottom + 3.2, -1.0), 1.7]]:
		add(collapse, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[0], r[1], randf() * 360.0, r[2])
	for i in 2:
		var beam := add(collapse, M + "Posts/beam_a.tscn", Vector3(25.9 - i * 0.6, bottom + 0.35 + i * 0.2, -0.8 + i * 1.4), 30.0 + i * 70.0, 1.0, "CharredBeam%d" % i)
		beam.rotate_object_local(Vector3.FORWARD, deg_to_rad(12.0 - i * 20.0))
	var staves := group(collapse, "Staves")
	for i in 2:
		var keg := add(staves, P + "Barrel.gltf", Vector3(25.2 + i * 0.7, bottom + 0.3, 0.9 - i * 1.7), 0.0, 0.75)
		keg.basis = Basis(Vector3.UP, 0.9 + i) * Basis(Vector3.RIGHT, PI / 2) * Basis.from_scale(Vector3(0.75, 0.5, 0.75))
	quad(collapse, "Soot", Vector2(3.2, 3.6), Transform3D(Basis(Vector3.RIGHT, -PI / 2), Vector3(25.8, bottom + 0.02, 0.0)), soot_mat)
	quad(collapse, "SootWall", Vector2(3.8, 3.2), Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(26.3, bottom + 1.6, 0.0)), soot_mat)
	solid(collapse, "Block", Vector3(2.0, 4.0, 4.4), Vector3(27.4, bottom + 2.0, 0.0))
	look(collapse.get_child(0), "Zawał", "Zawał od spągu po strop. Kamienie przy samym dole są czarne od sadzy, a między nimi leżą klepki z beczki i okucia. Stemple dookoła stoją całe. Tak nie wygląda zwykłe tąpnięcie.", {
		"on_use_flag": "saw_charge", "on_use_quest": &"slady", "on_use_quest_entry": "zawal", "padding": 0.3})
	var mark_post: Node3D = frames.get_child(frames.get_child_count() - 3)
	look(mark_post, "Znak na stemplu", "Na stemplu tuż przy zawale wyryto znak dziadka: dwie skrzyżowane kreski i kropkę. Pod spodem, głębiej i krzywo, jakby w pośpiechu: NIE KOPAĆ.", {"on_use_flag": "saw_grandpa_mark"})
	# the richest vein, glowing through the cracks
	var veins := vein_group(g, "Vein")
	var vein_rock := add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_b.tscn", Vector3(23.6, bottom + 1.3, 2.05), 180.0, 1.3)
	add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_d.tscn", Vector3(25.2, bottom + 1.0, 2.05), 180.0, 1.2)
	add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_f.tscn", Vector3(21.9, bottom + 1.6, -2.05), 0.0, 1.1)
	blue_light(g, Vector3(24.0, bottom + 1.4, 1.1), 3.2, 7.5)
	blue_light(g, Vector3(26.4, bottom + 1.0, -0.2), 2.0, 5.0)
	vein_mark(g, vein_rock, "upadowa", "Najgrubsza żyła, jaką widziałeś. Gruba jak ramię. Świeci też przez szczeliny w zawale, jakby po tamtej stronie było jej jeszcze więcej.\n\nZaznaczasz ją na mapie dla Racibora.", Vector3(22.8, bottom, 1.3))
	emitter(g, "Creak", "creak", Vector3(10.0, -1.0, 0.0), 12.0, 28.0, -6.0, 22.0, 0.12)
	emitter(g, "Pebbles", "drip", Vector3(14.0, -2.0, 1.0), 4.0, 11.0, -8.0, 18.0, 0.4)
	emitter(g, "BehindCollapse", "pick_taps", Vector3(30.0, bottom + 1.0, 0.0), 25.0, 60.0, -4.0, 30.0, 0.05)
	emitter(g, "RumbleDeep", "rumble", Vector3(27.0, bottom, 0.0), 35.0, 80.0, -2.0, 40.0, 0.15)

#endregion

#region Kaplica: the chapel below the east cave

func _kaplica() -> void:
	var g := group(root3d, "Kaplica", KAPLICA)
	var y0 := CHAPEL_Y
	# the passage: carved steps down from the entry (collision is a smooth ramp under them)
	slab(g, "EntryFloor", Vector3(1.6, 0.4, 2.4), Vector3(0.4, -0.2, 0.0), floor_mat)
	var ramp_len := sqrt(6.0 * 6.0 + y0 * y0)
	var ramp_tilt := Basis(Vector3.BACK, atan2(y0, 6.0))
	solid(g, "Ramp", Vector3(ramp_len, 0.2, 2.2), Vector3(4.2, y0 * 0.5 - 0.22, 0.0), ramp_tilt)
	var steps := group(g, "Steps")
	for i in 8:
		var top := -0.3 * (i + 1)
		slab(steps, "Step%d" % i, Vector3(0.75, 0.3, 2.2), Vector3(1.575 + i * 0.75, top - 0.15, 0.0), floor_mat, false)
	slab(g, "PassageN", Vector3(7.8, 6.0, 0.4), Vector3(3.6, 0.2, -1.3), rock)
	slab(g, "PassageS", Vector3(7.8, 6.0, 0.4), Vector3(3.6, 0.2, 1.3), rock)
	slab(g, "PassageTop", Vector3(7.8, 0.4, 3.0), Vector3(3.6, 3.0, 0.0), rock, false)
	slab(g, "PassageBack", Vector3(0.4, 3.6, 2.8), Vector3(-0.4, 1.2, 0.0), rock)
	# the chamber x 7.2..17.2, z -5..5
	slab(g, "Floor", Vector3(10.4, 0.4, 10.4), Vector3(12.2, y0 - 0.2, 0.0), floor_mat)
	slab(g, "WallWestN", Vector3(0.4, 5.4, 3.9), Vector3(7.0, y0 + 2.7, -3.05), rock)
	slab(g, "WallWestS", Vector3(0.4, 5.4, 3.9), Vector3(7.0, y0 + 2.7, 3.05), rock)
	slab(g, "WallWestTop", Vector3(0.4, 2.4, 2.2), Vector3(7.0, y0 + 4.2 + 0.6, 0.0), rock)
	slab(g, "WallNorth", Vector3(10.8, 5.4, 0.4), Vector3(12.2, y0 + 2.7, -5.2), rock)
	slab(g, "WallSouth", Vector3(10.8, 5.4, 0.4), Vector3(12.2, y0 + 2.7, 5.2), rock)
	slab(g, "WallEast", Vector3(0.4, 5.4, 10.4), Vector3(17.6, y0 + 2.7, 0.0), rock)
	slab(g, "Ceiling", Vector3(10.8, 0.4, 10.8), Vector3(12.2, y0 + 5.2, 0.0), rock, false)
	for r in [["a", Vector3(8.6, y0 + 1.2, -4.95), 0.0, 1.2], ["d", Vector3(14.6, y0 + 1.4, -4.95), 0.0, 1.1], ["g", Vector3(8.8, y0 + 1.1, 4.95), 180.0, 1.1],
			["b", Vector3(16.1, y0 + 1.3, 4.95), 180.0, 1.0]]:
		add(g, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % r[0], r[1], r[2], r[3])
	for c in [Vector3(7.4, y0, -4.9), Vector3(7.4, y0, 4.9), Vector3(17.0, y0, -4.9), Vector3(17.0, y0, 4.9)]:
		add(g, M + "Rocks/Cave_Rocks/cave_pillar_a.tscn", c, randf() * 360.0, 0.9)
	exit_sign(g, "kaplica", Vector3(0.5, 0.0, 0.85), 90.0, 3)
	marker("KaplicaEntry", KAPLICA + Vector3(0.6, 0.0, 0.0), -90.0)
	_riddle_wall(g, y0)
	_chapel_props(g, y0)
	# blue veins in the side walls
	var veins := vein_group(g, "Vein")
	var vein_rock := add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_c.tscn", Vector3(12.4, y0 + 1.3, 4.95), 180.0, 1.3)
	add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_e.tscn", Vector3(11.4, y0 + 1.6, -4.95), 0.0, 1.2)
	blue_light(g, Vector3(12.4, y0 + 1.6, 4.0), 2.2, 6.5)
	blue_light(g, Vector3(11.4, y0 + 1.8, -4.0), 1.8, 6.0)
	vein_mark(g, vein_rock, "kaplica", "Tu nie trzeba szukać. Błękit biegnie przez całe ściany, a im bliżej wyrytych znaków, tym jaśniej świeci. Zaznaczasz go na mapie dla Racibora.", Vector3(12.1, y0, 4.2))
	emitter(g, "Drip", "drip", Vector3(10.0, y0 + 4.5, -2.0), 3.0, 9.0, -6.0, 18.0, 0.25)
	emitter(g, "Hum", "rumble", Vector3(16.0, y0 + 1.0, 0.0), 20.0, 45.0, -10.0, 25.0, 0.3)

## The carved wall at the east end: glyphs above, three stone rings, the niche below them.
func _riddle_wall(g: Node3D, y0: float) -> void:
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.24, 0.25, 0.29)
	stone.metallic = 0.35
	stone.roughness = 0.35
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.04, 0.04, 0.05)
	dark.roughness = 1.0
	# the wall itself, built around the niche opening (z -0.45..0.45, 0.85 m high)
	slab(g, "WallUpper", Vector3(0.5, 3.05, 6.4), Vector3(16.9, y0 + 0.85 + 1.525, 0.0), stone)
	slab(g, "WallLowerN", Vector3(0.5, 0.85, 2.75), Vector3(16.9, y0 + 0.425, -1.825), stone)
	slab(g, "WallLowerS", Vector3(0.5, 0.85, 2.75), Vector3(16.9, y0 + 0.425, 1.825), stone)
	slab(g, "NicheBack", Vector3(0.1, 0.85, 0.9), Vector3(17.1, y0 + 0.425, 0.0), dark)
	var glyph_mat := ShaderMaterial.new()
	glyph_mat.shader = load("res://shader/sanctin_wall.gdshader")
	glyph_mat.set_shader_parameter("glyphs", load("res://assets/textures/sanctin_wall.png"))
	var wall := Node3D.new()
	wall.name = "RiddleWall"
	wall.position = Vector3(16.6, y0, 0.0)
	wall.set_script(load("res://script/riddle_wall.gd"))
	own(wall, g)
	var glyphs := quad(wall, "Glyphs", Vector2(6.2, 2.25), Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(0.04, 1.65 + 1.125, 0.0)), glyph_mat)
	for i in 3:
		var pivot := Node3D.new()
		pivot.name = "Pivot%d" % (i + 1)
		pivot.transform = Transform3D(Basis(Vector3.BACK, PI / 2), Vector3(0.0, 1.25, -1.35 + i * 1.35))
		own(pivot, wall)
		var ring := MeshInstance3D.new()
		ring.name = "Ring%d" % (i + 1)
		var disc := CylinderMesh.new()
		disc.top_radius = 0.36
		disc.bottom_radius = 0.36
		disc.height = 0.1
		disc.radial_segments = 32
		ring.mesh = disc
		ring.material_override = stone
		own(ring, pivot)
		var notch := MeshInstance3D.new()
		notch.name = "Notch"
		var notch_box := BoxMesh.new()
		notch_box.size = Vector3(0.06, 0.04, 0.24)
		notch.mesh = notch_box
		var notch_mat := StandardMaterial3D.new()
		notch_mat.albedo_color = Color(0.1, 0.15, 0.25)
		notch_mat.emission_enabled = true
		notch_mat.emission = Color(0.35, 0.6, 1.0)
		notch_mat.emission_energy_multiplier = 1.6
		notch.material_override = notch_mat
		notch.position = Vector3(0.0, 0.06, 0.2)
		own(notch, ring)
	var cover := slab(wall, "Slab", Vector3(0.12, 0.85, 0.9), Vector3(0.12, 0.425, 0.0), stone, false)
	solid(cover, "Body", Vector3(0.12, 0.85, 0.9), Vector3.ZERO)
	var niche_light := OmniLight3D.new()
	niche_light.name = "NicheLight"
	niche_light.position = Vector3(0.3, 0.35, 0.0)
	niche_light.light_color = Color(0.4, 0.65, 1.0)
	niche_light.light_energy = 1.2
	niche_light.omni_range = 2.5
	own(niche_light, wall)
	var grind := AudioStreamPlayer3D.new()
	grind.name = "Grind"
	grind.stream = load("res://assets/sounds/generated/rumble.wav")
	grind.volume_db = 2.0
	grind.pitch_scale = 1.6
	grind.bus = &"SFX"
	own(grind, wall)
	# the riddle (VN) while closed, a plain look once it is open
	interactable(wall, "WallRiddle", {
		"display_name": "Ściana ze znakami", "prompt_text": "Przyjrzyj się ścianie", "action": 1,
		"dialogue": load("res://dialogue/sciana.dialogue"), "dialogue_cue": "start",
		"hidden_by_flag": "wall_open", "highlight_target": glyphs, "solid": false, "padding": 0.1,
	})
	interactable(wall, "WallLook", {
		"display_name": "Ściana ze znakami", "required_flag": "wall_open", "highlight_target": glyphs, "solid": false, "padding": 0.1,
		"description": "Kręgi stoją tak, jak je ustawiłeś. Znaki przygasły, jakby ściana znowu zasnęła.",
	})
	# the niche: grandfather's letter and the crystal
	var letter := add(g, P + "Scroll_2.gltf", Vector3(16.9, y0 + 0.02, -0.2), 70.0, 1.2, "Letter")
	interactable(letter, "LetterPickup", {
		"display_name": "List dziadka", "required_flag": "wall_open", "remove_after_use": true, "padding": 0.12,
		"description": "List owinięty w natłuszczone płótno. Pismo dziadka, tym razem bez szyfru. Czytasz go przy świetle kryształu, dwa razy.\n\nPrzepisujesz każde słowo do notesu.",
		"on_use_flag": "read_letter", "on_use_note": &"list_dziadka", "on_use_quest": &"slady", "on_use_quest_entry": "list",
	})
	var crystal := MeshInstance3D.new()
	crystal.name = "Crystal"
	var prism := CylinderMesh.new()
	prism.top_radius = 0.0
	prism.bottom_radius = 0.05
	prism.height = 0.24
	prism.radial_segments = 6
	crystal.mesh = prism
	var crystal_mat := StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.6, 0.8, 1.0, 0.7)
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.35, 0.65, 1.0)
	crystal_mat.emission_energy_multiplier = 3.0
	crystal_mat.metallic = 0.2
	crystal_mat.roughness = 0.1
	crystal.material_override = crystal_mat
	crystal.position = Vector3(16.85, y0 + 0.14, 0.22)
	own(crystal, g)
	interactable(crystal, "CrystalPickup", {
		"display_name": "Kryształ", "required_flag": "wall_open", "remove_after_use": true, "padding": 0.1,
		"description": "Kryształ długości palca, przejrzysty, z błękitnym światłem w środku. Jest ciepły. Kiedy bierzesz go do ręki, amulet dziadka też robi się ciepły.",
		"on_use_item": "krysztal", "on_use_flag": "took_crystal",
	})
	light(g, "GlyphGlow", Vector3(15.0, y0 + 2.6, 0.0), Color(0.35, 0.6, 1.0), 1.6, 8.5, true, 0.3, 0.55, 1)

## What the old miners left in front of the wall: two stone altars with offerings, a bench.
func _chapel_props(g: Node3D, y0: float) -> void:
	for side in [-1.0, 1.0]:
		slab(g, "Altar", Vector3(0.8, 0.9, 1.4), Vector3(15.2, y0 + 0.45, 2.7 * side), rock)
	var top := y0 + 0.9
	add(g, P + "CandleStick.gltf", Vector3(15.1, top, -2.3), 0.0)
	add(g, P + "Candle_1.gltf", Vector3(15.3, top, -3.0), 0.0)
	add(g, P + "Chalice.gltf", Vector3(15.25, top, -2.6), 0.0)
	var book := add(g, P + "Book_Simplified_Single.gltf", Vector3(15.1, top, 2.4), 30.0, 1.0, "PrayerBook")
	look(book, "Modlitewnik", "Górniczy modlitewnik, spuchnięty od wilgoci. Na obrazkach zamiast świętych postacie bez twarzy, z gwiazdami zamiast oczu. Na marginesach dopiski różnymi rękami. Wszystkie o tym samym: żeby wrócić na górę.")
	add(g, P + "Mug.gltf", Vector3(15.35, top, 2.9), 0.0)
	var lamp := add(g, P + "Candle_2.gltf", Vector3(15.2, top, 3.15), 0.0, 1.0, "OilLamp")
	light(lamp, "Flame", Vector3(0.0, 0.25, 0.0), Color(1.0, 0.66, 0.35), 0.9, 4.0, false, 0.3, 8.0)
	look(lamp, "Lampka", "Mała lampka oliwna. Pali się. Knot przycięty, olej świeży. Ktoś tu bywa.", {"on_use_flag": "saw_lamp"})
	add(g, P + "Bench.gltf", Vector3(12.6, y0, 0.0), 90.0, 0.9, "PrayerBench")
	look(g.get_node("PrayerBench"), "Ławka", "Ławka z tych samych desek co stemple. Wytarta do połysku przez setki kolan i tyłków. Górnicy siadali tu przed szychtą.", {"solid": true})

#endregion

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
