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
