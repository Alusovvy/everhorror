extends "res://tools/tests/test_base.gd"
## The second night and the last morning: Racibor's announcement (with the player's objection),
## then the map table ends the demo with the summary.

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.set_flag("west_blasted")
	gs.set_flag("racibor_wants_upadowa")
	gs.set_flag("bolko_knows_fate")
	gs.add_note(&"list_dziadka")
	gs.give_item("krysztal")
	gs.day = 2
	gs.hour = 21.5

func scenario() -> void:
	step("start: day 2, 21:30")
	await start_world(_setup)

	step("sleep: dream, day card, announcement")
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Tak, idę spać"])
	await drive([])   # the dream
	await wait_for_vn()
	await drive(["Dziadek sam zasypał upadową."])
	await wait_idle()
	check(gs.day == 3 and gs.has_flag("announcement_done"), "day 3 began with the announcement")
	check(gs.has_flag("plan_upadowa"), "Racibor plans to open the decline")

	step("the map table ends the demo")
	await use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	await seconds(2.5)   # the end screen fades in over real time
	check(world.get_node("ScreenFade/EndPanel").visible, "end screen shown")
	print("   summary: ", world.get_node("ScreenFade/EndPanel/Center/VBox/Summary").text.replace("\n", " | "))
