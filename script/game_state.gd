extends Node

## Autoload "GameState": everything that changes during a playthrough.
## Day and hour, story flags, items, found notes, quests, NPC state, the hero's health and
## sanity, and the current expedition. Dialogue files use it through `using GameState`.

signal time_advanced(hours: float, reason: String)
## The clock moved without a toast or a log entry yet (a conversation charging per option).
signal clock_changed
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
## Health dropped to zero (spec 03_mechaniki/zdrowie_i_poczytalnosc.md, ZDR-2: death needs earlier wounds).
signal player_died(reason: String)
## Sanity dropped to zero: the hero panics and loses the rest of the day.
signal player_broke(reason: String)
## For short on-screen messages (HUD toast).
signal message(text: String)
## A dialogue asks the world to do something after it closes ("sleep", "blast"…).
signal action_requested(action: String)

const DAY_START_HOUR := 6.0
const DAY_LENGTH_HOURS := 16.0
## The week ends on the morning of this day: Racibor counts the veins (spec 03_mechaniki/czas.md CZAS-6, zyly_i_norma.md ZYL-6).
const LAST_DAY := 8
## Veins the Kniaź wants marked by the end of QUOTA_DAY (MECHANICS §13 pkt 2).
const QUOTA := 12
const QUOTA_DAY := 7

const PLAYER_MAX := 100
const PLAYER_START_SANITY := 80
## task_12: the hero's fatigue, 0-100. Hours in the tunnels (walking, scouting, work there) tire
## him more than hours in the camp. At 100 every walk to a place takes twice as long; the way
## back to the camp never does (decision-task-12). Sleep and the evening fire take some off.
const FATIGUE_MAX := 100.0
const FATIGUE_TUNNEL_PER_HOUR := 8.0
const FATIGUE_CAMP_PER_HOUR := 2.0
const FATIGUE_SLEEP := 60.0
const FATIGUE_FIRE := 15.0

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
	&"hrapek": preload("res://data/npc/hrapek.tres"),
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
	&"czternasty": preload("res://data/quests/czternasty.tres"),
	&"ryba": preload("res://data/quests/ryba.tres"),
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
	&"lampa": preload("res://data/items/lampa.tres"),
	&"ryba": preload("res://data/items/ryba.tres"),
	&"pierscien": preload("res://data/items/pierscien.tres"),
}
## NPCs whose sanity never moves (Hrapek: "always the same", card 02_postacie/hrapek.md).
const FIXED_SANITY: Array[StringName] = [&"hrapek"]
## task_10: on day 1 only Mirosław, Bolko, Tekla and Racibor are in the camp. These five are on
## a shift in the rooms of the first level (depth 1) and are met there, at most two to a room;
## from the morning of day 2 they follow their usual schedule (decision-task-10: 1A, 2a, 3a, 4a).
const FIRST_MEET: Array[StringName] = [&"wszebor", &"nasir", &"hagiwara", &"sobek", &"anzelm"]
const FIRST_ROOMS: Array[StringName] = [&"east", &"rzapie", &"west"]
const FIRST_ROOM_CAPACITY := 2
## task_14 (NPC-18): people who are not part of the week until a flag says so (the Exitium
## mages: the meeting; Sabina: once she has moved into the camp). Until then nothing that
## happens at night, the tremor included, touches them.
const ARRIVAL_FLAG := {&"sabina": "sabina_joined", &"ottokar": "drudzy_met", &"hieronim": "drudzy_met", &"welf": "drudzy_met"}
## task_37 (spec 04_tresc/otwarcie.md, OTW-1…OTW-3): a new game is the three-day opening (flag
## "opening"); a save without the flag is the full week. In the opening only the four camp people
## take part; these wait for later chapters (not in the camp, on no shift, nothing happens to them
## at night), and the Exitium mages are seen only in the closing scene. The map has three places.
const OPENING_DEFERRED: Array[StringName] = [&"wszebor", &"nasir", &"hagiwara", &"sobek", &"anzelm", &"dobrawa", &"hrapek", &"sabina", &"ottokar", &"hieronim", &"welf"]
const OPENING_PLACES: Array[StringName] = [&"east", &"west", &"upadowa"]
## The opening ends on the evening of this day (OTW-9, 07_balans.md "Otwarcie").
const OPENING_LAST_DAY := 3
const OPENING_FINALE_HOUR := 18.0
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
## What the time went on, per day (the notebook's "Czas" tab): "day" → [{"at": hour, "min": minutes, "why": reason}].
## Keys are strings so the dictionary survives JSON as it is.
var time_log: Dictionary = {}
## task_11 / factcheck 10: responses already picked, "<npc>|<text>" -> true. Picking one again
## costs no talk time.
var asked: Dictionary = {}
## task_12: see FATIGUE_*.
var player_fatigue: float = 0.0
## True while the StoryDirector moves the hero between places: those hours are tunnel hours
## even though the location flag is not set yet (leaving the camp) or already cleared (back).
var travelling := false
## task_14 (ZAP-12), for the run report: one entry per dawn (day 1 at reset(), then
## start_next_day()): {"day", "veins", "hero": {health, sanity, fever, fatigue},
## "npcs": {id: {sanity, health, rep, status, fever, arrived}}, "flags_new": [names set since the
## last dawn]}. Saved; a save from before version 6 has none ("brak danych" in the report).
var dawn_log: Array = []
## task_14 (ZAP-12): every vein as it was marked, {"id", "day", "at", "n"} (+ "via" when someone
## else marked it for the hero); "n" counts the veins on the map including this one. Saved like
## the dawn log.
var vein_log: Array = []

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
	player_fatigue = 0.0
	travelling = false
	expedition = {}
	time_log = {}
	asked = {}
	dawn_log = []
	vein_log = []
	for id in NPCS:
		var data: NpcData = NPCS[id]
		npcs[id] = {"sanity": data.start_sanity, "health": data.max_health, "reputation": data.start_reputation, "status": "camp"}
	# The hero never takes off his grandfather's amulet.
	items["amulet"] = 1
	_modal_count = 0
	start_quest("slady")
	roll_first_rooms()
	record_dawn()
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
	log_time(hour, hours, reason)
	hour += hours
	_tire(hours)
	time_advanced.emit(hours, reason)

