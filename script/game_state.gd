extends Node

## Autoload "GameState": everything that changes during a playthrough.
## Day and hour, story flags, items, found notes, quests, NPC state, the hero's health and
## sanity, and the current expedition. Dialogue files use it through `using GameState`.

signal time_advanced(hours: float, reason: String)
signal day_started(day: int)
## Emitted after reset() or load_state(): listeners re-read everything.
signal state_replaced
signal flags_changed
signal note_added(note: NoteData)
signal quest_updated(quest: QuestData, entry_text: String)
signal item_changed(item_id: String, count: int)
signal npc_changed(npc_id: StringName)
## The hero's health, sanity or fever changed.
signal player_changed
## Health dropped to zero (docs_v2/systemy/zdrowie_i_poczytalnosc.md: death needs earlier wounds).
signal player_died(reason: String)
## Sanity dropped to zero: the hero panics and loses the rest of the day.
signal player_broke(reason: String)
## For short on-screen messages (HUD toast).
signal message(text: String)
## A dialogue asks the world to do something after it closes ("sleep", "blast"…).
signal action_requested(action: String)

const DAY_START_HOUR := 6.0
const DAY_LENGTH_HOURS := 16.0
## The week ends on the morning of this day: Racibor counts the veins (docs_v2/systemy/czas.md).
const LAST_DAY := 8
## Veins the Kniaź wants marked by the end of QUOTA_DAY (MECHANICS §13 pkt 2).
const QUOTA := 12
const QUOTA_DAY := 7

const PLAYER_MAX := 100
const PLAYER_START_SANITY := 80

