extends RefCounted
class_name RunReport

## The run report (task_14: ZAP-11, ZAP-12, CZAS-16, UI-7). Two local files, `przebieg-<date>_<time>.md`
## (to read) and `.json` (to count), written at the end of the week (both endings) and on demand from
## the pause menu. It reads only GameState: the time log (sorted into categories), the dawn log
## (the hero and every character at each dawn), the vein log and the final flags. Nothing is sent
## anywhere. Costs and numbers are the game's own; this class only looks.

const REPORT_VERSION := 1
## Under the user data folder (Windows: %APPDATA%\Godot\app_userdata\Everhorror\raporty).
const REPORT_DIR := "user://raporty"

const ENDING_WEEK := "koniec_tygodnia"
const ENDING_ALONE := "zostales_sam"
const ENDING_IN_PROGRESS := "w_trakcie"
const ENDING_TITLES := {ENDING_WEEK: "Koniec tygodnia", ENDING_ALONE: "Zostałeś sam", ENDING_IN_PROGRESS: "w trakcie"}

## CZAS-16: every line of the time log belongs to one of these.
const CATEGORIES: Array[String] = ["rozmowy", "drogi", "żyły", "pomoc", "obóz", "eksploracja", "przedmioty", "sen", "inne"]
const OTHER := "inne"
## Labels as the game writes them to the time log (dialogues, interactables, StoryDirector).
const LABEL_CATEGORY := {
	"Znaczenie żyły": "żyły",
	"Odkuwanie nacieku": "żyły",
	"Mirosław wysadza zawał": "pomoc",
	"Praca przy pompach": "pomoc",
	"Opatrywanie ran": "pomoc",
	"Ottokar przerysowuje mapy": "pomoc",
	"Wieczór przy ogniu": "obóz",
	"Kości z Sobkiem": "obóz",
	"Przy ogniu z Mirosławem": "obóz",
	"Z Mirosławem w kącie": "obóz",
	"Obracanie kręgów": "eksploracja",
	"Rozbijanie skrytki": "eksploracja",
	"Powrót do obozu": "drogi",
	"Sen": "sen",
}
## Labels with a name after them ("Rozmowa z Teklą", "Wyprawa: Stara sztolnia").
const PREFIX_CATEGORY := {
	"Rozmowa z ": "rozmowy",
	"Wyprawa: ": "drogi",
	"Droga: ": "drogi",
	"Ryby w stawie z ": "pomoc",
}
## The fallback label of GameState.log_time() for an action with no reason: knowingly "inne".
const FALLBACK_LABEL := "Coś zajęło czas"

const MIND_WORDS := {"spokojny": "spokojny", "niespokojny": "niespokojny", "na_krawedzi": "na krawędzi", "zalamany": "załamany"}
const HEALTH_WORDS := {"zdrowy": "zdrowy", "poobijany": "poobijany", "ranny": "ranny", "ciezko_ranny": "ciężko ranny", "martwy": "martwy"}
const TRUST_WORDS := {"ufa": "ufa", "lubi": "lubi", "dystans": "dystans", "nie_ufa": "nie ufa"}
const FATIGUE_WORDS := {"wypoczety": "wypoczęty", "zmeczony": "zmęczony", "ledwo_idzie": "ledwo idzie", "wyczerpany": "wyczerpany"}
const NO_DATA := "brak danych"
const DASH := "—"

#region Categories (CZAS-16)

## The category of one time-log label; "inne" when it is not recognised.
static func categorize(why: String) -> String:
	if LABEL_CATEGORY.has(why):
		return LABEL_CATEGORY[why]
	for prefix in PREFIX_CATEGORY:
		if why.begins_with(prefix):
			return PREFIX_CATEGORY[prefix]
	# Using an item (bandages, a candle…) is logged under the item's name.
	for id in GameState.ITEMS:
		if (GameState.ITEMS[id] as ItemData).display_name == why:
			return "przedmioty"
	return OTHER

#endregion

#region Collecting the data

