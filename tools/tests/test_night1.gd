extends "res://tools/tests/test_base.gd"
## The first night: sleeping, the dream, deciphering the grandfather's message, and day 2 in
## the camp (Dobrawa has come down, everyone is at breakfast).

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.set_flag("west_blasted")
	gs.set_flag("mir_comforted")
	gs.add_note(&"szyfr")
	gs.add_note(&"klucz")
	gs.hour = 21.5

func scenario() -> void:
	step("start: day 1, 21:30")
	await start_world(_setup)

	step("sleep: prompt, dream, day card")
	await use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await drive(["Tak, idę spać"])
	await wait_idle()
	check(gs.day == 2 and is_equal_approx(gs.hour, 6.0), "day 2, 06:00 (%s)" % gs.clock_text())
	check(gs.has_note(&"odszyfrowana") and gs.has_flag("kaplica_known"), "message deciphered overnight, chapel known")

	step("task_14 (NPC-18): the night does not touch Sabina, who is not here yet")
	check(gs.sanity(&"sabina") == gs.npc_data(&"sabina").start_sanity, "Sabina keeps her sanity (%d)" % gs.sanity(&"sabina"))
	check(gs.sanity(&"wszebor") == gs.npc_data(&"wszebor").start_sanity - 2, "Wszebor, out on his shift, lost 2")
	check(gs.dawn_log.size() == 2 and int(gs.dawn_log[1]["day"]) == 2, "the dawn of day 2 is in the dawn log (ZAP-12)")
	check(gs.dawn_log[1]["npcs"]["sabina"]["arrived"] == false and gs.dawn_log[1]["npcs"]["dobrawa"]["arrived"] == true, "…with Sabina not yet arrived and Dobrawa here")

	step("day 2 morning in the camp")
	check(npc("Dobrawa").present and gs.npc_place(&"dobrawa") == "dowodztwo", "Dobrawa at Racibor's table")
	check(gs.npc_place(&"racibor") == "stol" and gs.npc_place(&"tekla") == "kuchnia", "breakfast again")
	check(gs.npc_place(&"miroslaw") in ["ognisko", "kat"], "Mirosław by the fire or in the corner (%s, sanity %d)" % [gs.npc_place(&"miroslaw"), gs.sanity(&"miroslaw")])
