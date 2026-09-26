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
	step("start: day 2, 16:00, travel to the chapel (3 h + 1 h scouting)")
	await start_world(_setup)
	await travel("kaplica")
	check(is_equal_approx(gs.hour, 20.0), "20:00 in the chapel (%s)" % gs.clock_text())
	check(not world.get_node("Locations/Kaplica/Letter").visible, "the niche is closed")

	step("the riddle: one wrong try, then the answer")
	await use(world.get_node("Locations/Kaplica/RiddleWall/WallRiddle"))
	await drive(["Gwiazda.", "Płomień.", "Oko.", "Spróbuję jeszcze raz.", "Gwiazda.", "Kamień.", "Zamknięte oko."])
	await wait_idle()
	check(gs.has_flag("wall_open") and is_equal_approx(gs.hour, 21.0), "wall open after one wrong try (%s)" % gs.clock_text())
	check("otwarta" in gs.quests[&"sciana"]["entries"], "quest entry for the open wall")

	step("the niche opens")
	var wall := world.get_node("Locations/Kaplica/RiddleWall")
	# the slab moves 1.3–2.6 s after the dialogue closes; headless frames can be slower
	var deadline := Time.get_ticks_msec() + 6000
	while wall.get_node("Slab").position.y > -0.45 and Time.get_ticks_msec() < deadline:
		await frames(5)
	check(wall.get_node("Slab").position.y < -0.45, "the slab went down 0.9 m (y %.2f)" % wall.get_node("Slab").position.y)
	check(wall.get_node("NicheLight").visible, "the niche glows")

	step("letter and crystal, back (task_12: half of the 3 h walk, past 22:00)")
	await use(world.get_node("Locations/Kaplica/Letter/LetterPickup"))
	await use(world.get_node("Locations/Kaplica/Crystal/CrystalPickup"))
	check(gs.has_note(&"list_dziadka") and gs.has_item("krysztal"), "letter read, crystal taken")
	check("list" in gs.quests[&"slady"]["entries"], "grandfather's trail updated")
	await go_on("oboz")
	check(gs.is_day_over() and String(gs.get_flag("location", "")) == "", "back in the camp at 22:30, day over (%s)" % gs.clock_text())
	check(is_equal_approx(gs.hour, 22.5), "the way back took 1 h 30 min")
