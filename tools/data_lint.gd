extends SceneTree
## Usage: godot --headless --path . --script res://tools/data_lint.gd
## Static cross-checks between the content sources and the GameState registries:
## - every item / quest / note / npc id used in dialogues, generators and the StoryDirector
##   exists in ITEMS / QUESTS / NOTES / NPCS,
## - every quest_log entry exists in its QuestData (and every defined entry is used somewhere,
##   so a renamed key can't silently orphan a notebook line),
## - the vein ids built by the generators match LOCATIONS[*].veins exactly,
## - every camp NPC dialogue has a [#leave] farewell (the free exit),
## - [#free] (a response that costs no talk time) only on responses that hand over an item,
## - task_11: every npc_place(...) == "<place>" names a place the schedule really uses, and
##   everyone who can be met first in the tunnels has a "teren" greeting with a line per
##   first-level room,
## - task_14: every time label written by a dialogue, a generator or the StoryDirector has a
##   category in the run report other than "inne" (CZAS-16), every hidden vein the bot knows
##   about is built with a pickaxe by the generators, and every flag a script or dialogue reads
##   is set somewhere (the dead `hieronim_gone` check was this kind of bug).
## Catches the typo class the scenario tests only hit when they walk the exact branch. ~2 s.

## Field-scene mages: every pick is meant to charge, so no [#leave] there.
const NO_LEAVE_EXEMPT := ["welf", "hieronim"]
## Camp people the hero can meet first in the tunnels (day-1 shift, work posts): their first
## greeting needs a "teren" branch (task_11).
const FIELD_FIRST_MEET := ["wszebor", "nasir", "hagiwara", "sobek", "anzelm"]
## Met only in the tunnels (the Exitium mages; Sabina until she joins the camp).
const FIELD_ONLY := ["ottokar", "hieronim", "welf", "sabina"]
## Flags whose names are put together at run time ("vein_" + id, "visited_%s" % place): a read of
## one of them has no literal `set_flag` to match.
const FLAG_FAMILIES := ["vein_", "visited_"]
const DIALOGUE_DIR := "res://dialogue"
const EXTRA_SOURCES := [
	"res://tools/generators/gen_camp.gd",
	"res://tools/generators/gen_locations.gd",
	"res://tools/generators/gen_mine_deep.gd",
	"res://script/story_director.gd",
]

var _failures := 0
var gs

