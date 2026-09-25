extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_camp.gd
## Generates res://scene/levels/camp.tscn: the expedition camp in the old hall, split into areas
## (docs_v2/03_poziomy.md):
## - west room (x 0–20): sleeping place, kitchen and common table by the fire, storage with the
##   ore carts and tools, the powder store (as far from the fire as it gets),
## - east room (x 20–31, behind the wooden partition): the leader's table with the map, and the
##   quartermaster's stall next to the east exit,
## plus the barricades with exits, the west segment (grandfather's key, broken supports, blast
## debris), the fuse box in the east chamber, and markers for spawning, travel and the NPC
## schedule (script/camp_schedule.gd).
## WARNING: overwrites the scene. Edit this generator, not the scene.

const K := "res://assets/props/kenney_survival/"
const P := "res://assets/prop_pack/Exports/glTF/"
const M := "res://assets/LoafbrrAssets/MineAndCavesSet/scenes/"
const OUT := "res://scene/levels/camp.tscn"
const Y_WEST_LOW := -2.0     # floor of the west tunnel below the first ramp
const Y_CHAMBER := -2.116    # floor of the east cave chamber
const TABLE_TOP := 0.81      # Table_Large height

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
	var camp := group(root3d, "CampProps")
	var wood := skinned(camp, "Wood", "res://material/kenney_wood.tres")
	var cloth := skinned(camp, "Cloth", "res://material/kenney_cloth.tres")
	_sleeping(camp, cloth)
	_kitchen(camp, wood)
	_storage(camp, wood)
	_command(camp, wood)
	_supply(camp)
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

#region West room: sleeping, kitchen, storage, powder

func _sleeping(camp: Node3D, cloth: Node3D) -> void:
	var bed := add(cloth, K + "bedroll.glb", Vector3(7.0, 0.0, 3.75), 90.0, 3.2, "Bedroll")
	interactable(bed, "BedUse", {"display_name": "Posłanie", "prompt_text": "Połóż się spać", "action": 2})
	add(cloth, K + "bedroll.glb", Vector3(4.55, 0.0, 3.8), 90.0, 3.2, "BolkoBedroll")
	add(cloth, K + "bedroll.glb", Vector3(4.2, 0.0, -3.95), 90.0, 3.2, "MiroslawBedroll")
	add(camp, P + "Bag.gltf", Vector3(5.8, 0.0, 4.2), 60.0)
	add(camp, P + "Bag.gltf", Vector3(3.15, 0.0, 4.05), -20.0)
	var water := add(camp, P + "Barrel.gltf", Vector3(6.3, 0.0, 2.3), 0.0, 1.0, "WaterBarrel")
	look(water, "Beczka z wodą", "Woda spuszczona z góry w bukłakach. Pachnie żelazem. Tekla pilnuje, żeby nikt się w niej nie mył.", true)

