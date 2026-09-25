extends Node
class_name StoryDirector

## Runs the vertical slice in the world scene: intro, travel from the map table, returning to
## camp, Mirosław's blast, the night (sanity, dream, deciphering), day-2 changes in the camp
## and the end of the demo. Story state lives in GameState; this node only acts on it.

const SYSTEM_DIALOGUE := preload("res://dialogue/system.dialogue")
const TRAVEL_HOURS := 2.0
const BLAST_HOURS := 4.0

@onready var world: Node3D = get_parent()
@onready var player: Player = $"../Player"
@onready var fade: ScreenFade = $"../ScreenFade"
@onready var map_screen: MapScreen = $"../MapScreen"
@onready var miroslaw: Npc = $"../NPCs/Miroslaw"
@onready var bolko: Npc = $"../NPCs/Bolko"
@onready var markers: Node3D = $"../Camp/Markers"
@onready var blast_sound: AudioStreamPlayer = $"../Sounds/BlastSound"
@onready var west_debris: Node3D = $"../Camp/WestSegment/BlastDebris"

## Actions requested by dialogue ("sleep", "blast"); run once the dialogue has closed.
var _pending_actions: Array[String] = []
var _busy := false

func _ready() -> void:
	GameState.action_requested.connect(func(action): _pending_actions.append(action))
	VN.finished.connect(_on_dialogue_finished)
	map_screen.destination_chosen.connect(_travel)
	for node in get_tree().get_nodes_in_group(&"story_use"):
		(node as Interactable).used.connect(_on_used)

## Called by the world scene after it restored a save (or started a new game).
func begin(is_new_game: bool) -> void:
	apply_world_state()
	if is_new_game:
		_place_player(markers.get_node("SpawnBed"))
		if not GameState.has_flag("intro_done"):
			GameState.set_flag("intro_done")
			_intro()
	else:
		fade.fade_in(0.6)

## Places NPCs and props according to the day and the story flags.
func apply_world_state() -> void:
	var day2 := GameState.day >= 2
	var mir_band := GameState.sanity_band(&"miroslaw")
	if day2 and (mir_band == "na_krawedzi" or mir_band == "zalamany"):
		miroslaw.place(markers.get_node("MiroslawCorner"), &"Crouch_Idle")
	else:
		miroslaw.place(markers.get_node("MiroslawFire"), &"Sitting_Idle")
	if day2 and GameState.rep(&"bolko") >= 10:
		bolko.place(markers.get_node("BolkoBed"), &"Idle")
	elif day2 and GameState.rep(&"bolko") < 0:
		bolko.place(markers.get_node("BolkoAway"), &"Idle")
	else:
		bolko.place(markers.get_node("BolkoTable"), &"Idle")
	west_debris.visible = GameState.has_flag("west_blasted")

func _intro() -> void:
	_busy = true
	await fade.fade_out(0.01)
	await fade.show_card("Dzień 1", "Obóz ekspedycji w starej hali górniczej")
	await fade.fade_in(1.0)
	await VN.play(SYSTEM_DIALOGUE, "intro")
	GameState.message.emit("[E] rozmowa i badanie   ·   [J] notes   ·   [Esc] pauza")
	_busy = false

#region Interactions

func _on_used(interactable: Interactable) -> void:
	if _busy:
		return
	match String(interactable.name):
		"MapTableUse":
			if GameState.day >= 2:
				_end_demo()
			else:
				map_screen.open()
		"BedUse":
			if GameState.day >= 2:
				_end_demo()
			else:
				VN.start(SYSTEM_DIALOGUE, "sleep")
		"EastExitUse", "WestExitUse":
			_return_to_camp()

func _on_dialogue_finished(_npc_id: StringName) -> void:
	while not _pending_actions.is_empty():
		var action: String = _pending_actions.pop_front()
		match action:
			"sleep":
				await _sleep()
			"blast":
				await _blast()

#endregion

#region Travel

func _travel(destination_id: String) -> void:
	var names := {"east": "Stara sztolnia", "west": "Zawalony chodnik"}
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.7)
	GameState.advance_time(TRAVEL_HOURS, "Wyprawa: %s" % names.get(destination_id, destination_id))
	GameState.set_flag("visited_%s" % destination_id)
	_place_player(markers.get_node("EastEntry" if destination_id == "east" else "WestEntry"))
	await fade.show_card(names.get(destination_id, destination_id), GameState.clock_text(), 1.2)
	await fade.fade_in(0.7)
	GameState.pop_modal()
	_busy = false