const NPCS: Dictionary = {
	&"miroslaw": preload("res://data/npc/miroslaw.tres"),
	&"bolko": preload("res://data/npc/bolko.tres"),
	&"racibor": preload("res://data/npc/racibor.tres"),
	&"tekla": preload("res://data/npc/tekla.tres"),
	&"dobrawa": preload("res://data/npc/dobrawa.tres"),
	&"wszebor": preload("res://data/npc/wszebor.tres"),
	&"nasir": preload("res://data/npc/nasir.tres"),
	&"hagiwara": preload("res://data/npc/hagiwara.tres"),
	&"sobek": preload("res://data/npc/sobek.tres"),
	&"anzelm": preload("res://data/npc/anzelm.tres"),
	&"sabina": preload("res://data/npc/sabina.tres"),
	&"ottokar": preload("res://data/npc/ottokar.tres"),
	&"hieronim": preload("res://data/npc/hieronim.tres"),
	&"welf": preload("res://data/npc/welf.tres"),
}
const NOTES: Dictionary = {
	&"notatka_dowodcy": preload("res://data/notes/notatka_dowodcy.tres"),
	&"szyfr": preload("res://data/notes/szyfr.tres"),
	&"klucz": preload("res://data/notes/klucz.tres"),
	&"odszyfrowana": preload("res://data/notes/odszyfrowana.tres"),
	&"raport_archiwum": preload("res://data/notes/raport_archiwum.tres"),
	&"list_konfraterni": preload("res://data/notes/list_konfraterni.tres"),
	&"slowniczek": preload("res://data/notes/slowniczek.tres"),
	&"list_dziadka": preload("res://data/notes/list_dziadka.tres"),
	&"zapiski_grabca": preload("res://data/notes/zapiski_grabca.tres"),
	&"wiersz_hagiwary": preload("res://data/notes/wiersz_hagiwary.tres"),
}
const QUESTS: Dictionary = {
	&"slady": preload("res://data/quests/slady.tres"),
	&"lonty": preload("res://data/quests/lonty.tres"),
	&"zloza": preload("res://data/quests/zloza.tres"),
	&"towar": preload("res://data/quests/towar.tres"),
	&"sciana": preload("res://data/quests/sciana.tres"),
	&"kilof": preload("res://data/quests/kilof.tres"),
	&"pompy": preload("res://data/quests/pompy.tres"),
	&"goraczka": preload("res://data/quests/goraczka.tres"),
	&"wiersz": preload("res://data/quests/wiersz.tres"),
	&"zaklad": preload("res://data/quests/zaklad.tres"),
	&"pokoj": preload("res://data/quests/pokoj.tres"),
	&"oferta": preload("res://data/quests/oferta.tres"),
	&"odlamek": preload("res://data/quests/odlamek.tres"),
}
const ITEMS: Dictionary = {
	&"amulet": preload("res://data/items/amulet.tres"),
	&"lonty": preload("res://data/items/lonty.tres"),
	&"lina": preload("res://data/items/lina.tres"),
	&"kwit": preload("res://data/items/kwit.tres"),
	&"tobolek": preload("res://data/items/tobolek.tres"),
	&"krysztal": preload("res://data/items/krysztal.tres"),
	&"bandaze": preload("res://data/items/bandaze.tres"),
	&"lekarstwo": preload("res://data/items/lekarstwo.tres"),
	&"nalewka": preload("res://data/items/nalewka.tres"),
	&"swieca": preload("res://data/items/swieca.tres"),
	&"olej": preload("res://data/items/olej.tres"),
	&"lom": preload("res://data/items/lom.tres"),
	&"obuch": preload("res://data/items/obuch.tres"),
	&"kilof": preload("res://data/items/kilof.tres"),
	&"grzyb": preload("res://data/items/grzyb.tres"),
	&"odlamek": preload("res://data/items/odlamek.tres"),
	&"klejnot": preload("res://data/items/klejnot.tres"),
}
## Places of the expedition map (Expeditions). The camp itself is "oboz".
const LOCATIONS: Dictionary = {
	&"east": preload("res://data/locations/east.tres"),
	&"west": preload("res://data/locations/west.tres"),
	&"rzapie": preload("res://data/locations/rzapie.tres"),
	&"upadowa": preload("res://data/locations/upadowa.tres"),
	&"kuznia": preload("res://data/locations/kuznia.tres"),
	&"kaplica": preload("res://data/locations/kaplica.tres"),
	&"wyrobisko": preload("res://data/locations/wyrobisko.tres"),
	&"pompy": preload("res://data/locations/pompy.tres"),
	&"szyb": preload("res://data/locations/szyb.tres"),
	&"kostnica": preload("res://data/locations/kostnica.tres"),
	&"grota": preload("res://data/locations/grota.tres"),
	&"przekop": preload("res://data/locations/przekop.tres"),
	&"zalany": preload("res://data/locations/zalany.tres"),
	&"szczelina": preload("res://data/locations/szczelina.tres"),
	&"galeria": preload("res://data/locations/galeria.tres"),
}

var day: int = 1
var hour: float = DAY_START_HOUR
var flags: Dictionary = {}
var items: Dictionary = {}
var notes: Array[StringName] = []
## quest id → {"state": "active" | "done" | "failed", "entries": [entry ids]}
var quests: Dictionary = {}
## npc id → {"sanity", "health", "reputation", "status"}
var npcs: Dictionary = {}
## npc id → where the NPC is right now ("" = not in the camp). Set by the StoryDirector from
## CampSchedule; not saved, it is recomputed from the day, hour and flags.
var places: Dictionary = {}
var player_health: int = PLAYER_MAX
var player_sanity: int = PLAYER_START_SANITY
var player_fever := false
## The expedition under way (empty in the camp): start time, places, veins, items, events.
var expedition: Dictionary = {}

## Open modal screens (dialogue, map, notebook…). While > 0 the player can't move.
var _modal_count := 0

func _ready() -> void:
	reset()

func reset() -> void:
	day = 1
	hour = DAY_START_HOUR
	flags = {}
	items = {}
	notes = []
	quests = {}
	npcs = {}
	places = {}
	player_health = PLAYER_MAX
	player_sanity = PLAYER_START_SANITY
	player_fever = false
	expedition = {}
	for id in NPCS:
		var data: NpcData = NPCS[id]
		npcs[id] = {"sanity": data.start_sanity, "health": data.max_health, "reputation": data.start_reputation, "status": "camp"}
	# The hero never takes off his grandfather's amulet.
	items["amulet"] = 1
	_modal_count = 0
	start_quest("slady")
	state_replaced.emit()