## Moves the clock during a conversation (5 minutes per option): the VN clock follows, the toast
## and the log entry come once, from commit_time(), when the conversation closes.
func add_quiet_time(hours: float) -> void:
	hour += hours
	_tire(hours)
	clock_changed.emit()

## Reports time already added with add_quiet_time() (a whole conversation) as one entry.
func commit_time(hours: float, reason: String, from_hour: float) -> void:
	if hours <= 0.0:
		return
	log_time(from_hour, hours, reason)
	time_advanced.emit(hours, reason)

## One line in the day's time log ("07:00 · Rozmowa z Bolkiem · 15 min").
func log_time(at_hour: float, hours: float, reason: String) -> void:
	var key := str(day)
	if not time_log.has(key):
		time_log[key] = []
	(time_log[key] as Array).append({"at": at_hour, "min": int(round(hours * 60.0)), "why": reason if reason != "" else "Coś zajęło czas"})

## Minutes the day's log adds up to.
func logged_minutes(on_day: int) -> int:
	var total := 0
	for entry in time_log.get(str(on_day), []):
		total += int(entry["min"])
	return total

func start_next_day() -> void:
	day += 1
	hour = DAY_START_HOUR
	# A night's sleep takes off a good part of the fatigue, not all of it (decision-task-12: 2a).
	change_fatigue(-FATIGUE_SLEEP)
	record_dawn()
	day_started.emit(day)

## task_14 (ZAP-12): writes this dawn into dawn_log (day 1 from reset(), later days from
## start_next_day(), after the night has been resolved). An entry for the same day is replaced.
func record_dawn() -> void:
	var known := {}
	for earlier in dawn_log:
		if int(earlier.get("day", 0)) < day:
			for flag_name in earlier.get("flags_new", []) + earlier.get("flags_all", []):
				known[String(flag_name)] = true
	# With no earlier entry on a later day (a save from before version 6) "new since the last
	# dawn" is unknown: this entry says so ("partial") and keeps every flag name instead, as the
	# base for the next one.
	var first_known := dawn_log.is_empty() and day > 1
	var fresh: Array = []
	for flag_name in flags.keys():
		if first_known or not known.has(String(flag_name)):
			fresh.append(String(flag_name))
	fresh.sort()
	var people := {}
	for id in NPCS:
		var state: Dictionary = npcs.get(id, {})
		if state.is_empty():
			continue
		people[String(id)] = {
			"sanity": int(state["sanity"]), "health": int(state["health"]), "rep": int(state["reputation"]),
			"status": String(state["status"]), "fever": has_fever(id), "arrived": has_arrived(id),
		}
	var entry := {
		"day": day,
		"veins": veins_mapped(),
		"hero": {"health": player_health, "sanity": player_sanity, "fever": player_fever, "fatigue": player_fatigue},
		"npcs": people,
		"flags_new": [] if first_known else fresh,
	}
	if first_known:
		entry["partial"] = true
		entry["flags_all"] = fresh
	for i in dawn_log.size():
		if int(dawn_log[i].get("day", 0)) == day:
			dawn_log[i] = entry
			return
	dawn_log.append(entry)