func _kitchen(camp: Node3D, wood: Node3D) -> void:
	var fire := group(camp, "Campfire")
	fire.position = Vector3(10.8, 0.0, 2.9)
	var stones := skinned(fire, "Stones", "res://material/cave_rock.tres")
	add(stones, K + "campfire-pit.glb", Vector3.ZERO, 0.0, 4.0, "Pit")
	flames(fire, Vector3(0, 0.2, 0))
	# The light sits above the kettle so the pot doesn't throw its shadow over the whole camp.
	flicker_light(fire, "FireLight", Vector3(0.0, 1.35, -0.45), Color(1.0, 0.55, 0.22), 2.8, 9.5, 0.3, 9.0)
	sound(fire, "FireCrackle", "res://assets/sounds/generated/lantern_crackle.wav", Vector3(0, 0.3, 0), -4.0, 12.0)
	var stand := skinned(fire, "Stand", "res://material/kenney_wood.tres")
	add(stand, K + "campfire-stand.glb", Vector3.ZERO, 0.0, 4.0, "Spit")
	var kettle := add(fire, P + "Cauldron.gltf", Vector3(0.0, 0.46, 0.0), 20.0, 0.46, "Kettle")
	interactable(kettle, "FireLook", {"display_name": "Ognisko z kociołkiem", "description": "Tekla gotuje tu dwa razy dziennie: rano kaszę, wieczorem to samo z tym, co zostało. Pali się połamanymi stemplami. Mirosław siada tak, żeby mieć do ognia jak najdalej.", "solid": true, "padding": 0.1})
	box_body(fire, "PitBlock", Vector3(1.2, 0.5, 1.2), Vector3(0, 0.25, 0))
	add(wood, K + "tree-log-small.glb", Vector3(12.55, 0.0, 3.45), -17.0, 1.6, "MiroslawLog")
	add(wood, K + "tree-log-small.glb", Vector3(10.6, 0.0, 4.15), 98.0, 1.5, "FireLog")
	# the cook's corner
	add(camp, P + "Barrel_Apples.gltf", Vector3(9.05, 0.0, 4.05), 30.0)
	add(camp, P + "FarmCrate_Carrot.gltf", Vector3(9.25, 0.0, 1.7), -10.0)
	add(camp, P + "Bucket_Wooden_1.gltf", Vector3(8.75, 0.0, 2.3), 0.0)
	add(camp, P + "Pot_1.gltf", Vector3(9.7, 0.0, 3.65), 30.0)
	add(camp, P + "Pot_1_Lid.gltf", Vector3(9.95, 0.0, 3.95), 0.0)
	# common table with benches (breakfast before 8, supper 18–20)
	var table := add(camp, P + "Table_Large.gltf", Vector3(14.0, 0.0, 1.05), 0.0, 1.0, "CommonTable")
	look(table, "Wspólny stół", "Tu się je, gra w kości i kłóci o to, kto dziś zjeżdża pierwszy. Deski lepią się od kaszy.", true)
	add(camp, P + "Bench.gltf", Vector3(14.0, 0.0, 0.22), 0.0, 0.9, "BenchNorth")
	add(camp, P + "Bench.gltf", Vector3(14.0, 0.0, 1.9), 0.0, 0.9, "BenchSouth")
	add(camp, P + "Stool.gltf", Vector3(15.75, 0.0, 1.05), 0.0, 1.0, "HeadStool")
	for p in [Vector3(13.2, TABLE_TOP, 0.75), Vector3(14.6, TABLE_TOP, 0.78), Vector3(13.3, TABLE_TOP, 1.35), Vector3(15.1, TABLE_TOP, 1.05)]:
		add(camp, P + "Table_Plate.gltf", p, randf() * 360.0)
	for p in [Vector3(13.55, TABLE_TOP, 0.62), Vector3(14.9, TABLE_TOP, 0.7), Vector3(12.9, TABLE_TOP, 1.2)]:
		add(camp, P + "Mug.gltf", p, randf() * 360.0)
	add(camp, P + "Table_Spoon.gltf", Vector3(13.25, TABLE_TOP + 0.01, 0.75), 30.0)
	add(camp, P + "Pot_1.gltf", Vector3(14.1, TABLE_TOP, 1.1), 0.0)
	candle(camp, P + "CandleStick.gltf", Vector3(14.75, TABLE_TOP, 1.3), 0.7, 3.2)

