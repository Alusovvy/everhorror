extends Node
class_name StoryDirector

## Runs the week in the world scene (spec 03_mechaniki/czas.md, wyprawy.md): the intro,
## the camp schedule (who is where), expeditions (the map table, [M] in the field, the way back
## and its summary), meetings in the tunnels (the Drudzy from Exitium), Mirosław's blast, the
## nights (sanity, fever, departures, dreams), the mornings (announcements, Racibor's reminders)
## and the end of the week, plus the hero's death and breakdown. Story state lives in GameState;
## this node only acts on it.

const SYSTEM_DIALOGUE := preload("res://dialogue/system.dialogue")
const RACIBOR_DIALOGUE := preload("res://dialogue/racibor.dialogue")
const DRUDZY_DIALOGUE := preload("res://dialogue/drudzy.dialogue")
const HRAPEK_DIALOGUE := preload("res://dialogue/hrapek.dialogue")
const BLAST_HOURS := 4.0
## After the meeting on day 3, the chance to run into one of the Drudzy on arrival (once a day).
const DRUDZY_CHANCE := 0.4
## Hrapek (task_09): after the first meeting, the chance he turns up on a way back (once a day).
const HRAPEK_CHANCE := 0.25
## The night he dies (from the evening of this day to the next morning).
const HRAPEK_LAST_NIGHT := 5
## Seconds between whispers while the hero is on the edge in the tunnels.
const WHISPER_SECONDS := Vector2(40.0, 80.0)
const WHISPERS: Array[String] = [
	"Ktoś wymawia twoje imię. Za plecami nikogo nie ma.",
	"Przez chwilę słyszysz oddech ściany. Równy, powolny.",
	"Lampa przygasa, choć oleju jest pełno.",
	"„Niżej”, szepcze coś z wnętrza skały. „Jeszcze niżej”.",
	"Amulet dziadka robi się ciepły. Potem gorący. Potem znowu zimny.",
	"Masz wrażenie, że ktoś idzie za tobą krok w krok. Kiedy stajesz, on też staje.",
]

@onready var world: Node3D = get_parent()
@onready var player: Player = $"../Player"
@onready var fade: ScreenFade = $"../ScreenFade"
@onready var map_screen: MapScreen = $"../MapScreen"
@onready var summary: ExpeditionSummary = $"../ExpeditionSummary"
@onready var markers: Node3D = $"../Camp/Markers"
@onready var location_markers: Node3D = $"../Locations/Markers"
@onready var blast_sound: AudioStreamPlayer = $"../Sounds/BlastSound"
@onready var west_debris: Node3D = $"../Camp/WestSegment/BlastDebris"

## npc id → Npc node.
var npcs: Dictionary = {}
## Actions requested by dialogue ("sleep", "blast"); run once the dialogue has closed.
var _pending_actions: Array[String] = []
var _busy := false
var _whisper_timer: Timer

func _ready() -> void:
	for node in $"../NPCs".get_children():
		var npc := node as Npc
		npcs[npc.data.id] = npc
	GameState.action_requested.connect(func(action): _pending_actions.append(action))
	GameState.time_advanced.connect(_on_time_advanced)
	GameState.player_died.connect(_on_player_died)
	GameState.player_broke.connect(_on_player_broke)
	VN.finished.connect(_on_dialogue_finished)
	map_screen.destination_chosen.connect(_on_destination)
	for node in get_tree().get_nodes_in_group(&"story_use"):
		(node as Interactable).used.connect(_on_used)
	_whisper_timer = Timer.new()
	_whisper_timer.one_shot = true
	_whisper_timer.timeout.connect(_whisper)
	add_child(_whisper_timer)
	_whisper_timer.start(randf_range(WHISPER_SECONDS.x, WHISPER_SECONDS.y))

## Called by the world scene after it restored a save (or started a new game).
func begin(is_new_game: bool) -> void:
	apply_world_state()
	if is_new_game:
		_place_player(markers.get_node("SpawnBed"))
		if not GameState.has_flag("intro_done"):
			GameState.set_flag("intro_done")
			_intro()
			return
	else:
		fade.fade_in(0.6)
	SaveManager.capture_morning()

func _intro() -> void:
	_busy = true
	await fade.fade_out(0.01)
	await fade.show_card("Dzień 1", "Obóz ekspedycji w jaskini pod starą kopalnią")
	await fade.fade_in(1.0)
	# task_37 (OTW-4): the opening has its own intro, with the first small job in it.
	await VN.play(SYSTEM_DIALOGUE, "intro_opening" if GameState.opening() else "intro")
	GameState.message.emit("[E] rozmowa i badanie   ·   [J] notes   ·   [I] ekwipunek   ·   [M] mapa w chodnikach   ·   [Esc] pauza")
	SaveManager.capture_morning()
	_busy = false

#region Camp and field state

