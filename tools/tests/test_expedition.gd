extends "res://tools/tests/test_base.gd"
## task_05 expedition flow in the world scene: the map table ("WYRUSZ"), scouting a new place,
## [M] onwards to a neighbour, a miner at work there, a vein and a pickup, the way back and the
## expedition summary, then the inventory (using bandages) and a locked place on the map.

func scenario() -> void:
	step("day 2, 08:00, set off east from the map table")
	# Day 2: on day 1 Wszebor is on his first-level shift (task_10), not in the old working.
	await start_world(func():
		gs.set_flag("intro_done")
		gs.day = 2
		gs.hour = 8.0)
	var map = world.get_node("MapScreen")
	await use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	check(map.visible and map.mode == 0, "map table open")
	check(map._blocked_reason(&"west", _path(&"oboz", &"west")).begins_with("Zasypane"), "west locked before the blast")
	map.close()
	await travel("east")
	check(gs.current_place() == &"east" and gs.has_flag("visited_east"), "in the old adit")
	check(is_equal_approx(gs.hour, 11.0), "2 h walk + 1 h scouting: 11:00 (%s)" % gs.clock_text())
	check(not gs.expedition.is_empty(), "expedition under way")

	step("task_16 (ZYL-1, ZYL-2): the old adit has exactly two veins, each glowing and markable; the first one counts 1")
	var glowing := world.get_node("MineDeep/BlueIronVeins").get_children().filter(func(n: Node) -> bool: return not n is Area3D)
	check(glowing.size() == 2, "two glowing rocks in the cave (%d)" % glowing.size())
	var marks := world.get_node("MineDeep").find_children("VeinMark_*", "Area3D", true, false)
	check(marks.size() == 2, "two vein marks in the cave (%d)" % marks.size())
	for mark in marks:
		check(mark.get_parent().name == "BlueIronVeins", "%s stands next to a glowing rock" % mark.name)
	for node in world.get_node("MineDeep").find_children("*", "Area3D", true, false):
		if node.get("display_name") == "Żyła błękitnego żelaza":
			check(String(node.get("on_use_flag")) != "", "a node called a vein can be marked (%s)" % node.name)
	check(gs.veins_mapped() == 0, "no vein marked yet")
	var messages: Array[String] = []
	var on_message := func(text: String) -> void: messages.append(text)
	gs.message.connect(on_message)
	await use(world.get_node("MineDeep/BlueIronVeins/VeinMark_east_1"))
	gs.message.disconnect(on_message)
	check(gs.has_flag("vein_east_1") and gs.veins_mapped() == 1, "east_1 marked, counter at 1 (%d)" % gs.veins_mapped())
	check(messages.any(func(t: String) -> bool: return t.contains("Żyły błękitu: 1 z 12")), "the message says 1 of 12 (%s)" % [messages])
	check(gs.quota_text().begins_with("Żyły błękitu: 1 z 12"), "the quota line says 1 (%s)" % gs.quota_text())
	check(load("res://script/expeditions.gd").veins_text(&"east") == "żyły: 1 z 2 zaznaczone", "the map shows 1 of 2 for the adit")
	check(is_equal_approx(gs.hour, 12.0), "marking took 1 h: 12:00 (%s)" % gs.clock_text())

	step("[M] onwards to the old working (1 h + 1 h scouting)")
	await go_on("wyrobisko")
	check(gs.current_place() == &"wyrobisko", "in the old working")
	check(is_equal_approx(gs.hour, 14.0), "14:00 (%s)" % gs.clock_text())
	check(npc("Wszebor").present and gs.npc_place(&"wszebor") == "teren", "Wszebor hews here by day")

	step("mark a vein (1 h), take the pickaxe head")
	var before: int = gs.veins_mapped()
	await use(find_interactable("Locations/Wyrobisko", "Żyła błękitnego żelaza"))
	check(gs.veins_mapped() == before + 1, "one more vein (%d)" % gs.veins_mapped())
	await use(find_interactable("Locations/Wyrobisko", "Kilof w gruzie"))
	check(gs.has_item("obuch"), "pickaxe head taken")

	step("back to the camp (task_12: half of the 3 h walked = 1 h 30 min), the summary")
	await go_on("oboz")
	check(not gs.is_away() and gs.expedition.is_empty(), "back in the camp, expedition closed")
	check(is_equal_approx(gs.hour, 16.5), "16:30 (%s)" % gs.clock_text())
	check(last_summary.contains("Stara sztolnia") and last_summary.contains("Stare wyrobisko"), "summary lists the places")
	check(last_summary.contains("Obuch kilofa") and last_summary.contains("Nowe żyły na mapie: 2"), "summary lists the pickaxe head and the two veins (the adit's east_1 and the old working's)")

	step("inventory: bandages on a wound")
	gs.player_health = 50
	gs.give_item("bandaze")
	var inventory = world.get_node("Inventory")
	inventory.open()
	check(inventory.visible and gs.is_modal(), "inventory open and modal")
	check(gs.use_item("bandaze") and gs.player_health == 80, "bandages heal 30 (%d)" % gs.player_health)
	inventory.close()
	check(not gs.is_modal(), "inventory closed")

	step("the map goes around closed places")
	gs.set_flag("west_blasted")
	gs.set_flag("pump_running")
	gs.give_item("olej")
	while gs.has_item("lina"):
		gs.take_item("lina")
	var route := _path(&"oboz", &"galeria")
	var ex = load("res://script/expeditions.gd")
	check(&"zalany" in route and ex.route_lock(route) == "", "no rope for the shaft: the gallery by the pumps %s" % str(route))
	gs.give_item("lina")
	gs.set_flag("mir_dead")
	route = _path(&"oboz", &"szyb")
	check(not &"west" in route and ex.route_lock(route) == "", "west sealed: the shaft from below %s" % str(route))
	check(ex.route_lock(_path(&"oboz", &"upadowa")).contains("Mirosław"), "west sealed: the decline is gone for good")

func _path(from: StringName, to: StringName) -> Array[StringName]:
	return load("res://script/expeditions.gd").path(from, to)