#region Time

func hours_left() -> float:
	return DAY_START_HOUR + DAY_LENGTH_HOURS - hour

func can_afford(hours: float) -> bool:
	return hours <= hours_left() + 0.001

func is_day_over() -> bool:
	return hours_left() <= 0.001

func advance_time(hours: float, reason: String = "") -> void:
	if hours <= 0.0:
		return
	hour += hours
	time_advanced.emit(hours, reason)

func start_next_day() -> void:
	day += 1
	hour = DAY_START_HOUR
	day_started.emit(day)

func hours_left_text() -> String:
	return hours_text(maxf(hours_left(), 0.0))

## "2 h", "1,5 h".
static func hours_text(hours: float) -> String:
	if is_equal_approx(hours, floor(hours)):
		return "%d h" % int(hours)
	return ("%.1f h" % hours).replace(".", ",")

## Called from dialogue: the world performs the action once the dialogue closes.
func request(action: String) -> void:
	action_requested.emit(action)

func clock_text() -> String:
	return "Dzień %d · %s" % [day, time_text(hour)]

## "07:30" for an hour of the day (may be past midnight after a late return).
static func time_text(at_hour: float) -> String:
	var h := int(at_hour) % 24
	var m := int(round((at_hour - floor(at_hour)) * 60.0)) % 60
	return "%02d:%02d" % [h, m]

## "rano" (breakfast, before 8), "dzien" (work, 8–18) or "wieczor" (supper and after).
func part_of_day() -> String:
	if hour < 8.0:
		return "rano"
	if hour < 18.0:
		return "dzien"
	return "wieczor"

## Days left until the Kniaź's deadline (0 on the last day).
func days_to_deadline() -> int:
	return maxi(QUOTA_DAY - day, 0)

#endregion

#region Flags and items

func set_flag(flag_name: String, value: Variant = true) -> void:
	var new_vein := flag_name.begins_with("vein_") and not has_flag(flag_name)
	flags[flag_name] = value
	flags_changed.emit()
	if new_vein:
		message.emit("Żyła na mapie. %s." % quota_text())
		_check_quota()

func clear_flag(flag_name: String) -> void:
	flags.erase(flag_name)
	flags_changed.emit()

func has_flag(flag_name: String) -> bool:
	return bool(flags.get(flag_name, false))

func get_flag(flag_name: String, default: Variant = null) -> Variant:
	return flags.get(flag_name, default)

## For once-a-day things in dialogues: `if not done_today("anzelm_care")` … `$> mark_today("anzelm_care")`.
func done_today(flag_name: String) -> bool:
	return int(flags.get(flag_name, 0)) == day

func mark_today(flag_name: String) -> void:
	set_flag(flag_name, day)

func item_data(item_id: String) -> ItemData:
	return ITEMS.get(StringName(item_id))

func item_name(item_id: String) -> String:
	var data := item_data(item_id)
	return data.display_name if data else item_id

func give_item(item_id: String, count: int = 1) -> void:
	items[item_id] = int(items.get(item_id, 0)) + count
	item_changed.emit(item_id, items[item_id])
	message.emit("Zdobyto: %s%s  [I]" % [item_name(item_id), " ×%d" % count if count > 1 else ""])
	if not expedition.is_empty():
		var found: Dictionary = expedition["items"]
		found[item_id] = int(found.get(item_id, 0)) + count

func take_item(item_id: String, count: int = 1) -> bool:
	if int(items.get(item_id, 0)) < count:
		return false
	items[item_id] = int(items[item_id]) - count
	if items[item_id] <= 0:
		items.erase(item_id)
	item_changed.emit(item_id, int(items.get(item_id, 0)))
	return true

func has_item(item_id: String) -> bool:
	return int(items.get(item_id, 0)) > 0