## Places NPCs by the camp schedule (or in the tunnels where the hero is) and shows story
## changes in the world.
func apply_world_state() -> void:
	var here := GameState.current_place()
	for id in npcs:
		var npc: Npc = npcs[id]
		var spot := CampSchedule.placement(id)
		if spot.is_empty() and GameState.is_away():
			spot = FieldSchedule.placement(id, here)
		var marker := _marker(String(spot.get("marker", "")))
		if spot.is_empty() or marker == null:
			npc.set_present(false)
			GameState.places[id] = ""
			continue
		npc.set_present(true)
		if npc.marker_name != spot["marker"] or npc.pose != spot["pose"]:
			npc.place(marker, spot["pose"])
		GameState.places[id] = spot["place"]
	west_debris.visible = GameState.has_flag("west_blasted")
	# The evening seat at the campfire (dialogue/ognisko.dialogue): 20:00+, once a day.
	var fire_seat := world.get_node_or_null(^"Camp/CampProps/Campfire/SeatUse")
	if fire_seat:
		fire_seat.set_enabled(not GameState.is_away() and GameState.hour >= 20.0 and not GameState.done_today("campfire"))

func _marker(marker_name: String) -> Node3D:
	if marker_name == "":
		return null
	if markers.has_node(marker_name):
		return markers.get_node(marker_name)
	if location_markers.has_node(marker_name):
		return location_markers.get_node(marker_name)
	push_warning("Marker '%s' not found." % marker_name)
	return null

## True if applying the schedule now would move someone to another spot in the camp.
func _camp_will_change() -> bool:
	for id in npcs:
		var npc: Npc = npcs[id]
		var spot := CampSchedule.placement(id)
		var marker: String = spot.get("marker", "")
		if marker != npc.marker_name:
			return true
	return false

## Time moved on: people go to their next place. A short blink hides the jump when the
## player is looking at the camp; while a dialogue or a scripted sequence runs, it waits.
func _refresh_camp() -> void:
	if VN.is_active() or _busy:
		return
	if not GameState.is_away() and _camp_will_change():
		_busy = true
		await fade.fade_out(0.15)
		apply_world_state()
		await fade.fade_in(0.3)
		_busy = false
	else:
		apply_world_state()
	_check_opening_finale()

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
			map_screen.open_table()
		"BedUse":
			# task_37 (OTW-9): on the last day of the opening the bed brings the closing scene.
			if _opening_finale_due(true):
				_opening_finale()
			else:
				VN.start(SYSTEM_DIALOGUE, "sleep")
		_:
			# Signposts in the tunnels open the field map: onwards or back to the camp.
			if use_name.ends_with("ExitUse"):
				map_screen.open_field()

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

#region Expeditions

func _on_destination(place_id: StringName) -> void:
	if _busy:
		return
	if not GameState.is_away():
		GameState.begin_expedition()
		await _arrive(place_id, Expeditions.path(Expeditions.CAMP, place_id), "Wyprawa: %s" % Expeditions.display_name(place_id))
	elif place_id == Expeditions.CAMP:
		await _return_to_camp()
	else:
		await _arrive(place_id, Expeditions.path(GameState.current_place(), place_id), "Droga: %s" % Expeditions.display_name(place_id))

func _arrive(place_id: StringName, route: Array[StringName], reason: String) -> void:
	var data := Expeditions.place(place_id)
	var first_visit := not Expeditions.is_visited(place_id)
	var hours := Expeditions.trip_hours(route)
	var walked := Expeditions.walk_hours(route)
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.7)
	_leave_encounter()
	# task_12: the walk tires like the tunnels, and half of it is the price of the way back.
	GameState.travelling = true
	GameState.advance_time(hours, reason)
	GameState.travelling = false
	if not GameState.expedition.is_empty():
		GameState.expedition["outbound_hours"] = float(GameState.expedition.get("outbound_hours", 0.0)) + walked
	GameState.set_flag("visited_%s" % place_id)
	GameState.set_flag("location", String(place_id))
	GameState.note_expedition_place(place_id)
	if place_id == &"zalany":
		GameState.mark_today("soaked")
	_roll_encounter(place_id)
	_place_player(_marker(data.entry))
	apply_world_state()
	await fade.show_card(data.display_name, _arrival_subtitle(route), 1.2)
	await fade.fade_in(0.7)
	GameState.pop_modal()
	_busy = false
	if first_visit:
		if data.arrival_text != "":
			GameState.message.emit(data.arrival_text)
		if data.dread > 0:
			GameState.change_player_sanity(-data.dread, "To miejsce cię przygniata")
	await _meet_drudzy_if_due(place_id)

## The clock, and the places passed on the way ("przez: Kaplica"): walking through a place
## doesn't scout it, so the player should at least know which way he went.
func _arrival_subtitle(route: Array[StringName]) -> String:
	var passed := Expeditions.passed_through(route)
	if passed.is_empty():
		return GameState.clock_text()
	return "%s\nprzez: %s" % [GameState.clock_text(), ", ".join(passed)]

