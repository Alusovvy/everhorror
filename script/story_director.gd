extends Node
class_name StoryDirector

## Runs the demo in the world scene: intro, the camp schedule (who is where), travel from the
## map table and back, Mirosław's blast, the nights (sanity, dreams, deciphering), Racibor's
## announcement on the last morning and the end of the demo. Story state lives in GameState;
## this node only acts on it.

const SYSTEM_DIALOGUE := preload("res://dialogue/system.dialogue")
const RACIBOR_DIALOGUE := preload("res://dialogue/racibor.dialogue")
const BLAST_HOURS := 4.0

@onready var world: Node3D = get_parent()
@onready var player: Player = $"../Player"
@onready var fade: ScreenFade = $"../ScreenFade"
@onready var map_screen: MapScreen = $"../MapScreen"
@onready var markers: Node3D = $"../Camp/Markers"
@onready var location_markers: Node3D = $"../Locations/Markers"
@onready var blast_sound: AudioStreamPlayer = $"../Sounds/BlastSound"
@onready var west_debris: Node3D = $"../Camp/WestSegment/BlastDebris"

## npc id → Npc node.
var npcs: Dictionary = {}
## Actions requested by dialogue ("sleep", "blast"); run once the dialogue has closed.
var _pending_actions: Array[String] = []
var _busy := false

func _ready() -> void:
	for node in $"../NPCs".get_children():
		var npc := node as Npc
		npcs[npc.data.id] = npc
	GameState.action_requested.connect(func(action): _pending_actions.append(action))
	GameState.time_advanced.connect(_on_time_advanced)
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

func _intro() -> void:
	_busy = true
	await fade.fade_out(0.01)
	await fade.show_card("Dzień 1", "Obóz ekspedycji w starej hali górniczej")
	await fade.fade_in(1.0)
	await VN.play(SYSTEM_DIALOGUE, "intro")
	GameState.message.emit("[E] rozmowa i badanie   ·   [J] notes   ·   [Esc] pauza")
	_busy = false

#region Camp state

## Places NPCs by the camp schedule and shows story changes in the world.
func apply_world_state() -> void:
	for id in npcs:
		var npc: Npc = npcs[id]
		var spot := CampSchedule.placement(id)
		if spot.is_empty():
			npc.set_present(false)
			GameState.places[id] = ""
			continue
		npc.set_present(true)
		if npc.marker_name != spot["marker"] or npc.pose != spot["pose"]:
			npc.place(markers.get_node(spot["marker"]), spot["pose"])
		GameState.places[id] = spot["place"]
	west_debris.visible = GameState.has_flag("west_blasted")

## True if applying the schedule now would move someone to another spot.
func _camp_will_change() -> bool:
	for id in npcs:
		var npc: Npc = npcs[id]
		var spot := CampSchedule.placement(id)
		var marker: String = spot.get("marker", "")
		if marker != npc.marker_name:
			return true
	return false

func _is_player_in_camp() -> bool:
	return String(GameState.get_flag("location", "")) == ""

## Time moved on: people go to their next place. A short blink hides the jump when the
## player is looking at the camp; while a dialogue or a scripted sequence runs, it waits.
func _refresh_camp() -> void:
	if VN.is_active() or _busy:
		return
	if _is_player_in_camp() and _camp_will_change():
		_busy = true
		await fade.fade_out(0.15)
		apply_world_state()
		await fade.fade_in(0.3)
		_busy = false
	else:
		apply_world_state()

func _on_time_advanced(_hours: float, _reason: String) -> void:
	_refresh_camp.call_deferred()

#endregion

#region Interactions

func _on_used(interactable: Interactable) -> void:
	if _busy:
		return
	var use_name := String(interactable.name)
	match use_name:
		"MapTableUse":
			if GameState.day >= GameState.LAST_DAY:
				_end_demo()
			else:
				map_screen.open()
		"BedUse":
			if GameState.day >= GameState.LAST_DAY:
				_end_demo()
			else:
				VN.start(SYSTEM_DIALOGUE, "sleep")
		_:
			if use_name.ends_with("ExitUse"):
				_return_to_camp()

func _on_dialogue_finished(_npc_id: StringName) -> void:
	while not _pending_actions.is_empty():
		var action: String = _pending_actions.pop_front()
		match action:
			"sleep":
				await _sleep()
			"blast":
				await _blast()
	_refresh_camp()

#endregion

#region Travel

func _travel(destination_id: String) -> void:
	var destination := MapScreen.destination(destination_id)
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.7)
	GameState.advance_time(destination["hours"], "Wyprawa: %s" % destination["name"])
	GameState.set_flag("visited_%s" % destination_id)
	GameState.set_flag("location", destination_id)
	_place_player(_entry_marker(destination["entry"]))
	apply_world_state()
	await fade.show_card(destination["name"], GameState.clock_text(), 1.2)
	await fade.fade_in(0.7)
	GameState.pop_modal()
	_busy = false

func _entry_marker(marker_name: String) -> Node3D:
	if markers.has_node(marker_name):
		return markers.get_node(marker_name)
	return location_markers.get_node(marker_name)

