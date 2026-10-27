extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_locations.gd
## (run gen_sanctin_textures.gd and import first).
## Generates res://scene/levels/locations.tscn: the expedition places reached from the map
## table and with [M] (spec 04_tresc/miejsca.md, "Miejsca wypraw"). Each is a closed space far away from the main
## level; travel places the player at its entry marker and the signpost opens the field map.
## Every place has spots "<Place>Spot1..4" for people met there (FieldSchedule).
## - Rzapie: the flooded bottom of the old shaft (Tekla's bundle, a vein, scratches on the wall),
## - Upadowa: the steep decline behind the broken supports, ending at the old collapse (a vein,
##   grandfather's mark, soot and barrel staves: the collapse was a charge),
## - Kaplica: the chapel below the east cave: the carved wall with the riddle (VN), the niche.
## task_05 adds ten simple places (a template: chamber or gallery, lights, a few props, looks,
## veins, pickups) further down the map: Wyrobisko, Pompy, Kuznia, Grota, Przekop, Zalany,
## Szyb, Kostnica, Szczelina, Galeria; and a hidden second vein (under flowstone, needs a
## pickaxe) in the sump, the decline and the chapel.
## WARNING: overwrites the scene. Edit this generator, not the scene.

const P := "res://assets/prop_pack/Exports/glTF/"
const K := "res://assets/props/kenney_survival/"
const M := "res://assets/LoafbrrAssets/MineAndCavesSet/scenes/"
const OUT := "res://scene/levels/locations.tscn"

const RZAPIE := Vector3(-60.0, 0.0, 70.0)
const UPADOWA := Vector3(-60.0, 0.0, 110.0)
const KAPLICA := Vector3(60.0, 0.0, 110.0)
const WYROBISKO := Vector3(-100.0, 0.0, 150.0)
const POMPY := Vector3(-50.0, 0.0, 150.0)
const GROTA := Vector3(0.0, 0.0, 150.0)
const KOSTNICA := Vector3(50.0, 0.0, 150.0)
const GALERIA := Vector3(100.0, 0.0, 150.0)
const KUZNIA := Vector3(-100.0, 0.0, 200.0)
const PRZEKOP := Vector3(-50.0, 0.0, 200.0)
const ZALANY := Vector3(0.0, 0.0, 200.0)
const SZCZELINA := Vector3(50.0, 0.0, 200.0)
const SZYB := Vector3(100.0, 0.0, 200.0)
## Veins that were in the demo before task_05 keep their entries in Racibor's quest.
const LEGACY_VEINS := ["rzapie", "upadowa", "kaplica"]
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
var crust_mat: StandardMaterial3D
var bone_mat: StandardMaterial3D

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
## `extra` overrides the interactable's properties (e.g. a pickaxe for a hidden vein).
func vein_mark(parent: Node, rock_node: Node3D, vein_id: String, description: String, stake_pos: Vector3, extra := {}, stake_parent: Node = null) -> void:
	var legacy := vein_id in LEGACY_VEINS
	var props := {
		"display_name": "Żyła błękitnego żelaza", "prompt_text": "Zaznacz żyłę na mapie",
		"description": description, "time_cost_hours": 1.0, "time_reason": "Znaczenie żyły",
		"on_use_flag": "vein_" + vein_id, "hidden_by_flag": "vein_" + vein_id,
		"highlight_target": rock_node, "solid": false, "padding": 0.1,
	}
	if legacy:
		props.merge({"on_use_quest": &"zloza", "on_use_quest_entry": vein_id, "quest_only_if_active": true}, true)
	props.merge(extra, true)
	interactable(parent, "VeinMark" if legacy else "VeinMark_" + vein_id, props)
	var stakes := Node3D.new()
	stakes.name = "Stake" if legacy else "Stake_" + vein_id
	stakes.set_script(load("res://script/material_applier.gd"))
	stakes.set("material", wood)
	own(stakes, stake_parent if stake_parent else parent)
	var stake := add(stakes, K + "signpost-single.glb", stake_pos, randf() * 360.0, 1.6, "VeinStake")
	look(stake, "Twój palik", "Tu zaznaczyłeś żyłę dla Racibora. Na palu wyciąłeś nożem kreskę.", {"required_flag": "vein_" + vein_id})

func exit_sign(parent: Node, place_id: String, pos: Vector3, yaw_deg: float, _hours := 0) -> void:
	var signs := Node3D.new()
	signs.name = "Sign"
	signs.set_script(load("res://script/material_applier.gd"))
	signs.set("material", wood)
	own(signs, parent)
	var post := add(signs, K + "signpost-single.glb", pos, yaw_deg, 3.2, "ExitSign")
	interactable(post, "%sExitUse" % place_id.capitalize(), {"display_name": "Drogowskaz", "prompt_text": "Dokąd dalej? (albo [M])", "action": 2})

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
	crust_mat = StandardMaterial3D.new()
	crust_mat.albedo_color = Color(0.5, 0.49, 0.45)
	crust_mat.roughness = 1.0
	bone_mat = StandardMaterial3D.new()
	bone_mat.albedo_color = Color(0.72, 0.68, 0.58)
	bone_mat.roughness = 0.9
	_rzapie()
	_upadowa()
	_kaplica()
	_wyrobisko()
	_pompy()
	_grota()
	_kostnica()
	_galeria()
	_kuznia()
	_przekop()
	_zalany()
	_szczelina()
	_szyb()
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
	look(tally, "Kreski na skale", "Ktoś wydrapał w skale kreski, grupami po pięć. Czternaście. Pod spodem zaczęte słowo, może imię. Urywa się po trzech literach.", {
		"padding": 0.12, "on_use_flag": "saw_marks_rzapie", "on_use_quest": &"czternasty", "on_use_quest_entry": "kreski_rzapie"})
	# the vein for Racibor
	var veins := vein_group(g, "Vein")
	var vein_rock := add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_c.tscn", Vector3(3.3, 1.2, -3.85), 0.0, 1.2)
	add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_e.tscn", Vector3(4.6, 0.6, -3.9), 0.0, 0.9)
	blue_light(g, Vector3(3.7, 1.6, -2.3), 1.2, 5.5)
	vein_mark(g, vein_rock, "rzapie", "Wąska żyła biegnie ukosem przez skałę i znika pod wodą. Odmierzasz ją krokami i wrysowujesz na mapę dla Racibora.", Vector3(2.9, 0.0, -3.3))
	light(g, "LandingGlow", Vector3(7.6, 1.4, 0.0), Color(0.7, 0.78, 0.9), 0.7, 5.0, false, 0.05, 0.5)
	hidden_vein(g, "rzapie_2", "c", Vector3(5.6, 1.3, 3.9), 180.0, "Odłupujesz naciek kawałek po kawałku. Pod spodem błękit, czysty i gruby na dwa palce. Stara ekipa musiała tu stać tysiąc razy i nic nie widziała.", Vector3(5.3, 0.0, 3.1))
	spots("rzapie", RZAPIE, [Vector3(3.0, 0.0, -2.3), Vector3(2.4, 0.0, 2.5), Vector3(4.8, 0.0, -2.8), Vector3(4.4, 0.0, 2.9)])
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
	hidden_vein(g, "upadowa_2", "d", Vector3(18.2, bottom + 1.2, -2.05), 0.0, "Pod białym naciekiem druga żyła, cieńsza, ale długa. Biegnie w stronę zawału, jak wszystko tutaj.", Vector3(18.4, bottom, -1.3))
	spots("upadowa", UPADOWA, [Vector3(3.8, 0.0, -1.5), Vector3(3.6, 0.0, 1.5), Vector3(6.0, _slope_y(6.0), -1.3), Vector3(6.4, _slope_y(6.4), 1.2)])
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
	hidden_vein(g, "kaplica_2", "e", Vector3(13.3, y0 + 1.3, -4.95), 0.0, "Naciek odpada płatami. Pod nim błękit tak jasny, że na chwilę zamykasz oczy. Ktoś ten naciek kiedyś wygładził ręką, jakby chciał coś zakryć.", Vector3(13.2, y0, -4.2))
	spots("kaplica", KAPLICA, [Vector3(8.8, y0, -2.6), Vector3(8.8, y0, 2.6), Vector3(10.4, y0, -3.4), Vector3(10.4, y0, 3.4)])
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
	look(lamp, "Lampka", "Mała lampka oliwna. Pali się. Knot przycięty, olej świeży. Ktoś tu bywa.", {
		"on_use_flag": "saw_lamp", "on_use_quest": &"czternasty", "on_use_quest_entry": "lampka", "quest_only_if_active": true})
	add(g, P + "Bench.gltf", Vector3(12.6, y0, 0.0), 90.0, 0.9, "PrayerBench")
	look(g.get_node("PrayerBench"), "Ławka", "Ławka z tych samych desek co stemple. Wytarta do połysku przez setki kolan i tyłków. Górnicy siadali tu przed szychtą.", {"solid": true})