func _return_to_camp() -> void:
	# task_12: half of the walking done since leaving the camp, never doubled by fatigue.
	var hours := Expeditions.return_hours()
	_busy = true
	# On the way back, before the walk: Hrapek, or what is left of him.
	await _hrapek_on_the_way_back()
	GameState.push_modal()
	await fade.fade_out(0.7)
	_leave_encounter()
	# Coming back is always possible, even late: the day may run over (MECHANICS §13 pkt 8).
	GameState.clear_flag("location")
	GameState.travelling = true
	GameState.advance_time(hours, "Powrót do obozu")
	GameState.travelling = false
	if GameState.has_flag("drudzy_met") and not GameState.has_flag("sabina_joined"):
		GameState.set_flag("sabina_joined")
	_place_player(markers.get_node("CampReturn"))
	apply_world_state()
	await fade.show_card("Obóz", GameState.clock_text(), 1.0)
	await fade.fade_in(0.7)
	GameState.pop_modal()
	await summary.present(GameState.end_expedition())
	_busy = false
	if GameState.is_day_over():
		GameState.change_player_sanity(-3, "Wracasz po nocy")
		GameState.message.emit("Noc. Ledwo trzymasz się na nogach, pora na posłanie.")
	if GameState.has_flag("sabina_joined") and not GameState.has_flag("sabina_arrival_seen"):
		GameState.set_flag("sabina_arrival_seen")
		GameState.message.emit("W obozie czeka już Sabina z Exitium. Racibor nie wygląda na zachwyconego.")
	_check_opening_finale()

func _place_player(marker: Node3D) -> void:
	if marker == null:
		return
	player.global_position = marker.global_position + Vector3(0, 1.05, 0)
	player.rotation = Vector3(0, marker.global_rotation.y, 0)
	player.head.rotation = Vector3.ZERO
	player.eye_camera.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO

#endregion

#region Drudzy in the tunnels

## Decides who from the Exitium expedition is at this place (kept until the hero leaves).
func _roll_encounter(place_id: StringName) -> void:
	# task_37 (OTW-9): in the opening Exitium comes to the camp at the end, never on the way.
	if GameState.opening():
		return
	var met: Array[String] = []
	if GameState.day >= 3 and not GameState.has_flag("drudzy_met"):
		for id in FieldSchedule.DRUDZY:
			if npcs.has(id):
				met.append(String(id))
	elif GameState.has_flag("drudzy_met") and not GameState.done_today("drudzy_seen"):
		var rng := RandomNumberGenerator.new()
		rng.seed = hash("%d-%s-%d" % [GameState.day, place_id, int(GameState.hour * 2.0)])
		if rng.randf() < DRUDZY_CHANCE:
			var candidates := _roaming_drudzy(place_id)
			if not candidates.is_empty():
				met.append(candidates[rng.randi_range(0, candidates.size() - 1)])
	if met.is_empty():
		return
	GameState.set_flag("encounter_place", String(place_id))
	GameState.set_flag("encounter_npcs", met)
	if GameState.has_flag("drudzy_met"):
		GameState.mark_today("drudzy_seen")

## Who of the three roaming mages can turn up here.
func _roaming_drudzy(place_id: StringName) -> Array[String]:
	var result: Array[String] = []
	var deep := Expeditions.place(place_id).depth >= 3 or place_id in [&"kaplica", &"upadowa"]
	# task_14 (NPC-18): Hieronim has no exit at 0% sanity (it is only a proposal on his card), so
	# nothing here asks whether he has gone.
	if npcs.has(&"hieronim"):
		result.append("hieronim")
	if npcs.has(&"ottokar") and deep:
		result.append("ottokar")
	if npcs.has(&"welf") and not GameState.has_flag("welf_lost"):
		if not GameState.has_flag("welf_wounded") and deep:
			# His one bad day: burnt and alone, he needs someone with bandages.
			GameState.set_flag("welf_wounded")
			GameState.set_flag("welf_wounded_day", GameState.day)
			return ["welf"]
		if GameState.has_flag("welf_helped"):
			result.append("welf")
	return result

func _leave_encounter() -> void:
	if GameState.has_flag("encounter_place"):
		# Nobody helped the wounded mage while you were there: he crawls away on his own.
		if "welf" in GameState.get_flag("encounter_npcs", []) and GameState.has_flag("welf_wounded") and not GameState.has_flag("welf_helped"):
			GameState.set_flag("welf_lost")
		GameState.clear_flag("encounter_place")
		GameState.clear_flag("encounter_npcs")

## The first meeting with the Exitium expedition (day 3 or the first trip after it).
func _meet_drudzy_if_due(place_id: StringName) -> void:
	if GameState.has_flag("drudzy_met") or String(GameState.get_flag("encounter_place", "")) != String(place_id):
		return
	GameState.set_flag("drudzy_met")
	GameState.set_flag("drudzy_met_at", String(place_id))
	GameState.mark_today("drudzy_seen")
	GameState.note_event("Spotkałeś wyprawę Drugich z Exitium. Jedna z nich ma zamieszkać w obozie.")
	await VN.play(DRUDZY_DIALOGUE, "meeting", &"ottokar")