func item_count(item_id: String) -> int:
	return int(items.get(item_id, 0))

## Why the hero can't use the item on themselves right now ("" = can).
func item_use_blocker(item_id: String) -> String:
	var data := item_data(item_id)
	if data == null or not data.is_usable():
		return "Tego nie da się użyć na sobie."
	if not has_item(item_id):
		return "Nie masz tego."
	var helps := (data.heal > 0 and player_health < PLAYER_MAX) or (data.sanity > 0 and player_sanity < PLAYER_MAX) or (data.cures_fever and player_fever)
	if not helps:
		return "Teraz ci to niepotrzebne. Szkoda marnować."
	return ""

## The hero uses an item on themselves (inventory [I]).
func use_item(item_id: String) -> bool:
	if item_use_blocker(item_id) != "":
		return false
	var data := item_data(item_id)
	if data.consumable:
		take_item(item_id)
	advance_time(data.use_hours, data.display_name)
	if data.heal > 0:
		heal_player(data.heal)
	if data.sanity > 0:
		change_player_sanity(data.sanity)
	if data.cures_fever:
		set_fever(false)
	if data.use_text != "":
		message.emit(data.use_text)
	return true

## Gives an item to an NPC; medicine and drink work on them like on the hero.
## Dialogue: `$> give_to_npc("lekarstwo", "nasir")`.
func give_to_npc(item_id: String, npc_id: StringName) -> bool:
	if not take_item(item_id):
		return false
	var data := item_data(item_id)
	if data and npcs.has(npc_id):
		if data.heal > 0:
			change_npc_health(npc_id, data.heal)
		if data.sanity > 0:
			change_sanity(npc_id, data.sanity)
		if data.cures_fever:
			clear_flag("fever_%s" % npc_id)
	message.emit("Oddano: %s" % item_name(item_id))
	return true

#endregion

#region Veins and the quota

## Every blue-iron vein on the expedition map (flag "vein_<id>" once marked).
func vein_ids() -> Array[String]:
	var result: Array[String] = []
	for id in LOCATIONS:
		for vein in (LOCATIONS[id] as LocationData).veins:
			result.append(vein)
	return result

## How many veins the player has marked for Racibor.
func veins_mapped() -> int:
	var count := 0
	for vein in vein_ids():
		if has_flag("vein_" + vein):
			count += 1
	return count

func vein_total() -> int:
	return vein_ids().size()

func quota_met() -> bool:
	return veins_mapped() >= QUOTA

## For dialogues (constants aren't visible there): the quota and how many veins are missing.
func quota() -> int:
	return QUOTA

func veins_short() -> int:
	return maxi(QUOTA - veins_mapped(), 0)

## Sabina's sense (dialogue): places the hero has visited that still hide unmarked veins.
func vein_hint() -> String:
	var hints: Array[String] = []
	var unseen := 0
	for id in LOCATIONS:
		var data: LocationData = LOCATIONS[id]
		var left := 0
		for vein in data.veins:
			if not has_flag("vein_" + vein):
				left += 1
		if left == 0:
			continue
		if has_flag("visited_%s" % id):
			hints.append("%s%s" % [data.display_name, "" if left == 1 else ", i to niejedna"])
		else:
			unseen += left
	var text := ""
	if hints.is_empty():
		text = "Tam, gdzie już byłeś, nic nie zostało. Wszystko, co znalazłeś, zaznaczyłeś."
	else:
		text = "Coś jeszcze śpi w tych miejscach: %s." % ", ".join(hints.slice(0, 4))
	if unseen > 0:
		text += " A niżej, tam, gdzie jeszcze nie byłeś, jest ich więcej, niż zdążysz policzyć."
	return text