#endregion

#region task_05: helpers for the simple places

## Entry from the west: a short tunnel stub with a lantern, the signpost (field map) and the
## entry marker. The chamber's west wall leaves a 2.4 m opening at z -1.2..1.2 for it.
func stub(g: Node3D, place_id: String, origin: Vector3, lamp := true) -> void:
	var tunnel := group(g, "Tunnel")
	slab(tunnel, "Floor", Vector3(3.8, 0.4, 2.6), Vector3(-1.9, -0.2, 0.0), floor_mat)
	slab(tunnel, "WallN", Vector3(3.8, 3.6, 0.4), Vector3(-1.9, 1.6, -1.4), rock)
	slab(tunnel, "WallS", Vector3(3.8, 3.6, 0.4), Vector3(-1.9, 1.6, 1.4), rock)
	slab(tunnel, "Ceiling", Vector3(3.8, 0.4, 3.2), Vector3(-1.9, 3.3, 0.0), rock)
	slab(tunnel, "End", Vector3(0.4, 3.6, 2.8), Vector3(-3.8, 1.6, 0.0), rock)
	for r in [["a", Vector3(-3.3, 0.3, -0.6), 1.0], ["c", Vector3(-3.4, 0.3, 0.7), 0.9]]:
		add(tunnel, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[0], r[1], randf() * 360.0, r[2])
	add(tunnel, M + "Posts/post_f.tscn", Vector3(-0.35, 0.0, -1.1), 0.0)
	add(tunnel, M + "Posts/post_f.tscn", Vector3(-0.35, 0.0, 1.1), 180.0)
	if lamp:
		lantern(tunnel, Vector3(-1.7, 2.05, 1.2), 180.0, 1.1, 6.0)
	exit_sign(g, place_id, Vector3(-1.2, 0.0, -0.95), 90.0)
	marker("%sEntry" % place_id.capitalize(), origin + Vector3(-2.3, 0.0, 0.0), -90.0)

## A plain rock chamber x 0..w, z -d/2..d/2, h high, open to the west for the stub.
func chamber(g: Node3D, w: float, d: float, h: float) -> void:
	slab(g, "Floor", Vector3(w + 0.4, 0.4, d + 0.4), Vector3(w * 0.5, -0.2, 0.0), floor_mat)
	slab(g, "WallNorth", Vector3(w + 0.8, h + 0.6, 0.4), Vector3(w * 0.5, h * 0.5, -d * 0.5 - 0.2), rock)
	slab(g, "WallSouth", Vector3(w + 0.8, h + 0.6, 0.4), Vector3(w * 0.5, h * 0.5, d * 0.5 + 0.2), rock)
	slab(g, "WallEast", Vector3(0.4, h + 0.6, d + 0.8), Vector3(w + 0.2, h * 0.5, 0.0), rock)
	var side := (d - 2.4) * 0.5
	if side > 0.01:
		slab(g, "WallWestN", Vector3(0.4, h + 0.6, side), Vector3(-0.2, h * 0.5, -1.2 - side * 0.5), rock)
		slab(g, "WallWestS", Vector3(0.4, h + 0.6, side), Vector3(-0.2, h * 0.5, 1.2 + side * 0.5), rock)
	if h > 3.3:
		slab(g, "WallWestTop", Vector3(0.4, h - 3.1, 2.4), Vector3(-0.2, 3.1 + (h - 3.1) * 0.5, 0.0), rock)
	slab(g, "Ceiling", Vector3(w + 0.8, 0.4, d + 0.8), Vector3(w * 0.5, h + 0.2, 0.0), rock, false)

## Relief on the walls: [piece, local position, yaw, scale].
func reliefs(g: Node3D, list: Array) -> void:
	for r in list:
		add(g, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % r[0], r[1], r[2], r[3])

## Loose rocks on the floor: [piece, local position, scale].
func rubble(g: Node3D, list: Array) -> void:
	for r in list:
		add(g, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[0], r[1], randf() * 360.0, r[2])

## Timber frames across a gallery (posts at ±half_width, a beam on top).
func frames(g: Node3D, xs: Array, half_width: float, beam_y := 3.75) -> Node3D:
	var f := group(g, "Frames")
	for x in xs:
		add(f, M + "Posts/post_f.tscn", Vector3(x, 0.0, -half_width), 0.0)
		add(f, M + "Posts/post_f.tscn", Vector3(x, 0.0, half_width), 180.0)
		add(f, M + "Posts/beam_a.tscn", Vector3(x, beam_y, 0.0), 90.0)
	return f

## A vein: a glowing wall rock, a blue light in front of it and the mark with its stake.
## The rock faces +Z at yaw 0 (north wall), -X at yaw -90 (east wall), -Z at 180 (south wall).
func vein(g: Node3D, vein_id: String, piece: String, pos: Vector3, yaw: float, text: String, stake_pos: Vector3, rock_scale := 1.2, extra := {}) -> Node3D:
	var veins := vein_group(g, "Vein_" + vein_id)
	var rock_node := add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % piece, pos, yaw, rock_scale)
	var normal := Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3.BACK
	blue_light(g, pos + normal * 1.3 + Vector3(0.0, 0.3, 0.0), 1.6, 6.0)
	vein_mark(g, rock_node, vein_id, text, stake_pos, extra)
	return rock_node

## A vein under white flowstone: a pickaxe opens it; the crust is gone once the vein is marked.
func hidden_vein(g: Node3D, vein_id: String, piece: String, pos: Vector3, yaw: float, text: String, stake_pos: Vector3) -> void:
	var veins := vein_group(g, "Vein_" + vein_id)
	add(veins, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % piece, pos, yaw, 1.0)
	var normal := Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3.BACK
	var crust := Node3D.new()
	crust.name = "Crust_" + vein_id
	crust.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), pos + normal * 0.28)
	own(crust, g)
	for c in [[Vector3(1.1, 0.9, 0.28), Vector3(0.0, 0.1, 0.0), 8.0], [Vector3(0.8, 0.7, 0.24), Vector3(-0.35, -0.4, 0.04), -14.0],
			[Vector3(0.6, 0.8, 0.22), Vector3(0.4, -0.35, 0.06), 22.0], [Vector3(0.35, 0.6, 0.18), Vector3(0.1, -0.9, 0.08), -5.0]]:
		slab(crust, "Flowstone", c[0], c[1], crust_mat, false, Basis(Vector3.BACK, deg_to_rad(c[2])))
	light(g, "FaintBlue_" + vein_id, pos + normal * 0.12 + Vector3(0.0, -0.2, 0.0), Color(0.35, 0.6, 1.0), 0.6, 2.2, false, 0.3, 0.7, 1)
	vein_mark(crust, crust, vein_id, text, stake_pos, {
		"display_name": "Biały naciek", "prompt_text": "Odkuj naciek i zaznacz żyłę", "time_cost_hours": 2.0,
		"time_reason": "Odkuwanie nacieku", "required_item": "kilof",
		"missing_text": "Spod białego nacieku sączy się niebieskie światło. Gołymi rękami się do tego nie dobierzesz, potrzebny kilof.",
	}, g)

