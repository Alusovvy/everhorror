extends "res://tools/tests/test_base.gd"
## Day 2: the bundle back to Tekla (the rope), Dobrawa's glossary, the decline (the collapse and
## the richest vein; Dobrawa is away in the afternoon), and the report to Racibor.

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.set_flag("west_blasted")
	gs.set_flag("met_racibor")
	gs.set_flag("met_tekla")
	gs.set_flag("tekla_asked_favor")
	gs.start_quest(&"towar")
	gs.start_quest(&"zloza")
	gs.set_flag("vein_rzapie")
	gs.quest_log(&"zloza", "rzapie")
	gs.give_item("tobolek")
	gs.add_note(&"list_konfraterni")
	gs.day = 2

func scenario() -> void:
	step("start: day 2, 06:00")
	await start_world(_setup)

	step("Tekla: the bundle back (1 h)")
	await converse("Tekla", ["Mam twój tobołek.", "Nikomu nie powiem.", "Muszę iść."])
	check(gs.has_item("lina") and gs.quest_state(&"towar") == "done", "rope from Tekla, bundle quest done")

	step("Dobrawa: the chapel and the glossary (1 h)")
	await converse("Dobrawa", ["Jesteś z Drugich?", "Czego tu właściwie szukasz?", "Pod jaskinią", "Muszę iść."])
	check(gs.has_flag("kaplica_known") and gs.has_note(&"slowniczek"), "chapel known, glossary")
	check(is_equal_approx(gs.hour, 8.0), "08:00 (%s)" % gs.clock_text())

	step("the decline (3 h + 1 h scouting): collapse, vein (1 h), back (3 h)")
	await travel("upadowa")
	check(is_equal_approx(gs.hour, 12.0), "12:00 at the decline (%s)" % gs.clock_text())
	await use(find_interactable("Locations/Upadowa", "Zawał"))
	check(gs.has_flag("saw_charge") and "zawal" in gs.quests[&"slady"]["entries"], "the collapse looks like a charge")
	await use(world.get_node("Locations/Upadowa/VeinMark"))
	check(gs.has_flag("vein_upadowa"), "decline vein marked")
	await go_on("oboz")
	check(is_equal_approx(gs.hour, 16.0), "16:00 back (%s)" % gs.clock_text())
	check(npc("Dobrawa").present and gs.npc_place(&"dobrawa") == "na_uboczu", "Dobrawa back from the tunnels, standing apart")

	step("Racibor: report two veins (1 h)")
	await converse("Racibor", ["Mam zaznaczone żyły.", "Muszę iść."])
	check(gs.has_flag("rac_first_report") and gs.has_note(&"raport_archiwum") and gs.quest_state(&"zloza") == "active", "first report accepted, archive note, the quota goes on")
	check(gs.has_flag("racibor_wants_upadowa"), "Racibor wants the decline")
