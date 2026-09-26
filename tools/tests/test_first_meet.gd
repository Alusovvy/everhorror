extends "res://tools/tests/test_base.gd"
## task_10: on day 1 only Mirosław, Bolko, Tekla and Racibor are in the camp. The other five are
## on a shift in the first-level rooms (Stara sztolnia, Rząpie, Zawalony chodnik), at most two
## to a room, met there with a "day-1 shift" greeting; from the morning of day 2 everyone is in
## the camp and whoever was not met gets the camp greeting.

var _seen: Array[String] = []

func scenario() -> void:
	step("day 1, 08:00: rooms fixed for the test (the game rolls them)")
	await start_world(func():
		gs.set_flag("intro_done")
		gs.hour = 8.0
		for pair in [["wszebor", "east"], ["sobek", "east"], ["nasir", "rzapie"], ["hagiwara", "rzapie"], ["anzelm", "west"]]:
			gs.set_flag("first_room_%s" % pair[0], pair[1]))
	root.get_node("DialogueManager").got_dialogue.connect(func(line): _seen.append(line.text))
	for id in ["Wszebor", "Nasir", "Hagiwara", "Sobek", "Anzelm"]:
		check(not npc(id).present, "%s not in the camp on day 1" % id)
	for id in ["Miroslaw", "Bolko", "Tekla", "Racibor"]:
		check(npc(id).present, "%s in the camp" % id)

	step("Stara sztolnia: Wszebor and Sobek on their shift")
	await travel("east")
	check(npc("Wszebor").present and npc("Wszebor").marker_name == "EastSpot1", "Wszebor on EastSpot1 (%s)" % npc("Wszebor").marker_name)
	check(npc("Sobek").present and npc("Sobek").marker_name == "EastSpot2", "Sobek on EastSpot2 (%s)" % npc("Sobek").marker_name)
	check(not npc("Nasir").present and not npc("Anzelm").present, "the others are elsewhere")
	check(gs.npc_place(&"wszebor") == "teren", "Wszebor counts as met in the field")
	_seen.clear()
	await converse("Wszebor", ["Muszę iść."])
	check(gs.has_flag("met_wszebor"), "Wszebor met")
	check(_seen_has("Zeszlim tu przed świtem"), "Wszebor's day-1 shift greeting")
	check(not _seen_has("Siadaj, siadaj"), "no camp greeting in the tunnel")
	_seen.clear()
	await converse("Sobek", ["Muszę iść."])
	check(_seen_has("Dziś pilnuję szychty") and not _seen_has("przy śniadaniu"), "Sobek's shift greeting, no \"saw you at breakfast\"")
	check(npc("Wszebor").present and npc("Sobek").present, "after the talks they stay in the room")
	await go_on("oboz")

	step("Rząpie: Nasir and Hagiwara")
	await travel("rzapie")
	check(npc("Nasir").marker_name == "RzapieSpot1" and npc("Hagiwara").marker_name == "RzapieSpot2", "Nasir and Hagiwara in the sump (%s, %s)" % [npc("Nasir").marker_name, npc("Hagiwara").marker_name])
	_seen.clear()
	await converse("Hagiwara", ["Muszę iść."])
	check(_seen_has("Wrócę do obozu jutro"), "Hagiwara's shift greeting")
	await go_on("oboz")

	step("evening of day 1: the camp still has only four")
	gs.hour = 20.5
	world.get_node("Story").apply_world_state()
	await frames(3)
	var present := []
	for id in ["Wszebor", "Nasir", "Hagiwara", "Sobek", "Anzelm"]:
		if npc(id).present:
			present.append(id)
	check(present.is_empty(), "the night shift is still out (%s)" % str(present))

	step("day 2 morning: all five in the camp; Anzelm (behind the rubble) gets the camp greeting")
	gs.start_next_day()
	world.get_node("Story").apply_world_state()
	await frames(3)
	for id in ["Wszebor", "Nasir", "Hagiwara", "Sobek", "Anzelm"]:
		check(npc(id).present and gs.is_in_camp(StringName(id.to_lower())), "%s in the camp on day 2 (%s)" % [id, gs.npc_place(StringName(id.to_lower()))])
	_seen.clear()
	await converse("Anzelm", ["Muszę iść."])
	check(gs.has_flag("met_anzelm") and not _seen_has("Zszedłem z ludźmi na szychtę"), "Anzelm met in the camp, no shift line")

func _seen_has(fragment: String) -> bool:
	for text in _seen:
		if text.contains(fragment):
			return true
	return false
