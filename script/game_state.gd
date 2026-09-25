extends Node

## Autoload "GameState": everything that changes during a playthrough.
## Day and hour, story flags, items, found notes, quests and NPC state.
## Dialogue files use it through `using GameState`.

signal time_advanced(hours: float, reason: String)
signal day_started(day: int)
## Emitted after reset() or load_state(): listeners re-read everything.
signal state_replaced
signal flags_changed
signal note_added(note: NoteData)
signal quest_updated(quest: QuestData, entry_text: String)
signal item_changed(item_id: String, count: int)
signal npc_changed(npc_id: StringName)
## For short on-screen messages (HUD toast).
signal message(text: String)
## A dialogue asks the world to do something after it closes ("sleep", "blast"…).
signal action_requested(action: String)

const DAY_START_HOUR := 6.0
const DAY_LENGTH_HOURS := 16.0
## The demo ends on the morning of this day.
const LAST_DAY := 3

const NPCS: Dictionary = {
	&"miroslaw": preload("res://data/npc/miroslaw.tres"),
	&"bolko": preload("res://data/npc/bolko.tres"),
	&"racibor": preload("res://data/npc/racibor.tres"),
	&"tekla": preload("res://data/npc/tekla.tres"),
	&"dobrawa": preload("res://data/npc/dobrawa.tres"),
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
}
const QUESTS: Dictionary = {
	&"slady": preload("res://data/quests/slady.tres"),
	&"lonty": preload("res://data/quests/lonty.tres"),
	&"zloza": preload("res://data/quests/zloza.tres"),
	&"towar": preload("res://data/quests/towar.tres"),
	&"sciana": preload("res://data/quests/sciana.tres"),
}
const ITEM_NAMES: Dictionary = {
	"lonty": "Suche lonty",
	"lina": "Lina",
	"kwit": "Kwit od Racibora",
	"tobolek": "Tobołek Tekli",
	"krysztal": "Kryształ z kaplicy",
}
## Blue iron veins the player can mark for Racibor (flag "vein_<id>").
const VEINS: Array[String] = ["rzapie", "upadowa", "kaplica"]

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
	for id in NPCS:
		var data: NpcData = NPCS[id]
		npcs[id] = {"sanity": data.start_sanity, "health": data.max_health, "reputation": data.start_reputation, "status": "camp"}
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
	var left := maxf(hours_left(), 0.0)
	return "%d h" % int(floor(left)) if is_equal_approx(left, floor(left)) else "%.1f h" % left

## Called from dialogue: the world performs the action once the dialogue closes.
func request(action: String) -> void:
	action_requested.emit(action)

func clock_text() -> String:
	var h := int(hour) % 24
	var m := int(round((hour - floor(hour)) * 60.0)) % 60
	return "Dzień %d · %02d:%02d" % [day, h, m]

## "rano" (breakfast, before 8), "dzien" (work, 8–18) or "wieczor" (supper and after).
func part_of_day() -> String:
	if hour < 8.0:
		return "rano"
	if hour < 18.0:
		return "dzien"
	return "wieczor"

#endregion

#region Flags and items

func set_flag(flag_name: String, value: Variant = true) -> void:
	flags[flag_name] = value
	flags_changed.emit()

func clear_flag(flag_name: String) -> void:
	flags.erase(flag_name)
	flags_changed.emit()

func has_flag(flag_name: String) -> bool:
	return bool(flags.get(flag_name, false))

func get_flag(flag_name: String, default: Variant = null) -> Variant:
	return flags.get(flag_name, default)

func give_item(item_id: String, count: int = 1) -> void:
	items[item_id] = int(items.get(item_id, 0)) + count
	item_changed.emit(item_id, items[item_id])
	message.emit("Zdobyto: %s" % ITEM_NAMES.get(item_id, item_id))

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

## How many blue iron veins the player has marked (Racibor's quest).
func veins_mapped() -> int:
	var count := 0
	for vein in VEINS:
		if has_flag("vein_" + vein):
			count += 1
	return count

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

func is_in_camp(npc_id: StringName) -> bool:
	return npc_place(npc_id) != ""

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
	}

func load_state(data: Dictionary) -> void:
	reset()
	day = int(data.get("day", 1))
	hour = float(data.get("hour", DAY_START_HOUR))
	flags = data.get("flags", {})
	items = {}
	for key in data.get("items", {}):
		items[key] = int(data["items"][key])
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
	state_replaced.emit()

#endregion