## A prop that can be taken (disappears when used; its flag remembers it).
func pickup(g: Node3D, prop: String, pos: Vector3, yaw: float, prop_scale: float, node_name: String, props: Dictionary) -> Node3D:
	var n := add(g, prop, pos, yaw, prop_scale, node_name)
	pickup_on(n, node_name, props)
	return n

func pickup_on(n: Node3D, node_name: String, props: Dictionary) -> void:
	var all := {"remove_after_use": true, "padding": 0.12}
	all.merge(props, true)
	interactable(n, node_name + "Pickup", all)

## Where people met here stand ("<Place>Spot1..n", facing the entry) and where a miner works
## ("<Place>Work", with its own facing).
func spots(place_id: String, origin: Vector3, list: Array, work := []) -> void:
	for i in list.size():
		marker("%sSpot%d" % [place_id.capitalize(), i + 1], origin + list[i], -90.0)
	if work.size() == 2:
		marker("%sWork" % place_id.capitalize(), origin + work[0], work[1])

## A mesh node (not a prop scene): a primitive with its material.
func mesh(parent: Node, node_name: String, primitive: PrimitiveMesh, pos: Vector3, material: Material, basis := Basis.IDENTITY) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = primitive
	mi.material_override = material
	mi.transform = Transform3D(basis, pos)
	own(mi, parent)
	return mi

func glow_material(albedo: Color, emission: Color, energy: float, alpha := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(albedo, alpha)
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.emission_enabled = true
	m.emission = emission
	m.emission_energy_multiplier = energy
	m.roughness = 0.3
	return m

## A crystal prism of blue iron (emissive), standing or leaning.
func crystal_prism(parent: Node, node_name: String, pos: Vector3, height: float, tilt_deg: float, yaw_deg: float) -> MeshInstance3D:
	var prism := CylinderMesh.new()
	prism.top_radius = 0.0
	prism.bottom_radius = height * 0.16
	prism.height = height
	prism.radial_segments = 6
	var basis := Basis(Vector3.UP, deg_to_rad(yaw_deg)) * Basis(Vector3.RIGHT, deg_to_rad(tilt_deg))
	return mesh(parent, node_name, prism, pos + basis * Vector3(0.0, height * 0.5, 0.0), glow_material(Color(0.55, 0.78, 1.0), Color(0.3, 0.6, 1.0), 2.4, 0.8), basis)

## A glowing mushroom: a stem and a flat cap.
func mushroom(parent: Node, node_name: String, pos: Vector3, size: float, material: Material) -> Node3D:
	var m := Node3D.new()
	m.name = node_name
	m.position = pos
	own(m, parent)
	var stem := CylinderMesh.new()
	stem.top_radius = 0.035 * size
	stem.bottom_radius = 0.05 * size
	stem.height = 0.3 * size
	mesh(m, "Stem", stem, Vector3(0.0, 0.15 * size, 0.0), material)
	var cap := SphereMesh.new()
	cap.radius = 0.16 * size
	cap.height = 0.12 * size
	mesh(m, "Cap", cap, Vector3(0.0, 0.3 * size, 0.0), material)
	return m

## A skull from primitives: a pale dome with two dark sockets.
func skull(parent: Node, pos: Vector3, yaw_deg: float) -> void:
	var s := Node3D.new()
	s.name = "Skull"
	s.transform = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw_deg)), pos)
	own(s, parent)
	var head := SphereMesh.new()
	head.radius = 0.1
	head.height = 0.19
	mesh(s, "Head", head, Vector3(0.0, 0.095, 0.0), bone_mat)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.03, 0.03, 0.03)
	for side in [-1.0, 1.0]:
		var eye := SphereMesh.new()
		eye.radius = 0.026
		eye.height = 0.052
		mesh(s, "Eye", eye, Vector3(0.037 * side, 0.1, 0.082), dark)

## Steam rising from a crack (CPU particles, soft white quads).
func steam(parent: Node, node_name: String, pos: Vector3) -> void:
	var p := CPUParticles3D.new()
	p.name = node_name
	p.position = pos
	p.amount = 24
	p.lifetime = 2.6
	p.direction = Vector3.UP
	p.spread = 12.0
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 1.1
	p.gravity = Vector3(0.0, 0.25, 0.0)
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.2
	var quad := QuadMesh.new()
	quad.size = Vector2(0.7, 0.7)
	var m := StandardMaterial3D.new()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.albedo_color = Color(0.85, 0.85, 0.82, 0.16)
	var tex := GradientTexture2D.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	m.albedo_texture = tex
	quad.material = m
	p.mesh = quad
	own(p, parent)

## Flat water over a floor (visual only), reusing the sump's shader.
func water(parent: Node, node_name: String, size: Vector2, pos: Vector3) -> void:
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
		noise.seed = 5 if key == "ripples_a" else 11
		noise_tex.noise = noise
		water_mat.set_shader_parameter(key, noise_tex)
	var plane := PlaneMesh.new()
	plane.size = size
	mesh(parent, node_name, plane, pos, water_mat)

#endregion

#region task_05: the ten simple places

