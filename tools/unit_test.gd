extends SceneTree
## Usage: godot --headless --path . --script res://tools/unit_test.gd
## Pure-logic checks, no world scene: the expedition graph (including the "route around
## closed places" regression from task_05), the Polish number helpers, the hero's bands
## and wound rules, payload flags and the Fourteenth's clue counter. Runs in ~2 s.

var _failures := 0
var gs
## Loaded at runtime: a compile-time reference would drag GameState in before the autoloads exist.
var Ex

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	Ex = load("res://script/expeditions.gd")

	print("--- Expeditions: the graph and trip costs")
	gs.reset()
	gs.set_flag("intro_done")
	_check(Ex.path(&"oboz", &"east") == [&"oboz", &"east"], "direct edge camp -> east")
	_check(Ex.walk_hours(Ex.path(&"oboz", &"east")) == 2.0, "camp -> east takes 2 h")
	_check(Ex.trip_hours(Ex.path(&"oboz", &"east")) == 3.0, "+1 h scouting on the first visit")
	gs.set_flag("visited_east")
	_check(Ex.trip_hours(Ex.path(&"oboz", &"east")) == 2.0, "no scouting the second time")
	gs.player_health = 30
	_check(Ex.walk_hours(Ex.path(&"oboz", &"wyrobisko")) == 5.0, "a wounded hero pays +1 h per leg")
	gs.player_health = 100
	_check(Ex.route_lock(Ex.path(&"oboz", &"upadowa")).contains("prochu"), "west is locked before the blast")

	print("--- Expeditions: the route goes around closed places (task_05 regression)")
	gs.reset()
	gs.set_flag("west_blasted")
	gs.set_flag("pump_running")
	for f in ["visited_rzapie", "visited_pompy", "visited_zalany"]:
		gs.set_flag(f)
	gs.give_item("olej")
	var route: Array = Ex.path(&"oboz", &"galeria")
	_check(&"zalany" in route and Ex.route_lock(route) == "", "no rope: the gallery via the pumps")
	gs.give_item("lina")
	gs.set_flag("mir_dead")
	route = Ex.path(&"oboz", &"szyb")
	_check(not &"west" in route and Ex.route_lock(route) == "", "Mirosław dead: the shaft from below")
	_check(Ex.route_lock(Ex.path(&"oboz", &"upadowa")).contains("Mirosław"), "the decline is gone for good")
	_check(Ex.path(&"oboz", &"nigdzie").is_empty(), "unknown place: empty route")

	print("--- Polish number helpers")
	_check(gs.plural(1, "został", "zostały", "zostało") == "został", "plural: 1")
	_check(gs.plural(3, "został", "zostały", "zostało") == "zostały", "plural: 3")
	_check(gs.plural(5, "został", "zostały", "zostało") == "zostało", "plural: 5")
	_check(gs.plural(12, "został", "zostały", "zostało") == "zostało", "plural: 12 (teens)")
	_check(gs.plural(22, "został", "zostały", "zostało") == "zostały", "plural: 22")
	_check(gs.hours_text(0.5) == "0,5 h", "hours_text uses the Polish comma")
	_check(gs.hours_text(2.0) == "2 h", "hours_text drops .0")
	gs.reset()
	for vein in gs.vein_ids().slice(0, 3):
		gs.set_flag("vein_" + vein)
	_check(gs.veins_acc() == "3 żyły", "veins_acc: 3")
	gs.day = 6
	_check(gs.days_to_deadline() == 1 and gs.days_left_text() == "został jeden dzień", "one day left")
	gs.day = 7
	_check(gs.days_left_text() == "termin mija dziś", "deadline today")

	print("--- The hero: bands and the wound floor")
	gs.reset()
	_check(gs.health_band() == "zdrowy" and gs.mind_band() == "spokojny", "start: healthy and calm")
	gs.hurt_player(100, "Test")
	_check(gs.player_health == 1, "a healthy hero survives the worst blow with 1")
	gs.player_health = 60
	gs.hurt_player(100, "Test")
	_check(gs.player_health == 0, "an already-hurt hero can die")
	gs.reset()
	gs.player_sanity = 34
	_check(gs.mind_band() == "na_krawedzi", "band edge: 34 is on the brink")
	gs.player_sanity = 35
	_check(gs.mind_band() == "niespokojny", "band edge: 35 is uneasy")

	print("--- Payload flags (the day-3 crash regression) and the Fourteenth")
	gs.reset()
	gs.set_flag("encounter_place", "wyrobisko")
	gs.set_flag("encounter_npcs", ["welf"])
	gs.set_flag("nasir_at_pumps", 2)
	_check(gs.has_flag("encounter_place") and gs.has_flag("encounter_npcs") and gs.has_flag("nasir_at_pumps"), "payload flags count as set")
	gs.set_flag("encounter_place", "")
	gs.set_flag("encounter_npcs", [])
	_check(not gs.has_flag("encounter_place") and not gs.has_flag("encounter_npcs"), "empty payloads count as unset")
	_check(gs.fourteenth_clues() == 0, "no clues at the start")
	for f in ["saw_bread", "saw_lamp", "saw_niches", "saw_medal"]:
		gs.set_flag(f)
	_check(gs.fourteenth_clues() == 4, "four clues counted")

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(0 if _failures == 0 else 1)

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
