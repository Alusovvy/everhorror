extends SceneTree
## Usage: godot --headless --path . --script res://tools/unit_test.gd
## Pure-logic checks, no world scene: the expedition graph (including the "route around
## closed places" regression from task_05), the Polish number helpers, the hero's bands
## and wound rules, payload flags and the Fourteenth's clue counter; task_09: durations ("5 min"),
## the time log, locked-response reasons (ResponseLock) and Hrapek's meeting rules. Runs in ~2 s.

var _failures := 0
var gs
## Loaded at runtime: a compile-time reference would drag GameState in before the autoloads exist.
var Ex
var Lock
var Story

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	Ex = load("res://script/expeditions.gd")
	Lock = load("res://script/response_lock.gd")
	Story = load("res://script/story_director.gd")

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

	print("--- Arrival card: the places passed on the way")
	gs.reset()
	for f in ["visited_east", "visited_kaplica", "kaplica_known"]:
		gs.set_flag(f)
	var via: Array[StringName] = [&"east", &"kaplica", &"kostnica"]
	_check(", ".join(Ex.passed_through(via)) == "Kaplica", "east -> kostnica goes through the chapel (%s)" % ", ".join(Ex.passed_through(via)))
	_check(Ex.passed_through(Ex.path(&"oboz", &"east")).is_empty(), "a direct leg passes nothing")
	_check(not Ex.is_visited(&"kostnica"), "passing through doesn't make a place visited")

	print("--- task_10: the day-1 rooms of the five")
	var worst := 0
	var unplaced := 0
	for roll in 200:
		gs.reset()
		var per_room := {}
		for id in gs.FIRST_MEET:
			var room: StringName = gs.first_room(id)
			if not room in gs.FIRST_ROOMS:
				unplaced += 1
			per_room[room] = int(per_room.get(room, 0)) + 1
		for room in per_room:
			worst = maxi(worst, per_room[room])
	_check(unplaced == 0, "every one of the five gets a first-level room")
	_check(worst <= gs.FIRST_ROOM_CAPACITY, "never more than two to a room (worst %d)" % worst)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	gs.roll_first_rooms(rng)
	var first: Array = gs.FIRST_MEET.map(func(id): return gs.first_room(id))
	rng.seed = 7
	gs.roll_first_rooms(rng)
	_check(first == gs.FIRST_MEET.map(func(id): return gs.first_room(id)), "the same seed gives the same rooms")
	for pair in [["wszebor", "east"], ["nasir", "rzapie"], ["hagiwara", "west"], ["sobek", "east"], ["anzelm", "rzapie"]]:
		gs.set_flag("first_room_%s" % pair[0], pair[1])
	_check(gs.first_room_slot(&"wszebor") == 1 and gs.first_room_slot(&"sobek") == 2, "two in one room take spots 1 and 2")
	_check(gs.away_first_day(&"sobek") and not gs.in_camp_today(&"sobek") and gs.in_camp_today(&"bolko"), "day 1: Sobek out, Bolko in")
	gs.day = 2
	_check(not gs.away_first_day(&"sobek") and gs.in_camp_today(&"sobek"), "day 2: Sobek back in the camp")
	gs.flags.erase("first_room_nasir")
	_check(gs.first_room(&"nasir") in gs.FIRST_ROOMS, "a save without rooms gets them on first ask")
	_check(gs.first_room(&"bolko") == &"", "Bolko has no first room")

	print("--- task_11: an option asked again is free")
	gs.reset()
	_check(not gs.was_asked(&"nasir", "Wiesz coś o pompach?"), "not asked yet")
	gs.mark_asked(&"nasir", "Wiesz coś o pompach?")
	_check(gs.was_asked(&"nasir", "Wiesz coś o pompach?") and not gs.was_asked(&"tekla", "Wiesz coś o pompach?"), "remembered per person")
	var asked_save: Dictionary = JSON.parse_string(JSON.stringify(gs.save_state()))
	gs.reset()
	gs.load_state(asked_save)
	_check(gs.was_asked(&"nasir", "Wiesz coś o pompach?"), "asked options survive save and load")

	print("--- task_12: fatigue and the way back")
	gs.reset()
	gs.set_flag("intro_done")
	gs.advance_time(2.0, "Obóz")
	_check(is_equal_approx(gs.player_fatigue, 4.0), "camp: +2%%/h (%.1f)" % gs.player_fatigue)
	gs.set_flag("location", "east")
	gs.advance_time(2.0, "Tunel")
	_check(is_equal_approx(gs.player_fatigue, 20.0), "tunnels: +8%%/h (%.1f)" % gs.player_fatigue)
	gs.clear_flag("location")
	gs.travelling = true
	gs.advance_time(1.0, "Droga")
	gs.travelling = false
	_check(is_equal_approx(gs.player_fatigue, 28.0), "walking between places counts as tunnels (%.1f)" % gs.player_fatigue)
	gs.rest_by_fire()
	_check(is_equal_approx(gs.player_fatigue, 13.0), "the fire takes 15 off (%.1f)" % gs.player_fatigue)
	gs.player_fatigue = 90.0
	gs.start_next_day()
	_check(is_equal_approx(gs.player_fatigue, 30.0), "a night's sleep takes 60 off (%.1f)" % gs.player_fatigue)
	gs.player_fatigue = 74.0
	_check(gs.fatigue_band() == "wypoczety" and gs.fatigue_text() == "", "below 75: nothing to say")
	gs.player_fatigue = 75.0
	_check(gs.fatigue_band() == "zmeczony", "75: tired")
	gs.player_fatigue = 92.0
	_check(gs.fatigue_band() == "ledwo_idzie", "90: barely walking")
	gs.player_fatigue = 100.0
	_check(gs.is_exhausted() and gs.fatigue_text() == "padasz z nóg", "100: exhausted")
	var to_wyrobisko: Array[StringName] = Ex.path(&"oboz", &"wyrobisko")
	_check(Ex.walk_hours(to_wyrobisko) == 6.0, "exhausted: camp -> old working doubled, 3 h -> 6 h (%.1f)" % Ex.walk_hours(to_wyrobisko))
	gs.player_health = 30
	_check(Ex.walk_hours(to_wyrobisko) == 8.0, "the wound penalty is added after doubling (%.1f)" % Ex.walk_hours(to_wyrobisko))
	gs.player_health = 100
	_check(Ex.walk_hours(to_wyrobisko, false) == 3.0, "without fatigue: 3 h")
	gs.player_fatigue = 0.0
	gs.begin_expedition()
	gs.expedition["outbound_hours"] = 4.5
	gs.set_flag("location", "grota")
	_check(is_equal_approx(Ex.return_hours(), 2.25), "back: half of 4.5 h = 2 h 15 min (%.3f)" % Ex.return_hours())
	gs.expedition["outbound_hours"] = 2.5
	_check(is_equal_approx(Ex.return_hours(), 1.25), "back: half of 2.5 h = 1 h 15 min")
	gs.expedition["outbound_hours"] = 1.0 + 1.0 / 12.0
	_check(is_equal_approx(Ex.return_hours(), 7.0 / 12.0), "back: rounded up to 5 min (%.4f)" % Ex.return_hours())
	gs.player_fatigue = 100.0
	gs.expedition["outbound_hours"] = 4.0
	_check(is_equal_approx(Ex.return_hours(), 2.0), "back is never doubled, even exhausted")
	gs.expedition.erase("outbound_hours")
	gs.player_fatigue = 0.0
	gs.set_flag("location", "east")
	_check(is_equal_approx(Ex.return_hours(), 1.0), "a save without the sum: half of the way home (camp <- east 2 h)")
	gs.player_fatigue = 55.0
	var tired_save: Dictionary = JSON.parse_string(JSON.stringify(gs.save_state()))
	gs.reset()
	gs.load_state(tired_save)
	_check(is_equal_approx(gs.player_fatigue, 55.0), "fatigue survives save and load")

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
	var said: Array[String] = []
	var listen := func(text: String) -> void: said.append(text)
	gs.message.connect(listen)
	gs.player_sanity = 90
	gs.change_player_sanity(-8, "To miejsce cię przygniata")
	_check(said.back() == "To miejsce cię przygniata.", "same band: only the line, no \"Czujesz się: spokojny\" (%s)" % said.back())
	gs.player_sanity = 62
	gs.change_player_sanity(-8, "To miejsce cię przygniata")
	_check(said.back() == "To miejsce cię przygniata. Czujesz się: niespokojny.", "band changed: the new state is named (%s)" % said.back())
	gs.message.disconnect(listen)

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

	print("--- task_09: durations and the time log")
	_check(gs.duration_text(5) == "5 min", "duration: 5 min")
	_check(gs.duration_text(80) == "1 h 20 min", "duration: 1 h 20 min")
	_check(gs.duration_text(120) == "2 h", "duration: 2 h")
	gs.reset()
	gs.advance_time(1.0, "Znaczenie żyły")
	gs.add_quiet_time(10.0 / 60.0)
	gs.commit_time(10.0 / 60.0, "Rozmowa z Bolkiem", 7.0)
	var log_day: Array = gs.time_log.get("1", [])
	_check(log_day.size() == 2 and log_day[0]["why"] == "Znaczenie żyły" and int(log_day[1]["min"]) == 10, "log: one line per action, one per conversation")
	_check(gs.logged_minutes(1) == 70, "log: the day adds up (%d min)" % gs.logged_minutes(1))
	_check(is_equal_approx(gs.hour, 7.0 + 10.0 / 60.0), "quiet time moves the clock once (%s)" % gs.clock_text())
	var saved: Dictionary = gs.save_state()
	gs.reset()
	gs.load_state(JSON.parse_string(JSON.stringify(saved)))
	_check(gs.logged_minutes(1) == 70, "log survives save and load (JSON)")
	var old: Dictionary = saved.duplicate(true)
	old.erase("time_log")
	gs.load_state(old)
	_check(gs.time_log.is_empty(), "a save without a log loads with an empty one")

	print("--- task_09: locked responses (DIA-2)")
	gs.reset()
	_check(Lock.split_and('has_flag("a") and has_item("lina")') == PackedStringArray(['has_flag("a")', 'has_item("lina")']), "split on top-level and")
	_check(Lock.split_and('has_flag("a") or has_item("lina")').is_empty(), "a top-level or is not guessed")
	_check(Lock.split_and('(has_flag("a") or has_flag("b")) and has_item("lina")').size() == 2, "brackets keep their or")
	_check(Lock.reason('has_item("lina")', gs) == "potrzebne: lina", "missing item: greyed with the item")
	_check(Lock.reason('has_item("tobolek")', gs) == "potrzebne: Tobołek Tekli", "proper names keep capitals")
	_check(Lock.reason('day >= 2 and rep("bolko") >= 5', gs) == "", "a later day stays hidden")
	gs.day = 2
	_check(Lock.reason('day >= 2 and rep("bolko") >= 5', gs) == "Bolko jeszcze ci nie ufa", "trust lock: greyed with the reason")
	_check(Lock.reason('quest_state("towar") == "active" and has_item("tobolek")', gs) == "", "an item for a quest not taken stays hidden")
	gs.start_quest("towar")
	_check(Lock.reason('quest_state("towar") == "active" and has_item("tobolek")', gs) != "", "the same with the quest taken: greyed")
	_check(Lock.reason('not has_item("lina")', gs) == "", "a negated item is not a lock")

	print("--- task_09: Hrapek on the way back")
	gs.reset()
	gs.day = 3
	_check(Story.hrapek_due() == "", "not before the rubble is blown")
	gs.set_flag("hrapek_free")
	gs.day = 2
	_check(Story.hrapek_due() == "", "not before day 3")
	gs.day = 3
	_check(Story.hrapek_due() == "meet", "day 3 after the blast: certain")
	gs.set_flag("hrapek_meetings", 1)
	gs.mark_today("hrapek_seen")
	_check(Story.hrapek_due() == "", "once a day")
	var hits := 0
	for d in [3, 4]:
		for place in ["east", "west", "rzapie", "kaplica", "grota"]:
			for h in range(10, 20):
				gs.day = d
				gs.hour = h
				gs.set_flag("location", place)
				gs.clear_flag("hrapek_seen")
				if Story.hrapek_due() == "meet":
					hits += 1
	_check(hits > 10 and hits < 45, "later meetings ~25%% (%d of 100)" % hits)
	gs.day = 5
	gs.clear_flag("hrapek_seen")
	gs.hour = 10.0
	_check(Story.hrapek_due() == "meet", "day 5 with one meeting: the second is certain")
	gs.set_flag("hrapek_dead")
	gs.day = 6
	_check(Story.hrapek_due() == "body", "day 6: the body")
	gs.set_flag("hrapek_meetings", 0)
	_check(Story.hrapek_due() == "", "never met: no body scene")
	gs.change_sanity(&"hrapek", -15)
	_check(gs.sanity(&"hrapek") == 20, "Hrapek's sanity never moves")

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(0 if _failures == 0 else 1)

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