## Everything the report says, as plain data (it goes to the .json as it is). `ending` is one of
## the ENDING_* ids.
static func collect(ending: String = ENDING_IN_PROGRESS) -> Dictionary:
	var current_day: int = GameState.day
	var days: Array = []
	for d in range(1, current_day + 1):
		days.append(_day_data(d))
	var people: Array = []
	for id in GameState.NPCS:
		var data: NpcData = GameState.NPCS[id]
		people.append({"id": String(id), "name": data.display_name, "met": is_met(id), "fixed_sanity": id in GameState.FIXED_SANITY})
	return {
		"report_version": REPORT_VERSION,
		"build": {"version": BuildInfo.version(), "spec": BuildInfo.SPEC_SHA},
		"generated_at": Time.get_datetime_string_from_system(),
		"ending": {"id": ending, "title": ENDING_TITLES.get(ending, ending)},
		"now": {"day": current_day, "hour": GameState.hour, "time": GameState.time_text(GameState.hour)},
		"quota": _quota_data(),
		"days": days,
		"people": people,
		"veins": _vein_rows(),
		"choices": _choices(),
	}

## The notebook's rule for "Ludzie": met in a conversation, or one of the Exitium expedition once
## it has been met.
static func is_met(npc_id: StringName) -> bool:
	if GameState.has_flag("met_%s" % npc_id):
		return true
	return npc_id in FieldSchedule.DRUDZY and GameState.has_flag("drudzy_met")

static func _dawn_for(day: int) -> Dictionary:
	for entry in GameState.dawn_log:
		if int(entry.get("day", 0)) == day:
			return entry
	return {}

static func _day_data(day: int) -> Dictionary:
	var result := {"day": day, "time": _time_data(day), "dawn": null}
	var dawn := _dawn_for(day)
	if dawn.is_empty():
		return result
	var block := {
		"veins": int(dawn.get("veins", 0)),
		"hero": _hero_data(dawn.get("hero", {})),
		"people": _people_data(dawn.get("npcs", {})),
		"flags_new": dawn.get("flags_new", []),
	}
	if bool(dawn.get("partial", false)):
		block["partial"] = true
	result["dawn"] = block
	return result

## Minutes per category for one day, the total, and the time left unused when the hero went to
## sleep (null while the day is still going, or when the log has nothing for it).
static func _time_data(day: int) -> Dictionary:
	var entries: Array = GameState.time_log.get(str(day), [])
	var minutes := {}
	for category in CATEGORIES:
		minutes[category] = 0
	var total := 0
	var slept_at := -1.0
	for entry in entries:
		var why := String(entry.get("why", ""))
		var spent := int(entry.get("min", 0))
		var category := categorize(why)
		minutes[category] = int(minutes[category]) + spent
		total += spent
		if why == "Sen":
			slept_at = float(entry.get("at", -1.0))
	var unused: Variant = null
	if slept_at >= 0.0:
		var night_at: float = GameState.DAY_START_HOUR + GameState.DAY_LENGTH_HOURS
		unused = maxi(0, int(round((night_at - slept_at) * 60.0)))
	return {"available": not entries.is_empty(), "minutes": minutes, "total": total, "entries": entries.size(), "unused_before_sleep_min": unused}

static func _hero_data(hero: Dictionary) -> Dictionary:
	var health := int(hero.get("health", 0))
	var sanity := int(hero.get("sanity", 0))
	var fatigue := float(hero.get("fatigue", 0.0))
	return {
		"health": health, "sanity": sanity, "fever": bool(hero.get("fever", false)), "fatigue": fatigue,
		"health_band": GameState.health_band_of(health), "mind_band": GameState.mind_band_of(sanity),
		"fatigue_band": GameState.fatigue_band_of(fatigue),
	}

## One character at one dawn: bands (as in the notebook) and the raw numbers. Someone who has
## not arrived yet (NPC-18) has no bands: the Markdown shows a dash.
static func _people_data(saved: Dictionary) -> Dictionary:
	var result := {}
	for id in GameState.NPCS:
		var key := String(id)
		if not saved.has(key):
			continue
		var state: Dictionary = saved[key]
		var sanity := int(state.get("sanity", 0))
		var health := int(state.get("health", 0))
		var rep := int(state.get("rep", 0))
		var arrived := bool(state.get("arrived", true))
		var entry := {
			"arrived": arrived, "status": String(state.get("status", "camp")), "fever": bool(state.get("fever", false)),
			"sanity": sanity, "health": health, "rep": rep,
			"mind_band": null, "health_band": null, "trust_band": null,
		}
		if arrived:
			entry["mind_band"] = "stala" if id in GameState.FIXED_SANITY else GameState.sanity_band_of(sanity)
			entry["health_band"] = GameState.health_band_of(health)
			entry["trust_band"] = GameState.trust_band_of(rep)
		result[key] = entry
	return result

