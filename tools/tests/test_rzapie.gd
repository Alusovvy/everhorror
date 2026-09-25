extends "res://tools/tests/test_base.gd"
## Racibor's deposits quest and the flooded sump: the bundle, marking the vein (the stake
## appears), the way back when the day is already over.

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.hour = 18.0

func scenario() -> void:
	step("start: day 1, 18:00")
	await start_world(_setup)

	step("Racibor: the deposits quest (1 h)")
	await converse("Racibor", ["Znam mapy dziadka.", "Muszę iść."])
	check(gs.quest_state(&"zloza") == "active" and gs.has_item("kwit"), "deposits quest, rope permit")

	step("the sump (2 h): bundle, vein (1 h)")
	await travel("rzapie")
	check(is_equal_approx(gs.hour, 21.0), "21:00 in the sump (%s)" % gs.clock_text())
	await use(world.get_node("Locations/Rzapie/Bundle/BundlePickup"))
	check(gs.has_item("tobolek") and gs.has_note(&"list_konfraterni"), "bundle and the Confraternity letter")
	check(not world.get_node("Locations/Rzapie/Bundle").visible, "the bundle is gone from the landing")
	check(not world.get_node("Locations/Rzapie/Stake/VeinStake").visible, "no stake before marking")
	await use(world.get_node("Locations/Rzapie/VeinMark"))
	check(gs.has_flag("vein_rzapie") and "rzapie" in gs.quests[&"zloza"]["entries"], "vein marked and logged")
	check(is_equal_approx(gs.hour, 22.0), "marking cost 1 h (%s)" % gs.clock_text())
	check(world.get_node("Locations/Rzapie/Stake/VeinStake").visible, "stake appears at the marked vein")

	step("back to the camp (2 h, allowed after 22:00)")
	await use(world.get_node("Locations/Rzapie/Sign/ExitSign/RzapieExitUse"))
	await wait_idle()
	check(gs.is_day_over() and String(gs.get_flag("location", "")) == "", "back in the camp, day over (%s)" % gs.clock_text())
