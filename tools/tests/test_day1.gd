extends "res://tools/tests/test_base.gd"
## Day 1 from the intro to the evening: the camp schedule, Mirosław and Tekla, the trip east
## (fuses, cipher), the blast and comforting Mirosław.

var _intro_lines: Array[String] = []

func scenario() -> void:
	step("new game: intro")
	root.get_node("DialogueManager").got_dialogue.connect(func(line): _intro_lines.append(line.text))
	await start_world()
	check(gs.has_flag("intro_done") and is_equal_approx(gs.hour, 6.0), "intro played, 06:00 (%s)" % gs.clock_text())
	check(_intro_lines.any(func(t): return t.contains("w zagrodzie Racibora, za palisadą bez dachu")), "task_17: the intro puts the map table in Racibor's pen, behind the roofless palisade")
	check(not _intro_lines.any(func(t): return t.contains("niską")), "task_17: the intro no longer calls the palisade low")
	var map_messages: Array[String] = []
	gs.message.connect(func(text): map_messages.append(text))
	var map_key := InputEventAction.new()
	map_key.action = &"field_map"
	map_key.pressed = true
	world.get_node("MapScreen")._unhandled_input(map_key)
	check(map_messages.any(func(t): return t.contains("w zagrodzie Racibora")) and not map_messages.any(func(t): return t.contains("kwaterze")), "task_17: [M] in camp says the map table is in Racibor's pen (%s)" % str(map_messages))
	check(not _intro_lines.any(func(t): return t.contains("kwaterze zarządcy") or t.contains("drewnianą ścianką")), "task_14: the old \"manager's quarters behind a wooden partition\" wording is gone")
	check(gs.npc_place(&"tekla") == "kuchnia" and gs.npc_place(&"racibor") == "stol", "breakfast: Tekla cooks, Racibor eats (%s)" % gs.places)
	check(not npc("Dobrawa").present, "Dobrawa not in the camp yet")
	var away := []
	for id in ["Wszebor", "Nasir", "Hagiwara", "Sobek", "Anzelm"]:
		if not npc(id).present:
			away.append(id)
	check(away.size() == 5, "task_10: the five are out on the day-1 shift (%s)" % str(away))

	step("talks cost 5 min an option; a peek-and-leave is free")
	await converse("Miroslaw", ["Co się stało z zachodnim chodnikiem?", "Muszę iść."])
	await converse("Tekla", ["Masz dla mnie jakąś robotę?", "Dobrze, przyniosę.", "Muszę iść."])
	check(gs.quest_state(&"lonty") == "active" and gs.quest_state(&"towar") == "active", "fuse and bundle quests active")
	check(is_equal_approx(gs.hour, 6.25), "three options = 15 min, 06:15 (%s)" % gs.clock_text())
	await converse("Bolko", ["Pójdę już."])
	check(is_equal_approx(gs.hour, 6.25), "leaving at once is free (%s)" % gs.clock_text())
	gs.advance_time(8.0 - gs.hour, "Poranek schodzi na drobiazgach")
	await wait_idle()
	check(gs.npc_place(&"tekla") == "lada" and npc("Tekla").marker_name == "TeklaCounter", "work time: Tekla moved to the stall")
	check(gs.npc_place(&"miroslaw") == "proch", "work time: Mirosław at the powder")

	step("east: fuses and cipher (2 h + 1 h scouting), back (task_12: half of the 2 h walk)")
	await travel("east")
	check(is_equal_approx(gs.hour, 11.0), "11:00 after travel and scouting (%s)" % gs.clock_text())
	await use(world.get_node("Camp/EastSegment/FuseBox/FuseBoxPickup"))
	await use(world.get_node("MineDeep/Props/Scroll_2_1/Interactable"))
	check(gs.has_item("lonty") and gs.has_note(&"szyfr"), "fuses and cipher")
	await use(world.get_node("Camp/Barricades/Signs/EastSign/EastExitUse"))
	check(world.get_node("MapScreen").visible and world.get_node("MapScreen").mode == 1, "the signpost opens the field map")
	world.get_node("MapScreen").close()
	await go_on("oboz")
	check(is_equal_approx(gs.hour, 12.0), "12:00 back in camp, 1 h back (%s)" % gs.clock_text())
	check(last_summary.contains("Stara sztolnia") and last_summary.contains("Suche lonty"), "expedition summary")

	step("blast (fuses free, the blast 4 h, no extra 5 min), comfort Mirosław")
	await converse("Miroslaw", ["Mam dla ciebie lonty", "Wysadź zawał na zachodzie. (4 h)"])
	check(gs.has_flag("west_blasted") and is_equal_approx(gs.hour, 16.0), "west blasted, 16:00 (%s)" % gs.clock_text())
	check(world.get_node("Camp/WestSegment/BlastDebris").visible, "blast debris visible")
	# task_37 (OTW-7): one of three ways, an hour with him.
	var before_comfort: float = gs.hour
	await converse("Miroslaw", ["Jak się trzymasz?", "Posiedzę z tobą w ciszy.", "Muszę iść."])
	check(gs.has_flag("mir_comforted") and String(gs.get_flag("mir_support", "")) == "cisza", "Mirosław comforted, quietly (sanity %d)" % gs.sanity(&"miroslaw"))
	check(gs.hour >= before_comfort + 1.0, "the hour with him (%s)" % gs.clock_text())
	gs.advance_time(18.5 - gs.hour, "Do kolacji")
	await wait_idle()
	check(gs.npc_place(&"miroslaw") == "ognisko", "supper: Mirosław back by the fire")
	check(gs.player_fatigue > 25.0 and gs.fatigue_text() == "", "task_12: a day-1 trip tires, but not yet to words (%.0f%%)" % gs.player_fatigue)