## Someone else marks veins on the hero's map (Ottokar's price): visited places first.
func mark_veins_for_player(count: int) -> void:
	var marked: Array[String] = []
	for pass_visited in [true, false]:
		for id in LOCATIONS:
			if marked.size() >= count:
				break
			if has_flag("visited_%s" % id) != pass_visited:
				continue
			var data: LocationData = LOCATIONS[id]
			for vein in data.veins:
				if marked.size() < count and not has_flag("vein_" + vein):
					flags["vein_" + vein] = true
					marked.append(data.display_name)
	if not marked.is_empty():
		flags_changed.emit()
		message.emit("Nowe kreski na mapie: %s. %s." % [", ".join(marked), quota_text()])
		_check_quota()

## The quota reached for the first time: a note in Racibor's quest.
func _check_quota() -> void:
	if quota_met() and not has_flag("quota_met_logged"):
		flags["quota_met_logged"] = true
		quest_log(&"zloza", "norma")
		message.emit("Dwanaście żył. Norma Kniazia zrobiona.")

## "7 z 12" plus the deadline, for the map, the notebook and the summary.
func quota_text() -> String:
	var deadline := "termin mija dziś wieczorem" if days_to_deadline() == 0 else "termin: koniec dnia %d, %s" % [QUOTA_DAY, days_left_text()]
	return "Żyły błękitu: %d z %d · %s" % [veins_mapped(), QUOTA, deadline]

## Polish plural forms: 1 → one, 2–4 (but not 12–14) → few, the rest → many.
static func plural(n: int, one: String, few: String, many: String) -> String:
	if n == 1:
		return one
	var last := n % 10
	var tens := n % 100
	if last >= 2 and last <= 4 and (tens < 12 or tens > 14):
		return few
	return many

## For dialogues after "mam": "jedną żyłę", "3 żyły", "7 żył".
func veins_acc() -> String:
	var n := veins_mapped()
	if n == 1:
		return "jedną żyłę"
	return "%d %s" % [n, plural(n, "żyłę", "żyły", "żył")]

## "został jeden dzień", "zostały 2 dni", "zostało 5 dni" ("termin mija dziś" on the last day).
func days_left_text() -> String:
	var n := days_to_deadline()
	if n == 0:
		return "termin mija dziś"
	if n == 1:
		return "został jeden dzień"
	return "%s %d dni" % [plural(n, "został", "zostały", "zostało"), n]

#endregion

#region The hero

## "zdrowy" ≥ 75, "poobijany" ≥ 45, "ranny" ≥ 20, "ciezko_ranny" > 0, "martwy" = 0.
func health_band() -> String:
	if player_health >= 75:
		return "zdrowy"
	if player_health >= 45:
		return "poobijany"
	if player_health >= 20:
		return "ranny"
	if player_health > 0:
		return "ciezko_ranny"
	return "martwy"

## "spokojny" ≥ 60, "niespokojny" ≥ 35, "na_krawedzi" > 0, "zalamany" = 0.
func mind_band() -> String:
	if player_sanity >= 60:
		return "spokojny"
	if player_sanity >= 35:
		return "niespokojny"
	if player_sanity > 0:
		return "na_krawedzi"
	return "zalamany"

func health_text() -> String:
	return {"zdrowy": "cały i zdrowy", "poobijany": "poobijany", "ranny": "ranny", "ciezko_ranny": "ciężko ranny", "martwy": "martwy"}[health_band()]

func mind_text() -> String:
	return {"spokojny": "spokojny", "niespokojny": "niespokojny", "na_krawedzi": "na krawędzi", "zalamany": "załamany"}[mind_band()]

func is_badly_hurt() -> bool:
	return health_band() in ["ranny", "ciezko_ranny"]

## A wound from the world (a hot vent, a fall, a mage). Death only comes on top of earlier
## wounds: one blow never takes more than the hero has above 1 unless he was already hurt.
func hurt_player(amount: int, reason: String = "") -> void:
	if amount <= 0:
		return
	var was_hurt := player_health < 75
	var floor_value := 0 if was_hurt else 1
	player_health = clampi(player_health - amount, floor_value, PLAYER_MAX)
	player_changed.emit()
	message.emit("%s. Jesteś teraz: %s." % [reason if reason != "" else "Rana", health_text()])
	if player_health <= 0:
		player_died.emit(reason)