func _return_to_camp() -> void:
	var from := String(GameState.get_flag("location", ""))
	var hours: float = MapScreen.destination(from).get("hours", 2.0) if from != "" else 2.0
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.7)
	# Coming back is always possible, even late: the day may run over.
	GameState.clear_flag("location")
	GameState.hour += hours
	GameState.time_advanced.emit(hours, "Powrót do obozu")
	_place_player(markers.get_node("CampReturn"))
	apply_world_state()
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

#region Blast and nights

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
	if GameState.day >= GameState.LAST_DAY:
		await VN.play(RACIBOR_DIALOGUE, "announcement", &"racibor")
		GameState.set_flag("announcement_done")
		GameState.message.emit("Ostatni poranek wersji demo. Porozmawiaj z kim chcesz, a kiedy skończysz, podejdź do stołu z mapą.")
	else:
		GameState.message.emit("Nowy dzień. Ludzie są tam, gdzie zwykle o tej porze: rano przy śniadaniu, potem przy robocie.")
	_busy = false

## Night resolution (docs_v2/systemy/czas.md, zasada 5): sanity, departures, deciphering.
func _resolve_night() -> void:
	var night := GameState.day
	var miroslaw_loss := 6
	if GameState.has_flag("west_blasted") and not GameState.has_flag("mir_night_blast_done"):
		GameState.set_flag("mir_night_blast_done")
		miroslaw_loss += 4 if GameState.has_flag("mir_comforted") else 12
	if night >= 2 and GameState.has_flag("mir_saw_charge"):
		miroslaw_loss += 4
	GameState.change_sanity(&"miroslaw", -miroslaw_loss)
	GameState.change_sanity(&"bolko", -2 if not GameState.has_flag("bolko_knows_fate") else -6)
	GameState.change_sanity(&"racibor", -4)
	GameState.change_sanity(&"tekla", -10 if GameState.has_flag("tekla_reported") else -2)
	if night >= 2:
		GameState.change_sanity(&"dobrawa", -8)
	if GameState.has_flag("dobrawa_leaving"):
		GameState.set_flag("dobrawa_left")
		GameState.set_npc_status(&"dobrawa", "gone")
	if GameState.has_note(&"szyfr") and GameState.has_note(&"klucz") and not GameState.has_flag("deciphered"):
		GameState.add_note(&"odszyfrowana")
		GameState.quest_log(&"slady", "odszyfrowane")
		GameState.set_flag("deciphered")
		GameState.set_flag("kaplica_known")

func _morning_subtitle() -> String:
	if GameState.has_flag("dobrawa_left"):
		return "Dobrawy nie ma. Zniknęła przed świtem, razem z kryształem."
	if GameState.sanity_band(&"miroslaw") in ["na_krawedzi", "zalamany"]:
		return "Mirosława nie ma przy ognisku."
	if GameState.day == 2:
		return "Nocą szybem zjechał ktoś nowy."
	return "Obóz budzi się powoli. Ogień ledwo się tli."

#endregion

#region End

func _end_demo() -> void:
	_busy = true
	var band := {"spokojny": "spokojny", "niespokojny": "niespokojny", "na_krawedzi": "na krawędzi", "zalamany": "załamany"}
	var lines: Array[String] = []
	lines.append("Przetrwałeś trzy dni w kopalni. Tu kończy się wersja demo.")
	lines.append("")
	lines.append("Zachodni chodnik: %s" % ("wysadzony" if GameState.has_flag("west_blasted") else "wciąż zawalony"))
	lines.append("Żyły błękitu zaznaczone dla Racibora: %d z %d" % [GameState.veins_mapped(), GameState.VEINS.size()])
	lines.append("Wiadomość dziadka: %s" % ("odczytana" if GameState.has_flag("deciphered") else ("szyfr bez klucza" if GameState.has_note(&"szyfr") else "nieodnaleziona")))
	lines.append("Ściana w kaplicy: %s" % ("otwarta, list dziadka przeczytany" if GameState.has_flag("wall_open") else "nierozwiązana"))
	lines.append("Kryształ: %s" % _crystal_summary())
	lines.append("")
	lines.append("Mirosław: %s" % band.get(GameState.sanity_band(&"miroslaw"), "?"))
	var trust := GameState.rep(&"bolko")
	lines.append("Bolko: %s" % ("ufa ci" if trust >= 10 else ("nie ufa ci" if trust < 0 else "ostrożny")))
	lines.append("Tekla: %s" % _tekla_summary())
	lines.append("Racibor: %s" % ("liczy na ciebie" if GameState.rep(&"racibor") >= 10 else ("ma cię na oku" if GameState.rep(&"racibor") < 0 else "zdystansowany")))
	lines.append("")
	lines.append("Dziękujemy za grę.")
	await fade.show_end("\n".join(lines))

func _crystal_summary() -> String:
	if GameState.has_flag("crystal_to_dobrawa"):
		return "u Dobrawy, w drodze do Initium"
	if GameState.has_flag("crystal_to_racibor"):
		return "u Racibora, dla Kniazia"
	if GameState.has_item("krysztal"):
		return "zostaje u ciebie"
	return "nieodnaleziony"

func _tekla_summary() -> String:
	if GameState.has_flag("tekla_reported"):
		return "pod strażą, przez ciebie"
	if GameState.quest_state(&"towar") == "done":
		return "ma u ciebie dług"
	return "liczy każdą świeczkę"

#endregion