func hours_left_text() -> String:
	return hours_text(maxf(hours_left(), 0.0))

## "5 min", "1 h 20 min", "2 h" (the time log and the toasts).
static func duration_text(minutes: int) -> String:
	if minutes < 60:
		return "%d min" % minutes
	if minutes % 60 == 0:
		return "%d h" % (minutes / 60)
	return "%d h %d min" % [minutes / 60, minutes % 60]

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
		if has_flag(flag_name):
			_log_vein(flag_name.trim_prefix("vein_"))
		message.emit("Żyła na mapie. %s." % quota_text())
		_check_quota()

## task_14 (ZAP-12): a vein marked now goes into vein_log (the day and the hour it was done at;
## interactables advance the clock before they set the flag, so this is the finishing time).
## "n" is how many veins are on the map with this one (its flag is already set), so the quota
## time is the entry with n = QUOTA even when the log starts late: a save from before version 6
## that already had veins has a log of only the veins marked after the load.
func _log_vein(vein_id: String, via: String = "") -> void:
	for logged in vein_log:
		if String(logged.get("id", "")) == vein_id:
			return
	var entry := {"id": vein_id, "day": day, "at": hour, "n": veins_mapped()}
	if via != "":
		entry["via"] = via
	vein_log.append(entry)

func clear_flag(flag_name: String) -> void:
	flags.erase(flag_name)
	flags_changed.emit()

## True when the flag is set. Flags may carry a payload (a day number, a place id, a list:
## "encounter_place", "nasir_at_pumps"…) — any non-empty payload counts as set.
func has_flag(flag_name: String) -> bool:
	var value: Variant = flags.get(flag_name, false)
	if value is bool:
		return value
	if value is String or value is StringName:
		return String(value) != ""
	if value is Array:
		return not value.is_empty()
	if value is int or value is float:
		return value != 0
	return value != null

func get_flag(flag_name: String, default: Variant = null) -> Variant:
	return flags.get(flag_name, default)

## For once-a-day things in dialogues: `if not done_today("anzelm_care")` … `$> mark_today("anzelm_care")`.
func done_today(flag_name: String) -> bool:
	return int(flags.get(flag_name, 0)) == day

func mark_today(flag_name: String) -> void:
	set_flag(flag_name, day)

## task_37: a flag holding a day (`mark`-style payload) was set on an earlier day than today. For
## dialogues ("the next morning"), which cannot call int().
func earlier_day(flag_name: String) -> bool:
	return has_flag(flag_name) and int(get_flag(flag_name, 0)) < day

## Counts in a flag and returns the new count (Hrapek's questions in a row: `if bump_flag("hrapek_q") >= 3`).
func bump_flag(flag_name: String) -> int:
	var count := int(flags.get(flag_name, 0)) + 1
	flags[flag_name] = count
	return count

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
					_log_vein(vein, "ottokar")
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
	return health_band_of(player_health)

## The same bands for any health value (an NPC's, or a number kept in the run report's logs).
static func health_band_of(value: int) -> String:
	if value >= 75:
		return "zdrowy"
	if value >= 45:
		return "poobijany"
	if value >= 20:
		return "ranny"
	if value > 0:
		return "ciezko_ranny"
	return "martwy"

## "spokojny" ≥ 60, "niespokojny" ≥ 35, "na_krawedzi" > 0, "zalamany" = 0.
func mind_band() -> String:
	return mind_band_of(player_sanity)

static func mind_band_of(value: int) -> String:
	if value >= 60:
		return "spokojny"
	if value >= 35:
		return "niespokojny"
	if value > 0:
		return "na_krawedzi"
	return "zalamany"