func heal_player(amount: int) -> void:
	player_health = clampi(player_health + amount, 0, PLAYER_MAX)
	player_changed.emit()

func change_player_sanity(delta: int, reason: String = "") -> void:
	if delta == 0:
		return
	player_sanity = clampi(player_sanity + delta, 0, PLAYER_MAX)
	player_changed.emit()
	if delta < 0 and reason != "":
		message.emit("%s. Czujesz się: %s." % [reason, mind_text()])
	if player_sanity <= 0:
		player_broke.emit(reason)

func set_fever(on: bool) -> void:
	if player_fever == on:
		return
	player_fever = on
	player_changed.emit()
	message.emit("Masz gorączkę. Bez lekarstwa będzie tylko gorzej." if on else "Gorączka spada.")

#endregion

#region Expeditions

func current_place() -> StringName:
	var place := String(get_flag("location", ""))
	return &"oboz" if place == "" else StringName(place)

func is_away() -> bool:
	return String(get_flag("location", "")) != ""

func begin_expedition() -> void:
	expedition = {
		"day": day, "start": hour, "places": [], "veins": veins_mapped(), "items": {},
		"events": [], "health": player_health, "sanity": player_sanity,
	}

func note_expedition_place(place_id: String) -> void:
	if expedition.is_empty():
		return
	var visited: Array = expedition["places"]
	if not place_id in visited:
		visited.append(place_id)

## Something worth a line in the expedition summary ("Spotkałeś wyprawę Drugich").
func note_event(text: String) -> void:
	if not expedition.is_empty() and not text in expedition["events"]:
		(expedition["events"] as Array).append(text)

## Ends the expedition and returns its record (for the summary screen).
func end_expedition() -> Dictionary:
	var record := expedition
	expedition = {}
	return record

#endregion

#region Notes and quests

func add_note(note_id: StringName) -> void:
	if note_id in notes or not NOTES.has(note_id):
		return
	notes.append(note_id)
	note_added.emit(NOTES[note_id])
	message.emit("Nowa notatka w notesie: %s  [J]" % NOTES[note_id].title)

func has_note(note_id: StringName) -> bool:
	return note_id in notes

func start_quest(quest_id: StringName) -> void:
	if quests.has(quest_id) or not QUESTS.has(quest_id):
		return
	quests[quest_id] = {"state": "active", "entries": []}
	quest_log(quest_id, "start")

func quest_log(quest_id: StringName, entry_id: String) -> void:
	start_quest(quest_id)
	var quest: Dictionary = quests[quest_id]
	if entry_id in quest["entries"]:
		return
	quest["entries"].append(entry_id)
	var data: QuestData = QUESTS[quest_id]
	quest_updated.emit(data, data.entries.get(entry_id, ""))

func complete_quest(quest_id: StringName) -> void:
	if quests.has(quest_id):
		quests[quest_id]["state"] = "done"
		quest_updated.emit(QUESTS[quest_id], "")

func fail_quest(quest_id: StringName) -> void:
	if quests.has(quest_id):
		quests[quest_id]["state"] = "failed"
		quest_updated.emit(QUESTS[quest_id], "")

func quest_state(quest_id: StringName) -> String:
	return quests[quest_id]["state"] if quests.has(quest_id) else ""

#endregion

#region NPCs

func npc_data(npc_id: StringName) -> NpcData:
	return NPCS.get(npc_id)

## Finds an NPC by the speaker name used in dialogue files.
func npc_by_dialogue_name(speaker: String) -> NpcData:
	for id in NPCS:
		if NPCS[id].dialogue_name == speaker:
			return NPCS[id]
	return null

func sanity(npc_id: StringName) -> int:
	return int(npcs[npc_id]["sanity"])

## Symptom band used by dialogues: "spokojny" ≥ 40, "niespokojny" ≥ 20, "na_krawedzi" > 0, "zalamany" = 0.
func sanity_band(npc_id: StringName) -> String:
	var value := sanity(npc_id)
	if value >= 40:
		return "spokojny"
	if value >= 20:
		return "niespokojny"
	if value > 0:
		return "na_krawedzi"
	return "zalamany"

