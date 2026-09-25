extends "res://tools/tests/test_base.gd"
## task_05: nights and mornings of the week: Nasir's fever after night 3 and Racibor's reminder
## on day 4, the hero's death with "retry from the morning", and the end of the week without the
## quota (the expedition leaves without the hero).

func _init() -> void:
	timeout_s = 150.0

func scenario() -> void:
	step("day 3, 21:30: sleep; night 3 brings Nasir's fever, day 4 Racibor's reminder")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.set_flag("announcement_done")
		gs.set_flag("met_racibor")
		gs.day = 3
		gs.hour = 21.5)
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Tak, idę spać"])
	await wait_for_vn(20.0)
	await drive([])   # the dream
	await wait_for_vn(25.0)
	await drive(["Znajdę je."])   # the reminder at breakfast
	await wait_idle()
	check(gs.day == 4 and gs.has_fever(&"nasir"), "day 4, Nasir has a fever")
	check(gs.npc_place(&"nasir") == "chory", "Nasir on the sick bed (%s)" % gs.npc_place(&"nasir"))
	check(int(gs.get_flag("reminder_day", 0)) == 4, "Racibor reminded about the quota")

	step("death: a wounded hero takes another blow; retry from the morning")
	var health_morning: int = gs.player_health
	gs.player_health = 30
	gs.hurt_player(40, "Test")
	await seconds(2.5)
	var buttons := "ScreenFade/EndPanel/Center/VBox/Buttons/"
	check(world.get_node("ScreenFade/EndPanel").visible and world.get_node(buttons + "RetryButton").visible, "death screen with 'retry from morning'")
	check(world.get_node("ScreenFade/EndPanel/Center/VBox/Title").text == "Nie żyjesz", "death title")
	world.get_node(buttons + "RetryButton").pressed.emit()
	await frames(15)
	world = current_scene
	await wait_idle()
	check(gs.day == 4 and is_equal_approx(gs.hour, 6.0) and gs.player_health == health_morning, "back at dawn of day 4 (%s, health %d)" % [gs.clock_text(), gs.player_health])
	check(gs.has_fever(&"nasir") and not world.get_node("ScreenFade/EndPanel").visible, "the morning state is back")

	step("day 7 evening without the quota: the expedition leaves without you")
	gs.day = 7
	gs.hour = 21.5
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Tak, idę spać"])
	await wait_for_vn(20.0)
	await drive([])   # the dream
	await wait_for_vn(25.0)
	await drive([])   # left behind
	await seconds(3.0)
	check(world.get_node("ScreenFade/EndPanel").visible, "end screen")
	check(world.get_node("ScreenFade/EndPanel/Center/VBox/Title").text == "Zostałeś sam", "the 'left alone' ending")
	print("   summary: ", world.get_node("ScreenFade/EndPanel/Center/VBox/Summary").text.replace("\n", " | "))
