extends SceneTree
## Usage: godot --headless --path . --script res://tools/dialogue_test.gd
## Plays through the slice's dialogues without UI (picks responses by text) and checks the state.

var _failures := 0
var _requests: Array[String] = []

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	var gs = root.get_node("GameState")
	var dm = root.get_node("DialogueManager")
	gs.action_requested.connect(func(a): _requests.append(a))
	var mir: Resource = load("res://dialogue/miroslaw.dialogue")
	var bolko: Resource = load("res://dialogue/bolko.dialogue")
	var system: Resource = load("res://dialogue/system.dialogue")

	print("--- Mirosław: first talk, ask about the collapse")
	await _talk(dm, mir, "start", ["Co się stało z zachodnim chodnikiem?", "Muszę iść."])
	_check(gs.has_flag("met_miroslaw"), "met_miroslaw set")
	_check(gs.quest_state("lonty") == "active", "quest lonty started")

	print("--- Mirosław: deliver fuses, then ask to blast")
	gs.give_item("lonty")
	await _talk(dm, mir, "start", ["Mam dla ciebie lonty", "Wysadź zawał na zachodzie. (4 h)"])
	_check(not gs.has_item("lonty"), "fuses taken")
	_check(gs.has_flag("fuses_delivered"), "fuses_delivered set")
	_check(gs.rep("miroslaw") == 10, "Mirosław rep +10 (got %d)" % gs.rep("miroslaw"))
	_check("blast" in _requests, "blast requested")

	print("--- Mirosław: too late for blasting")
	gs.hour = 20.0
	_requests.clear()
	await _talk(dm, mir, "start", ["Wysadź zawał na zachodzie. (4 h)", "Muszę iść."])
	_check(not ("blast" in _requests), "no blast when out of time")
	gs.hour = 8.0

	print("--- Bolko: cipher before trust, then after")
	gs.add_note(&"szyfr")
	await _talk(dm, bolko, "start", ["Znalazłem kartkę zapisaną szyfrem dziadka.", "Pójdę już."])
	_check(not gs.has_flag("bolko_hint"), "no hint without trust")
	await _talk(dm, bolko, "start", ["Jaki był mój dziadek?", "Pewnie miał swoje powody.", "Znalazłem kartkę zapisaną szyfrem dziadka.", "Pójdę już."])
	_check(gs.has_flag("bolko_hint"), "hint with trust (rep %d)" % gs.rep("bolko"))

	print("--- Sleep prompt and dream")
	_requests.clear()
	await _talk(dm, system, "sleep", ["Tak, idę spać"])
	_check("sleep" in _requests, "sleep requested")
	gs.set_flag("visited_east")
	await _talk(dm, system, "dream", [])

	print("--- Day 2 variants")
	gs.start_next_day()
	gs.set_flag("west_blasted")
	gs.npcs[&"miroslaw"]["sanity"] = 12
	await _talk(dm, mir, "start", ["Posiedzę z tobą."])
	_check(gs.sanity(&"miroslaw") == 17, "day-2 comfort +5 (got %d)" % gs.sanity(&"miroslaw"))
	await _talk(dm, bolko, "start", [])

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit()

## Runs a conversation, choosing responses whose text starts with the given strings, in order.
func _talk(dm, resource: Resource, cue: String, choices: Array) -> void:
	var line = await dm.get_next_dialogue_line(resource, cue)
	var guard := 0
	while line != null and guard < 60:
		guard += 1
		print("   %s%s" % ["%s: " % line.character if line.character != "" else "", line.text])
		if line.responses.size() > 0:
			var allowed: Array = line.responses.filter(func(r): return r.is_allowed)
			var pick = null
			if choices.size() > 0:
				for r in allowed:
					if r.text.begins_with(choices[0]):
						pick = r
						break
			if pick == null:
				print("   !! no allowed response matching %s among %s" % [choices.slice(0, 1), allowed.map(func(r): return r.text)])
				_failures += 1
				return
			choices.pop_front()
			print("   > %s" % pick.text)
			line = await dm.get_next_dialogue_line(resource, pick.next_id)
		else:
			line = await dm.get_next_dialogue_line(resource, line.next_id)

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
