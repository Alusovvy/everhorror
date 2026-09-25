extends SceneTree
## Base for the scenario tests in tools/tests/ (run them with tools/run_tests.sh).
## A scenario extends this file and implements `scenario()`. It starts the world from a prepared
## GameState (no need to replay earlier days), prints every step as it starts, and ends with one
## line: "RESULT: ALL PASSED", "RESULT: n FAILED" or "RESULT: TIMEOUT in step '…'".
## Every wait is limited in time, and a watchdog quits the whole scenario after `timeout_s`.
## No class_name types here (Npc, Interactable…): typing with them compiles those scripts before
## the autoloads exist, and they fail on GameState / VN.

## Seconds before the watchdog gives up on the whole scenario.
var timeout_s := 90.0
var gs
var vn
var sm
var world: Node

var _failures := 0
var _step_name := "start"
var _started_ms := 0
var _done := false

func _initialize() -> void:
	# Autoloads are only available after the first frame.
	process_frame.connect(_boot, CONNECT_ONE_SHOT)

func _boot() -> void:
	gs = root.get_node("GameState")
	vn = root.get_node("VN")
	sm = root.get_node("SaveManager")
	_started_ms = Time.get_ticks_msec()
	create_timer(timeout_s).timeout.connect(_on_timeout)
	await scenario()
	_finish()

## Implemented by each scenario.
func scenario() -> void:
	pass

#region Setup and reporting

## Starts a new game in the world scene. `setup` changes the fresh GameState before the world's
## _ready, so the camp is laid out for that day and hour (set "intro_done" to skip the intro).
func start_world(setup: Callable = Callable()) -> void:
	sm.new_game()
	if setup.is_valid():
		setup.call()
	await frames(10)
	world = current_scene
	await wait_idle()

func step(step_name: String) -> void:
	_step_name = step_name
	print("--- %s  (%.1f s)" % [step_name, _elapsed()])

func check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1

func _elapsed() -> float:
	return (Time.get_ticks_msec() - _started_ms) / 1000.0

func _finish() -> void:
	if _done:
		return
	_done = true
	print("RESULT: %s  (%.1f s)" % ["ALL PASSED" if _failures == 0 else "%d FAILED" % _failures, _elapsed()])
	quit(0 if _failures == 0 else 1)

func _on_timeout() -> void:
	if _done:
		return
	_done = true
	print("RESULT: TIMEOUT in step '%s' after %.0f s" % [_step_name, timeout_s])
	quit(2)

#endregion

#region Acting like the player

## Text of the last expedition summary closed by wait_idle().
var last_summary := ""

func npc(npc_name: String) -> Node:
	return world.get_node("NPCs/" + npc_name)

func talk(npc_name: String) -> Node:
	return world.get_node("NPCs/%s/Talk" % npc_name)

## Uses an interactable the way the player does.
func use(interactable) -> void:
	if interactable == null:
		check(false, "interactable exists")
		return
	world.get_node("Player").interacted.emit(interactable)
	interactable.interact()
	await frames(3)

## Talks to an NPC and plays the conversation with the given choices, then waits for the camp.
func converse(npc_name: String, choices: Array) -> void:
	await use(talk(npc_name))
	await drive(choices)
	await wait_idle()

## Opens the map at the table, chooses a destination, presses "WYRUSZ" and waits for the trip.
func travel(destination_id: String) -> void:
	await use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	await _map_go(destination_id)

## In the field: [M], a neighbouring place (or "oboz" to go back), "IDŹ DALEJ" / "WRACAJ".
func go_on(destination_id: String) -> void:
	var map_screen = world.get_node("MapScreen")
	map_screen.open_field()
	await _map_go(destination_id)

func _map_go(destination_id: String) -> void:
	var map_screen = world.get_node("MapScreen")
	check(map_screen.visible, "map open for %s" % destination_id)
	map_screen._select(StringName(destination_id))
	check(not map_screen.go_button.disabled, "can go to %s (%s)" % [destination_id, map_screen.details.text.get_slice("
", 0)])
	map_screen._go()
	await wait_idle()

func find_interactable(under: String, display_name: String) -> Node:
	for node in world.get_node(under).find_children("*", "Area3D", true, false):
		if node.has_method("interact") and node.get("display_name") == display_name:
			return node
	check(false, "interactable '%s' under %s" % [display_name, under])
	return null

## Clicks through the open dialogue, choosing responses that start with the given texts.
## `auto` (used by wait_idle): an unexpected question fails once and gets the first answer, so a
## scenario never loops on it.
func drive(choices: Array, max_s := 30.0, auto := false) -> void:
	await frames(2)
	var deadline := Time.get_ticks_msec() + int(max_s * 1000)
	while vn.is_active():
		if Time.get_ticks_msec() > deadline:
			check(false, "dialogue finished within %.0f s" % max_s)
			return
		var balloon = vn._balloon
		var label = balloon.dialogue_label
		if label.is_typing:
			label.skip_typing()
		elif balloon.responses_menu.visible:
			var pick = null
			for r in balloon.dialogue_line.responses:
				if r.is_allowed and choices.size() > 0 and r.text.begins_with(choices[0]):
					pick = r
					break
			if pick == null and auto and choices.is_empty():
				check(false, "unexpected question %s, answering the first" % [balloon.dialogue_line.responses.map(func(r): return r.text)])
				for r in balloon.dialogue_line.responses:
					if r.is_allowed:
						pick = r
						break
				choices.append("")
			if pick == null:
				check(false, "response %s among %s" % [choices.slice(0, 1), balloon.dialogue_line.responses.map(func(r): return r.text)])
				return
			choices.pop_front()
			print("   > %s" % pick.text)
			balloon.next(pick.next_id)
		elif balloon.is_waiting_for_input:
			balloon.next(balloon.dialogue_line.next_id)
		await frames(2)

## Waits until a scripted dialogue opens (e.g. the announcement after the day card).
func wait_for_vn(max_s := 15.0) -> void:
	var deadline := Time.get_ticks_msec() + int(max_s * 1000)
	while not vn.is_active():
		if Time.get_ticks_msec() > deadline:
			check(false, "a dialogue opened within %.0f s" % max_s)
			return
		await frames(1)

## Waits until fades, cards and scripted sequences finish (dialogues that pop up are clicked through).
func wait_idle(max_s := 20.0) -> void:
	await frames(5)
	var deadline := Time.get_ticks_msec() + int(max_s * 1000)
	var summary = world.get_node("ExpeditionSummary")
	while world.get_node("Story")._busy or vn.is_active() or summary.visible:
		if Time.get_ticks_msec() > deadline:
			check(false, "story idle within %.0f s" % max_s)
			return
		if vn.is_active():
			await drive([], 30.0, true)
		elif summary.visible:
			last_summary = summary.body.text
			summary._close()
		await frames(1)
	await frames(3)

func frames(n: int) -> void:
	for i in n:
		await process_frame

func seconds(s: float) -> void:
	await create_timer(s).timeout

#endregion
