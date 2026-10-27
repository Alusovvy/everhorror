extends "res://tools/tests/test_base.gd"
## task_05: the Exitium expedition met on the first trip of day 3, Sabina joins the camp when
## you come back, then the roaming mages: who can turn up where, and the wounded Welf saved
## with bandages.

func _init() -> void:
	timeout_s = 120.0

func scenario() -> void:
	step("day 3, 09:00: to the old working; the Drudzy are there")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.set_flag("announcement_done")
		gs.set_flag("visited_east")
		gs.day = 3
		gs.hour = 9.0)
	await use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	var map = world.get_node("MapScreen")
	map._select(&"wyrobisko")
	map._go()
	await wait_for_vn(20.0)
	await drive(["Kim jesteście?", "Mapy dziadka nie są na sprzedaż."])
	await wait_idle()
	check(gs.has_flag("drudzy_met"), "met the Exitium expedition")
	for who in ["Ottokar", "Sabina", "Hieronim", "Welf"]:
		check(npc(who).present and gs.npc_place(StringName(who.to_lower())) == "teren", "%s stands in the working" % who)
	check(not gs.has_flag("sabina_joined"), "Sabina joins only when you come back")

	step("back to the camp: Sabina joins")
	await go_on("oboz")
	check(gs.has_flag("sabina_joined") and not npc("Ottokar").present, "Sabina in the camp, the others gone")
	check(npc("Sabina").present and gs.is_in_camp(&"sabina"), "Sabina has a place in the camp (%s)" % gs.npc_place(&"sabina"))
	check(last_summary.contains("Exitium"), "the meeting is in the summary")

	step("task_14 (NPC-18): the night after Sabina has moved in wears her down, and not the mages")
	var story = world.get_node("Story")
	var sabina_before: int = gs.sanity(&"sabina")
	var mages_before := {}
	for id in [&"ottokar", &"hieronim", &"welf"]:
		mages_before[id] = gs.sanity(id)
	story._resolve_night()
	check(gs.sanity(&"sabina") == sabina_before - 2, "Sabina loses 2 (%d -> %d)" % [sabina_before, gs.sanity(&"sabina")])
	check(gs.sanity(&"ottokar") == mages_before[&"ottokar"] and gs.sanity(&"hieronim") == mages_before[&"hieronim"] and gs.sanity(&"welf") == mages_before[&"welf"], "the mages lose nothing at night (met, no tremor yet)")

	step("who can turn up where")
	var shallow: Array = story._roaming_drudzy(&"rzapie")
	check("hieronim" in shallow and not "ottokar" in shallow and not "welf" in shallow, "near the camp only Hieronim (%s)" % [shallow])
	var deep: Array = story._roaming_drudzy(&"grota")
	check(deep == ["welf"] and gs.has_flag("welf_wounded"), "the first deep place: the wounded Welf (%s)" % [deep])

	step("day 5: the wounded Welf in the grotto, bandages")
	gs.day = 5
	gs.hour = 7.0
	gs.set_flag("visited_wyrobisko")
	gs.give_item("bandaze")
	await travel("grota")
	gs.set_flag("encounter_place", "grota")
	gs.set_flag("encounter_npcs", ["welf"])
	story.apply_world_state()
	check(npc("Welf").present and npc("Welf").pose == &"Crouch_Idle", "Welf crouches at the wall, wounded")
	await converse("Welf", ["Mam bandaże."])
	check(gs.has_flag("welf_helped") and not gs.has_item("bandaze"), "Welf bandaged")
	await go_on("oboz")
	check(not gs.has_flag("welf_lost"), "Welf is not lost")
	check(last_summary.contains("Welfa"), "the rescue is in the summary")