func _storage(camp: Node3D, wood: Node3D) -> void:
	var store := group(camp, "Storage")
	for c in [[16.5, 3.9, 5.0, 1.0], [17.4, 3.95, -8.0, 1.0]]:
		add(store, P + "Crate_Wooden.gltf", Vector3(c[0], 0.0, c[1]), c[2], c[3])
	add(store, P + "Crate_Wooden.gltf", Vector3(16.95, 0.88, 3.95), 22.0, 0.85)
	var boxes := skinned(store, "Boxes", "res://material/kenney_wood.tres")
	add(boxes, K + "box.glb", Vector3(18.45, 0.0, 3.95), 12.0, 2.4)
	add(boxes, K + "box.glb", Vector3(18.4, 0.6, 3.9), 40.0, 2.0)
	add(store, P + "Barrel.gltf", Vector3(15.95, 0.0, 3.95), 0.0)
	add(store, P + "Bag.gltf", Vector3(15.9, 0.0, 3.2), 110.0)
	# tools on a workbench along the partition
	var bench := add(store, P + "Workbench.gltf", Vector3(18.75, 0.0, -1.6), 90.0, 1.0, "ToolBench")
	look(bench, "Narzędzia", "Kilofy, łopaty, kliny, zapasowe trzonki. Bolko ostrzy je co wieczór, choć jeszcze nikt ich tu nie użył.", true)
	var pick := add(store, P + "Pickaxe_Bronze.gltf", Vector3(18.75, 0.9, -1.25), 0.0, 1.0)
	pick.basis = Basis(Vector3.UP, 0.4) * Basis(Vector3.RIGHT, PI / 2)
	var axe := add(store, P + "Axe_Bronze.gltf", Vector3(18.6, 0.9, -2.2), 0.0, 1.0)
	axe.basis = Basis(Vector3.UP, 1.2) * Basis(Vector3.RIGHT, PI / 2)
	add(store, P + "Whetstone.gltf", Vector3(19.05, 0.0, 0.35), 90.0, 0.8)
	# old ore left in the cart at the end of the rails
	var ore := blue_ore(store, "CartOre")
	for r in [[16.75, 0.62, 0.05, "b", 0.32], [17.05, 0.6, -0.1, "a", 0.28], [16.95, 0.66, 0.2, "c", 0.25]]:
		add(ore, M + "Rocks/Cave_Rocks/cave_rocks_%s.tscn" % r[3], Vector3(r[0], r[1], r[2]), randf() * 360.0, r[4])
	interactable(ore.get_child(0), "Look", {"display_name": "Wózek z urobkiem", "description": "Urobek po starej ekipie. Stał tu czterdzieści lat i dalej świeci. Bolko przebiera go kamień po kamieniu i odkłada najlepsze kawałki na bok.", "solid": false, "padding": 0.2})
	# powder store: the far corner, away from the fire
	# a dim lantern over the old carts in the north-west corner
	wall_lantern(camp, "CartsLantern", Vector3(8.3, 1.45, -4.35), 0.0, 0.8, 6.0, false)
	var powder := group(camp, "Powder")
	for b in [[16.1, -3.9], [16.85, -3.95], [16.45, -3.25]]:
		add(powder, P + "Barrel.gltf", Vector3(b[0], 0.0, b[1]), randf() * 360.0)
	var fuse_chest := add(powder, P + "Chest_Wood.gltf", Vector3(15.3, 0.0, -3.95), 0.0, 0.8, "FuseChest")
	look(fuse_chest, "Skrzynia z lontami", "Zamknięta na kłódkę. Klucz Mirosław nosi na szyi.", true)
	look(powder.get_child(0), "Beczki z prochem", "Proch Mirosława. Trzyma go jak najdalej od ogniska i od ludzi. Na wieku jednej beczki ktoś wydrapał nożem: NIE PALIĆ.", true)

#endregion

#region East room: command and supply

