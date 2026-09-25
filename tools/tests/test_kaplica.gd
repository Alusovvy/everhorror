extends "res://tools/tests/test_base.gd"
## The chapel: the riddle wall in the VN (a wrong try costs an hour), the rings turn and the
## slab sinks after the dialogue closes, the letter and the crystal in the niche.

func _setup() -> void:
	gs.set_flag("intro_done")
	gs.set_flag("kaplica_known")
	gs.add_note(&"slowniczek")
	gs.start_quest(&"sciana")
	gs.day = 2
	gs.hour = 16.0

func scenario() -> void:
	step("start: day 2, 16:00, travel to the chapel (3 h)")
	await start_world(_setup)
	await travel("kaplica")
	check(is_equal_approx(gs.hour, 19.0), "19:00 in the chapel (%s)" % gs.clock_text())
	check(not world.get_node("Locations/Kaplica/Letter").visible, "the niche is closed")

	step("the riddle: one wrong try, then the answer")
	await use(world.get_node("Locations/Kaplica/RiddleWall/WallRiddle"))
	await drive(["Gwiazda.", "Płomień.", "Oko.", "Spróbuję jeszcze raz.", "Gwiazda.", "Kamień.", "Zamknięte oko."])
	await wait_idle()
	check(gs.has_flag("wall_open") and is_equal_approx(gs.hour, 20.0), "wall open after one wrong try (%s)" % gs.clock_text())
	check("otwarta" in gs.quests[&"sciana"]["entries"], "quest entry for the open wall")

	step("the niche opens")
	await seconds(3.0)
	var wall := world.get_node("Locations/Kaplica/RiddleWall")
	check(wall.get_node("Slab").position.y < -0.5, "the slab went down (y %.2f)" % wall.get_node("Slab").position.y)
	check(wall.get_node("NicheLight").visible, "the niche glows")

	step("letter and crystal, back (3 h)")
	await use(world.get_node("Locations/Kaplica/Letter/LetterPickup"))
	await use(world.get_node("Locations/Kaplica/Crystal/CrystalPickup"))
	check(gs.has_note(&"list_dziadka") and gs.has_item("krysztal"), "letter read, crystal taken")
	check("list" in gs.quests[&"slady"]["entries"], "grandfather's trail updated")
	await use(world.get_node("Locations/Kaplica/Sign/ExitSign/KaplicaExitUse"))
	await wait_idle()
	check(gs.is_day_over() and String(gs.get_flag("location", "")) == "", "back in the camp, day over (%s)" % gs.clock_text())
