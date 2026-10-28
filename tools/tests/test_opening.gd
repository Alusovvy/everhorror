extends "res://tools/tests/test_base.gd"
## task_37 (spec 04_tresc/otwarcie.md, OTW-1…OTW-10): the three-day opening in the real world
## scene. Only the four in the camp and none of the others anywhere, three places on the map,
## no deciphering in the night, nobody new on day 2, the evening of day 3 brings the Exitium
## expedition, the end screen "Koniec otwarcia" and its run report.

const DEFERRED := ["Wszebor", "Nasir", "Hagiwara", "Sobek", "Anzelm", "Dobrawa", "Sabina", "Ottokar", "Hieronim", "Welf"]

func _init() -> void:
	timeout_s = 150.0

func scenario() -> void:
	step("day 1, 08:00 of a new opening")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.hour = 8.0, true)
	check(gs.opening(), "a new game from the menu is the opening")
	for id in ["Miroslaw", "Bolko", "Tekla", "Racibor"]:
		check(npc(id).present, "%s in the camp" % id)
	check(_present(DEFERRED).is_empty(), "nobody else in the camp (%s)" % str(_present(DEFERRED)))
	var known: Array = Array(load("res://script/expeditions.gd").known_places()).map(func(id): return String(id))
	check(known.has("east") and known.all(func(id): return id in ["east", "west", "upadowa"]), "the map knows only the opening's places (%s)" % str(known))

	step("Stara sztolnia: nobody on a shift, fuses and the cipher")
	await travel("east")
	check(_present(DEFERRED).is_empty(), "no shift in the tunnels (%s)" % str(_present(DEFERRED)))
	await use(world.get_node("Camp/EastSegment/FuseBox/FuseBoxPickup"))
	await use(world.get_node("MineDeep/Props/Scroll_2_1/Interactable"))
	check(gs.has_item("lonty") and gs.has_note(&"szyfr"), "fuses and cipher")
	await go_on("oboz")

	step("night 1 with the cipher and the key: nothing reads itself")
	gs.add_note(&"klucz")
	gs.hour = 21.5
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Tak, idę spać"])
	await wait_idle()
	check(gs.day == 2 and not gs.has_flag("deciphered") and not gs.has_note(&"odszyfrowana"), "day 2, the message still unread")
	check(_present(DEFERRED).is_empty(), "nobody came down the shaft (%s)" % str(_present(DEFERRED)))
	for id in ["wszebor", "nasir", "dobrawa"]:
		check(gs.sanity(StringName(id)) == gs.npc_data(StringName(id)).start_sanity, "the night leaves %s alone" % id)

	step("the papers alone at the bed (1 h)")
	var before: float = gs.hour
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Usiądź sam nad kartką dziadka.", "Szukam liter z kartki w dolnym", "„…kawałek Ich snu.”", "Upadową.", "Jeszcze nie."])
	await wait_idle()
	check(gs.has_flag("deciphered") and gs.hour >= before + 1.0, "read alone in an hour (%s)" % gs.clock_text())

	step("day 3, 17:30 in the camp: the bed brings Exitium, then the end")
	var reports_before := _report_files()
	gs.day = 3
	gs.hour = 17.5
	world.get_node("Story").apply_world_state()
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	check(vn.is_active() and not gs.has_flag("opening_done"), "the bed asks \"Kładziesz się?\" first")
	await _bed_then_finale(["Tak, idę spać", "Po co ci one?", "Nie dostaniesz ich."])
	check(gs.has_flag("opening_done") and String(gs.get_flag("opening_maps", "")) == "odmowa", "the maps refused")
	check(gs.day == 3, "no night after the closing scene")
	check(world.get_node("ScreenFade/EndPanel").visible, "end screen")
	check(world.get_node("ScreenFade/EndPanel/Center/VBox/Title").text == "Koniec otwarcia", "the opening's ending")
	var summary: String = world.get_node("ScreenFade/EndPanel/Center/VBox/Summary").text
	print("   summary: ", summary.replace("\n", " | "))
	check(summary.contains("Tu kończy się otwarcie") and summary.contains("Mapy dziadka: zostały u ciebie") and summary.contains("odczytana w pojedynkę"), "the summary of the opening")
	check(not summary.contains("wymaganych"), "no quota in the opening's summary")
	var fresh := _report_files().filter(func(f): return not f in reports_before)
	check(fresh.size() == 2, "a run report for the ending (%s)" % str(fresh))
	for f in fresh:
		if f.ends_with(".json"):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(sm.report_dir + "/" + f))
			check(parsed is Dictionary and parsed["ending"]["id"] == "koniec_otwarcia", "the JSON says \"koniec_otwarcia\"")

	step("the evening hour alone brings the scene too (a fresh opening, day 3, 17:50)")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 3
		gs.hour = 17.0 + 50.0 / 60.0, true)
	gs.advance_time(0.25, "Czekanie")
	await wait_for_vn()
	check(vn.is_active() and gs.has_flag("opening_done"), "the closing scene starts at 18:00 in the camp")
	await _finale_to_the_end_screen(["Pokazujesz mu mapy"])
	check(String(gs.get_flag("opening_maps", "")) == "pokazane" and world.get_node("ScreenFade/EndPanel").visible, "maps shown, end screen")
	check(not _pause_gap, "the pause menu stays shut from the closing scene to the end screen (no save without the end)")

	step("day 3, trust of Bolko below zero, both notes held: the bed asks, the papers alone work, then sleep brings the finale")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 3
		gs.hour = 10.0
		gs.change_rep(&"bolko", -30)
		gs.add_note(&"szyfr")
		gs.add_note(&"klucz"), true)
	check(gs.rep(&"bolko") < 0 and not gs.has_flag("deciphered"), "Bolko will not sit down with the hero")
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	check(vn.is_active() and not gs.has_flag("opening_done"), "the bed at 10:00 on day 3 does not end the game")
	var alone_hour: float = gs.hour
	await _bed_then_finale(["Usiądź sam nad kartką dziadka.", "Szukam liter z kartki w dolnym", "„…kawałek Ich snu.”", "Upadową.", "Tak, idę spać", "Pokazujesz mu mapy"])
	check(gs.has_flag("deciphered") and gs.has_note(&"odszyfrowana") and gs.hour >= alone_hour + 1.0, "deciphered alone in an hour")
	check(gs.has_flag("opening_done") and gs.day == 3 and world.get_node("ScreenFade/EndPanel").visible, "sleeping then brought the finale, no night")

	step("coming back from an expedition after 18:00 brings the finale")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 3
		gs.hour = 15.5, true)
	await travel("east")
	check(gs.hour > 18.0 and not gs.has_flag("opening_done"), "away after 18:00: nothing yet (%s)" % gs.clock_text())
	await _return_to_the_finale()
	await _finale_to_the_end_screen(["Pokazujesz mu mapy"])
	check(world.get_node("ScreenFade/EndPanel").visible and gs.day == 3, "the end screen after the return")

	step("coming back after 22:00 brings the finale too")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 3
		gs.hour = 15.5, true)
	await travel("east")
	gs.hour = 22.5
	await _return_to_the_finale()
	check(gs.hour >= 23.0, "a late return (%s)" % gs.clock_text())
	await _finale_to_the_end_screen(["Mapy dziadka nie są"])
	check(String(gs.get_flag("opening_maps", "")) == "odmowa" and world.get_node("ScreenFade/EndPanel").visible, "refused, end screen")

	step("Hrapek does not come in the opening either")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 3
		gs.set_flag("hrapek_free"), true)
	check(world.get_node("Story").hrapek_due() == "", "no Hrapek (hrapek_due is empty)")