#endregion

#region Hrapek on the way back

## Met only on the way back to the camp (card 02_postacie/hrapek.md, decisions 1A–3a): from day 3
## once the west rubble is blown (the first way back then is certain), afterwards 25% a way back,
## once a day; a second meeting is certain on the first way back on day 5. He dies in the night
## after day 5; the first way back after that finds the body, if the hero ever met him.
static func hrapek_due() -> String:
	# task_37 (OTW-2): Hrapek waits for a later chapter.
	if GameState.deferred(&"hrapek"):
		return ""
	if not GameState.has_flag("hrapek_free") or GameState.has_flag("hrapek_found"):
		return ""
	var meetings := int(GameState.get_flag("hrapek_meetings", 0))
	if GameState.has_flag("hrapek_dead"):
		return "body" if meetings > 0 else ""
	if GameState.day < 3 or GameState.done_today("hrapek_seen"):
		return ""
	if meetings == 0 or (GameState.day == HRAPEK_LAST_NIGHT and meetings < 2):
		return "meet"
	# Seeded by the day, the place and the hour, so loading a save doesn't reroll it.
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("hrapek-%d-%s-%d" % [GameState.day, GameState.current_place(), int(GameState.hour * 2.0)])
	return "meet" if rng.randf() < HRAPEK_CHANCE else ""

func _hrapek_on_the_way_back() -> void:
	var due := hrapek_due()
	if due == "":
		return
	if due == "meet":
		GameState.mark_today("hrapek_seen")
		GameState.set_flag("hrapek_meetings", int(GameState.get_flag("hrapek_meetings", 0)) + 1)
		GameState.set_flag("met_hrapek")
		GameState.set_flag("hrapek_q", 0)
		GameState.note_event("W drodze powrotnej zaczepił cię Hrapek.")
		await VN.play(HRAPEK_DIALOGUE, "meet", &"hrapek")
	else:
		GameState.note_event("W chodniku przed obozem leżał martwy Hrapek.")
		await VN.play(HRAPEK_DIALOGUE, "body", &"hrapek")

#endregion

#region Blast, nights and mornings

func _blast() -> void:
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.8)
	GameState.advance_time(BLAST_HOURS, "Mirosław wysadza zawał")
	blast_sound.play()
	await fade.show_card("Huk", "Mirosław wysadza zawał w zachodnim chodniku. Pył długo nie chce opaść.", 2.4)
	GameState.set_flag("west_blasted")
	# Kept for good: west_blasted goes away when Mirosław takes the tunnel with him, Hrapek doesn't.
	GameState.set_flag("hrapek_free")
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
	# The night is one line in the notebook's time log.
	GameState.log_time(GameState.hour, 0.0, "Sen")
	var news := _resolve_night()
	GameState.pop_modal()
	await VN.play(SYSTEM_DIALOGUE, "dream")
	GameState.push_modal()
	GameState.start_next_day()
	if GameState.day >= GameState.LAST_DAY:
		GameState.pop_modal()
		await _week_end()
		return
	apply_world_state()
	_place_player(markers.get_node("SpawnBed"))
	await fade.show_card("Dzień %d" % GameState.day, news if news != "" else _morning_subtitle(), 2.6)
	await fade.fade_in(1.2)
	GameState.pop_modal()
	SaveManager.capture_morning()
	await _morning_events()
	_busy = false