## Stare wyrobisko: a wide, low working held up by rock pillars; an overturned cart; Wszebor
## works here by day. The pickaxe head for him lies in the rubble.
func _wyrobisko() -> void:
	var g := group(root3d, "Wyrobisko", WYROBISKO)
	chamber(g, 14.0, 10.0, 3.4)
	stub(g, "wyrobisko", WYROBISKO)
	for pl in [["a", Vector3(4.6, 0.0, -1.9)], ["b", Vector3(8.2, 0.0, 2.1)], ["c", Vector3(10.6, 0.0, -2.3)]]:
		add(g, M + "Rocks/Cave_Rocks/cave_pillar_%s.tscn" % pl[0], pl[1], randf() * 360.0, 1.0, "Pillar_" + pl[0])
	look(g.get_node("Pillar_a"), "Filar", "Filar zostawiony przez starą ekipę, żeby trzymał strop. Ktoś wyrył na nim rząd kresek. Czternaście. Tyle dni tu kopali. Albo tylu ich tu zostało.", {
		"padding": 0.1, "on_use_flag": "saw_marks_pillar", "on_use_quest": &"czternasty", "on_use_quest_entry": "kreski_filar"})
	# After the night-5 tremor the middle pillar splits (Faza 2: the world shows the quake).
	interactable(g.get_node("Pillar_b"), "TremorLook", {
		"display_name": "Pęknięty filar", "required_flag": "tremor_seen",
		"description": "Po nocnym wstrząsie przez filar biegnie świeże pęknięcie, szerokie na palec. Sypie się z niego miałki pył, równo, jakby filar oddychał. Strop trzyma się już chyba tylko z przyzwyczajenia.",
		"on_use_flag": "saw_cracked_pillar", "sanity_change": -2, "sanity_reason": "Strop wisi ci nad głową", "padding": 0.12})
	reliefs(g, [["a", Vector3(2.0, 1.1, -4.9), 0.0, 1.1], ["g", Vector3(11.5, 1.2, -4.9), 0.0, 1.0], ["b", Vector3(13.9, 1.2, -3.0), -90.0, 1.1],
		["e", Vector3(3.5, 1.0, 4.9), 180.0, 1.1], ["f", Vector3(9.8, 1.2, 4.9), 180.0, 1.0]])
	rubble(g, [["b", Vector3(12.2, 0.2, 3.9), 1.1], ["d", Vector3(1.6, 0.2, 3.6), 0.9], ["a", Vector3(6.0, 0.15, -4.0), 0.8]])
	add(g, M + "Mine_Rails/rail_a.tscn", Vector3(9.0, 0.02, 3.2), 90.0)
	add(g, M + "Mine_Rails/rail_end.tscn", Vector3(12.4, 0.02, 3.2), 90.0)
	var cart := add(g, M + "Mine_Carts/mine_cart_aa.tscn", Vector3(11.4, 0.45, 3.1), 70.0, 1.0, "OverturnedCart")
	cart.rotate_object_local(Vector3.FORWARD, deg_to_rad(80.0))
	look(cart, "Wywrócony wózek", "Wózek bez jednego koła, na boku. Ktoś go tu zostawił w pośpiechu, z urobkiem w środku. Urobek potem ktoś wybrał. Co do kamienia.", {"padding": 0.1})
	var head := pickup(g, P + "Pickaxe_Bronze.gltf", Vector3(10.3, 0.05, 4.2), 0.0, 1.0, "PickHead", {
		"display_name": "Kilof w gruzie",
		"description": "W gruzie pod wózkiem leży kilof. Trzonek zbutwiał i rozpada się w palcach, ale obuch jest cały. Stal dobra, hawiarska. Wszebor by się ucieszył.\n\nZabierasz obuch.",
		"on_use_item": "obuch", "on_use_flag": "took_obuch", "on_use_quest": &"kilof", "on_use_quest_entry": "znaleziony", "quest_only_if_active": true,
	})
	head.basis = Basis(Vector3.UP, 0.7) * Basis(Vector3.RIGHT, PI / 2)
	vein(g, "wyrobisko_1", "c", Vector3(7.0, 1.3, -4.9), 0.0, "Stara ekipa kopała tuż obok i jej nie zauważyła. Błękit przebija spod kurzu dopiero, kiedy przetrzesz skałę rękawem. Zaznaczasz ją na mapie.", Vector3(6.6, 0.0, -4.0))
	vein(g, "wyrobisko_2", "e", Vector3(13.9, 1.2, 1.5), -90.0, "Żyła wchodzi w ścianę, na której opiera się strop. Kto ją kiedyś wybierze, pójdzie razem ze stropem. Zaznaczasz ją z dopiskiem: ostrożnie.", Vector3(13.0, 0.0, 2.3))
	light(g, "Glow", Vector3(6.5, 2.6, 0.0), Color(1.0, 0.62, 0.32), 0.55, 9.0, true, 0.1, 3.0)
	spots("wyrobisko", WYROBISKO, [Vector3(3.2, 0.0, -2.6), Vector3(3.0, 0.0, 2.4), Vector3(5.8, 0.0, 0.2), Vector3(6.2, 0.0, 3.2)], [Vector3(9.5, 0.0, -3.9), 180.0])
	emitter(g, "Drip", "drip", Vector3(8.0, 3.0, -1.0), 3.0, 9.0, -7.0, 16.0, 0.25)
	emitter(g, "Creak", "creak", Vector3(5.0, 3.0, 2.0), 14.0, 30.0, -8.0, 20.0, 0.12)

## Komora pomp: the old crew's pump under the sump. It needs oil and someone who knows pumps
## (Nasir); once it runs, the flooded gallery below can be reached.
func _pompy() -> void:
	var g := group(root3d, "Pompy", POMPY)
	chamber(g, 11.0, 9.0, 5.0)
	stub(g, "pompy", POMPY)
	reliefs(g, [["d", Vector3(2.4, 1.2, -4.4), 0.0, 1.1], ["f", Vector3(10.9, 1.3, -1.2), -90.0, 1.0], ["a", Vector3(4.0, 1.1, 4.4), 180.0, 1.0]])
	# the pump: a wooden wheel between two posts, a pipe up to the sump, a trough of water
	var pump := group(g, "Pump", Vector3(7.2, 0.0, -2.9))
	add(pump, M + "Posts/post_reinforced_a.tscn", Vector3(-0.9, 0.0, 0.0), 0.0)
	add(pump, M + "Posts/post_reinforced_a.tscn", Vector3(0.9, 0.0, 0.0), 0.0)
	var wheel := CylinderMesh.new()
	wheel.top_radius = 1.1
	wheel.bottom_radius = 1.1
	wheel.height = 0.22
	wheel.radial_segments = 24
	var wheel_node := mesh(pump, "Wheel", wheel, Vector3(0.0, 1.6, 0.0), wood, Basis(Vector3.RIGHT, PI / 2))
	var axle := CylinderMesh.new()
	axle.top_radius = 0.08
	axle.bottom_radius = 0.08
	axle.height = 2.0
	mesh(pump, "Axle", axle, Vector3(0.0, 1.6, 0.0), wood, Basis(Vector3.BACK, PI / 2))
	var pipe := CylinderMesh.new()
	pipe.top_radius = 0.13
	pipe.bottom_radius = 0.13
	pipe.height = 5.0
	mesh(g, "Pipe", pipe, Vector3(8.6, 2.5, -3.9), wood)
	solid(pump, "Block", Vector3(2.2, 3.0, 0.8), Vector3(0.0, 1.5, 0.0))
	look(wheel_node, "Pompa", "Koło zablokowane, skórzane uszczelki spękały na wiór. Bez smaru i kogoś, kto zna się na pompach, ani drgnie. Nasir by wiedział, od czego zacząć.", {"hidden_by_flag": "pump_running", "padding": 0.15})
	interactable(wheel_node, "LookRunning", {"display_name": "Pompa", "required_flag": "pump_running", "solid": false, "padding": 0.15,
		"description": "Pompa skrzypi i sapie, ale chodzi. W rurze chlupie woda, a z dołu, z zalanego chodnika, dochodzi bulgotanie."})
	slab(g, "Trough", Vector3(8.0, 0.3, 1.2), Vector3(5.5, 0.15, 3.6), wood)
	water(g, "TroughWater", Vector2(7.8, 1.0), Vector3(5.5, 0.32, 3.6))
	pickup(g, P + "Bucket_Metal.gltf", Vector3(9.6, 0.0, -3.4), 20.0, 0.9, "OilCan", {
		"display_name": "Bańka pod pompą",
		"description": "Blaszana bańka, szczelnie zamknięta. W środku gęsty olej, którym smarowano tłoki. Do lampy też się nada. Albo do pompy, jeśli ktoś umie.",
		"on_use_item": "olej", "on_use_flag": "took_pump_oil",
	})
	vein(g, "pompy_1", "b", Vector3(10.9, 1.4, 2.0), -90.0, "Żyła tuż nad lustrem wody w korycie. Woda jest przez nią lekko niebieska, jakby ktoś wrzucił do niej kawałek nieba. Zaznaczasz ją.", Vector3(10.0, 0.0, 1.6))
	lantern(g, Vector3(0.6, 1.6, -4.3), 0.0, 0.9, 6.0)
	light(g, "PumpLight", Vector3(5.6, 2.9, -1.6), Color(1.0, 0.62, 0.32), 0.9, 7.5, true, 0.12, 4.0)
	spots("pompy", POMPY, [Vector3(3.0, 0.0, -2.0), Vector3(3.2, 0.0, 2.0), Vector3(5.0, 0.0, 0.4), Vector3(5.8, 0.0, 1.8)], [Vector3(6.3, 0.0, -1.7), 145.0])
	emitter(g, "Drip", "drip", Vector3(7.0, 4.5, 3.0), 2.0, 6.0, -5.0, 16.0, 0.3)
	emitter(g, "Creak", "creak", Vector3(7.2, 2.0, -2.9), 18.0, 40.0, -9.0, 16.0, 0.1)

