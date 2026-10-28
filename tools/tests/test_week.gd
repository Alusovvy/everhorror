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

	step("task_14 (UI-7, ZAP-11): SAVE REPORT in the pause menu writes the report and says where")
	var reports_before := _report_files()
	var pause = world.get_node("PauseMenu")
	var button: Button = pause.get_node("Root/Center/Content/MainButtons/ReportButton")
	var order: Array = pause.get_node("Root/Center/Content/MainButtons").get_children().map(func(n): return n.name)
	check(order.find("ReportButton") == order.find("OptionsButton") + 1 and order.find("MainMenuButton") == order.find("ReportButton") + 1, "SAVE REPORT sits between OPTIONS and MAIN MENU %s" % [order])
	check(button.text == "SAVE REPORT", "the button says SAVE REPORT")
	button.pressed.emit()
	var status: Label = pause.get_node("Root/ReportStatus")
	var new_files := _new_report_files(reports_before)
	check(status.visible and status.text.begins_with("Report saved:\n") and status.text.contains("raporty"), "the menu shows the path, in English (%s)" % status.text.replace("\n", " | "))
	check(new_files.size() == 2 and new_files.any(func(f): return f.ends_with(".md")) and new_files.any(func(f): return f.ends_with(".json")), "a .md and a .json appeared (%s)" % [new_files])
	for f in new_files:
		if f.ends_with(".json"):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(sm.report_dir + "/" + f))
			check(parsed is Dictionary and parsed["ending"]["id"] == "w_trakcie" and int(parsed["now"]["day"]) == 4, "from the pause the report is \"w trakcie\", day 4")
			check(parsed["days"].size() == 4 and parsed["days"][3]["dawn"] != null and bool(parsed["days"][3]["dawn"]["people"]["nasir"]["fever"]), "four days, the dawn of day 4 with Nasir's fever")
	_remove_reports(new_files)

	step("death: a wounded hero takes another blow; retry from the morning")
	var before_death := _report_files()
	var health_morning: int = gs.player_health
	gs.player_health = 30
	gs.hurt_player(40, "Test")
	await seconds(2.5)
	var buttons := "ScreenFade/EndPanel/Center/VBox/Buttons/"
	check(world.get_node("ScreenFade/EndPanel").visible and world.get_node(buttons + "RetryButton").visible, "death screen with 'retry from morning'")
	check(world.get_node("ScreenFade/EndPanel/Center/VBox/Title").text == "Nie żyjesz", "death title")
	# task_20: the end screen does not pause the tree, but the play-time counter stands still on it.
	var at_death: int = gs.play_ms
	await frames(20)
	check(gs.play_frozen and gs.play_ms == at_death, "task_20: the play-time counter stands still on the death screen (%d ms)" % at_death)
	world.get_node(buttons + "RetryButton").pressed.emit()
	await frames(15)
	world = current_scene
	await wait_idle()
	check(gs.day == 4 and is_equal_approx(gs.hour, 6.0) and gs.player_health == health_morning, "back at dawn of day 4 (%s, health %d)" % [gs.clock_text(), gs.player_health])
	check(gs.has_fever(&"nasir") and not world.get_node("ScreenFade/EndPanel").visible, "the morning state is back")
	check(not gs.play_frozen and gs.play_ms >= at_death and gs.play_ms < at_death + 5000, "task_20: the retry keeps the day's counter as it was at death, not doubled (%d, was %d)" % [gs.play_ms, at_death])
	check(FileAccess.file_exists(sm.slot_path(0)), "the dawn autosave is on disk")
	check(_new_report_files(before_death).is_empty(), "task_14 (ZAP-11): the hero's death writes no report of its own")
	check(gs.dawn_log.size() == 2 and int(gs.dawn_log[1]["day"]) == 4, "task_14 (ZAP-12): the retry brings back the dawn log of that morning (days %s)" % [gs.dawn_log.map(func(d): return int(d["day"]))])

	step("the tremor leaves marks in the world")
	gs.set_flag("tremor_seen")
	for path in ["Locations/Przekop/TremorCrack/Look", "Locations/Wyrobisko/Pillar_b/TremorLook", "Locations/Szczelina/FreshCrack/Look"]:
		var mark: Area3D = world.get_node(path)
		mark.refresh_from_state()
		check(mark.collision_layer != 0, "%s active after the tremor" % path)

	step("the evening at the fire: the seat opens at 20:00 and the tales play")
	var seat: Area3D = world.get_node("Camp/CampProps/Campfire/SeatUse")
	check(seat.collision_layer == 0, "seat off in the morning")
	gs.hour = 20.0
	world.get_node("Story").apply_world_state()
	check(seat.collision_layer != 0, "seat on in the evening")
	var sanity_before: int = gs.player_sanity
	await use(seat)
	await drive([])
	await wait_idle()
	check(gs.done_today("campfire") and gs.player_sanity == sanity_before + 5, "the fireside tales play (+5 sanity)")
	check(is_equal_approx(gs.hour, 21.0), "the evening costs an hour (%s)" % gs.clock_text())
	world.get_node("Story").apply_world_state()
	check(seat.collision_layer == 0, "seat gone after the evening scene")

	step("day 7 evening without the quota: the expedition leaves without you")
	reports_before = _report_files()
	gs.quest_log(&"czternasty", "kreski_rzapie")
	for f in ["saw_marks_rzapie", "saw_marks_pillar", "opened_grabiec_cache", "saw_bread"]:
		gs.set_flag(f)
	# Nasir too weak: the night hauls him up and the fever quest fails with its entry.
	gs.start_quest(&"goraczka")
	gs.npcs[&"nasir"]["health"] = 15
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
	check(gs.has_flag("fourteenth_gift") and gs.has_item("lampa"), "the fourteenth answered with the lamp")
	check(gs.quest_state("goraczka") == "failed" and "wywieziony" in gs.quests[&"goraczka"]["entries"], "Nasir hauled up: the quest fails with its notebook entry")
	var summary: String = world.get_node("ScreenFade/EndPanel/Center/VBox/Summary").text
	check(summary.contains("Czternasty: ktoś odpowiedział ci lampą"), "the fourteenth in the summary")
	print("   summary: ", summary.replace("\n", " | "))
	var end_menu_button: Button = world.get_node("ScreenFade/EndPanel/Center/VBox/Buttons/MenuButton")
	var screen_height: float = world.get_viewport().get_visible_rect().size.y
	check(end_menu_button.get_global_rect().end.y <= screen_height and end_menu_button.get_global_rect().position.y >= 0.0, "task_14: the end screen's buttons are on screen (bottom %.0f of %.0f)" % [end_menu_button.get_global_rect().end.y, screen_height])

	step("task_14 (ZAP-11): the end of the week writes the run report for this ending")
	var ending_files := _new_report_files(reports_before)
	check(ending_files.size() == 2, "one .md and one .json for the ending (%s)" % [ending_files])
	check(summary.contains("Raport przebiegu zapisano: raporty/przebieg-"), "the end screen says where the report went")
	for f in ending_files:
		var text := FileAccess.get_file_as_string(sm.report_dir + "/" + f)
		if f.ends_with(".md"):
			check(text.contains("zakończenie: Zostałeś sam") and text.contains("## Kluczowe wybory") and text.contains("Nasir: wywieziony"), "the Markdown names the ending and the key choices (Nasir hauled up)")
			check(text.contains("Jeszcze nie poznani:") and text.contains("## Ludzie o świcie"), "people the hero never met are listed apart, not in the tables")
		else:
			var parsed = JSON.parse_string(text)
			check(parsed is Dictionary and parsed["ending"]["id"] == "zostales_sam" and int(parsed["now"]["day"]) == 8, "the JSON says \"zostales_sam\" on day 8")
			check(parsed["days"].size() == 8 and parsed["days"][7]["dawn"] != null, "eight days, the last dawn included")
			var tekla = parsed["choices"].filter(func(c): return c["id"] == "nasir")
			check(tekla.size() == 1 and tekla[0]["value"] == "wywieziony", "the choices list has Nasir's fate")
	_remove_reports(ending_files)

func _report_files() -> Array:
	if not DirAccess.dir_exists_absolute(sm.report_dir):
		return []
	return Array(DirAccess.get_files_at(sm.report_dir)).filter(func(f): return f.begins_with("przebieg-"))

func _new_report_files(before: Array) -> Array:
	return _report_files().filter(func(f): return not f in before)

func _remove_reports(files: Array) -> void:
	for f in files:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(sm.report_dir + "/" + f))