func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	var sources := {}
	for file in DirAccess.get_files_at(DIALOGUE_DIR):
		if file.ends_with(".dialogue"):
			sources[DIALOGUE_DIR + "/" + file] = FileAccess.get_file_as_string(DIALOGUE_DIR + "/" + file)
	for path in EXTRA_SOURCES:
		sources[path] = FileAccess.get_file_as_string(path)

	print("--- Ids used in the sources exist in the registries")
	var checks := [
		[["give_item\\(\"(\\w+)\"", "take_item\\(\"(\\w+)\"", "has_item\\(\"(\\w+)\"", "item_count\\(\"(\\w+)\"", "\"required_item\": \"(\\w+)\""], gs.ITEMS, "item"],
		[["give_to_npc\\(\"(\\w+)\""], gs.ITEMS, "item"],
		[["start_quest\\(&?\"(\\w+)\"", "complete_quest\\(&?\"(\\w+)\"", "fail_quest\\(&?\"(\\w+)\"", "quest_state\\(&?\"(\\w+)\"", "quest_log\\(&?\"(\\w+)\"", "\"on_use_quest\": &\"(\\w+)\""], gs.QUESTS, "quest"],
		[["add_note\\(&?\"(\\w+)\"", "has_note\\(&?\"(\\w+)\"", "\"on_use_note\": &\"(\\w+)\""], gs.NOTES, "note"],
		[["change_rep\\(&?\"(\\w+)\"", "change_sanity\\(&?\"(\\w+)\"", "npc_place\\(&?\"(\\w+)\"", "npc_status\\(&?\"(\\w+)\"", "has_fever\\(&?\"(\\w+)\"", "sanity_band\\(&?\"(\\w+)\"", "npc_health\\(&?\"(\\w+)\"", "change_npc_health\\(&?\"(\\w+)\"", "give_to_npc\\(\"\\w+\", \"(\\w+)\""], gs.NPCS, "npc"],
		[["has_flag\\(\"vein_(\\w+)\"", "set_flag\\(\"vein_(\\w+)\""], _vein_registry(), "vein"],
	]
	var unknown := 0
	for group in checks:
		for pattern in group[0]:
			var re := RegEx.create_from_string(pattern)
			for path in sources:
				for m in re.search_all(sources[path]):
					var id := m.get_string(1)
					if not group[1].has(StringName(id)) and not group[1].has(id):
						unknown += 1
						print("   LINT %s: unknown %s '%s'" % [path, group[2], id])
	# on_use_item accepts lists like "bandaze:2,swieca".
	var re_list := RegEx.create_from_string("\"on_use_item\": \"([\\w:, ]+)\"")
	for path in sources:
		for m in re_list.search_all(sources[path]):
			for entry in m.get_string(1).split(",", false):
				var id := entry.strip_edges().get_slice(":", 0)
				if not gs.ITEMS.has(StringName(id)):
					unknown += 1
					print("   LINT %s: unknown item '%s' (on_use_item)" % [path, id])
	_check(unknown == 0, "all used ids exist (%d unknown)" % unknown)

	print("--- Quest entries: used ones exist, defined ones are used")
	var used_entries := {}
	var re_pair := RegEx.create_from_string("quest_log\\(&?\"(\\w+)\",\\s*\"(\\w+)\"")
	var re_gen_pair := RegEx.create_from_string("\"on_use_quest\": &\"(\\w+)\"[^}]*?\"on_use_quest_entry\": \"(\\w+)\"")
	var bad_entries := 0
	for path in sources:
		for re: RegEx in [re_pair, re_gen_pair]:
			for m in re.search_all(sources[path]):
				var quest := StringName(m.get_string(1))
				var entry: String = m.get_string(2)
				used_entries[m.get_string(1) + "/" + entry] = true
				if gs.QUESTS.has(quest) and not gs.QUESTS[quest].entries.has(entry):
					bad_entries += 1
					print("   LINT %s: quest '%s' has no entry '%s'" % [path, quest, entry])
	_check(bad_entries == 0, "all logged entries exist (%d bad)" % bad_entries)
	var orphans := 0
	for quest_id in gs.QUESTS:
		for entry in gs.QUESTS[quest_id].entries:
			if entry != "start" and not used_entries.has(String(quest_id) + "/" + entry):
				orphans += 1
				print("   LINT quest '%s': entry '%s' is defined but never logged" % [quest_id, entry])
	_check(orphans == 0, "no orphaned quest entries (%d)" % orphans)

	print("--- Veins: generators and LOCATIONS agree")
	var built := {}
	var re_vein := RegEx.create_from_string("(?:hidden_vein|vein|vein_mark)\\((?:[^,]+,){1,2}?\\s*\"(\\w+)\"")
	# Some veins are built as plain interactables (gen_camp's west_1).
	var re_vein_flag := RegEx.create_from_string("\"on_use_flag\": \"vein_(\\w+)\"")
	for path in EXTRA_SOURCES:
		for re: RegEx in [re_vein, re_vein_flag]:
			for m in re.search_all(sources[path]):
				built[m.get_string(1)] = true
	var registry: Dictionary = _vein_registry()
	var missing := registry.keys().filter(func(id): return not built.has(String(id)))
	var extra := built.keys().filter(func(id): return not registry.has(id) and not registry.has(StringName(id)))
	_check(missing.is_empty(), "every registered vein is built by a generator %s" % [missing])
	_check(extra.is_empty(), "every built vein is registered %s" % [extra])

	print("--- Every camp NPC dialogue has a [#leave] farewell")
	var no_leave := 0
	for npc_id in gs.NPCS:
		if String(npc_id) in NO_LEAVE_EXEMPT:
			continue
		var path := "%s/%s.dialogue" % [DIALOGUE_DIR, npc_id]
		if not sources.has(path) or not sources[path].contains("[#leave]"):
			no_leave += 1
			print("   LINT %s: no [#leave] farewell" % path)
	_check(no_leave == 0, "farewells tagged everywhere (%d missing)" % no_leave)

	print("--- [#free] only on responses that hand over an item")
	var bad_free := 0
	var free_count := 0
	for path in sources:
		if not String(path).ends_with(".dialogue"):
			continue
		var lines: PackedStringArray = sources[path].split("\n")
		for i in lines.size():
			if not lines[i].contains("[#free]"):
				continue
			free_count += 1
			var indent := lines[i].length() - lines[i].lstrip("\t").length()
			var hands_over := false
			for j in range(i + 1, lines.size()):
				var line := lines[j]
				if line.strip_edges() == "":
					continue
				if line.length() - line.lstrip("\t").length() <= indent:
					break
				if line.contains("take_item(") or line.contains("give_to_npc("):
					hands_over = true
			if not hands_over:
				bad_free += 1
				print("   LINT %s:%d: [#free] on a response that hands nothing over" % [path, i + 1])
	_check(free_count > 5 and bad_free == 0, "%d free hand-overs, %d wrongly tagged" % [free_count, bad_free])

	print("--- task_11: first greetings know where they happen")
	var places_of := _schedule_places()
	var bad_place := 0
	var place_checks := 0
	var re_place := RegEx.create_from_string("npc_place\\(&?\"(\\w+)\"\\) [!=]= \"(\\w*)\"")
	for path in sources:
		for m in re_place.search_all(sources[path]):
			var who := m.get_string(1)
			var where := m.get_string(2)
			if where != "" and places_of.has(who):
				place_checks += 1
			if where != "" and places_of.has(who) and not where in places_of[who]:
				bad_place += 1
				print("   LINT %s: %s is never at '%s' (schedule: %s)" % [path, who, where, places_of[who]])
	_check(place_checks > 20 and bad_place == 0, "every npc_place(...) == \"...\" names a place the schedule really uses (%d checked, %d wrong)" % [place_checks, bad_place])
	var no_field_greeting := 0
	for who in FIELD_FIRST_MEET:
		var text: String = sources.get("%s/%s.dialogue" % [DIALOGUE_DIR, who], "")
		var intro := _block_after(text, "if not has_flag(\"met_%s\")" % who)
		if not intro.contains("npc_place(\"%s\") == \"teren\"" % who):
			no_field_greeting += 1
			print("   LINT %s: can be met first in the tunnels, but the first greeting has no \"teren\" branch" % who)
		if StringName(who) in gs.FIRST_MEET:
			for room in gs.FIRST_ROOMS:
				if not intro.contains("current_place() == \"%s\"" % room):
					no_field_greeting += 1
					print("   LINT %s: no line for the first meeting in '%s'" % [who, room])
	_check(no_field_greeting == 0, "everyone met first in the tunnels has a tunnel greeting and a line per first-level room (%d missing)" % no_field_greeting)

	# The dialogues, the generators and every script (a label written in any script/*.gd counts).
	var all_sources := sources.duplicate()
	for file in DirAccess.get_files_at("res://script"):
		if file.ends_with(".gd"):
			all_sources["res://script/" + file] = FileAccess.get_file_as_string("res://script/" + file)

	print("--- task_14: time labels have a report category (CZAS-16)")
	var report = load("res://script/run_report.gd")
	var label_patterns := [
		"advance_time\\(\\s*[^,()\"]+,\\s*\"([^\"%]+)\"\\s*\\)",
		"log_time\\([^,()]+,[^,()]+,\\s*\"([^\"%]+)\"\\s*\\)",
		"\"time_reason\":\\s*\"([^\"%]+)\"",
	]
	var labels := {}
	for pattern in label_patterns:
		var re_label := RegEx.create_from_string(pattern)
		for path in all_sources:
			for m in re_label.search_all(all_sources[path]):
				labels[m.get_string(1)] = path
	var uncategorised := 0
	for label in labels:
		if report.categorize(label) == report.OTHER and label != report.FALLBACK_LABEL:
			uncategorised += 1
			print("   LINT %s: the time label \"%s\" would count as \"inne\" in the run report (add it to RunReport.LABEL_CATEGORY)" % [labels[label], label])
	# Any label at all proves the patterns still match the sources; how many there are is not a rule.
	if labels.is_empty():
		print("   LINT: no time label found in the sources: the patterns of this check no longer match how the game writes them")
	_check(not labels.is_empty() and uncategorised == 0, "%d time labels in the sources, %d without a category" % [labels.size(), uncategorised])

	print("--- task_14: the bot's hidden veins are the generators' pickaxe veins")
	var hidden_built := {}
	var re_hidden := RegEx.create_from_string("hidden_vein\\(\\s*\\w+,\\s*\"(\\w+)\"")
	for m in re_hidden.search_all(sources["res://tools/generators/gen_locations.gd"]):
		hidden_built[m.get_string(1)] = true
	var bot_hidden := {}
	for id in load("res://tools/balance_sim.gd").HIDDEN_VEINS:
		bot_hidden[String(id)] = true
	_check(not hidden_built.is_empty() and hidden_built.keys().all(func(id): return bot_hidden.has(id)) and bot_hidden.keys().all(func(id): return hidden_built.has(id)), "balance_sim.gd knows exactly the veins gen_locations.gd hides under flowstone %s" % [hidden_built.keys()])

	print("--- task_14: every flag that is read is set somewhere")
	var read_patterns := ["has_flag\\(\\s*\"([^\"%+]+)\"", "done_today\\(\\s*\"([^\"%+]+)\"", "\"required_flag\":\\s*\"([^\"%+]+)\"", "\"hidden_by_flag\":\\s*\"([^\"%+]+)\""]
	var write_patterns := ["set_flag\\(\\s*\"([^\"%+]+)\"", "mark_today\\(\\s*\"([^\"%+]+)\"", "bump_flag\\(\\s*\"([^\"%+]+)\"", "flags\\[\\s*\"([^\"%+]+)\"\\s*\\]\\s*=", "\"on_use_flag\":\\s*\"([^\"%+]+)\""]
	var written := {}
	for pattern in write_patterns:
		var re_write := RegEx.create_from_string(pattern)
		for path in all_sources:
			for m in re_write.search_all(all_sources[path]):
				written[m.get_string(1)] = true
	var read_flags := {}
	for pattern in read_patterns:
		var re_read := RegEx.create_from_string(pattern)
		for path in all_sources:
			for m in re_read.search_all(all_sources[path]):
				read_flags[m.get_string(1)] = path
	var never_set := 0
	for flag_name in read_flags:
		var family := false
		for prefix in FLAG_FAMILIES:
			if flag_name.begins_with(prefix):
				family = true
		if not written.has(flag_name) and not family:
			never_set += 1
			print("   LINT %s: the flag '%s' is read but nothing sets it" % [read_flags[flag_name], flag_name])
	_check(read_flags.size() > 100 and never_set == 0, "%d flags are read, %d of them never set" % [read_flags.size(), never_set])

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(0 if _failures == 0 else 1)