func _return_to_camp() -> void:
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.7)
	# Coming back is always possible, even late: the day may run over.
	GameState.hour += TRAVEL_HOURS
	GameState.time_advanced.emit(TRAVEL_HOURS, "Powrót do obozu")
	_place_player(markers.get_node("CampReturn"))
	await fade.show_card("Obóz", GameState.clock_text(), 1.0)
	await fade.fade_in(0.7)
	GameState.pop_modal()
	_busy = false

func _place_player(marker: Node3D) -> void:
	player.global_position = marker.global_position + Vector3(0, 1.05, 0)
	player.rotation = Vector3(0, marker.global_rotation.y, 0)
	player.head.rotation = Vector3.ZERO
	player.eye_camera.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO

#endregion

#region Blast and night

func _blast() -> void:
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.8)
	GameState.advance_time(BLAST_HOURS, "Mirosław wysadza zawał")
	blast_sound.play()
	await fade.show_card("Huk", "Mirosław wysadza zawał w zachodnim chodniku. Pył długo nie chce opaść.", 2.4)
	GameState.set_flag("west_blasted")
	GameState.quest_log(&"lonty", "wysadzone")
	GameState.complete_quest(&"lonty")
	GameState.change_sanity(&"miroslaw", -4)
	apply_world_state()
	await fade.fade_in(0.8)
	GameState.pop_modal()
	GameState.message.emit("Zachodni chodnik jest otwarty. Wyprawę zaplanujesz przy stole z mapą.")
	_busy = false

func _sleep() -> void:
	_busy = true
	GameState.push_modal()
	await fade.fade_out(1.2)
	_resolve_night()
	GameState.pop_modal()
	await VN.play(SYSTEM_DIALOGUE, "dream")
	GameState.push_modal()
	GameState.start_next_day()
	apply_world_state()
	_place_player(markers.get_node("SpawnBed"))
	await fade.show_card("Dzień %d" % GameState.day, _morning_subtitle(), 2.6)
	await fade.fade_in(1.2)
	GameState.pop_modal()
	GameState.message.emit("To już ostatni dzień wersji demo. Rozejrzyj się po obozie, a kiedy skończysz, podejdź do stołu z mapą.")
	_busy = false

## Night resolution (docs_v2/systemy/czas.md, zasada 5): sanity changes and deciphering.
func _resolve_night() -> void:
	var miroslaw_loss := 6
	if GameState.has_flag("west_blasted"):
		miroslaw_loss += 4 if GameState.has_flag("mir_comforted") else 12
	GameState.change_sanity(&"miroslaw", -miroslaw_loss)
	GameState.change_sanity(&"bolko", -2)
	if GameState.has_note(&"szyfr") and GameState.has_note(&"klucz"):
		GameState.add_note(&"odszyfrowana")
		GameState.quest_log(&"slady", "odszyfrowane")
		GameState.set_flag("deciphered")

func _morning_subtitle() -> String:
	if GameState.sanity_band(&"miroslaw") in ["na_krawedzi", "zalamany"]:
		return "Mirosława nie ma przy ognisku."
	return "Obóz budzi się powoli. Ogień ledwo się tli."

#endregion

#region End

func _end_demo() -> void:
	_busy = true
	var lines: Array[String] = []
	lines.append("Zakończyłeś dzień 1 wersji demo.")
	lines.append("Lonty dla Mirosława: %s" % ("oddane" if GameState.has_flag("fuses_delivered") else "nieoddane"))
	lines.append("Zachodni chodnik: %s" % ("wysadzony" if GameState.has_flag("west_blasted") else "wciąż zawalony"))
	var band := {"spokojny": "spokojny", "niespokojny": "niespokojny", "na_krawedzi": "na krawędzi", "zalamany": "załamany"}
	lines.append("Mirosław: %s" % band.get(GameState.sanity_band(&"miroslaw"), "?"))
	var trust := GameState.rep(&"bolko")
	lines.append("Bolko: %s" % ("ufa ci" if trust >= 10 else ("nie ufa ci" if trust < 0 else "ostrożny")))
	lines.append("Wiadomość dziadka: %s" % ("odczytana" if GameState.has_flag("deciphered") else ("szyfr bez klucza" if GameState.has_note(&"szyfr") else "nieodnaleziona")))
	lines.append("")
	lines.append("Dziękujemy za grę.")
	await fade.show_end("\n".join(lines))

#endregion
