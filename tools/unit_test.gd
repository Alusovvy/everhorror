extends SceneTree
## Usage: godot --headless --path . --script res://tools/unit_test.gd
## Pure-logic checks, no world scene: the expedition graph (including the "route around
## closed places" regression from task_05), the Polish number helpers, the hero's bands
## and wound rules, payload flags and the Fourteenth's clue counter; task_09: durations ("5 min"),
## the time log, locked-response reasons (ResponseLock) and Hrapek's meeting rules; task_14: who
## has not arrived loses no sanity at night or in the tremor (NPC-18), the same version in
## project.godot / CHANGELOG.md / CZYTAJ_MNIE.txt and a well-formed menu label (UI-6, TECH-2),
## the bands, the time categories, the dawn and vein logs and their save (ZAP-12, CZAS-16) and the
## run report itself (ZAP-11). Runs in ~2 s.

var _failures := 0
var gs
## Loaded at runtime: a compile-time reference would drag GameState in before the autoloads exist.
var Ex
var Lock
var Story
var Info
var Report

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	Ex = load("res://script/expeditions.gd")
	Lock = load("res://script/response_lock.gd")
	Story = load("res://script/story_director.gd")
	Info = load("res://script/build_info.gd")
	Report = load("res://script/run_report.gd")

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

	_task14_arrival()
	_task14_bands()
	_task14_version()
	_task14_logs_and_categories()
	_task14_report()

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(0 if _failures == 0 else 1)

#region task_14

## NPC-18: nobody who has not arrived loses sanity at night or in the tremor; B2: nothing asks
## whether Hieronim has gone.
func _task14_arrival() -> void:
	print("--- task_14: who has not arrived loses no sanity (NPC-18)")
	gs.reset()
	_check(not gs.has_arrived(&"sabina") and not gs.has_arrived(&"ottokar") and not gs.has_arrived(&"hieronim") and not gs.has_arrived(&"welf"), "at the start nobody from Exitium has arrived")
	_check(gs.has_arrived(&"wszebor") and gs.has_arrived(&"dobrawa") and gs.has_arrived(&"hrapek"), "everyone else is part of the week from the start")
	for id in load("res://script/field_schedule.gd").DRUDZY:
		_check(gs.ARRIVAL_FLAG.has(id), "%s (an Exitium arrival) has an arrival flag" % id)
	var director = Story.new()
	var before := {}
	for id in [&"sabina", &"ottokar", &"hieronim", &"welf", &"wszebor", &"dobrawa"]:
		before[id] = gs.sanity(id)
	gs.day = 1
	director._resolve_night()
	_check(gs.sanity(&"sabina") == before[&"sabina"], "night 1: Sabina keeps her sanity before she has moved in")
	_check(gs.sanity(&"wszebor") == before[&"wszebor"] - 2, "night 1: Wszebor, out on his shift, loses 2 as before")
	_check(gs.sanity(&"dobrawa") == before[&"dobrawa"], "night 1: Dobrawa is not touched yet (she comes on day 2)")
	gs.day = 2
	director._resolve_night()
	_check(gs.sanity(&"dobrawa") == before[&"dobrawa"] - 5, "night 2: Dobrawa loses 5 as before")
	gs.day = 5
	director._resolve_night()
	for id in [&"sabina", &"ottokar", &"hieronim", &"welf"]:
		_check(gs.sanity(id) == before[id], "night 5: the tremor skips %s before the meeting" % id)
	_check(gs.has_flag("tremor_seen"), "the tremor still happens")

	gs.reset()
	gs.set_flag("drudzy_met")
	_check(gs.has_arrived(&"ottokar") and gs.has_arrived(&"hieronim") and gs.has_arrived(&"welf") and not gs.has_arrived(&"sabina"), "the meeting brings the three mages, not yet Sabina")
	for id in [&"sabina", &"ottokar", &"hieronim", &"welf"]:
		before[id] = gs.sanity(id)
	gs.day = 3
	director._resolve_night()
	_check(gs.sanity(&"ottokar") == before[&"ottokar"] and gs.sanity(&"sabina") == before[&"sabina"], "night 3: the mages have no nightly loss, Sabina is not in the camp yet")
	gs.set_flag("sabina_joined")
	gs.day = 4
	director._resolve_night()
	_check(gs.sanity(&"sabina") == before[&"sabina"] - 2, "night 4: Sabina, now in the camp, loses 2")
	gs.day = 5
	director._resolve_night()
	_check(gs.sanity(&"ottokar") == before[&"ottokar"] - 2 and gs.sanity(&"welf") == before[&"welf"] - 2 and gs.sanity(&"hieronim") == before[&"hieronim"] - 2, "night 5: after the meeting the tremor shakes the mages like the others (-2)")
	_check(gs.sanity(&"sabina") == before[&"sabina"] - 6, "night 5: Sabina loses 2 and the tremor 2 more (%d)" % (before[&"sabina"] - gs.sanity(&"sabina")))
	gs.set_npc_status(&"welf", "gone")
	var welf_sanity: int = gs.sanity(&"welf")
	gs.day = 5
	director._resolve_night()
	_check(gs.sanity(&"welf") == welf_sanity, "a mage who has left is not shaken")

	print("--- task_14: nothing asks whether Hieronim has gone")
	director.npcs = {&"hieronim": null, &"ottokar": null, &"welf": null}
	gs.set_flag("hieronim_gone")
	_check("hieronim" in director._roaming_drudzy(&"rzapie"), "Hieronim can turn up near the camp whatever that old flag says")
	_check(not FileAccess.get_file_as_string("res://script/story_director.gd").contains("hieronim_gone\""), "story_director.gd no longer reads hieronim_gone")
	director.free()