## Grzybowa grota: a cave full of glowing fungi. The spores make your head swim; Anzelm can
## brew medicine from the mushrooms and Hagiwara wants to see one.
func _grota() -> void:
	var g := group(root3d, "Grota", GROTA)
	chamber(g, 12.0, 12.0, 5.5)
	stub(g, "grota", GROTA)
	reliefs(g, [["a", Vector3(2.2, 1.0, -5.9), 0.0, 1.3], ["g", Vector3(9.4, 1.2, -5.9), 0.0, 1.2], ["b", Vector3(11.9, 1.1, -3.4), -90.0, 1.3],
		["e", Vector3(3.2, 1.1, 5.9), 180.0, 1.3], ["c", Vector3(7.4, 1.3, 5.9), 180.0, 1.1], ["f", Vector3(11.9, 1.2, 4.6), -90.0, 1.1]])
	for pl in [["b", Vector3(6.5, 0.0, 1.2)], ["a", Vector3(9.0, 0.0, -2.6)]]:
		add(g, M + "Rocks/Cave_Rocks/cave_pillar_%s.tscn" % pl[0], pl[1], randf() * 360.0, 1.1)
	rubble(g, [["c", Vector3(2.6, 0.2, 4.0), 1.2], ["a", Vector3(10.4, 0.2, 2.8), 1.0], ["d", Vector3(4.2, 0.2, -3.8), 0.9]])
	var spore := glow_material(Color(0.55, 0.85, 0.8), Color(0.25, 0.9, 0.75), 2.2)
	var clusters := group(g, "Fungi")
	var centres := [Vector3(3.8, 0.0, -4.4), Vector3(8.4, 0.0, 4.6), Vector3(10.6, 0.0, -0.6), Vector3(5.6, 0.0, 3.6)]
	for c in centres.size():
		var cluster := group(clusters, "Cluster%d" % c)
		for i in 6:
			var offset := Vector3(randf_range(-0.7, 0.7), 0.0, randf_range(-0.5, 0.5))
			mushroom(cluster, "Mushroom%d" % i, centres[c] + offset, randf_range(0.7, 1.6), spore)
		light(g, "SporeLight%d" % c, centres[c] + Vector3(0.0, 0.7, 0.0), Color(0.3, 0.95, 0.8), 1.1, 4.5, false, 0.3, 0.6, 1)
	look(clusters.get_child(0), "Grzyby", "Z bliska kapelusze pulsują w rytm, którego nie słyszysz, ale czujesz w zębach. Kręci ci się w głowie. Lepiej nie wdychać tego za długo.", {
		"on_use_flag": "saw_fungi", "sanity_change": -4, "sanity_reason": "Zarodniki", "padding": 0.2})
	var one := mushroom(g, "BigMushroom1", Vector3(2.4, 0.0, -1.8), 2.0, spore)
	pickup_on(one, "Mushroom1", {"display_name": "Świecący grzyb", "on_use_item": "grzyb", "on_use_flag": "took_mushroom_1",
		"description": "Grzyb wielkości pięści, blady, z niebieską poświatą pod kapeluszem. Pachnie słodko, jak zepsute jabłka. Odcinasz go nożem i owijasz w chustę."})
	var two := mushroom(g, "BigMushroom2", Vector3(9.8, 0.0, 2.2), 2.1, spore)
	pickup_on(two, "Mushroom2", {"display_name": "Świecący grzyb", "on_use_item": "grzyb", "on_use_flag": "took_mushroom_2",
		"description": "Drugi taki sam, tylko większy. Przez chwilę masz wrażenie, że odsuwa się od noża. Tylko wrażenie."})
	vein(g, "grota_1", "d", Vector3(5.6, 1.5, -5.9), 0.0, "Żyła przerasta grzybnię albo grzybnia przerasta żyłę. Trudno powiedzieć, co tu rosło pierwsze. Zaznaczasz ją.", Vector3(5.8, 0.0, -5.0))
	vein(g, "grota_2", "f", Vector3(11.9, 1.3, 1.2), -90.0, "Pod grzybami ściana świeci równo i spokojnie. Grzyby rosną tylko tam, gdzie błękitu jest najwięcej. Wrysowujesz ją na mapę.", Vector3(11.0, 0.0, 0.4))
	spots("grota", GROTA, [Vector3(3.0, 0.0, 0.4), Vector3(4.2, 0.0, -1.9), Vector3(4.6, 0.0, 1.9), Vector3(6.0, 0.0, -0.5)])
	emitter(g, "Drip", "drip", Vector3(6.0, 5.0, 0.0), 2.5, 7.0, -5.0, 18.0, 0.35)
	emitter(g, "Hum", "rumble", Vector3(10.0, 1.0, 0.0), 25.0, 55.0, -10.0, 22.0, 0.4)

## Kostnica: the old crew's dead in wall niches, candles that someone keeps lit, fresh bread.
func _kostnica() -> void:
	var g := group(root3d, "Kostnica", KOSTNICA)
	chamber(g, 10.0, 8.0, 3.6)
	stub(g, "kostnica", KOSTNICA)
	var niches := group(g, "Niches")
	for side in [-1.0, 1.0]:
		for i in 4:
			var x := 2.0 + i * 2.1
			var z: float = 3.75 * side
			var shelf := group(niches, "Niche%d%s" % [i, "S" if side > 0 else "N"])
			slab(shelf, "Shelf", Vector3(1.4, 0.12, 0.5), Vector3(x, 1.0, z), rock, false)
			slab(shelf, "ShelfHigh", Vector3(1.4, 0.12, 0.5), Vector3(x, 1.9, z), rock, false)
			skull(shelf, Vector3(x - 0.3, 1.06, z), 180.0 if side > 0 else 0.0)
			skull(shelf, Vector3(x + 0.35, 1.96, z), 180.0 if side > 0 else 0.0)
	for c in [Vector3(3.0, 0.0, -3.1), Vector3(7.1, 0.0, -3.1), Vector3(5.0, 0.0, 3.1)]:
		var floor_candle := add(niches, P + "Candle_2.gltf", c, 0.0)
		light(floor_candle, "Flame", Vector3(0.0, 0.25, 0.0), Color(1.0, 0.64, 0.33), 0.9, 4.5, false, 0.3, 8.0)
	look(niches.get_child(1), "Nisze z czaszkami", "Stara ekipa chowała tu swoich. Pod każdą czaszką wydrapane imię. Dwóch Grabców. Trzech Wojsławów. Jedna nisza jest pusta i podpisana, ale imienia nie umiesz przeczytać, choć litery są wyraźne.", {
		"on_use_quest": &"czternasty", "on_use_quest_entry": "nisza", "quest_only_if_active": true,
		"on_use_flag": "saw_niches", "sanity_change": -2, "sanity_reason": "Czaszki", "padding": 0.2})
	# the altar with bread and candles that someone keeps lit
	slab(g, "Altar", Vector3(0.8, 0.8, 1.6), Vector3(8.6, 0.4, 0.0), rock)
	var loaf := SphereMesh.new()
	loaf.radius = 0.16
	loaf.height = 0.18
	var bread_mat := StandardMaterial3D.new()
	bread_mat.albedo_color = Color(0.55, 0.36, 0.18)
	bread_mat.roughness = 0.9
	var bread := mesh(g, "Bread", loaf, Vector3(8.6, 0.88, -0.4), bread_mat)
	look(bread, "Chleb", "Bochenek chleba. Świeży, jeszcze pachnie. Tak w Jaksarze karmi się zmarłych w Święto Przodków, tylko że do Święta Przodków daleko. Ktoś tu schodzi. Regularnie.", {
		"on_use_quest": &"czternasty", "on_use_quest_entry": "chleb", "quest_only_if_active": true,
		"on_use_flag": "saw_bread", "sanity_change": -3, "sanity_reason": "Ktoś tu bywa", "padding": 0.12})
	for c in [Vector3(8.4, 0.8, 0.5), Vector3(8.8, 0.8, 0.6)]:
		var stick := add(g, P + "CandleStick.gltf", c, 0.0)
		light(stick, "Flame", Vector3(0.0, 0.3, 0.0), Color(1.0, 0.66, 0.35), 0.7, 4.0, false, 0.3, 8.0)
	pickup(g, P + "Candle_1.gltf", Vector3(8.7, 0.8, -0.1), 0.0, 1.0, "Candles", {
		"display_name": "Nowe świece",
		"description": "Dwie łojowe świece, jeszcze nie zapalone, zostawione przy chlebie. Bierzesz je. Zmarłym wystarczą te, które już płoną. Chyba.",
		"on_use_item": "swieca:2", "on_use_flag": "took_ossuary_candles", "sanity_change": -2, "sanity_reason": "Zabierasz zmarłym świece",
	})
	vein(g, "kostnica_1", "a", Vector3(9.9, 1.4, -2.2), -90.0, "Za ołtarzem, w ścianie, żyła. Czaszki patrzą na nią ze wszystkich nisz, jakby jej pilnowały. Zaznaczasz ją szybko.", Vector3(9.1, 0.0, -2.8))
	spots("kostnica", KOSTNICA, [Vector3(2.8, 0.0, -1.6), Vector3(2.8, 0.0, 1.6), Vector3(4.8, 0.0, -2.0), Vector3(4.8, 0.0, 2.0)])
	emitter(g, "Drip", "drip", Vector3(5.0, 3.2, 0.0), 4.0, 11.0, -8.0, 14.0, 0.2)