## Night resolution (spec 03_mechaniki/czas.md, CZAS-9): sanity, fever, departures, deciphering.
## Returns news for the morning card ("" = nothing special).
func _resolve_night() -> String:
	var night := GameState.day
	var news := ""
	# Mirosław: the week wears him down; an evening in company holds him together.
	var miroslaw_loss := 4
	if GameState.has_flag("west_blasted") and not GameState.has_flag("mir_night_blast_done"):
		GameState.set_flag("mir_night_blast_done")
		miroslaw_loss += 3 if GameState.has_flag("mir_comforted") else 10
	if night >= 2 and GameState.has_flag("mir_saw_charge"):
		miroslaw_loss += 2
	if GameState.done_today("mir_company"):
		miroslaw_loss -= 4
	if GameState.npc_status(&"miroslaw") != "dead":
		GameState.change_sanity(&"miroslaw", -miroslaw_loss)
		if GameState.sanity(&"miroslaw") <= 0:
			news = _miroslaw_breaks()
	GameState.change_sanity(&"bolko", -2 if not GameState.has_flag("bolko_knows_fate") else -5)
	GameState.change_sanity(&"racibor", -4 if GameState.quota_met() or night < 5 else -7)
	GameState.change_sanity(&"tekla", -10 if GameState.has_flag("tekla_reported") else -2)
	if night >= 2 and not GameState.has_flag("dobrawa_left") and GameState.has_arrived(&"dobrawa"):
		GameState.change_sanity(&"dobrawa", -5)
		if GameState.sanity(&"dobrawa") <= 0 and not GameState.has_flag("dobrawa_leaving"):
			GameState.set_flag("dobrawa_leaving")
			GameState.set_flag("dobrawa_went_down")
	if GameState.has_flag("dobrawa_leaving") and not GameState.has_flag("dobrawa_left"):
		GameState.set_flag("dobrawa_left")
		GameState.set_npc_status(&"dobrawa", "gone")
		if news == "":
			news = "Dobrawa zeszła sama w głąb. Nie wróciła." if GameState.has_flag("dobrawa_went_down") else "Dobrawy nie ma. Zniknęła przed świtem, razem z kryształem."
	_resolve_new_people(night)
	# The fifth night the ground shakes (Wszebor calls it the Day of the Bloody Sky). task_14
	# (NPC-18): it shakes those who are here; the Exitium mages only once they have been met.
	if night == 5:
		GameState.set_flag("tremor_seen")
		GameState.change_player_sanity(-3)
		for id in GameState.npcs:
			if GameState.has_arrived(id) and GameState.npc_status(id) in ["camp", "field"]:
				GameState.change_sanity(id, -2)
	if GameState.has_flag("welf_wounded") and not GameState.has_flag("welf_helped"):
		GameState.set_flag("welf_lost")
	# Hrapek dies in the night after day 5. Nobody in the camp knows; the hero finds him later.
	if night == HRAPEK_LAST_NIGHT:
		GameState.set_flag("hrapek_dead")
	# The hero: bad dreams, rest, the fever (it never kills in his sleep).
	GameState.change_player_sanity(-3)
	if GameState.done_today("soaked") and not GameState.player_fever:
		GameState.set_fever(true)
	if GameState.player_fever:
		GameState.player_health = maxi(GameState.player_health - 12, 5)
		GameState.change_player_sanity(-3)
		GameState.player_changed.emit()
	else:
		GameState.heal_player(8)
	# "Czternaście kresek": once the hero has read enough of the traces, whoever leaves the
	# bread and trims the lamp answers in kind. No word on who they are; the demo keeps that.
	if night >= 5 and GameState.quest_state(&"czternasty") == "active" and GameState.fourteenth_clues() >= 4 and not GameState.has_flag("fourteenth_gift"):
		GameState.set_flag("fourteenth_gift")
		GameState.give_item("lampa")
		GameState.quest_log(&"czternasty", "podarunek")
		GameState.complete_quest(&"czternasty")
		if news == "":
			news = "Przy twoim posłaniu stoi stara górnicza lampa. Pali się. Nikt się nie przyznaje."
	# task_37 (OTW-6): in the opening the hero reads it himself in the camp, with Bolko or alone.
	if GameState.has_note(&"szyfr") and GameState.has_note(&"klucz") and not GameState.has_flag("deciphered") and not GameState.opening():
		GameState.add_note(&"odszyfrowana")
		GameState.quest_log(&"slady", "odszyfrowane")
		GameState.set_flag("deciphered")
		GameState.set_flag("kaplica_known")
	return news

## The camp people added in task_05: nightly wear, Nasir's fever from the third night. Sabina
## wears down only from the night after she has moved into the camp (task_14, NPC-18).
func _resolve_new_people(night: int) -> void:
	for id in [&"wszebor", &"hagiwara", &"sobek", &"anzelm", &"nasir", &"sabina"]:
		if GameState.npcs.has(id) and GameState.has_arrived(id):
			GameState.change_sanity(id, -2)
	if GameState.npcs.has(&"anzelm") and GameState.has_flag("sabina_joined") and not GameState.has_flag("anzelm_sabina_peace"):
		GameState.change_sanity(&"anzelm", -2)
	if not GameState.npcs.has(&"nasir") or GameState.npc_status(&"nasir") == "gone" or not GameState.has_arrived(&"nasir"):
		return
	if night == 3 and not GameState.has_flag("nasir_fever_started"):
		GameState.set_flag("nasir_fever_started")
		GameState.set_flag("fever_nasir")
	if GameState.has_fever(&"nasir"):
		GameState.change_npc_health(&"nasir", -18)
		if GameState.npc_health(&"nasir") <= 10:
			# Too weak to stay: Racibor has him hauled up the shaft in the night.
			GameState.set_npc_status(&"nasir", "gone")
			GameState.set_flag("nasir_carried_up")
			if GameState.quest_state(&"goraczka") == "active":
				GameState.quest_log(&"goraczka", "wywieziony")
				GameState.fail_quest(&"goraczka")
	else:
		GameState.change_npc_health(&"nasir", 10)

## GDD: at zero sanity Mirosław blows himself up in a tunnel and closes it for good.
func _miroslaw_breaks() -> String:
	GameState.set_npc_status(&"miroslaw", "dead")
	GameState.set_flag("mir_dead")
	GameState.clear_flag("west_blasted")
	return "W nocy huk w zachodnim chodniku. Mirosław zabrał beczkę prochu i już nie wrócił."