func change_sanity(npc_id: StringName, delta: int) -> void:
	var data: NpcData = NPCS[npc_id]
	npcs[npc_id]["sanity"] = clampi(sanity(npc_id) + delta, 0, data.max_sanity)
	npc_changed.emit(npc_id)

func npc_health(npc_id: StringName) -> int:
	return int(npcs[npc_id]["health"])

func change_npc_health(npc_id: StringName, delta: int) -> void:
	var data: NpcData = NPCS[npc_id]
	npcs[npc_id]["health"] = clampi(npc_health(npc_id) + delta, 0, data.max_health)
	npc_changed.emit(npc_id)

func has_fever(npc_id: StringName) -> bool:
	return has_flag("fever_%s" % npc_id)

func rep(npc_id: StringName) -> int:
	return int(npcs[npc_id]["reputation"])

func change_rep(npc_id: StringName, delta: int) -> void:
	npcs[npc_id]["reputation"] = clampi(rep(npc_id) + delta, -100, 100)
	npc_changed.emit(npc_id)

func npc_status(npc_id: StringName) -> String:
	return String(npcs[npc_id]["status"])

func set_npc_status(npc_id: StringName, status: String) -> void:
	npcs[npc_id]["status"] = status
	npc_changed.emit(npc_id)

## Where the NPC is in the camp right now, e.g. "ognisko", "proch", "lada" ("" = away).
func npc_place(npc_id: StringName) -> String:
	return String(places.get(npc_id, ""))

## "teren" = met out in the tunnels (FieldSchedule), not in the camp.
func is_in_camp(npc_id: StringName) -> bool:
	var place := npc_place(npc_id)
	return place != "" and place != "teren"

#endregion

#region Modal screens

func push_modal() -> void:
	_modal_count += 1
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func pop_modal() -> void:
	_modal_count = max(0, _modal_count - 1)
	# During shutdown the tree may already be gone.
	if _modal_count == 0 and is_inside_tree() and not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func is_modal() -> bool:
	return _modal_count > 0

#endregion

#region Save / load

func save_state() -> Dictionary:
	return {
		"day": day,
		"hour": hour,
		"flags": flags.duplicate(true),
		"items": items.duplicate(true),
		"notes": notes.map(func(n): return String(n)),
		"quests": quests.duplicate(true),
		"npcs": npcs.duplicate(true),
		"player": {"health": player_health, "sanity": player_sanity, "fever": player_fever},
		"expedition": expedition.duplicate(true),
	}

## Saves from older versions lack the hero and the expedition: they start healthy, in the camp.
func load_state(data: Dictionary) -> void:
	reset()
	day = int(data.get("day", 1))
	hour = float(data.get("hour", DAY_START_HOUR))
	flags = data.get("flags", {})
	items = {}
	for key in data.get("items", {}):
		items[key] = int(data["items"][key])
	items["amulet"] = 1
	notes = []
	for note_id in data.get("notes", []):
		notes.append(StringName(note_id))
	quests = {}
	var saved_quests: Dictionary = data.get("quests", {})
	for key in saved_quests:
		quests[StringName(key)] = saved_quests[key]
	var saved_npcs: Dictionary = data.get("npcs", {})
	for key in saved_npcs:
		if npcs.has(StringName(key)):
			npcs[StringName(key)] = saved_npcs[key]
	var hero: Dictionary = data.get("player", {})
	player_health = int(hero.get("health", PLAYER_MAX))
	player_sanity = int(hero.get("sanity", PLAYER_START_SANITY))
	player_fever = bool(hero.get("fever", false))
	expedition = data.get("expedition", {})
	if not expedition.is_empty():
		# JSON turns numbers into floats and loses nothing else we need.
		expedition["places"] = Array(expedition.get("places", []))
		expedition["events"] = Array(expedition.get("events", []))
		expedition["items"] = Dictionary(expedition.get("items", {}))
	state_replaced.emit()

#endregion
