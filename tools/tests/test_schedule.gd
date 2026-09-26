extends "res://tools/tests/test_base.gd"
## The whole week's camp schedule resolves: every placement points at a marker that exists
## in the scene and no two NPCs share one at the same moment. Sweeps 7 days x 5 hours x 5
## story states (~2500 placements), then spot-checks the miners' field posts.

func scenario() -> void:
	step("boot the world once")
	await start_world(func(): gs.set_flag("intro_done"))
	var story = world.get_node("Story")
	# Loaded at runtime: a compile-time class reference would drag the autoloads in too early.
	var CampS = load("res://script/camp_schedule.gd")
	var FieldS = load("res://script/field_schedule.gd")

	step("camp: days 1-7, five times of day, five story states")
	var states: Array = [
		["base", func() -> void: pass],
		["po Exitium", func() -> void:
			gs.set_flag("drudzy_met")
			gs.set_flag("sabina_joined")],
		["goraczka Nasira", func() -> void:
			gs.set_flag("nasir_fever_started")
			gs.set_flag("fever_nasir")],
		["Miroslaw na krawedzi", func() -> void: gs.npcs[&"miroslaw"]["sanity"] = 5],
		["odejscia", func() -> void:
			gs.set_npc_status(&"dobrawa", "gone")
			gs.set_npc_status(&"miroslaw", "dead")],
	]
	var missing := 0
	var overlaps := 0
	for state in states:
		gs.reset()
		gs.set_flag("intro_done")
		state[1].call()
		for day in range(1, 8):
			gs.day = day
			for hour in [6.5, 9.0, 13.0, 18.5, 20.5]:
				gs.hour = hour
				var taken := {}
				for id in gs.NPCS:
					var spot: Dictionary = CampS.placement(id)
					if spot.is_empty():
						continue
					var marker_name := String(spot.get("marker", ""))
					if story._marker(marker_name) == null:
						missing += 1
						print("   BRAK markera '%s' (%s, %s, dzień %d, %.1f)" % [marker_name, id, state[0], day, hour])
					if taken.has(marker_name):
						overlaps += 1
						print("   KOLIZJA: %s i %s na '%s' (%s, dzień %d, %.1f)" % [id, taken[marker_name], marker_name, state[0], day, hour])
					taken[marker_name] = id
	check(missing == 0, "every camp placement has its marker (%d missing)" % missing)
	check(overlaps == 0, "no two NPCs share a marker (%d overlaps)" % overlaps)

	step("field: the miners' work posts and the Drudzy spots")
	gs.reset()
	gs.set_flag("intro_done")
	gs.day = 2
	gs.hour = 13.0
	var wsz: Dictionary = FieldS.placement(&"wszebor", &"wyrobisko")
	check(not wsz.is_empty() and story._marker(String(wsz["marker"])) != null, "Wszebor's post in the old working exists")
	gs.set_flag("nasir_at_pumps", 1)
	var nas: Dictionary = FieldS.placement(&"nasir", &"pompy")
	check(not nas.is_empty() and story._marker(String(nas["marker"])) != null, "Nasir's post at the pumps exists")
	gs.set_flag("drudzy_met")
	gs.set_flag("encounter_place", "grota")
	gs.set_flag("encounter_npcs", ["hieronim"])
	var hie: Dictionary = FieldS.placement(&"hieronim", &"grota")
	check(not hie.is_empty() and story._marker(String(hie["marker"])) != null, "an encounter spot in the grotto exists")

	step("task_10, day 1: four in the camp, the five in first-level rooms (100 rolls)")
	var camp_extra := 0
	var field_bad := 0
	var crowded := 0
	for roll in 100:
		gs.reset()
		gs.set_flag("intro_done")
		for hour in [6.5, 13.0, 20.5]:
			gs.hour = hour
			for id in gs.NPCS:
				if not CampS.placement(id).is_empty() and not id in [&"miroslaw", &"bolko", &"tekla", &"racibor"]:
					camp_extra += 1
			for room in gs.FIRST_ROOMS:
				var taken := {}
				for id in gs.FIRST_MEET:
					var spot: Dictionary = FieldS.placement(id, room)
					if spot.is_empty():
						continue
					var marker_name := String(spot["marker"])
					if story._marker(marker_name) == null or taken.has(marker_name) or spot["place"] != "teren":
						field_bad += 1
						print("   ZŁE miejsce: %s w %s -> %s" % [id, room, marker_name])
					taken[marker_name] = id
				if taken.size() > gs.FIRST_ROOM_CAPACITY:
					crowded += 1
	check(camp_extra == 0, "day 1: only Mirosław, Bolko, Tekla and Racibor in the camp (%d others)" % camp_extra)
	check(field_bad == 0, "day 1: each of the five on an existing spot of their room (%d bad)" % field_bad)
	check(crowded == 0, "day 1: never more than two to a room (%d crowded)" % crowded)
	gs.reset()
	gs.day = 2
	gs.hour = 6.5
	var back := 0
	for id in gs.FIRST_MEET:
		if not CampS.placement(id).is_empty():
			back += 1
	check(back == gs.FIRST_MEET.size(), "day 2 morning: all five in the camp (%d)" % back)