func health_text() -> String:
	return {"zdrowy": "cały i zdrowy", "poobijany": "poobijany", "ranny": "ranny", "ciezko_ranny": "ciężko ranny", "martwy": "martwy"}[health_band()]

func mind_text() -> String:
	return {"spokojny": "spokojny", "niespokojny": "niespokojny", "na_krawedzi": "na krawędzi", "zalamany": "załamany"}[mind_band()]

#region Fatigue (task_12)

## Hours passed: the tunnels tire more than the camp.
func _tire(hours: float) -> void:
	var rate := FATIGUE_TUNNEL_PER_HOUR if (travelling or is_away()) else FATIGUE_CAMP_PER_HOUR
	change_fatigue(hours * rate)

func change_fatigue(delta: float) -> void:
	var before := fatigue_band()
	player_fatigue = clampf(player_fatigue + delta, 0.0, FATIGUE_MAX)
	if fatigue_band() != before:
		player_changed.emit()

## The evening by the fire (dialogue/ognisko.dialogue) takes some fatigue off.
func rest_by_fire() -> void:
	change_fatigue(-FATIGUE_FIRE)

## True at 100%: every walk to a place takes twice as long.
func is_exhausted() -> bool:
	return player_fatigue >= FATIGUE_MAX - 0.001

## "wypoczety" (< 75), "zmeczony" (75+), "ledwo_idzie" (90+), "wyczerpany" (100).
func fatigue_band() -> String:
	return fatigue_band_of(player_fatigue)

static func fatigue_band_of(value: float) -> String:
	if value >= FATIGUE_MAX - 0.001:
		return "wyczerpany"
	if value >= 90.0:
		return "ledwo_idzie"
	if value >= 75.0:
		return "zmeczony"
	return "wypoczety"

## Short word for the HUD corner ("" while rested).
func fatigue_text() -> String:
	return {"wypoczety": "", "zmeczony": "zmęczony", "ledwo_idzie": "ledwo idziesz", "wyczerpany": "padasz z nóg"}[fatigue_band()]

#endregion

## task_11 / factcheck 10: has this response been picked before with this person?
func was_asked(npc_id: StringName, text: String) -> bool:
	return asked.has("%s|%s" % [npc_id, text])

func mark_asked(npc_id: StringName, text: String) -> void:
	asked["%s|%s" % [npc_id, text]] = true

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
	var band_before := mind_band()
	player_sanity = clampi(player_sanity + delta, 0, PLAYER_MAX)
	player_changed.emit()
	if delta < 0 and reason != "":
		# The state of mind only when it changed: "Czujesz się: spokojny." after "To miejsce
		# cię przygniata" contradicts the line itself.
		if mind_band() != band_before:
			message.emit("%s. Czujesz się: %s." % [reason, mind_text()])
		else:
			message.emit("%s." % reason)
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
		# task_12: hours walked since leaving the camp; the way back costs half of it.
		"outbound_hours": 0.0,
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

## The "Czternaście kresek" observations (quest `czternasty`). At four or more, someone
## below answers with a gift in the night (StoryDirector._resolve_night).
const FOURTEENTH_CLUES: Array[String] = [
	"saw_marks_rzapie", "saw_marks_pillar", "opened_grabiec_cache",
	"saw_bread", "saw_lamp", "saw_niches", "saw_medal",
]

func fourteenth_clues() -> int:
	var count := 0
	for flag in FOURTEENTH_CLUES:
		if has_flag(flag):
			count += 1
	return count

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
	return sanity_band_of(sanity(npc_id))

static func sanity_band_of(value: int) -> String:
	if value >= 40:
		return "spokojny"
	if value >= 20:
		return "niespokojny"
	if value > 0:
		return "na_krawedzi"
	return "zalamany"

## How an NPC feels about the hero (the notebook's "Do ciebie" line): "ufa" ≥ 20, "lubi" ≥ 5,
## "nie_ufa" < 0, otherwise "dystans".
static func trust_band_of(value: int) -> String:
	if value >= 20:
		return "ufa"
	if value >= 5:
		return "lubi"
	if value < 0:
		return "nie_ufa"
	return "dystans"

func change_sanity(npc_id: StringName, delta: int) -> void:
	if npc_id in FIXED_SANITY:
		return
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