## The band helpers behind the notebook and the report.
func _task14_bands() -> void:
	print("--- task_14: bands as values (the run report reads the same thresholds as the notebook)")
	_check(gs.health_band_of(75) == "zdrowy" and gs.health_band_of(74) == "poobijany" and gs.health_band_of(44) == "ranny" and gs.health_band_of(19) == "ciezko_ranny" and gs.health_band_of(0) == "martwy", "health bands by value")
	_check(gs.mind_band_of(60) == "spokojny" and gs.mind_band_of(59) == "niespokojny" and gs.mind_band_of(34) == "na_krawedzi" and gs.mind_band_of(0) == "zalamany", "the hero's mind bands by value")
	_check(gs.sanity_band_of(40) == "spokojny" and gs.sanity_band_of(39) == "niespokojny" and gs.sanity_band_of(19) == "na_krawedzi" and gs.sanity_band_of(0) == "zalamany", "an NPC's mind bands by value")
	_check(gs.trust_band_of(20) == "ufa" and gs.trust_band_of(5) == "lubi" and gs.trust_band_of(0) == "dystans" and gs.trust_band_of(-1) == "nie_ufa", "trust bands by value")
	_check(gs.fatigue_band_of(74.9) == "wypoczety" and gs.fatigue_band_of(75.0) == "zmeczony" and gs.fatigue_band_of(90.0) == "ledwo_idzie" and gs.fatigue_band_of(100.0) == "wyczerpany", "fatigue bands by value")
	gs.reset()
	gs.player_health = 30
	gs.player_sanity = 20
	gs.player_fatigue = 80.0
	_check(gs.health_band() == gs.health_band_of(30) and gs.mind_band() == gs.mind_band_of(20) and gs.fatigue_band() == gs.fatigue_band_of(80.0), "the old band functions say the same")