## Kryształowa galeria: the deepest place on the map, walls of blue iron and crystal columns.
## No lanterns here: you need oil for your own lamp to get this far.
func _galeria() -> void:
	var g := group(root3d, "Galeria", GALERIA)
	chamber(g, 16.0, 12.0, 7.0)
	stub(g, "galeria", GALERIA, false)
	var walls := vein_group(g, "BlueWalls")
	for r in [["a", Vector3(2.5, 1.4, -5.9), 0.0, 1.4], ["g", Vector3(9.0, 2.2, -5.9), 0.0, 1.5], ["b", Vector3(15.9, 1.6, -4.0), -90.0, 1.4],
			["f", Vector3(15.9, 2.4, 3.4), -90.0, 1.5], ["e", Vector3(4.2, 1.6, 5.9), 180.0, 1.4], ["d", Vector3(13.4, 2.0, 5.9), 180.0, 1.3]]:
		add(walls, M + "Rocks/Cave_Wall_Rocks/cave_wall_rocks_%s.tscn" % r[0], r[1], r[2], r[3])
	var columns := group(g, "Columns")
	for c in [[Vector3(5.5, 0.0, -1.8), 1.3, 8.0], [Vector3(6.0, 0.0, -2.3), 0.8, -12.0], [Vector3(8.2, 0.0, 2.6), 1.6, 5.0], [Vector3(8.8, 0.0, 3.0), 0.9, 18.0],
			[Vector3(11.4, 0.0, -2.8), 1.1, -6.0], [Vector3(12.8, 0.0, 1.4), 1.4, 10.0], [Vector3(13.2, 0.0, 1.9), 0.7, -15.0], [Vector3(3.6, 0.0, 3.8), 0.9, 12.0]]:
		crystal_prism(columns, "Column", c[0], c[1], c[2], randf() * 360.0)
	look(columns.get_child(0), "Kryształowe kolumny", "Kryształy rosną tu z podłogi jak kolumny w świątyni. Najwyższe sięgają ci do piersi. Wszystkie pochylone w jedną stronę, w dół, jak trawa pod wiatrem.", {"padding": 0.15})
	var shard := crystal_prism(g, "Shard", Vector3(10.2, 0.02, 0.4), 0.22, 70.0, 30.0)
	pickup_on(shard, "Shard", {"display_name": "Odłamek", "on_use_item": "odlamek", "on_use_flag": "took_shard",
		"description": "Od kolumny odprysnął kawałek wielkości kciuka. Czysty błękit, bez grama skały. Kiedy go podnosisz, buczy, a amulet dziadka buczy razem z nim."})
	vein(g, "galeria_1", "c", Vector3(6.0, 1.5, -5.9), 0.0, "Tu nie ma żył. Tu cała ściana jest żyłą. Rysujesz na mapie grubą kreskę i przez chwilę nie możesz oderwać wzroku.", Vector3(6.2, 0.0, -5.0), 1.5)
	vein(g, "galeria_2", "e", Vector3(15.9, 1.4, -0.6), -90.0, "Błękit pulsuje tu wolniej niż gdzie indziej. Równo z twoim oddechem. Wstrzymujesz oddech. Błękit też.", Vector3(15.0, 0.0, -1.2), 1.4)
	vein(g, "galeria_3", "g", Vector3(9.4, 1.3, 5.9), 180.0, "Najjaśniejsza żyła, jaką widziałeś. Światło przechodzi ci przez palce, kiedy zasłaniasz ją dłonią. Zaznaczasz ją drżącą ręką.", Vector3(9.6, 0.0, 5.0), 1.4)
	for p in [Vector3(4.0, 3.5, 0.0), Vector3(10.0, 4.0, -1.0), Vector3(13.5, 3.0, 2.0)]:
		light(g, "Glow", p, Color(0.35, 0.6, 1.0), 2.4, 10.0, true, 0.35, 0.5, 1)
	spots("galeria", GALERIA, [Vector3(3.0, 0.0, -1.2), Vector3(3.2, 0.0, 1.6), Vector3(5.2, 0.0, 0.4), Vector3(7.0, 0.0, -0.4)])
	emitter(g, "Hum", "rumble", Vector3(12.0, 1.0, 0.0), 12.0, 30.0, -6.0, 30.0, 0.5)
	emitter(g, "Taps", "pick_taps", Vector3(16.5, 1.0, 0.0), 30.0, 70.0, -8.0, 30.0, 0.05)

## Kuźnia starej ekipy: a cold forge, an anvil with a crowbar on it, a hidden flask.
func _kuznia() -> void:
	var g := group(root3d, "Kuznia", KUZNIA)
	chamber(g, 9.0, 8.0, 3.6)
	stub(g, "kuznia", KUZNIA)
	# the hearth against the north wall, with a hood up to the roof
	slab(g, "Hearth", Vector3(1.8, 0.8, 1.2), Vector3(3.0, 0.4, -3.3), rock)
	slab(g, "Hood", Vector3(1.6, 2.8, 0.9), Vector3(3.0, 2.2, -3.5), rock)
	var ash := slab(g, "Ash", Vector3(1.4, 0.05, 0.8), Vector3(3.0, 0.82, -3.2), charred, false)
	look(ash, "Palenisko", "Zimne od czterdziestu lat. W popiele ktoś narysował palcem znak: dwie skrzyżowane kreski i kropkę. Popiół powinien był to dawno zatrzeć.", {"on_use_flag": "saw_forge_mark", "padding": 0.2})
	add(g, P + "Anvil_Log.gltf", Vector3(4.8, 0.0, -1.0), 30.0, 1.0, "Anvil")
	var bar := CylinderMesh.new()
	bar.top_radius = 0.018
	bar.bottom_radius = 0.018
	bar.height = 0.9
	var iron := StandardMaterial3D.new()
	iron.albedo_color = Color(0.18, 0.17, 0.16)
	iron.metallic = 0.7
	iron.roughness = 0.5
	var crowbar := mesh(g, "Crowbar", bar, Vector3(4.8, 0.95, -1.0), iron, Basis(Vector3.UP, 0.4) * Basis(Vector3.BACK, PI / 2))
	pickup_on(crowbar, "Crowbar", {"display_name": "Łom na kowadle", "on_use_item": "lom", "on_use_flag": "took_crowbar",
		"description": "Łom leży na kowadle, jakby kowal odłożył go na chwilę. Ciężki, dobrze kuty, z rozpłaszczonym końcem. Taki podważy wszystko, co ktoś kiedyś zabił na głucho."})
	add(g, P + "WeaponStand.gltf", Vector3(7.8, 0.0, 3.3), 180.0)
	add(g, P + "Barrel.gltf", Vector3(6.4, 0.0, -3.3), 0.0)
	add(g, P + "Bucket_Metal.gltf", Vector3(6.9, 0.0, -2.6), 40.0)
	add(g, P + "Chain_Coil.gltf", Vector3(1.6, 0.0, 2.8), 0.0)
	add(g, P + "Workbench_Drawers.gltf", Vector3(2.6, 0.0, 3.5), 180.0, 1.0, "Bench")
	pickup(g, P + "Bottle_1.gltf", Vector3(2.9, 0.93, 3.4), 0.0, 1.0, "Flask", {
		"display_name": "Butelka za szufladą",
		"description": "Zakurzona butelka schowana za szufladą, korek zalany woskiem. W środku coś, co pachnie korzeniami i ogniem. Kowal starej ekipy wiedział, co dobre.",
		"on_use_item": "nalewka", "on_use_flag": "took_smith_flask",
	})
	reliefs(g, [["c", Vector3(8.9, 1.2, -2.6), -90.0, 1.0], ["a", Vector3(6.0, 1.1, 3.9), 180.0, 1.0]])
	vein(g, "kuznia_1", "b", Vector3(8.9, 1.3, 1.4), -90.0, "Kowal musiał na nią patrzeć codziennie przez całą robotę. Może dlatego wykuwał tu tylko gwoździe. Zaznaczasz ją.", Vector3(8.0, 0.0, 1.0))
	light(g, "Glow", Vector3(4.5, 2.6, 0.5), Color(1.0, 0.6, 0.3), 0.6, 8.0, true, 0.1, 3.0)
	spots("kuznia", KUZNIA, [Vector3(2.6, 0.0, 0.6), Vector3(3.4, 0.0, -1.4), Vector3(3.8, 0.0, 1.8), Vector3(6.0, 0.0, 0.6)])
	emitter(g, "Creak", "creak", Vector3(4.0, 3.0, 0.0), 16.0, 34.0, -9.0, 16.0, 0.12)

