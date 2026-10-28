extends SceneTree
var out := ""
var world: Node
func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	process_frame.connect(_run, CONNECT_ONE_SHOT)
func _shot(name: String) -> void:
	for i in 12:
		await process_frame
	root.get_texture().get_image().save_png("%s/%s.png" % [out, name])
func _run() -> void:
	var gs = root.get_node("GameState")
	gs.set_flag("intro_done")
	for f in ["visited_east", "visited_wyrobisko", "visited_rzapie", "west_blasted", "kaplica_known", "met_racibor", "met_miroslaw", "met_bolko", "met_tekla", "met_wszebor", "met_nasir", "drudzy_met", "sabina_joined", "vein_east_1", "vein_rzapie", "vein_wyrobisko_1"]:
		gs.set_flag(f)
	gs.day = 4
	gs.hour = 9.5
	gs.player_health = 55
	gs.player_sanity = 40
	gs.set_flag("fever_nasir")
	gs.start_quest("zloza")
	gs.start_quest("kilof")
	for it in ["bandaze", "lekarstwo", "nalewka", "lina", "kilof", "swieca"]:
		gs.give_item(it)
	gs.give_item("swieca")
	world = load("res://scene/world.tscn").instantiate()
	root.add_child(world)
	world.get_node("HUD").visible = false
	for i in 30:
		await process_frame
	var map = world.get_node("MapScreen")
	map.open_table()
	map._select(&"wyrobisko")
	await _shot("ui_map_table")
	map.close()
	gs.set_flag("location", "wyrobisko")
	map.open_field()
	await _shot("ui_map_field")
	map.close()
	gs.clear_flag("location")
	var inv = world.get_node("Inventory")
	inv.open()
	await _shot("ui_inventory")
	inv.close()
	var nb = world.get_node("Notebook")
	nb.open()
	nb.tabs.current_tab = 2
	await _shot("ui_people")
	nb.tabs.current_tab = 0
	await _shot("ui_quests")
	nb.close()
	var summary = world.get_node("ExpeditionSummary")
	summary.present({"day": 4, "start": 8.0, "places": ["east", "wyrobisko"], "veins": 1, "items": {"obuch": 1, "grzyb": 2}, "events": ["Spotkałeś wyprawę Drugich z Exitium. Jedna z nich ma zamieszkać w obozie."], "health": 80, "sanity": 60})
	await _shot("ui_summary")
	quit()