## TECH-2 / UI-6: one version everywhere, and a label the menu can show.
func _task14_version() -> void:
	print("--- task_14: the version is the same everywhere (TECH-2); the menu label (UI-6)")
	var version := str(ProjectSettings.get_setting("application/config/version", ""))
	_check(RegEx.create_from_string("^\\d+\\.\\d+\\.\\d+$").search(version) != null, "project.godot has application/config/version (\"%s\")" % version)
	var changelog := FileAccess.get_file_as_string("res://CHANGELOG.md")
	var top := RegEx.create_from_string("(?m)^## \\[([\\d.]+)\\]").search(changelog)
	_check(top != null and top.get_string(1) == version, "CHANGELOG.md starts with version %s (heading: %s)" % [version, top.get_string(1) if top else "none"])
	_check(changelog.contains("Zgodność ze spec: `"), "the newest CHANGELOG entry names the spec it matches")
	var readme := FileAccess.get_file_as_string("res://tools/release/CZYTAJ_MNIE.txt").get_slice("\n", 0)
	var head := RegEx.create_from_string("\\(demo ([\\d.]+)\\)").search(readme)
	_check(head != null and head.get_string(1) == version, "the CZYTAJ_MNIE.txt header names version %s (header: %s)" % [version, head.get_string(1) if head else "none"])
	var label: String = Info.label()
	_check(RegEx.create_from_string("^\\d+\\.\\d+\\.\\d+ · spec ([0-9a-f]{7}\\+?|unknown)$").search(label) != null, "BuildInfo.label() looks like \"0.5.3 · spec 8e46253\" (\"%s\")" % label)
	_check(label.begins_with(version + " · spec "), "the label starts with the project version")

