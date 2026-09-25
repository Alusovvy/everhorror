extends SceneTree
## Usage: godot --headless --path . --script res://tools/slice_test.gd
## Plays the whole vertical slice through the real systems (world scene, VN screen, map,
## interactables, story director) and checks the state after every step.

var gs
var vn
var sm
var world: Node
var _failures := 0

func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	vn = root.get_node("VN")
	sm = root.get_node("SaveManager")
	sm.new_game()
	await _frames(10)
	world = current_scene
	print("--- intro")
	await _drive_dialogue([])
	await _wait_idle()
	_check(gs.has_flag("intro_done"), "intro played")
	_check(is_equal_approx(gs.hour, 6.0), "06:00 after intro (%s)" % gs.clock_text())

	print("--- talk to Mirosław (1 h)")
	await _use(world.get_node("NPCs/Miroslaw/Talk"))
	await _drive_dialogue(["Co się stało z zachodnim chodnikiem?", "Muszę iść."])
	_check(gs.quest_state(&"lonty") == "active", "fuse quest active")
	_check(is_equal_approx(gs.hour, 7.0), "07:00 after talk (%s)" % gs.clock_text())

	print("--- map: travel east (2 h)")
	await _use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	_check(world.get_node("MapScreen").visible, "map screen open")
	world.get_node("MapScreen")._choose("east")
	await _wait_idle()
	_check(is_equal_approx(gs.hour, 9.0), "09:00 after travel (%s)" % gs.clock_text())
	_check(world.get_node("Player").global_position.x > 36.0, "player in east segment (x=%.1f)" % world.get_node("Player").global_position.x)

	print("--- pick up fuses and read the cipher")
	await _use(world.get_node("Camp/EastSegment/FuseBox/FuseBoxPickup"))
	_check(gs.has_item("lonty"), "got fuses")
	_check(not world.get_node("Camp/EastSegment/FuseBox").visible, "fuse box removed")
	await _use(world.get_node("MineDeep/Props/Scroll_2_1/Interactable"))
	_check(gs.has_note(&"szyfr"), "cipher note in notebook")

	print("--- return to camp (2 h)")
	await _use(world.get_node("Camp/Barricades/Signs/EastSign/EastExitUse"))
	await _wait_idle()
	_check(is_equal_approx(gs.hour, 11.0), "11:00 back in camp (%s)" % gs.clock_text())

	print("--- Mirosław: deliver fuses and blast (1 h + 4 h)")
	await _use(world.get_node("NPCs/Miroslaw/Talk"))
	await _drive_dialogue(["Mam dla ciebie lonty", "Wysadź zawał na zachodzie. (4 h)"])
	await _wait_idle()
	_check(gs.has_flag("west_blasted"), "west blasted")
	_check(is_equal_approx(gs.hour, 16.0), "16:00 after blast (%s)" % gs.clock_text())
	_check(world.get_node("Camp/WestSegment/BlastDebris").visible, "blast debris visible")

	print("--- comfort Mirosław (1 h)")
	await _use(world.get_node("NPCs/Miroslaw/Talk"))
	await _drive_dialogue(["Jak się trzymasz?", "Posiedzę z tobą chwilę.", "Muszę iść."])
	_check(gs.has_flag("mir_comforted"), "Mirosław comforted (sanity %d)" % gs.sanity(&"miroslaw"))

	print("--- save in slot 3, travel west, then load")
	var slot3_existed: bool = sm.has_save(3)
	_check(sm.save_game(3), "saved to slot 3")
	await _use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	world.get_node("MapScreen")._choose("west")
	await _wait_idle()
	_check(is_equal_approx(gs.hour, 19.0), "19:00 after travel west (%s)" % gs.clock_text())
	await _use(world.get_node("Camp/WestSegment/KeyWood/KeyBoard/KeyBoardLook"))
	_check(gs.has_note(&"klucz"), "key note found")
	sm.load_game(3)
	await _frames(15)
	world = current_scene
	await _wait_idle()
	_check(is_equal_approx(gs.hour, 17.0) and not gs.has_note(&"klucz"), "load restored 17:00 without the key (%s)" % gs.clock_text())
	_check(world.get_node("Camp/WestSegment/BlastDebris").visible, "blast state restored after load")
	_check(not world.get_node("Camp/EastSegment/FuseBox").visible, "picked-up fuse box stays gone after load")
	if not slot3_existed:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(sm.slot_path(3)))

	print("--- west again, key, return")
	await _use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	world.get_node("MapScreen")._choose("west")
	await _wait_idle()
	await _use(world.get_node("Camp/WestSegment/KeyWood/KeyBoard/KeyBoardLook"))
	await _use(world.get_node("Camp/Barricades/Signs/WestSign/WestExitUse"))
	await _wait_idle()
	_check(is_equal_approx(gs.hour, 21.0), "21:00 back from the west (%s)" % gs.clock_text())

	print("--- Bolko: respect, then the cipher hint (last hour of the day)")
	await _use(world.get_node("NPCs/Bolko/Talk"))
	await _drive_dialogue(["Jaki był mój dziadek?", "Pewnie miał swoje powody.", "Znalazłem kartkę zapisaną szyfrem dziadka.", "Pójdę już."])
	_check(gs.has_flag("bolko_hint"), "Bolko gave the hint (rep %d)" % gs.rep(&"bolko"))
	_check(gs.is_day_over(), "day is over at %s" % gs.clock_text())
	await _use(world.get_node("NPCs/Miroslaw/Talk"))
	_check(not vn.is_active(), "no talking when the day is over")

	print("--- sleep: night, dream, day 2")
	await _use(world.get_node("Camp/CampProps/Cloth/Bedroll/BedUse"))
	await _drive_dialogue(["Tak, idę spać"])
	await _drive_dialogue([])   # dream
	await _wait_idle()
	_check(gs.day == 2 and is_equal_approx(gs.hour, 6.0), "day 2, 06:00 (%s)" % gs.clock_text())
	_check(gs.has_note(&"odszyfrowana"), "message deciphered overnight")
	var mir_pos: Vector3 = world.get_node("NPCs/Miroslaw").global_position
	_check(mir_pos.distance_to(world.get_node("Camp/Markers/MiroslawFire").global_position) < 0.1, "Mirosław by the fire (sanity %d, band %s)" % [gs.sanity(&"miroslaw"), gs.sanity_band(&"miroslaw")])

	print("--- day 2: map table ends the demo")
	await _use(world.get_node("Camp/CampProps/MapTable/MapTableUse"))
	await create_timer(2.5).timeout   # the end screen fades in over real time
	var end_panel: Control = world.get_node("ScreenFade/EndPanel")
	_check(end_panel.visible, "end screen shown")
	print("   summary: ", world.get_node("ScreenFade/EndPanel/Center/VBox/Summary").text.replace("\n", " | "))
	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit()

## Uses an interactable the way the player does.
func _use(interactable) -> void:
	world.get_node("Player").interacted.emit(interactable)
	interactable.interact()
	await _frames(3)

## Clicks through the open dialogue, choosing responses that start with the given texts.
func _drive_dialogue(choices: Array) -> void:
	await _frames(2)
	var guard := 0
	while vn.is_active() and guard < 400:
		guard += 1
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
			if pick == null:
				print("   !! no response for %s among %s" % [choices.slice(0, 1), balloon.dialogue_line.responses.map(func(r): return r.text)])
				_failures += 1
				return
			choices.pop_front()
			print("   > %s" % pick.text)
			balloon.next(pick.next_id)
		elif balloon.is_waiting_for_input:
			balloon.next(balloon.dialogue_line.next_id)
		await _frames(2)

## Waits until fades, cards and scripted sequences finish.
func _wait_idle() -> void:
	await _frames(5)
	var guard := 0
	while (world.get_node("Story")._busy or vn.is_active()) and guard < 2000:
		guard += 1
		if vn.is_active():
			await _drive_dialogue([])
		await _frames(1)
	await _frames(3)

func _frames(n: int) -> void:
	for i in n:
		await process_frame

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