static func _quota_data() -> Dictionary:
	var reached: Variant = null
	if GameState.vein_log.size() >= GameState.QUOTA:
		var logged: Dictionary = GameState.vein_log[GameState.QUOTA - 1]
		var at := float(logged.get("at", 0.0))
		reached = {"day": int(logged.get("day", 0)), "at": at, "time": GameState.time_text(at)}
	return {
		"required": GameState.QUOTA, "deadline_day": GameState.QUOTA_DAY, "veins": GameState.veins_mapped(),
		"met": GameState.quota_met(), "reached_at": reached,
		# True when the logs cannot tell when it was reached (a save from before version 6).
		"reached_unknown": GameState.quota_met() and reached == null,
	}

static func _vein_rows() -> Array:
	var rows: Array = []
	for logged in GameState.vein_log:
		var id := String(logged.get("id", ""))
		var at := float(logged.get("at", 0.0))
		var row := {"id": id, "place": _vein_place(id), "day": int(logged.get("day", 0)), "at": at, "time": GameState.time_text(at)}
		if logged.has("via"):
			row["via"] = String(logged["via"])
		rows.append(row)
	return rows

static func _vein_place(vein_id: String) -> String:
	for place_id in GameState.LOCATIONS:
		var data: LocationData = GameState.LOCATIONS[place_id]
		if vein_id in data.veins:
			return data.display_name
	return vein_id

#endregion

#region Key choices

## The week's decisions, read from the final flags and items: {id, label, value, text}.
static func _choices() -> Array:
	var rows: Array = []
	rows.append(_choice("krysztal", "Kryształ", _crystal()))
	rows.append(_choice("tekla", "Tekla", _tekla()))
	rows.append(_choice("welf", "Welf z Exitium", _welf()))
	rows.append(_choice("nasir", "Nasir", _nasir()))
	rows.append(_choice("miroslaw", "Mirosław", _miroslaw()))
	rows.append(_choice("dobrawa", "Dobrawa", _dobrawa()))
	rows.append(_choice("sabina", "Sabina z Exitium", _sabina()))
	rows.append(_choice("upadowa", "Upadowa", _upadowa()))
	rows.append(_choice("wiadomosc", "Wiadomość dziadka", _flag("deciphered", "odczytana", "nieodczytana")))
	rows.append(_choice("sciana", "Ściana w kaplicy", _flag("wall_open", "otwarta", "nierozwiązana")))
	rows.append(_choice("hrapek", "Hrapek", _hrapek()))
	rows.append(_choice("czternasty", "Czternasty", _fourteenth()))
	rows.append(_choice("wstrzas", "Wstrząs w piątą noc", _flag("tremor_seen", "był", "jeszcze nie było")))
	return rows

static func _choice(id: String, label: String, pair: Array) -> Dictionary:
	return {"id": id, "label": label, "value": pair[0], "text": pair[1]}

## [value, text] for a plain yes/no flag.
static func _flag(flag_name: String, yes_text: String, no_text: String) -> Array:
	if GameState.has_flag(flag_name):
		return ["tak", yes_text]
	return ["nie", no_text]

static func _crystal() -> Array:
	if GameState.has_flag("crystal_to_dobrawa"):
		return ["dobrawa", "u Dobrawy, w drodze do Initium"]
	if GameState.has_flag("crystal_to_racibor"):
		return ["racibor", "u Racibora, dla Kniazia"]
	if GameState.has_flag("crystal_to_ottokar"):
		return ["ottokar", "u Ottokara, w Exitium"]
	if GameState.has_item("krysztal"):
		return ["bohater", "zostaje u bohatera"]
	if GameState.has_flag("took_crystal"):
		return ["zabrany", "zabrany z kaplicy, nie ma go ani w ekwipunku, ani u nikogo"]
	return ["nieodnaleziony", "nieodnaleziony"]

static func _tekla() -> Array:
	if GameState.has_flag("tekla_reported"):
		return ["wydana", "wydana Raciborowi, pod strażą"]
	if GameState.quest_state(&"towar") == "done" or GameState.has_flag("tekla_owes"):
		return ["dlug", "ma u bohatera dług"]
	return ["bez_zmian", "bez zmian, liczy każdą świeczkę"]