## True when the pause menu could have opened (no modal) between the closing scene and its end screen.
var _pause_gap := false

## The bed's question and, after "Tak, idę spać", the closing scene: one list of choices for both.
func _bed_then_finale(choices: Array) -> void:
	await drive(choices)
	await _finale_to_the_end_screen(choices)

## Plays the closing scene with what is left of `choices` and waits for the end screen, watching
## that the game stays modal (Esc opens nothing) from the first scene to the end screen.
func _finale_to_the_end_screen(choices: Array) -> void:
	_pause_gap = false
	if not gs.has_flag("opening_done"):
		await wait_for_vn()
	if not choices.is_empty():
		await drive(choices)
	var panel: Control = world.get_node("ScreenFade/EndPanel")
	var deadline := Time.get_ticks_msec() + 8000
	while not panel.visible and Time.get_ticks_msec() < deadline:
		if gs.has_flag("opening_done") and not gs.is_modal():
			_pause_gap = true
		await frames(1)
	await seconds(0.5)
	check(panel.visible, "the end screen")

## Back to the camp by the field map; the expedition summary is closed by hand, then the closing
## scene must start by itself (wait_idle would click through it).
func _return_to_the_finale() -> void:
	var map_screen = world.get_node("MapScreen")
	var summary = world.get_node("ExpeditionSummary")
	map_screen.open_field()
	map_screen._select(&"oboz")
	map_screen._go()
	var deadline := Time.get_ticks_msec() + 20000
	while not vn.is_active() and Time.get_ticks_msec() < deadline:
		if summary.visible:
			summary._close()
		await frames(1)
	check(vn.is_active() and gs.has_flag("opening_done"), "the closing scene starts on the return (%s)" % gs.clock_text())

func _present(names: Array) -> Array:
	return names.filter(func(n): return npc(n).present)

func _report_files() -> Array:
	var dir := DirAccess.open(sm.report_dir)
	return Array(dir.get_files()) if dir else []