func _morning_subtitle() -> String:
	if GameState.sanity_band(&"miroslaw") in ["na_krawedzi", "zalamany"] and GameState.npc_status(&"miroslaw") != "dead":
		return "Mirosława nie ma przy ognisku."
	if GameState.day == 2:
		# task_37 (OTW-5): nobody comes down the shaft in the opening.
		if GameState.opening():
			return tr("Kocioł Tekli dymi od świtu. Przy szybie ktoś już klnie na zimno.")
		return "Nocą szybem zjechał ktoś nowy."
	if GameState.day == 4 and GameState.has_fever(&"nasir"):
		return "Nasir kaszle od świtu. Anzelm kręci głową."
	if GameState.day == 6:
		return "W nocy ziemia drżała. Ze sklepienia sypał się żwir, a nikt nie spał."
	if GameState.day == GameState.QUOTA_DAY:
		return "Ostatni dzień. Wieczorem Racibor liczy żyły."
	return "Obóz budzi się powoli. Ogień ledwo się tli."

## Announcements at breakfast: the plans on day 3, Racibor's reminders when the quota lags.
func _morning_events() -> void:
	if GameState.day == 3 and not GameState.has_flag("announcement_done"):
		await VN.play(RACIBOR_DIALOGUE, "announcement", &"racibor")
		GameState.set_flag("announcement_done")
		GameState.message.emit("Do wieczora dnia %d Kniaź chce %d żył. Zaznaczonych masz %d." % [GameState.QUOTA_DAY, GameState.QUOTA, GameState.veins_mapped()])
		return
	if GameState.day >= 4 and GameState.day <= GameState.QUOTA_DAY and _quota_lags() and GameState.npc_status(&"racibor") == "camp":
		GameState.set_flag("reminder_day", GameState.day)
		await VN.play(RACIBOR_DIALOGUE, "reminder", &"racibor")
		GameState.change_rep(&"racibor", -2)
		return
	GameState.message.emit("Dzień %d. %s." % [GameState.day, GameState.quota_text()])

## Behind the pace the Kniaź expects (about QUOTA/7 a day, with a little slack), or the last day.
func _quota_lags() -> bool:
	if GameState.quota_met():
		return false
	var expected := int(floor(GameState.QUOTA * (GameState.day - 1) / 7.0)) - 1
	return GameState.veins_mapped() < expected or GameState.day == GameState.QUOTA_DAY

#endregion

#region The end of the opening

## task_37 (OTW-9): on the last day of the opening the Exitium expedition comes to the palisade once
## the hero is in the camp from the evening hour on, or earlier when he goes to bed.
func _opening_finale_due(at_bed := false) -> bool:
	if not GameState.opening() or GameState.has_flag("opening_done") or GameState.is_away():
		return false
	if GameState.day < GameState.OPENING_LAST_DAY:
		return false
	return at_bed or GameState.day > GameState.OPENING_LAST_DAY or GameState.hour >= GameState.OPENING_FINALE_HOUR - 0.001

func _check_opening_finale() -> void:
	if _busy or VN.is_active() or not _opening_finale_due():
		return
	await _opening_finale()

## The closing scene, the run report and the end screen (OTW-10). No night follows.
func _opening_finale() -> void:
	_busy = true
	GameState.set_flag("opening_done")
	await VN.play(DRUDZY_DIALOGUE, "finale", &"ottokar")
	var report_path := RunReport.write(RunReport.ENDING_OPENING)
	await fade.show_end(_opening_summary(report_path), tr("Koniec otwarcia"))

func _opening_summary(report_path := "") -> String:
	var band := {"spokojny": tr("spokojny"), "niespokojny": tr("niespokojny"), "na_krawedzi": tr("na krawędzi"), "zalamany": tr("załamany")}
	var lines: Array[String] = []
	lines.append(tr("Exitium przyszło po mapy dziadka. Tu kończy się otwarcie."))
	lines.append("")
	lines.append(tr("Żyły błękitu na mapie: %d") % GameState.veins_mapped())
	lines.append(tr("Raport z archiwum: %s") % (tr("u ciebie, Racibor dotrzymał słowa") if GameState.has_note(&"raport_archiwum") else tr("jeszcze nie")))
	lines.append(tr("Wiadomość dziadka: %s") % _opening_message_summary())
	lines.append(tr("Upadowa: %s") % _opening_upadowa_summary())
	lines.append(tr("Mapy dziadka: %s") % _opening_maps_summary())
	lines.append("")
	lines.append(tr("Mirosław: %s") % (tr("nie żyje, zabrał ze sobą zachodni chodnik") if GameState.npc_status(&"miroslaw") == "dead" else band.get(GameState.sanity_band(&"miroslaw"), "?")))
	var trust := GameState.rep(&"bolko")
	var bolko := tr("ufa ci") if trust >= 10 else (tr("nie ufa ci") if trust < 0 else tr("ostrożny"))
	if GameState.has_flag("bolko_relieved"):
		bolko += tr(", wie już, że to nie jego stempel")
	lines.append(tr("Bolko: %s") % bolko)
	lines.append(tr("Tekla: %s") % (tr("zna cię z kolacji") if GameState.has_flag("supper_eaten") else tr("liczy każdą świeczkę")))
	lines.append(tr("Racibor: %s") % (tr("liczy na ciebie") if GameState.rep(&"racibor") >= 10 else (tr("ma cię na oku") if GameState.rep(&"racibor") < 0 else tr("zdystansowany"))))
	lines.append("")
	lines.append(tr("Dziękujemy za grę."))
	if report_path != "":
		lines.append(tr("Raport przebiegu zapisano: %s/%s") % [SaveManager.report_dir.get_file(), report_path.get_file()])
	return "\n".join(lines)