static func _welf() -> Array:
	if not GameState.has_flag("welf_wounded"):
		return ["nie_ranny", "nie spotkany w potrzebie"]
	if GameState.has_flag("welf_helped"):
		return ["uratowany", "uratowany bandażami"]
	return ["przepadl", "przepadł w chodnikach"]

static func _nasir() -> Array:
	if GameState.has_flag("nasir_carried_up"):
		return ["wywieziony", "wywieziony na górę w gorączce"]
	if GameState.has_flag("nasir_fever_started"):
		if GameState.has_fever(&"nasir"):
			return ["chory", "gorączka trwa"]
		return ["wyleczony", "wyzdrowiał"]
	return ["zdrowy", "gorączka jeszcze nie zaczęła się"]

static func _miroslaw() -> Array:
	if GameState.has_flag("mir_dead"):
		return ["nie_zyje", "nie żyje, zabrał ze sobą zachodni chodnik"]
	var how := ""
	if GameState.has_flag("mir_comforted"):
		how = ", pocieszony po wybuchu"
	elif GameState.has_flag("mir_scolded"):
		how = ", skarcony po wybuchu"
	return ["zyje", "żyje (%s)%s" % [MIND_WORDS.get(GameState.sanity_band(&"miroslaw"), "?"), how]]

static func _dobrawa() -> Array:
	if GameState.has_flag("dobrawa_left"):
		if GameState.has_flag("dobrawa_went_down"):
			return ["zeszla", "zeszła sama w głąb"]
		return ["odeszla", "odeszła z kryształem"]
	return ["w_obozie", "w obozie"]

static func _sabina() -> Array:
	if not GameState.has_flag("sabina_joined"):
		return ["nie_dotarla", "nie dotarła do obozu"]
	var peace := ", pogodzona z Anzelmem" if GameState.has_flag("anzelm_sabina_peace") else ", bez zgody z Anzelmem"
	if GameState.npc_status(&"sabina") == "gone":
		return ["odeszla", "odeszła" + peace]
	return ["w_obozie", "w obozie" + peace]

static func _upadowa() -> Array:
	if not GameState.has_flag("plan_upadowa"):
		return ["nikt_nie_rusza", "nikt jej nie rusza"]
	if GameState.has_flag("racibor_doubts"):
		return ["racibor_sie_waha", "Racibor się waha, list dziadka zrobił swoje"]
	return ["otworzona", "Racibor każe ją otworzyć"]

static func _hrapek() -> Array:
	if not GameState.has_flag("met_hrapek"):
		return ["nie_spotkany", "nie spotkany"]
	var parts: Array[String] = []
	parts.append("zjadł rybę" if GameState.quest_state(&"ryba") == "done" else "ryby się nie doczekał")
	if GameState.has_flag("hrapek_found"):
		parts.append("ciało znalezione")
		if GameState.has_flag("hrapek_ring"):
			parts.append("pierścień u bohatera")
	elif GameState.has_flag("hrapek_dead"):
		parts.append("od dnia 6 nikt go nie widział")
	return ["spotkany", ", ".join(parts)]

static func _fourteenth() -> Array:
	if GameState.has_flag("fourteenth_gift"):
		return ["lampa", "ktoś odpowiedział lampą"]
	if GameState.quest_state(&"czternasty") == "":
		return ["nie_podjety", "zagadka niepodjęta"]
	return ["slady", "%d śladów, bez odpowiedzi" % GameState.fourteenth_clues()]

#endregion

#region Markdown