## Places each NPC can have, read from the schedule scripts: every _at("<place>", …) in the
## NPC's CampSchedule function, plus "teren" for whoever FieldSchedule can put in the tunnels.
func _schedule_places() -> Dictionary:
	var result := {}
	var camp := FileAccess.get_file_as_string("res://script/camp_schedule.gd")
	var re_func := RegEx.create_from_string("static func _(\\w+)\\(\\) -> Dictionary:")
	var re_at := RegEx.create_from_string("_at\\(\"(\\w+)\"")
	var funcs := re_func.search_all(camp)
	for i in funcs.size():
		var who := funcs[i].get_string(1)
		if not gs.NPCS.has(StringName(who)):
			continue
		var end := funcs[i + 1].get_start() if i + 1 < funcs.size() else camp.length()
		var body := camp.substr(funcs[i].get_end(), end - funcs[i].get_end())
		var places: Array[String] = []
		for m in re_at.search_all(body):
			places.append(m.get_string(1))
		result[who] = places
	for who in FIELD_FIRST_MEET + FIELD_ONLY:
		if not result.has(who):
			result[who] = []
		result[who].append("teren")
	return result

## The lines indented under `header` (its whole if-block), or "" if it isn't there.
func _block_after(text: String, header: String) -> String:
	var lines := text.split("\n")
	for i in lines.size():
		if lines[i].strip_edges() == header:
			var indent := lines[i].length() - lines[i].lstrip("\t").length()
			var block: Array[String] = []
			for j in range(i + 1, lines.size()):
				if lines[j].strip_edges() != "" and lines[j].length() - lines[j].lstrip("\t").length() <= indent:
					break
				block.append(lines[j])
			return "\n".join(block)
	return ""

func _vein_registry() -> Dictionary:
	var veins := {}
	for id in gs.LOCATIONS:
		for vein in gs.LOCATIONS[id].veins:
			veins[String(vein)] = true
	return veins

func _check(ok: bool, what: String) -> void:
	print("   [%s] %s" % ["OK" if ok else "FAIL", what])
	if not ok:
		_failures += 1