## Przekop Grabca: a dead-straight crosscut with frames and rails; at its end the old sztygar's
## cache behind nailed boards (a crowbar opens it).
func _przekop() -> void:
	var g := group(root3d, "Przekop", PRZEKOP)
	chamber(g, 24.0, 3.6, 4.0)
	stub(g, "przekop", PRZEKOP)
	var f := frames(g, [2.0, 5.0, 8.0, 11.0, 14.0, 17.0, 20.0], 1.4)
	look(f.get_child(0), "Tabliczka na stemplu", "Wypalone w drewnie: PRZEKOP SIÓDMY. SZTYGAR W. GRABIEC. Pod spodem, nożem, inną ręką: kto to czyta, niech idzie prosto i się nie ogląda.", {"padding": 0.1})
	for x in [3.0, 7.0, 11.0, 15.0, 19.0]:
		add(g, M + "Mine_Rails/rail_a.tscn", Vector3(x, 0.02, 0.0), 90.0)
	add(g, M + "Mine_Carts/mine_cart_ba.tscn", Vector3(15.6, 0.0, 0.0), 90.0, 1.0, "Cart")
	var boards := add(g, M + "Panel_Wood/panel_wood_a.tscn", Vector3(23.7, 0.0, 0.0), 90.0, 1.0, "CacheBoards")
	interactable(boards, "CachePickup", {
		"display_name": "Zabita deskami wnęka", "prompt_text": "Podważ deski łomem", "time_cost_hours": 0.5, "time_reason": "Rozbijanie skrytki",
		"required_item": "lom", "missing_text": "Deski przybite na głucho. Gołymi rękami ich nie oderwiesz. Przydałby się łom.",
		"description": "Deski puszczają z jękiem. W środku skrzynka: bańka oleju, zeszyt w ceracie i garść zardzewiałych gwoździ. Zeszyt jest pełen liczb, a na ostatniej stronie liczby się urywają.\n\nZabierasz olej i zeszyt.",
		"on_use_item": "olej", "on_use_note": &"zapiski_grabca", "on_use_flag": "opened_grabiec_cache", "remove_after_use": true,
		"on_use_quest": &"czternasty", "on_use_quest_entry": "zeszyt",
		"expedition_event": "Otworzyłeś skrytkę sztygara Grabca.", "padding": 0.1,
	})
	vein(g, "przekop_1", "d", Vector3(12.5, 1.3, -1.7), 0.0, "Przekop idzie prosto przez żyłę, jakby Grabiec jej nie zauważył. Albo zauważył i kopał dalej, bo miał rozkaz iść prosto. Zaznaczasz ją.", Vector3(12.3, 0.0, -0.9))
	# The tremor splits the floor by the wall and gives back something of the old crew's.
	var tremor_crack := slab(g, "TremorCrack", Vector3(1.3, 0.04, 0.4), Vector3(9.2, 0.02, 1.4), charred, false)
	look(tremor_crack, "Świeże pęknięcie", "Wstrząs rozstąpił skałę przy samym spągu. W szczelinie coś błyska: zgnieciony blaszany medalik, jakie stara ekipa dostawała od Kniazia za pełny rok szychty. Wypolerowany od dotyku.

Ktoś nosił go jeszcze długo po tym, jak przestali liczyć dni.", {
		"required_flag": "tremor_seen", "on_use_flag": "saw_medal", "sanity_change": -2, "sanity_reason": "Wypolerowany od dotyku",
		"on_use_quest": &"czternasty", "on_use_quest_entry": "medalik", "quest_only_if_active": true, "padding": 0.15})
	for x in [6.5, 16.5]:
		light(g, "Glow", Vector3(x, 2.8, 0.0), Color(1.0, 0.6, 0.3), 0.5, 7.0, true, 0.12, 4.0)
	spots("przekop", PRZEKOP, [Vector3(3.8, 0.0, -0.8), Vector3(4.6, 0.0, 0.8), Vector3(6.2, 0.0, -0.8), Vector3(7.0, 0.0, 0.8)])
	emitter(g, "Creak", "creak", Vector3(12.0, 3.0, 0.0), 12.0, 26.0, -7.0, 22.0, 0.12)
	emitter(g, "Drip", "drip", Vector3(20.0, 3.5, 0.0), 3.0, 9.0, -7.0, 16.0, 0.25)

## Zalany chodnik: a gallery with knee-deep icy water (after the pump runs). A night after
## wading here brings a fever.
func _zalany() -> void:
	var g := group(root3d, "Zalany", ZALANY)
	chamber(g, 16.0, 3.6, 4.0)
	stub(g, "zalany", ZALANY)
	frames(g, [2.5, 6.0, 9.5, 13.0], 1.4)
	water(g, "Water", Vector2(16.0, 3.6), Vector3(8.0, 0.45, 0.0))
	for pl in [[Vector3(5.0, 0.48, 0.6), 20.0], [Vector3(10.4, 0.48, -0.7), -35.0]]:
		slab(g, "FloatingPlank", Vector3(1.4, 0.05, 0.22), pl[0], wood, false, Basis(Vector3.UP, deg_to_rad(pl[1])))
	var cart := add(g, M + "Mine_Carts/mine_cart_ba.tscn", Vector3(12.0, 0.0, 0.6), 80.0, 1.0, "DrownedCart")
	look(cart, "Woda", "Lodowata woda po kolana. Po kilku krokach nie czujesz palców. Coś ociera ci się o łydkę. Pewnie deska. Pewnie.\n\nPo takiej kąpieli łatwo o gorączkę.", {"padding": 0.1})
	vein(g, "zalany_1", "a", Vector3(6.2, 1.3, -1.7), 0.0, "Żyła biegnie tuż nad wodą i odbija się w niej, więc widzisz ją podwójnie. Zaznaczasz tę prawdziwą.", Vector3(6.0, 0.0, -0.9))
	vein(g, "zalany_2", "c", Vector3(15.9, 1.4, 0.4), -90.0, "Na samym końcu chodnika, gdzie woda jest najgłębsza, ściana świeci jak latarnia. Brniesz do niej i zaznaczasz ją na mapie.", Vector3(15.0, 0.0, -0.4))
	light(g, "Glow", Vector3(3.0, 2.6, 0.0), Color(1.0, 0.6, 0.3), 0.45, 6.0, true, 0.12, 4.0)
	spots("zalany", ZALANY, [Vector3(3.2, 0.0, -0.8), Vector3(3.8, 0.0, 0.9), Vector3(5.2, 0.0, -0.6), Vector3(5.8, 0.0, 0.9)])
	emitter(g, "Drip", "drip", Vector3(8.0, 3.5, 0.0), 1.5, 5.0, -4.0, 18.0, 0.3)
	emitter(g, "Drip2", "drip", Vector3(13.0, 3.5, 0.5), 2.0, 6.0, -6.0, 18.0, 0.3)