## CZAS-16 categories, the dawn log and the vein log (ZAP-12), and their save.
func _task14_logs_and_categories() -> void:
	print("--- task_14: time categories (CZAS-16)")
	var expected := [
		["Rozmowa z Teklą", "rozmowy"], ["Wyprawa: Stara sztolnia", "drogi"], ["Droga: Kaplica", "drogi"], ["Powrót do obozu", "drogi"],
		["Znaczenie żyły", "żyły"], ["Odkuwanie nacieku", "żyły"],
		["Mirosław wysadza zawał", "pomoc"], ["Praca przy pompach", "pomoc"], ["Opatrywanie ran", "pomoc"],
		["Ottokar przerysowuje mapy", "pomoc"], ["Ryby w stawie z Wszeborem", "pomoc"], ["Ryby w stawie z Mirosławem", "pomoc"],
		["Wieczór przy ogniu", "obóz"], ["Kości z Sobkiem", "obóz"], ["Przy ogniu z Mirosławem", "obóz"], ["Z Mirosławem w kącie", "obóz"],
		["Obracanie kręgów", "eksploracja"], ["Rozbijanie skrytki", "eksploracja"],
		[gs.item_name("bandaze"), "przedmioty"], [gs.item_name("swieca"), "przedmioty"],
		["Sen", "sen"], ["Coś zajęło czas", "inne"], ["Coś zupełnie nowego", "inne"],
	]
	for pair in expected:
		_check(Report.categorize(pair[0]) == pair[1], "\"%s\" counts as %s (%s)" % [pair[0], pair[1], Report.categorize(pair[0])])
	_check(Report.CATEGORIES.size() == 9 and Report.CATEGORIES.has("inne"), "nine categories, the last one is the catch-all")

	print("--- task_14: the dawn log and the vein log (ZAP-12)")
	gs.reset()
	_check(gs.dawn_log.size() == 1 and int(gs.dawn_log[0]["day"]) == 1, "a new game starts the dawn log with day 1")
	var first: Dictionary = gs.dawn_log[0]
	_check(first["npcs"]["wszebor"]["arrived"] == true and first["npcs"]["sabina"]["arrived"] == false, "day 1: the five are in the week, Sabina has not arrived")
	_check(int(first["veins"]) == 0 and int(first["hero"]["health"]) == 100, "day 1: no veins, a healthy hero")
	_check(gs.vein_log.is_empty(), "no veins logged yet")
	gs.set_flag("location", "east")
	gs.set_flag("vein_east_1")
	_check(gs.vein_log.size() == 1 and gs.vein_log[0]["id"] == "east_1" and int(gs.vein_log[0]["day"]) == 1 and is_equal_approx(float(gs.vein_log[0]["at"]), 6.0), "a marked vein is logged with its day and hour")
	gs.set_flag("vein_east_1")
	_check(gs.vein_log.size() == 1, "the same vein is not logged twice")
	gs.mark_veins_for_player(1)
	_check(gs.vein_log.size() == 2 and gs.vein_log[1].get("via", "") == "ottokar", "veins marked for the hero by Ottokar are logged as his")
	gs.clear_flag("location")
	gs.set_flag("some_flag_of_day_one")
	gs.start_next_day()
	_check(gs.dawn_log.size() == 2 and int(gs.dawn_log[1]["day"]) == 2 and int(gs.dawn_log[1]["veins"]) == 2, "day 2 has its dawn entry, with the veins marked so far")
	_check("some_flag_of_day_one" in gs.dawn_log[1]["flags_new"] and not "some_flag_of_day_one" in gs.dawn_log[0]["flags_new"], "the flags set during the day are listed with the next dawn")
	gs.record_dawn()
	_check(gs.dawn_log.size() == 2, "recording the same dawn again replaces the entry")
	gs.set_flag("later_flag")
	gs.start_next_day()
	_check(not "some_flag_of_day_one" in gs.dawn_log[2]["flags_new"] and "later_flag" in gs.dawn_log[2]["flags_new"], "a dawn lists only what is new since the last one")

	print("--- task_14: the logs survive a save, and an old save has none")
	var saved: Dictionary = JSON.parse_string(JSON.stringify(gs.save_state()))
	gs.reset()
	gs.load_state(saved)
	_check(gs.dawn_log.size() == 3 and gs.vein_log.size() == 2, "a save keeps both logs (%d dawns, %d veins)" % [gs.dawn_log.size(), gs.vein_log.size()])
	_check(int(gs.dawn_log[2]["day"]) == 3 and int(gs.vein_log[0]["day"]) == 1, "the numbers come back from JSON as floats and read as ints")
	var old: Dictionary = saved.duplicate(true)
	old.erase("dawn_log")
	old.erase("vein_log")
	gs.load_state(old)
	_check(gs.dawn_log.is_empty() and gs.vein_log.is_empty(), "a save from before version 6 loads with empty logs")
	gs.start_next_day()
	_check(gs.dawn_log.size() == 1 and gs.dawn_log[0].get("partial", false) == true and gs.dawn_log[0]["flags_new"].is_empty(), "its first new dawn is marked partial, with no \"new flags\" claimed")
	gs.set_flag("after_old_save")
	gs.start_next_day()
	_check(gs.dawn_log[1]["flags_new"] == ["after_old_save"], "the next dawn lists just the flag set since (%s)" % [gs.dawn_log[1]["flags_new"]])
	var save_manager = root.get_node("SaveManager")
	_check(int(save_manager.SAVE_VERSION) == 6, "the save version is 6")

