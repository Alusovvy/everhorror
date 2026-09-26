extends "res://tools/tests/test_base.gd"
## task_09 in the real world: Hrapek on the way back to the camp (day 3 after the blast, the
## certain second meeting on day 5), the fish from Tekla and 5 minutes a conversation option,
## a greyed-out trust lock in the dialogue window, no clock on the HUD, his death in the night
## after day 5 and the body with the ring on the first way back on day 6.

func _init() -> void:
	timeout_s = 150.0

func scenario() -> void:
	step("day 3, 9:00, the west rubble blown")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.set_flag("announcement_done")
		gs.set_flag("met_racibor")
		gs.set_flag("west_blasted")
		gs.set_flag("hrapek_free")
		gs.set_flag("drudzy_met")
		gs.set_flag("sabina_joined")
		gs.set_flag("sabina_arrival_seen")
		# enough veins that Racibor doesn't remind at breakfast
		for vein in gs.vein_ids().slice(0, 8):
			gs.set_flag("vein_" + vein)
		gs.day = 3
		gs.hour = 9.0)
	check(world.get_node_or_null("HUD/Clock") == null, "no clock on the HUD")

	step("to the old adit and back: Hrapek on the way")
	await travel("east")
	await back_to_camp()
	check(vn.current_npc == &"hrapek", "the scene on the way back is Hrapek's")
	await drive(["Co tu robisz?", "Muszę iść."])
	await wait_idle()
	check(gs.has_flag("met_hrapek") and int(gs.get_flag("hrapek_meetings", 0)) == 1, "first meeting counted")
	check(gs.quest_state(&"ryba") == "active", "Ryba dla Hrapka started")
	check(last_summary.contains("Hrapek"), "the expedition summary mentions him")

	step("5 minutes an option: the fish from Tekla")
	gs.set_flag("tekla_owes")
	var before: float = gs.hour
	await converse("Tekla", ["Masz może jakąś rybę?", "Muszę iść."])
	check(gs.has_item("ryba"), "fish from Tekla")
	check(is_equal_approx(gs.hour - before, 5.0 / 60.0), "one option + goodbye = 5 min (%s)" % gs.clock_text())
	var today: Array = gs.time_log.get(str(gs.day), [])
	var last: Dictionary = today[today.size() - 1] if not today.is_empty() else {}
	check(last.get("why", "") == "Rozmowa z Teklą" and int(last.get("min", 0)) == 5, "the time log has the conversation (%s)" % [last])

	step("a trust lock shows greyed out with the reason")
	await use(talk("Bolko"))
	var balloon = vn._balloon
	var deadline := Time.get_ticks_msec() + 15000
	while vn.is_active() and not balloon.responses_menu.visible and Time.get_ticks_msec() < deadline:
		if balloon.dialogue_label.is_typing:
			balloon.dialogue_label.skip_typing()
		elif balloon.is_waiting_for_input:
			balloon.next(balloon.dialogue_line.next_id)
		await frames(2)
	var greyed := ""
	for item in balloon.responses_menu.get_children():
		if item is Button and item.visible and item.disabled:
			greyed = item.text
	check(greyed.contains("Bolko jeszcze ci nie ufa"), "greyed: '%s'" % greyed)
	await drive(["Pójdę już."])
	await wait_idle()

	step("day 5: the second meeting is certain; the fish for Hrapek")
	gs.day = 5
	gs.hour = 9.0
	await travel("east")
	await back_to_camp()
	check(vn.current_npc == &"hrapek", "Hrapek again on day 5")
	await drive(["Mam dla ciebie rybę.", "Muszę iść."])
	await wait_idle()
	check(gs.quest_state(&"ryba") == "done" and int(gs.get_flag("hrapek_meetings", 0)) == 2, "fish eaten, two meetings")

	step("night 5: he dies; the night is one line in the time log")
	gs.hour = 21.5
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Tak, idę spać"])
	await wait_for_vn(20.0)
	await drive([])   # the dream
	await wait_idle(30.0)
	check(gs.day == 6 and gs.has_flag("hrapek_dead"), "day 6, Hrapek dead in the night")
	var night: Array = (gs.time_log.get("5", []) as Array).filter(func(e): return e["why"] == "Sen")
	check(night.size() == 1, "day 5 ends with 'Sen' in the time log")

	step("day 6: the body on the way back, the ring")
	gs.hour = 9.0
	await travel("east")
	await back_to_camp()
	check(vn.current_npc == &"hrapek", "the body scene")
	await drive(["Zabierz pierścień."])
	await wait_idle()
	check(gs.has_item("pierscien") and gs.has_flag("hrapek_found") and gs.npc_status(&"hrapek") == "dead", "the ring taken, Hrapek dead")
	check(world.get_node("Story").hrapek_due() == "", "no more Hrapek")

## [M] → Obóz → back; stops when the Hrapek scene opens (before the walk).
func back_to_camp() -> void:
	var map_screen = world.get_node("MapScreen")
	map_screen.open_field()
	map_screen._select(&"oboz")
	map_screen._go()
	await wait_for_vn(10.0)
