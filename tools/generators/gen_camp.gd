extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_camp.gd
## Generates res://scene/levels/camp.tscn for the vertical slice: the camp in the old hall
## (bedroll, campfire, map table, supplies), barricades with exits to the east/west segments,
## the west segment (grandfather's key, broken supports, blast debris), the fuse box in the
## east chamber, and markers for spawning/travel/NPC placement.
## WARNING: overwrites the scene. Edit this generator, not the scene.

const K := "res://assets/props/kenney_survival/"
const P := "res://assets/prop_pack/Exports/glTF/"
const M := "res://assets/LoafbrrAssets/MineAndCavesSet/scenes/"
const OUT := "res://scene/levels/camp.tscn"
const Y_WEST_LOW := -2.0     # floor of the west tunnel below the first ramp
const Y_CHAMBER := -2.116    # floor of the east cave chamber

var root3d: Node3D
var cache := {}
var counter := {}

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

func _initialize() -> void:
	root3d = Node3D.new()
	root3d.name = "Camp"

	# --- Camp in the south walkway of the old hall (z 1.1 … 4.5, x 6 … 19) ---
	var camp := group(root3d, "CampProps")
	var wood := skinned(camp, "Wood", "res://material/kenney_wood.tres")
	var cloth := skinned(camp, "Cloth", "res://material/kenney_cloth.tres")
	var bed := add(cloth, K + "bedroll.glb", Vector3(7.0, 0.0, 3.75), 90.0, 3.2, "Bedroll")
	interactable(bed, "BedUse", {"display_name": "Posłanie", "prompt_text": "Połóż się spać", "action": 2})
	var fire := group(camp, "Campfire")
	fire.position = Vector3(10.8, 0.0, 2.9)
	var stones := skinned(fire, "Stones", "res://material/cave_rock.tres")
	add(stones, K + "campfire-pit.glb", Vector3.ZERO, 0.0, 4.0, "Pit")
	flames(fire, Vector3(0, 0.2, 0))
	flicker_light(fire, "FireLight", Vector3(0, 0.6, 0), Color(1.0, 0.55, 0.22), 2.6, 9.0, 0.3, 9.0)
	sound(fire, "FireCrackle", "res://assets/sounds/generated/lantern_crackle.wav", Vector3(0, 0.3, 0), -4.0, 12.0)
	interactable(fire, "FireLook", {"display_name": "Ognisko", "description": "Ogień z połamanych stempli. Pali się nisko i kopci. Mirosław siedzi tak, żeby mieć do niego jak najdalej.", "solid": true})
	add(wood, K + "tree-log-small.glb", Vector3(12.55, 0.0, 3.45), -17.0, 1.6, "MiroslawLog")
	add(wood, K + "tree-log-small.glb", Vector3(10.6, 0.0, 4.15), 98.0, 1.5, "FireLog")
	add(camp, P + "Pot_1.gltf", Vector3(9.7, 0.0, 3.6), 30.0)
	# map table with a map, books and a candle
	var table := add(camp, P + "Table_Large.gltf", Vector3(15.6, 0.0, 3.75), 0.0, 1.0, "MapTable")
	interactable(table, "MapTableUse", {"display_name": "Stół z mapą", "prompt_text": "Zaplanuj wyprawę", "action": 2})
	add(camp, P + "Scroll_1.gltf", Vector3(15.3, 0.81, 3.7), 80.0, 1.6)
	add(camp, P + "Book_Stack_1.gltf", Vector3(16.6, 0.81, 3.95), 20.0)
	add(camp, P + "CandleStick.gltf", Vector3(14.6, 0.81, 3.6), 0.0)
	flicker_light(camp, "CandleLight", Vector3(14.6, 1.05, 3.6), Color(1.0, 0.7, 0.4), 0.9, 3.5, 0.25, 7.0, false)
	# supplies
	add(wood, K + "box.glb", Vector3(18.3, 0.0, 3.9), 12.0, 2.4)
	add(wood, K + "box.glb", Vector3(18.2, 0.6, 3.85), 40.0, 2.0)
	add(wood, K + "box.glb", Vector3(17.9, 0.0, 2.9), -15.0, 2.4)
	add(camp, P + "Barrel.gltf", Vector3(6.3, 0.0, 2.3), 0.0)
	add(camp, P + "Bag.gltf", Vector3(6.0, 0.0, 4.2), 60.0)

	# --- Barricades between the camp and the expedition segments ---
	var barricades := group(root3d, "Barricades")
	var signs := skinned(barricades, "Signs", "res://material/kenney_wood.tres")
	var east_panel := add(barricades, M + "Panel_Wood/panel_wood_a.tscn", Vector3(35.2, 0.0, 3.0), 90.0, 1.0, "EastBoards")
	interactable(east_panel, "EastBoardsLook", {"display_name": "Zabite deskami zejście", "description": "Chodnik zabity deskami. Ktoś napisał na nich kredą: „STARA SZTOLNIA”.\n\nNa wyprawę wyruszasz od stołu z mapą w obozie.", "solid": false})
	var lamp := add(barricades, P + "Lantern_Wall.gltf", Vector3(34.0, 1.35, 4.45), 180.0, 1.0, "EastLantern")
	flicker_light(lamp, "Light", Vector3(0, 0.6, 0.95), Color(1.0, 0.62, 0.32), 1.2, 6.0).set("housing_casts_shadow", false)
	box_body(barricades, "EastBlock", Vector3(0.4, 4.0, 4.2), Vector3(35.2, 2.0, 3.0))
	var east_sign := add(signs, K + "signpost-single.glb", Vector3(36.1, 0.0, 1.5), -90.0, 3.5, "EastSign")
	interactable(east_sign, "EastExitUse", {"display_name": "Drogowskaz", "prompt_text": "Wróć do obozu · 2 h", "action": 2})
	var west_panel := add(barricades, M + "Panel_Wood/panel_wood_a.tscn", Vector3(-1.8, 0.0, 3.0), 90.0, 1.0, "WestBoards")
	interactable(west_panel, "WestBoardsLook", {"display_name": "Zabity deskami chodnik", "description": "Zachodni chodnik zabity deskami. Zza nich słychać, jak co jakiś czas osypuje się żwir.\n\nNa wyprawę wyruszasz od stołu z mapą w obozie.", "solid": false})
	box_body(barricades, "WestBlock", Vector3(0.4, 4.0, 4.2), Vector3(-1.8, 2.0, 3.0))
	var west_sign := add(signs, K + "signpost-single.glb", Vector3(-2.7, 0.0, 1.5), 90.0, 3.5, "WestSign")
	interactable(west_sign, "WestExitUse", {"display_name": "Drogowskaz", "prompt_text": "Wróć do obozu · 2 h", "action": 2})

	# --- West segment: behind the collapse ---
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
	interactable(beam, "BarrierLook", {"display_name": "Połamane stemple", "description": "Dalej chodnik stromo opada w ciemność, a stemple połamało jak zapałki. Bez lin i paru ludzi nie ma tu czego szukać. Na pewno nie dziś.", "solid": false, "padding": 0.3})
	box_body(barrier, "BarrierBlock", Vector3(1.2, 3.0, 4.4), Vector3(-17.5, Y_WEST_LOW + 1.5, 3.0))
	var debris := group(west, "BlastDebris")
	for r in [[-6.4, 1.4, "a", 0.8], [-7.2, 4.6, "c", 0.9], [-8.3, 1.6, "b", 0.7], [-5.8, 4.4, "d", 0.6], [-9.2, 4.5, "a", 0.6]]:
		add(debris, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[2], Vector3(r[0], lerpf(0.0, Y_WEST_LOW, clampf((-r[0] - 5.0) / 4.0, 0.0, 1.0)) + 0.1, r[1]), randf() * 360.0, r[3])

	# --- East segment: the fuse box in the cave chamber ---
	var east := group(root3d, "EastSegment")
	var chest := add(east, P + "Chest_Wood.gltf", Vector3(70.4, Y_CHAMBER, 7.4), 90.0, 0.6, "FuseBox")
	interactable(chest, "FuseBoxPickup", {
		"display_name": "Skrzynka z lontami",
		"description": "Skrzynka po starej ekipie. W środku, w natłuszczonym płótnie, leżą lonty. Suche. Ktoś się postarał, żeby przetrwały.\n\nZabierasz je.",
		"on_use_item": "lonty", "on_use_flag": "took_fuses", "on_use_quest": &"lonty", "on_use_quest_entry": "znalezione",
		"quest_only_if_active": true, "remove_after_use": true,
	})

	# --- Markers: spawn, travel and NPC places (yaw 0 = facing +Z for NPCs, -Z for the player) ---
	var markers := group(root3d, "Markers")
	marker(markers, "SpawnBed", Vector3(8.4, 0.0, 3.3), -90.0)
	marker(markers, "CampReturn", Vector3(13.8, 0.0, 2.2), 90.0)
	marker(markers, "EastEntry", Vector3(37.2, 0.0, 3.0), -90.0)
	marker(markers, "WestEntry", Vector3(-3.4, 0.0, 3.0), 90.0)
	marker(markers, "MiroslawFire", Vector3(12.4, 0.0, 3.4), -107.0)
	marker(markers, "MiroslawCorner", Vector3(7.0, 0.0, -3.85), 0.0)
	marker(markers, "BolkoTable", Vector3(15.4, 0.0, 2.55), -90.0)
	marker(markers, "BolkoBed", Vector3(8.6, 0.0, 2.6), -54.0)
	marker(markers, "BolkoAway", Vector3(18.6, 0.0, 1.9), 90.0)

	var packed := PackedScene.new()
	var err := packed.pack(root3d)
	if err == OK:
		err = ResourceSaver.save(packed, OUT)
		_strip_meshes()
	print("saved ", OUT, " err=", err)
	root3d.free()
	quit()

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