## Where each of the FIRST_MEET five works on day 1: a random room of the first level, at most
## FIRST_ROOM_CAPACITY to a room. Kept in the flags "first_room_<id>" (so saves keep it).
## Also Zawalony chodnik: whoever is there waits until the rubble is blown, or turns up in the
## camp on day 2.
func roll_first_rooms(rng: RandomNumberGenerator = null) -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	var free: Array[StringName] = []
	for room in FIRST_ROOMS:
		for i in FIRST_ROOM_CAPACITY:
			free.append(room)
	for id in FIRST_MEET:
		var room: StringName = free.pop_at(rng.randi_range(0, free.size() - 1))
		flags["first_room_%s" % id] = String(room)

## The room where this one of the five is on day 1 (&"" for everyone else). A save from before
## task_10 has no rooms yet: they are rolled the first time someone asks.
func first_room(npc_id: StringName) -> StringName:
	if not npc_id in FIRST_MEET:
		return &""
	if not flags.has("first_room_%s" % npc_id):
		roll_first_rooms()
	return StringName(String(flags["first_room_%s" % npc_id]))

## 1 or 2: the spot this one takes in the room ("EastSpot1"), in FIRST_MEET order.
func first_room_slot(npc_id: StringName) -> int:
	var room := first_room(npc_id)
	var slot := 0
	for id in FIRST_MEET:
		if first_room(id) == room:
			slot += 1
		if id == npc_id:
			break
	return slot

## Out on the day-1 shift: not in the camp, not even in the evening. The opening has no shift.
func away_first_day(npc_id: StringName) -> bool:
	return day == 1 and npc_id in FIRST_MEET and not opening()

## task_37 (OTW-1): this run is the three-day opening, not the full week.
func opening() -> bool:
	return has_flag("opening")

## task_37 (OTW-2): this person waits for a later chapter and takes no part in the opening.
func deferred(npc_id: StringName) -> bool:
	return opening() and npc_id in OPENING_DEFERRED

## For dialogues and scenes: this person is in the camp today (the campfire on day 1 has only
## the four who stayed).
func in_camp_today(npc_id: StringName) -> bool:
	return npc_status(npc_id) == "camp" and not away_first_day(npc_id) and not deferred(npc_id)

## task_14 (NPC-18): has this person reached the story yet? Sabina counts from the moment she
## moves into the camp (`sabina_joined`), Ottokar, Hieronim and Welf from the first meeting with
## the Exitium expedition (`drudzy_met`); everyone else is part of the week from the start. The
## nightly sanity losses and the tremor skip anyone who has not arrived. Derived from the flags,
## so nothing is saved and nobody's status changes.
## task_37 (OTW-2): in the opening the deferred people never arrive.
func has_arrived(npc_id: StringName) -> bool:
	if deferred(npc_id):
		return false
	return not ARRIVAL_FLAG.has(npc_id) or has_flag(String(ARRIVAL_FLAG[npc_id]))

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
		"player": {"health": player_health, "sanity": player_sanity, "fever": player_fever, "fatigue": player_fatigue},
		"expedition": expedition.duplicate(true),
		"time_log": time_log.duplicate(true),
		"asked": asked.duplicate(),
		"dawn_log": dawn_log.duplicate(true),
		"vein_log": vein_log.duplicate(true),
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
	# Saves before task_11/12: nothing asked yet, the hero rested.
	player_fatigue = float(hero.get("fatigue", 0.0))
	asked = Dictionary(data.get("asked", {})).duplicate()
	# Saves before task_09 have no time log: the notebook starts it from now on.
	time_log = Dictionary(data.get("time_log", {})).duplicate(true)
	# Saves before version 6 (task_14) have no report logs: empty, the report says "brak danych".
	# reset() above wrote a day-1 entry that does not belong to this run, so replace it either way.
	var saved_dawns: Variant = data.get("dawn_log", [])
	dawn_log = (saved_dawns as Array).duplicate(true) if saved_dawns is Array else []
	var saved_veins: Variant = data.get("vein_log", [])
	vein_log = (saved_veins as Array).duplicate(true) if saved_veins is Array else []
	expedition = data.get("expedition", {})
	if not expedition.is_empty():
		# JSON turns numbers into floats and loses nothing else we need.
		expedition["places"] = Array(expedition.get("places", []))
		expedition["events"] = Array(expedition.get("events", []))
		expedition["items"] = Dictionary(expedition.get("items", {}))
	state_replaced.emit()

#endregion