## Parująca szczelina: a tall, narrow crack with hot steam and sulphur. One vein sits right
## next to a vent: marking it burns you.
func _szczelina() -> void:
	var g := group(root3d, "Szczelina", SZCZELINA)
	chamber(g, 14.0, 3.0, 6.0)
	stub(g, "szczelina", SZCZELINA)
	reliefs(g, [["b", Vector3(2.6, 1.4, -1.8), 0.0, 0.9], ["d", Vector3(8.0, 2.6, -1.8), 0.0, 1.0], ["f", Vector3(6.6, 1.5, 1.8), 180.0, 0.9],
		["a", Vector3(13.9, 1.8, 0.0), -90.0, 1.0], ["g", Vector3(9.2, 3.2, 1.8), 180.0, 0.9]])
	var sulphur := StandardMaterial3D.new()
	sulphur.albedo_color = Color(0.72, 0.64, 0.18)
	sulphur.roughness = 1.0
	var first_stain: Node3D = null
	for v in [Vector3(6.2, 0.0, 0.8), Vector3(11.0, 0.0, -0.7)]:
		steam(g, "Steam", v)
		var stain := slab(g, "Sulphur", Vector3(0.9, 0.03, 0.7), v + Vector3(0.0, 0.015, 0.0), sulphur, false)
		if first_stain == null:
			first_stain = stain
		light(g, "Heat", v + Vector3(0.0, 0.4, 0.0), Color(1.0, 0.42, 0.18), 1.2, 4.5, false, 0.35, 5.0)
	look(first_stain, "Para", "Z pęknięcia bucha para, gorąca jak z kotła. Śmierdzi zgniłymi jajami. Dziadek miał rację: nie siedzieć tu długo.", {"padding": 0.3})
	var fresh_crack := slab(g, "FreshCrack", Vector3(1.1, 0.04, 0.5), Vector3(8.8, 0.02, 0.3), sulphur, false)
	look(fresh_crack, "Nowa szczelina", "Ta szczelina jest nowa. Brzegi ostre, nieokopcone, siarka nie zdążyła ich zażółcić. Wstrząs otworzył ją jak list.

Ze środka idzie ciepło. I bardzo powolny, równy oddech pary.", {
		"required_flag": "tremor_seen", "on_use_flag": "saw_fresh_crack", "sanity_change": -1, "sanity_reason": "Oddech spod skały", "padding": 0.15})
	vein(g, "szczelina_1", "e", Vector3(4.4, 1.4, -1.75), 0.0, "Wąska żyła w pęknięciu skały, ciepła jak piec. Zaznaczasz ją, zanim zdążysz się spocić.", Vector3(4.0, 0.0, -0.8), 1.0)
	vein(g, "szczelina_2", "b", Vector3(11.2, 1.3, 1.75), 180.0, "Żyła biegnie tuż nad wylotem pary. Kiedy się nad nią pochylasz, para bucha ci prosto w twarz. Parzy, ale kończysz rysunek.", Vector3(11.4, 0.0, 0.9), 1.0, {
		"wound": 10, "wound_reason": "Poparzyła cię para"})
	spots("szczelina", SZCZELINA, [Vector3(2.8, 0.0, -0.6), Vector3(3.4, 0.0, 0.7), Vector3(5.0, 0.0, -0.7), Vector3(5.4, 0.0, 0.6)])
	emitter(g, "Hiss", "rumble", Vector3(8.0, 1.0, 0.0), 6.0, 14.0, -6.0, 18.0, 0.6)

## Ślepy szyb: the bottom of a blind shaft you came down on a rope. Wind from nowhere, a vein
## and candles on a ledge (a fall if you climb for them).
func _szyb() -> void:
	var g := group(root3d, "Szyb", SZYB)
	chamber(g, 6.5, 6.0, 9.0)
	stub(g, "szyb", SZYB)
	slab(g, "CeilingDark", Vector3(6.0, 0.4, 5.6), Vector3(3.25, 8.4, 0.0), charred, false)
	rope(g, "YourRope", Vector3(1.4, 9.0, -0.4), Vector3(1.4, 0.05, -0.4), 0.03)
	add(g, P + "Rope_3.gltf", Vector3(1.6, 0.0, -0.2), 30.0)
	reliefs(g, [["a", Vector3(3.4, 1.2, -2.9), 0.0, 1.1], ["e", Vector3(6.4, 3.8, -1.2), -90.0, 1.2], ["c", Vector3(2.6, 4.5, 2.9), 180.0, 1.2],
		["g", Vector3(5.0, 6.0, -2.9), 0.0, 1.0]])
	slab(g, "Ledge", Vector3(1.4, 0.2, 0.7), Vector3(4.6, 2.0, -2.65), rock)
	var niche := add(g, P + "CandleStick_Triple.gltf", Vector3(4.6, 2.1, -2.65), 0.0, 1.0, "Niche")
	pickup_on(niche, "Candles", {
		"display_name": "Świece na półce",
		"description": "Wspinasz się na półkę po świece. Kamień obsuwa ci się pod nogą i spadasz z wysokości człowieka. Świece ocalały. Ty trochę mniej.",
		"on_use_item": "swieca:2", "on_use_flag": "took_shaft_candles", "wound": 15, "wound_reason": "Spadłeś z półki",
	})
	var draft := Node3D.new()
	draft.name = "Draft"
	draft.position = Vector3(3.2, 1.2, 0.0)
	own(draft, g)
	var draft_box := BoxMesh.new()
	draft_box.size = Vector3(0.6, 0.6, 0.6)
	var invisible := StandardMaterial3D.new()
	invisible.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	invisible.albedo_color = Color(1, 1, 1, 0.0)
	mesh(draft, "Air", draft_box, Vector3.ZERO, invisible)
	look(draft, "Wiatr", "Z góry ciągnie zimne powietrze, choć szyb nie ma wyjścia na powierzchnię. Dziadek napisał tylko jedno słowo: wiatr. Teraz wiesz dlaczego. I zarazem nie wiesz.", {"padding": 0.3})
	vein(g, "szyb_1", "f", Vector3(6.4, 1.5, 1.4), -90.0, "Żyła pnie się po ścianie szybu w górę, w ciemność. Zaznaczasz tyle, ile widzisz. Reszta ucieka poza zasięg lampy.", Vector3(5.6, 0.0, 1.9), 1.3)
	light(g, "Glow", Vector3(3.0, 2.0, 0.5), Color(1.0, 0.6, 0.3), 0.45, 6.0, true, 0.12, 4.0)
	spots("szyb", SZYB, [Vector3(2.8, 0.0, 1.4), Vector3(3.6, 0.0, -1.2), Vector3(4.4, 0.0, 1.8), Vector3(4.8, 0.0, 0.0)])
	emitter(g, "Wind", "rumble", Vector3(3.2, 7.0, 0.0), 8.0, 18.0, -4.0, 20.0, 0.9)

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