func _command(camp: Node3D, wood: Node3D) -> void:
	# between the hall posts at x 24 and 27 (z -3.1); Racibor stands behind it
	var table := add(camp, P + "Table_Large.gltf", Vector3(25.5, 0.0, -2.2), 0.0, 1.0, "MapTable")
	interactable(table, "MapTableUse", {"display_name": "Stół z mapą", "prompt_text": "Zaplanuj wyprawę", "action": 2})
	add(camp, P + "Scroll_1.gltf", Vector3(25.3, TABLE_TOP, -2.15), 80.0, 1.6)
	add(camp, P + "Scroll_2.gltf", Vector3(26.2, TABLE_TOP, -2.3), 10.0, 1.2)
	add(camp, P + "Book_Stack_1.gltf", Vector3(26.65, TABLE_TOP, -2.5), 20.0)
	add(camp, P + "Coin_Pile.gltf", Vector3(24.6, TABLE_TOP, -1.9), 0.0)
	candle(camp, P + "CandleStick_Triple.gltf", Vector3(24.45, TABLE_TOP, -2.45), 1.4, 5.0)
	add(camp, P + "Chair_1.gltf", Vector3(26.35, 0.0, -3.5), 0.0)
	var ledger := add(camp, P + "BookStand.gltf", Vector3(27.75, 0.0, -2.2), -60.0, 1.0, "Ledger")
	look(ledger, "Księga zarządcy", "Równe rubryki: ludzie, zapasy, urobek. Przy urobku na razie same zera. Na ostatniej stronie, drobno: „Kniaź czeka”.", true)
	var banner := add(camp, P + "Banner_1.gltf", Vector3(24.0, 2.55, -4.3), 0.0, 1.0, "KniazBanner")
	look(banner, "Chorągiew Kniazia", "Herb Jacyntów: srebrny gród na czerwonym polu. Racibor powiesił ją pierwszego dnia, zanim ktokolwiek rozpakował swoje rzeczy.")
	var bed := add(camp, P + "Bed_Twin1.gltf", Vector3(22.0, 0.0, -3.2), 0.0, 1.0, "LeaderBed")
	look(bed, "Łóżko zarządcy", "Prawdziwe łóżko, zniesione z góry w częściach. Jedyne w obozie.", true)
	add(camp, P + "Chest_Wood.gltf", Vector3(27.5, 0.0, -4.0), 0.0, 0.9, "PayChest")
	var seat := skinned(camp, "GuardSeat", "res://material/kenney_wood.tres")
	add(seat, K + "box.glb", Vector3(21.4, 0.0, -1.3), 25.0, 2.1)
	wall_lantern(camp, "CommandLantern", Vector3(20.2, 1.35, -1.6), 90.0, 1.6, 8.0)
	wall_lantern(camp, "CommandLantern2", Vector3(28.4, 1.35, -4.35), 0.0, 1.3, 7.0, false)

func _supply(camp: Node3D) -> void:
	# no look on the stall: Tekla stands right behind it and has to stay easy to talk to
	add(camp, P + "Stall_Empty.gltf", Vector3(24.6, 0.0, 3.35), 180.0, 1.0, "SupplyStall")
	box_body(camp, "StallBlock", Vector3(1.84, 1.0, 0.93), Vector3(24.6, 0.5, 3.35))
	add(camp, P + "Rope_1.gltf", Vector3(24.1, 0.93, 3.3), 30.0)
	add(camp, P + "SmallBottles_1.gltf", Vector3(25.0, 0.93, 3.2), 0.0)
	add(camp, P + "Pouch_Large.gltf", Vector3(25.35, 0.93, 3.4), 40.0)
	candle(camp, P + "CandleStick.gltf", Vector3(24.65, 0.93, 3.45), 0.7, 3.5)
	add(camp, P + "Rope_3.gltf", Vector3(22.7, 0.0, 3.95), 10.0)
	add(camp, P + "Rope_2.gltf", Vector3(22.6, 0.1, 3.9), 70.0)
	add(camp, P + "Barrel.gltf", Vector3(26.55, 0.0, 3.95), 0.0)
	add(camp, P + "Barrel.gltf", Vector3(27.3, 0.0, 4.0), 40.0)
	add(camp, P + "Crate_Wooden.gltf", Vector3(28.2, 0.0, 3.9), -12.0)
	add(camp, P + "FarmCrate_Empty.gltf", Vector3(28.15, 0.93, 3.9), 5.0)
	add(camp, P + "Bag.gltf", Vector3(23.05, 0.0, 3.35), 200.0)
	add(camp, P + "Shelf_Small_Bottles.gltf", Vector3(26.95, 1.45, 4.35), 180.0)
	wall_lantern(camp, "SupplyLantern", Vector3(25.8, 1.35, 4.4), 180.0, 1.0, 6.5)

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
	interactable(east_sign, "EastExitUse", {"display_name": "Drogowskaz", "prompt_text": "Wróć do obozu · 2 h", "action": 2})
	var west_panel := add(barricades, M + "Panel_Wood/panel_wood_a.tscn", Vector3(-1.8, 0.0, 3.0), 90.0, 1.0, "WestBoards")
	interactable(west_panel, "WestBoardsLook", {"display_name": "Zabity deskami chodnik", "description": "Zachodni chodnik zabity deskami. Zza nich słychać, jak co jakiś czas osypuje się żwir.\n\nNa wyprawę wyruszasz od stołu z mapą w obozie.", "solid": false})
	box_body(barricades, "WestBlock", Vector3(0.4, 4.0, 4.2), Vector3(-1.8, 2.0, 3.0))
	var west_sign := add(signs, K + "signpost-single.glb", Vector3(-2.7, 0.0, 1.5), 90.0, 3.5, "WestSign")
	interactable(west_sign, "WestExitUse", {"display_name": "Drogowskaz", "prompt_text": "Wróć do obozu · 2 h", "action": 2})

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