## The readable version: the build, the ending, time by category and day, the hero and the people
## at each dawn, the veins and the choices.
static func to_markdown(data: Dictionary) -> String:
	var lines: Array[String] = []
	var build: Dictionary = data.get("build", {})
	var ending: Dictionary = data.get("ending", {})
	var now: Dictionary = data.get("now", {})
	var quota: Dictionary = data.get("quota", {})
	lines.append("# Raport przebiegu: Everhorror %s · spec %s" % [build.get("version", "?"), build.get("spec", "?")])
	lines.append("")
	lines.append("- Zapisano: %s" % String(data.get("generated_at", "?")).replace("T", " "))
	lines.append("- Stan: dzień %d, %s · zakończenie: %s" % [int(now.get("day", 0)), now.get("time", "?"), ending.get("title", "?")])
	lines.append("- Żyły: %d z %d · %s" % [int(quota.get("veins", 0)), int(quota.get("required", 0)), _quota_sentence(quota)])
	lines.append("")
	var days: Array = data.get("days", [])
	lines.append("## Czas według kategorii (minuty)")
	lines.append("")
	lines.append_array(_time_table(days))
	lines.append("")
	lines.append("## Bohater o świcie")
	lines.append("")
	lines.append_array(_hero_table(days))
	lines.append("")
	lines.append("## Ludzie o świcie")
	lines.append("")
	lines.append("Kreska (%s) oznacza kogoś, kto jeszcze nie dotarł do obozu. Pokazani są tylko poznani; pasma jak w notesie." % DASH)
	lines.append("")
	var people: Array = data.get("people", [])
	lines.append("### Głowa")
	lines.append("")
	lines.append_array(_people_table(days, people, "mind_band", MIND_WORDS))
	lines.append("")
	lines.append("### Zdrowie")
	lines.append("")
	lines.append_array(_people_table(days, people, "health_band", HEALTH_WORDS))
	lines.append("")
	lines.append("### Stosunek do bohatera")
	lines.append("")
	lines.append_array(_people_table(days, people, "trust_band", TRUST_WORDS))
	var strangers: Array[String] = []
	for person in people:
		if not bool(person.get("met", false)):
			strangers.append(String(person.get("name", "?")))
	if not strangers.is_empty():
		lines.append("")
		lines.append("Jeszcze nie poznani: %s." % ", ".join(strangers))
	lines.append("")
	lines.append("## Żyły")
	lines.append("")
	lines.append_array(_vein_table(data.get("veins", [])))
	lines.append("")
	lines.append("## Kluczowe wybory")
	lines.append("")
	for choice in data.get("choices", []):
		lines.append("- %s: %s" % [choice.get("label", "?"), choice.get("text", "?")])
	lines.append("")
	lines.append("---")
	lines.append("Raport zapisała gra na tym komputerze (ZAP-11). Nic nie jest wysyłane przez sieć. Te same dane z surowymi liczbami leżą obok, w pliku .json.")
	return "\n".join(lines) + "\n"

static func _quota_sentence(quota: Dictionary) -> String:
	var reached: Variant = quota.get("reached_at")
	if reached is Dictionary:
		return "norma osiągnięta: dzień %d, %s" % [int(reached.get("day", 0)), reached.get("time", "?")]
	if bool(quota.get("reached_unknown", false)):
		return "norma osiągnięta, kiedy: %s" % NO_DATA
	return "norma jeszcze nie osiągnięta"

static func _table(headers: Array, rows: Array) -> Array[String]:
	var out: Array[String] = []
	out.append("| " + " | ".join(headers) + " |")
	out.append("|" + "---|".repeat(headers.size()))
	for row in rows:
		out.append("| " + " | ".join(row) + " |")
	return out

static func _time_table(days: Array) -> Array[String]:
	var headers: Array = ["Dzień"]
	headers.append_array(CATEGORIES)
	headers.append_array(["razem", "niewykorzystane przed snem"])
	var rows: Array = []
	for day in days:
		var time: Dictionary = day.get("time", {})
		var row: Array = [str(int(day.get("day", 0)))]
		if not bool(time.get("available", false)):
			# Day 8 is only the morning of the reckoning: no actions, so no row.
			if int(day.get("day", 0)) > GameState.QUOTA_DAY:
				continue
			# Nothing logged: no data for a finished day, nothing yet for the day in progress.
			var empty_text := "dzień trwa" if int(day.get("day", 0)) == _last_day(days) else NO_DATA
			row.append(empty_text)
			for i in headers.size() - 2:
				row.append(DASH)
			rows.append(row)
			continue
		var minutes: Dictionary = time.get("minutes", {})
		for category in CATEGORIES:
			row.append(str(int(minutes.get(category, 0))))
		row.append(str(int(time.get("total", 0))))
		var unused: Variant = time.get("unused_before_sleep_min")
		row.append(str(int(unused)) if unused != null else "dzień trwa")
		rows.append(row)
	return _table(headers, rows)

static func _last_day(days: Array) -> int:
	return int(days.back().get("day", 0)) if not days.is_empty() else 0

