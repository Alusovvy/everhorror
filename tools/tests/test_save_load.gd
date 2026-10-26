extends "res://tools/tests/test_base.gd"
## Save in the evening, go to the sump and take the bundle, then load: the hour, items, the
## taken pickup, world changes and the camp schedule all come back as saved.

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.set_flag("west_blasted")
	gs.hour = 18.0
	# task_14 (ZAP-12): one vein marked at 18:00 on day 1, to be found in the vein log after the load.
	gs.set_flag("vein_east_1")

func scenario() -> void:
	step("start: day 1, 18:00")
	await start_world(_setup)
	var slot_existed: bool = sm.has_save(3)

	step("save, travel to the sump, take the bundle")
	check(sm.save_game(3), "saved to slot 3")
	check(int(sm.read_slot(3).get("version", 0)) == 6, "task_14: the save is version 6 (ZAP-12)")
	await travel("rzapie")
	await use(world.get_node("Locations/Rzapie/Bundle/BundlePickup"))
	check(gs.has_item("tobolek"), "bundle taken")

	step("load slot 3")
	sm.load_game(3)
	await frames(15)
	world = current_scene
	await wait_idle()
	check(is_equal_approx(gs.hour, 18.0) and not gs.has_item("tobolek"), "18:00 without the bundle (%s)" % gs.clock_text())
	check(world.get_node("Locations/Rzapie/Bundle").visible, "the bundle is back in the sump")
	check(world.get_node("Camp/WestSegment/BlastDebris").visible, "blast state restored")
	check(String(gs.get_flag("location", "")) == "", "back in the camp, not in the sump")
	check(gs.npc_place(&"tekla") == "kuchnia" and npc("Tekla").marker_name == "TeklaCook", "camp schedule re-applied")
	check(gs.dawn_log.size() == 1 and int(gs.dawn_log[0]["day"]) == 1, "task_14: the dawn log came back with the save")
	check(gs.vein_log.size() == 1 and gs.vein_log[0]["id"] == "east_1" and int(gs.vein_log[0]["day"]) == 1 and is_equal_approx(float(gs.vein_log[0]["at"]), 18.0), "task_14: the vein log came back (east_1, day 1, 18:00)")
	if not slot_existed:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(sm.slot_path(3)))