## Spawn, travel and NPC places (yaw 0 = facing +Z for NPCs, -Z for the player).
func _markers() -> void:
	var markers := group(root3d, "Markers")
	marker(markers, "SpawnBed", Vector3(8.4, 0.0, 3.3), -90.0)
	marker(markers, "CampReturn", Vector3(18.3, 0.0, 2.4), 90.0)
	marker(markers, "EastEntry", Vector3(37.2, 0.0, 3.0), -90.0)
	marker(markers, "WestEntry", Vector3(-3.4, 0.0, 3.0), 90.0)
	# Mirosław: fire (morning, evening), powder store (day), dark corner (when he breaks)
	marker(markers, "MiroslawFire", Vector3(12.4, 0.0, 3.4), -107.0)
	marker(markers, "MiroslawPowder", Vector3(16.5, 0.0, -2.5), 180.0)
	marker(markers, "MiroslawCorner", Vector3(7.0, 0.0, -3.85), 0.0)
	# Bolko: common table, ore cart, his bedroll, by the player's bed, turned away
	marker(markers, "BolkoEat", Vector3(13.3, 0.0, 0.22), 0.0)
	marker(markers, "BolkoStorage", Vector3(17.4, 0.0, 1.0), -153.0)
	marker(markers, "BolkoEvening", Vector3(5.4, 0.0, 2.9), 90.0)
	marker(markers, "BolkoBed", Vector3(8.6, 0.0, 2.6), -54.0)
	marker(markers, "BolkoAway", Vector3(19.3, 0.0, 1.2), 90.0)
	# Racibor: head of the common table, behind the map table
	marker(markers, "RaciborEat", Vector3(15.75, 0.0, 1.05), -90.0)
	marker(markers, "RaciborTable", Vector3(25.5, 0.0, -3.25), 0.0)
	# Tekla: kettle, stall, on a crate next to Racibor's table when under watch
	marker(markers, "TeklaCook", Vector3(9.55, 0.0, 2.55), 70.0)
	marker(markers, "TeklaCounter", Vector3(24.6, 0.0, 4.08), 180.0)
	marker(markers, "TeklaGuarded", Vector3(21.4, 0.0, -1.3), 25.0)
	# Dobrawa: with Racibor, at the old ore cart, alone by the dark west tunnel
	marker(markers, "DobrawaLeader", Vector3(27.6, 0.0, -1.2), -134.0)
	marker(markers, "DobrawaCarts", Vector3(8.2, 0.0, -3.2), 36.0)
	marker(markers, "DobrawaApart", Vector3(1.4, 0.0, 0.6), -90.0)

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
