extends "res://tools/tests/test_base.gd"
## Day 1 from the intro to the evening: the camp schedule, Mirosław and Tekla, the trip east
## (fuses, cipher), the blast and comforting Mirosław.

func scenario() -> void:
	step("new game: intro")
	await start_world()
	check(gs.has_flag("intro_done") and is_equal_approx(gs.hour, 6.0), "intro played, 06:00 (%s)" % gs.clock_text())
	check(gs.npc_place(&"tekla") == "kuchnia" and gs.npc_place(&"racibor") == "stol", "breakfast: Tekla cooks, Racibor eats (%s)" % gs.places)
	check(not npc("Dobrawa").present, "Dobrawa not in the camp yet")

	step("talks cost 5 min an option; a peek-and-leave is free")
	await converse("Miroslaw", ["Co się stało z zachodnim chodnikiem?", "Muszę iść."])
	await converse("Tekla", ["Masz dla mnie jakąś robotę?", "Dobrze, przyniosę.", "Muszę iść."])
	check(gs.quest_state(&"lonty") == "active" and gs.quest_state(&"towar") == "active", "fuse and bundle quests active")
	check(is_equal_approx(gs.hour, 6.25), "three options = 15 min, 06:15 (%s)" % gs.clock_text())
	await converse("Sobek", ["Muszę iść."])
	check(is_equal_approx(gs.hour, 6.25), "leaving at once is free (%s)" % gs.clock_text())
	gs.advance_time(1.0, "Poranek schodzi na drobiazgach")
	await wait_idle()
	check(gs.npc_place(&"tekla") == "lada" and npc("Tekla").marker_name == "TeklaCounter", "work time: Tekla moved to the stall")
	check(gs.npc_place(&"miroslaw") == "proch", "work time: Mirosław at the powder")

	step("east: fuses and cipher (2 h + 1 h scouting), back (2 h)")
	await travel("east")
	check(is_equal_approx(gs.hour, 10.25), "10:15 after travel and scouting (%s)" % gs.clock_text())
	await use(world.get_node("Camp/EastSegment/FuseBox/FuseBoxPickup"))
	await use(world.get_node("MineDeep/Props/Scroll_2_1/Interactable"))
	check(gs.has_item("lonty") and gs.has_note(&"szyfr"), "fuses and cipher")
	await use(world.get_node("Camp/Barricades/Signs/EastSign/EastExitUse"))
	check(world.get_node("MapScreen").visible and world.get_node("MapScreen").mode == 1, "the signpost opens the field map")
	world.get_node("MapScreen").close()
	await go_on("oboz")
	check(is_equal_approx(gs.hour, 12.25), "12:15 back in camp (%s)" % gs.clock_text())
	check(last_summary.contains("Stara sztolnia") and last_summary.contains("Suche lonty"), "expedition summary")

	step("blast (fuses free, the blast 4 h, no extra 5 min), comfort Mirosław")
	await converse("Miroslaw", ["Mam dla ciebie lonty", "Wysadź zawał na zachodzie. (4 h)"])
	check(gs.has_flag("west_blasted") and is_equal_approx(gs.hour, 16.25), "west blasted, 16:15 (%s)" % gs.clock_text())
	check(world.get_node("Camp/WestSegment/BlastDebris").visible, "blast debris visible")
	await converse("Miroslaw", ["Jak się trzymasz?", "Posiedzę z tobą chwilę.", "Muszę iść."])
	check(gs.has_flag("mir_comforted"), "Mirosław comforted (sanity %d)" % gs.sanity(&"miroslaw"))
	check(gs.npc_place(&"miroslaw") == "ognisko", "supper: Mirosław back by the fire")
