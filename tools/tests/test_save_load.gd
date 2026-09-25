extends "res://tools/tests/test_base.gd"
## Save in the evening, go to the sump and take the bundle, then load: the hour, items, the
## taken pickup, world changes and the camp schedule all come back as saved.

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.set_flag("west_blasted")
	gs.hour = 18.0

func scenario() -> void:
	step("start: day 1, 18:00")
	await start_world(_setup)
	var slot_existed: bool = sm.has_save(3)

	step("save, travel to the sump, take the bundle")
	check(sm.save_game(3), "saved to slot 3")
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
	if not slot_existed:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(sm.slot_path(3)))