## ZAP-11: the report built from a short synthetic week.
func _task14_report() -> void:
	print("--- task_14: the run report (ZAP-11)")
	gs.reset()
	# Day 1: a talk, a trip, a vein, the way back, the fire, bed.
	gs.add_quiet_time(0.25)
	gs.commit_time(0.25, "Rozmowa z Teklą", 6.0)
	gs.advance_time(2.0, "Wyprawa: Stara sztolnia")
	gs.set_flag("location", "east")
	gs.advance_time(1.0, "Znaczenie żyły")
	gs.set_flag("vein_east_1")
	gs.clear_flag("location")
	gs.advance_time(1.0, "Powrót do obozu")
	gs.advance_time(1.0, "Wieczór przy ogniu")
	gs.log_time(gs.hour, 0.0, "Sen")
	gs.start_next_day()
	# Day 2: the Exitium expedition is met.
	gs.advance_time(0.5, "Coś zupełnie nowego")
	gs.set_flag("met_wszebor")
	gs.set_flag("drudzy_met")
	gs.log_time(gs.hour, 0.0, "Sen")
	gs.start_next_day()
	# Day 3: Sabina moves in. Late bedtime, nothing unused.
	gs.set_flag("sabina_joined")
	gs.advance_time(16.0, "Droga: Kaplica")
	gs.log_time(gs.hour, 0.0, "Sen")
	gs.start_next_day()
	# Day 4 is in progress.
	var data: Dictionary = Report.collect(Report.ENDING_IN_PROGRESS)
	var days: Array = data["days"]
	_check(days.size() == 4 and int(data["now"]["day"]) == 4, "a report on day 4 has four days")
	var time1: Dictionary = days[0]["time"]
	_check(int(time1["minutes"]["rozmowy"]) == 15 and int(time1["minutes"]["drogi"]) == 180 and int(time1["minutes"]["żyły"]) == 60 and int(time1["minutes"]["obóz"]) == 60, "day 1 by category: 15 + 180 + 60 + 60 min")
	var sum := 0
	for category in Report.CATEGORIES:
		sum += int(time1["minutes"][category])
	_check(sum == int(time1["total"]) and int(time1["total"]) == gs.logged_minutes(1), "the categories add up to the day's log (%d min)" % int(time1["total"]))
	_check(int(time1["unused_before_sleep_min"]) == 645, "day 1: 10 h 45 min unused when he went to bed (%s)" % [time1["unused_before_sleep_min"]])
	_check(int(days[1]["time"]["minutes"]["inne"]) == 30, "an unknown label counts as inne")
	_check(int(days[2]["time"]["unused_before_sleep_min"]) == 0, "day 3: no time left at bed")
	_check(days[3]["time"]["unused_before_sleep_min"] == null and not bool(days[3]["time"]["available"]), "day 4: still going, nothing unused to report")
	_check(int(days[0]["dawn"]["veins"]) == 0 and int(days[1]["dawn"]["veins"]) == 1, "veins at dawn: 0, then 1")
	_check(days[0]["dawn"]["hero"]["mind_band"] == "spokojny" and days[0]["dawn"]["hero"]["health_band"] == "zdrowy", "the hero's bands at the first dawn")
	var sabina_by_day: Array = days.map(func(d): return d["dawn"]["people"]["sabina"]["arrived"])
	var ottokar_by_day: Array = days.map(func(d): return d["dawn"]["people"]["ottokar"]["arrived"])
	_check(sabina_by_day == [false, false, false, true], "Sabina arrives at the dawn after she moved in %s" % [sabina_by_day])
	_check(ottokar_by_day == [false, false, true, true], "Ottokar at the dawn after the meeting %s" % [ottokar_by_day])
	_check(days[0]["dawn"]["people"]["sabina"]["mind_band"] == null and days[3]["dawn"]["people"]["sabina"]["mind_band"] != null, "someone who has not arrived has no bands")
	_check(data["veins"].size() == 1 and data["veins"][0]["place"] == "Stara sztolnia" and data["veins"][0]["time"] == "09:15", "the vein table: Stara sztolnia at 09:15 (%s)" % [data["veins"]])
	_check(not bool(data["quota"]["met"]) and data["quota"]["reached_at"] == null and int(data["quota"]["veins"]) == 1, "the quota is not met")
	_check(data["ending"]["id"] == "w_trakcie" and data["ending"]["title"] == "w trakcie", "from the pause the ending is \"w trakcie\"")
	var choice_ids: Array = data["choices"].map(func(c): return c["id"])
	for id in ["krysztal", "tekla", "welf", "nasir", "miroslaw", "dobrawa"]:
		_check(id in choice_ids, "the key choices include %s" % id)

	var parsed: Dictionary = JSON.parse_string(Report.to_json(data))
	_check(parsed["build"]["version"] == Info.version() and parsed["days"].size() == 4 and int(parsed["days"][0]["time"]["total"]) == 315, "the JSON reads back")
	var markdown: String = Report.to_markdown(data)
	_check(markdown.contains(Info.version()) and markdown.contains("spec " + Info.SPEC_SHA), "the Markdown names the build")
	_check(markdown.contains("## Czas według kategorii") and markdown.contains("## Bohater o świcie") and markdown.contains("## Ludzie o świcie") and markdown.contains("## Żyły") and markdown.contains("## Kluczowe wybory"), "the Markdown has all its sections")
	var sabina_row := ""
	var ottokar_row := ""
	var head_section := markdown.get_slice("### Głowa", 1).get_slice("### Zdrowie", 0)
	for line in head_section.split("\n"):
		if line.begins_with("| %s " % gs.NPCS[&"sabina"].display_name):
			sabina_row = line
		if line.begins_with("| %s " % gs.NPCS[&"ottokar"].display_name):
			ottokar_row = line
	_check(sabina_row.contains("| — | — | — | "), "Sabina's row has dashes before she arrived (%s)" % sabina_row)
	_check(ottokar_row.contains("| — | — | "), "Ottokar's row has dashes too (%s)" % ottokar_row)
	_check(not head_section.contains("Hagiwara") and markdown.contains("Jeszcze nie poznani: ") and markdown.contains("Hagiwara"), "people not met are left out of the tables and listed below them")

	var path: String = Report.write(Report.ENDING_IN_PROGRESS)
	_check(path.begins_with("user://raporty/przebieg-") and path.ends_with(".md") and FileAccess.file_exists(path), "write() puts przebieg-….md under user://raporty (%s)" % path)
	var json_path := path.trim_suffix(".md") + ".json"
	_check(FileAccess.file_exists(json_path) and JSON.parse_string(FileAccess.get_file_as_string(json_path)) is Dictionary, "…and the .json beside it, valid")
	var shown: String = Report.display_path(path)
	_check(shown.ends_with(path.get_file()) and shown.contains("raporty") and not shown.begins_with("user:") and (OS.get_name() != "Windows" or not shown.contains("/")), "display_path gives the real folder of the file, as Windows writes it (%s)" % shown)
	var path_again: String = Report.write(Report.ENDING_IN_PROGRESS)
	_check(path_again != path and FileAccess.file_exists(path_again), "two reports in the same second do not overwrite each other")
	for file in [path, json_path, path_again, path_again.trim_suffix(".md") + ".json"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(file))

	print("--- task_14: a report from a save with no logs says so")
	var saved: Dictionary = JSON.parse_string(JSON.stringify(gs.save_state()))
	saved.erase("dawn_log")
	saved.erase("vein_log")
	gs.load_state(saved)
	var thin: Dictionary = Report.collect(Report.ENDING_IN_PROGRESS)
	_check(thin["days"][0]["dawn"] == null and thin["days"][3]["dawn"] == null, "no dawn data for any day")
	var thin_md: String = Report.to_markdown(thin)
	_check(thin_md.contains("brak danych"), "the Markdown says \"brak danych\"")

	print("--- task_14: the quota time comes from the vein log")
	gs.reset()
	for vein in gs.vein_ids().slice(0, 12):
		gs.advance_time(1.0, "Znaczenie żyły")
		gs.set_flag("vein_" + vein)
	var done: Dictionary = Report.collect(Report.ENDING_WEEK)
	_check(bool(done["quota"]["met"]) and done["quota"]["reached_at"] != null and int(done["quota"]["reached_at"]["day"]) == 1 and done["quota"]["reached_at"]["time"] == "18:00", "12 veins at one an hour from 06:00: the quota at 18:00 (%s)" % [done["quota"]["reached_at"]])
	_check(Report.to_markdown(done).contains("norma osiągnięta: dzień 1, 18:00"), "the Markdown says when")

#endregion

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