static func _hero_table(days: Array) -> Array[String]:
	var rows: Array = []
	for day in days:
		var dawn: Variant = day.get("dawn")
		var row: Array = [str(int(day.get("day", 0)))]
		if dawn == null:
			row.append(NO_DATA)
			for i in 4:
				row.append(DASH)
		else:
			var hero: Dictionary = dawn.get("hero", {})
			row.append(str(int(dawn.get("veins", 0))))
			row.append(HEALTH_WORDS.get(hero.get("health_band", ""), "?"))
			row.append(MIND_WORDS.get(hero.get("mind_band", ""), "?"))
			row.append("tak" if bool(hero.get("fever", false)) else "nie")
			row.append(FATIGUE_WORDS.get(hero.get("fatigue_band", ""), "?"))
		rows.append(row)
	return _table(["Dzień", "Żyły o świcie", "Zdrowie", "Głowa", "Gorączka", "Zmęczenie"], rows)

## One matrix: a row per met character, a column per day, the band words (or a dash, or the fate).
static func _people_table(days: Array, people: Array, band_key: String, words: Dictionary) -> Array[String]:
	var headers: Array = ["Postać"]
	for day in days:
		headers.append("D%d" % int(day.get("day", 0)))
	var rows: Array = []
	for person in people:
		if not bool(person.get("met", false)):
			continue
		var row: Array = [String(person.get("name", "?"))]
		for day in days:
			row.append(_person_cell(day.get("dawn"), String(person.get("id", "")), band_key, words))
		rows.append(row)
	if rows.is_empty():
		return ["Jeszcze z nikim nie rozmawiałeś."]
	return _table(headers, rows)

static func _person_cell(dawn: Variant, id: String, band_key: String, words: Dictionary) -> String:
	if dawn == null:
		return NO_DATA
	var state: Variant = (dawn.get("people", {}) as Dictionary).get(id)
	if state == null:
		return NO_DATA
	if not bool(state.get("arrived", true)):
		return DASH
	var status := String(state.get("status", "camp"))
	if status == "dead":
		return "nie żyje"
	if status == "gone":
		return "odszedł"
	var band: Variant = state.get(band_key)
	if band == "stala":
		return "stała"
	if band == null:
		return DASH
	return String(words.get(band, band))

static func _vein_table(rows_data: Array) -> Array[String]:
	if rows_data.is_empty():
		return ["Żadna żyła nie została jeszcze zaznaczona (albo zapis jest sprzed wersji 6: %s)." % NO_DATA]
	var rows: Array = []
	var n := 0
	for logged in rows_data:
		n += 1
		var via := " (zaznaczył %s)" % String(logged["via"]).capitalize() if logged.has("via") else ""
		rows.append([str(n), "%s%s" % [logged.get("place", "?"), via], str(int(logged.get("day", 0))), String(logged.get("time", "?"))])
	return _table(["#", "Miejsce", "Dzień", "Godzina"], rows)

#endregion

#region Writing

static func to_json(data: Dictionary) -> String:
	return JSON.stringify(data, "\t")

## Writes the report for the state of the game right now and returns the path of the .md file
## ("" when it could not be written). `ending` is one of the ENDING_* ids.
static func write(ending: String = ENDING_IN_PROGRESS) -> String:
	var data := collect(ending)
	DirAccess.make_dir_recursive_absolute(REPORT_DIR)
	var stem := _file_stem()
	var md_path := "%s/%s.md" % [REPORT_DIR, stem]
	var json_path := "%s/%s.json" % [REPORT_DIR, stem]
	if not _store(md_path, to_markdown(data)) or not _store(json_path, to_json(data)):
		return ""
	return md_path

## Where a report really is on this machine, for a person to open (Windows: with backslashes).
static func display_path(path: String) -> String:
	var os_path := ProjectSettings.globalize_path(path)
	return os_path.replace("/", "\\") if OS.get_name() == "Windows" else os_path

## przebieg-2026-10-27_14-03-22, with "-2", "-3"… when that second already has a report.
static func _file_stem() -> String:
	var t := Time.get_datetime_dict_from_system()
	var stem := "przebieg-%04d-%02d-%02d_%02d-%02d-%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]
	var candidate := stem
	var n := 1
	while FileAccess.file_exists("%s/%s.md" % [REPORT_DIR, candidate]) or FileAccess.file_exists("%s/%s.json" % [REPORT_DIR, candidate]):
		n += 1
		candidate = "%s-%d" % [stem, n]
	return candidate

static func _store(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write the report %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(text)
	return true

#endregion