func _opening_message_summary() -> String:
	if GameState.has_flag("deciphered"):
		return tr("odczytana razem z Bolkiem") if GameState.has_flag("papers_with_bolko") else tr("odczytana w pojedynkę")
	if GameState.has_note(&"szyfr"):
		return tr("kartka i klucz czekają") if GameState.has_note(&"klucz") else tr("szyfr bez klucza")
	return tr("nieodnaleziona")

func _opening_upadowa_summary() -> String:
	if GameState.has_flag("mir_saw_charge"):
		return tr("zawał od ładunku, Mirosław nie ma wątpliwości")
	if GameState.has_flag("saw_charge"):
		return tr("okopcone kamienie, klepki z beczki")
	return tr("nikt jej jeszcze nie oglądał")

func _opening_maps_summary() -> String:
	match String(GameState.get_flag("opening_maps", "")):
		"pokazane":
			return tr("Ottokar je przerysował")
		"odmowa":
			return tr("zostały u ciebie, Ottokar odszedł bez nich")
		"zwloka":
			return tr("Ottokar czeka na odpowiedź")
	return tr("bez odpowiedzi")

#endregion

#region The hero falls

func _on_player_died(reason: String) -> void:
	if VN.is_active():
		await VN.finished
	_busy = true
	var lines: Array[String] = []
	lines.append(reason + "." if reason != "" else "Ostatnia rana była o jedną za dużo.")
	lines.append("")
	lines.append("Dzień %d, %s. %s." % [GameState.day, GameState.time_text(GameState.hour), Expeditions.display_name(GameState.current_place())])
	lines.append("Kopalnia zabiera tych, którzy schodzą do niej poranieni.")
	await fade.show_end("\n".join(lines), "Nie żyjesz", SaveManager.retry_morning)

## Sanity at zero: the hero runs blindly, someone brings him back, the day is lost.
func _on_player_broke(_reason: String) -> void:
	if VN.is_active():
		await VN.finished
	if _busy:
		return
	_busy = true
	GameState.push_modal()
	await fade.fade_out(0.5)
	await fade.show_card("Ciemność", "Uciekasz przed czymś, czego nie ma. Nie pamiętasz drogi. Budzisz się na posłaniu, ktoś cię przyniósł.", 3.2)
	_leave_encounter()
	if GameState.is_away():
		GameState.note_event("Straciłeś głowę i ktoś odniósł cię do obozu.")
		GameState.clear_flag("location")
		GameState.end_expedition()
	GameState.player_sanity = 20
	GameState.player_changed.emit()
	GameState.hour = maxf(GameState.hour, GameState.DAY_START_HOUR + GameState.DAY_LENGTH_HOURS)
	_place_player(markers.get_node("SpawnBed"))
	apply_world_state()
	GameState.pop_modal()
	_busy = false
	await _sleep()

func _whisper() -> void:
	_whisper_timer.start(randf_range(WHISPER_SECONDS.x, WHISPER_SECONDS.y))
	if GameState.is_away() and GameState.mind_band() == "na_krawedzi" and not GameState.is_modal():
		GameState.message.emit(WHISPERS[randi() % WHISPERS.size()])

#endregion

#region End of the week

## The morning of day 8: Racibor counts the veins. Short of the quota, the expedition leaves at
## dawn without the hero (MECHANICS §13 pkt 2).
func _week_end() -> void:
	_busy = true
	var success := GameState.quota_met()
	if success:
		apply_world_state()
		_place_player(markers.get_node("SpawnBed"))
		await fade.show_card("Dzień %d" % GameState.day, "Ranek po tygodniu. Racibor siedzi nad mapą od świtu.", 2.4)
		await fade.fade_in(1.0)
		await VN.play(RACIBOR_DIALOGUE, "reckoning", &"racibor")
	else:
		await fade.show_card("Dzień %d" % GameState.day, "Budzi cię cisza.", 2.4)
		await VN.play(SYSTEM_DIALOGUE, "left_behind")
	# task_14 (ZAP-11): the run report is written with the state of the very end, for both endings.
	var report_path := RunReport.write(RunReport.ENDING_WEEK if success else RunReport.ENDING_ALONE)
	await fade.show_end(_end_summary(success, report_path), "Koniec tygodnia" if success else "Zostałeś sam")

func _end_summary(success: bool, report_path := "") -> String:
	var band := {"spokojny": "spokojny", "niespokojny": "niespokojny", "na_krawedzi": "na krawędzi", "zalamany": "załamany"}
	var lines: Array[String] = []
	if success:
		lines.append("Przetrwałeś tydzień w kopalni. Kniaź dostanie swoje żyły. Tu kończy się wersja demo.")
	else:
		lines.append("Wyprawa odjechała bez ciebie. Zostałeś w kopalni sam, z lampą, mapą dziadka i szeptami. Tu kończy się wersja demo.")
	lines.append("")
	lines.append("Żyły błękitu: %d z %d wymaganych" % [GameState.veins_mapped(), GameState.QUOTA])
	lines.append("Wiadomość dziadka: %s" % ("odczytana" if GameState.has_flag("deciphered") else ("szyfr bez klucza" if GameState.has_note(&"szyfr") else "nieodnaleziona")))
	lines.append("Ściana w kaplicy: %s" % ("otwarta, list dziadka przeczytany" if GameState.has_flag("wall_open") else "nierozwiązana"))
	lines.append("Kryształ: %s" % _crystal_summary())
	lines.append("Upadowa: %s" % _upadowa_summary(success))
	if GameState.has_flag("met_hrapek"):
		lines.append("Hrapek: %s" % _hrapek_summary())
	if GameState.quest_state(&"czternasty") != "":
		lines.append("Czternasty: %s" % ("ktoś odpowiedział ci lampą" if GameState.has_flag("fourteenth_gift") else "%d śladów, odpowiedzi brak" % GameState.fourteenth_clues()))
	lines.append("")
	lines.append("Mirosław: %s" % ("nie żyje, zabrał ze sobą zachodni chodnik" if GameState.npc_status(&"miroslaw") == "dead" else band.get(GameState.sanity_band(&"miroslaw"), "?")))
	var trust := GameState.rep(&"bolko")
	lines.append("Bolko: %s" % ("ufa ci" if trust >= 10 else ("nie ufa ci" if trust < 0 else "ostrożny")))
	lines.append("Tekla: %s" % _tekla_summary())
	lines.append("Racibor: %s" % ("liczy na ciebie" if GameState.rep(&"racibor") >= 10 else ("ma cię na oku" if GameState.rep(&"racibor") < 0 else "zdystansowany")))
	for line in _new_people_summary():
		lines.append(line)
	lines.append("")
	lines.append("Dziękujemy za grę.")
	if report_path != "":
		# The folder name and the file only: the full path is long, and the panel is tall already.
		lines.append("Raport przebiegu zapisano: %s/%s" % [SaveManager.report_dir.get_file(), report_path.get_file()])
	return "\n".join(lines)

func _upadowa_summary(success: bool) -> String:
	if not GameState.has_flag("plan_upadowa"):
		return "nikt jej nie rusza"
	if GameState.has_flag("racibor_doubts"):
		return "Racibor się waha, list dziadka zrobił swoje"
	return "Racibor każe ją otworzyć" if success else "otworzą ją bez ciebie"

func _new_people_summary() -> Array[String]:
	var result: Array[String] = []
	if GameState.npcs.has(&"nasir"):
		if GameState.has_flag("nasir_carried_up"):
			result.append("Nasir: wywieziony na górę w gorączce")
		elif GameState.has_flag("nasir_fever_started") and not GameState.has_fever(&"nasir"):
			result.append("Nasir: wyzdrowiał")
	if GameState.npcs.has(&"sabina") and GameState.has_flag("sabina_joined"):
		result.append("Sabina z Exitium: %s" % ("zostaje w obozie" if GameState.npc_status(&"sabina") != "gone" else "odeszła"))
	if GameState.has_flag("welf_wounded"):
		result.append("Welf z Exitium: %s" % ("żyje dzięki twoim bandażom" if GameState.has_flag("welf_helped") else "przepadł w chodnikach"))
	return result

func _hrapek_summary() -> String:
	var parts: Array[String] = []
	parts.append("zjadł twoją rybę" if GameState.quest_state(&"ryba") == "done" else "ryby się nie doczekał")
	if GameState.has_flag("hrapek_found"):
		parts.append("zginął szóstego dnia w chodniku")
		if GameState.has_flag("hrapek_ring"):
			parts.append("jego pierścień masz przy sobie")
	elif GameState.has_flag("hrapek_dead"):
		parts.append("od szóstego dnia nikt go nie widział")
	return ", ".join(parts)

func _crystal_summary() -> String:
	if GameState.has_flag("crystal_to_dobrawa"):
		return "u Dobrawy, w drodze do Initium"
	if GameState.has_flag("crystal_to_racibor"):
		return "u Racibora, dla Kniazia"
	if GameState.has_flag("crystal_to_ottokar"):
		return "u Ottokara, w Exitium"
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
