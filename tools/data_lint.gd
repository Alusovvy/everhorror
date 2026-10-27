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
## - warnings (they never fail the run; the count is printed as "WARNINGS: n"): flags only written
##   and never read by the game, `%d <noun>` in Polish player text (use veins_acc() / plural()),
##   and a response whose condition gates only on an item (DIA-2: it shows greyed out for ever
##   once the item is gone; add a quest or event guard).
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
var _warnings := 0
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

	print("--- warnings: flags that are only written, never read by the game (G-E2)")
	# A flag counts as read when its name appears quoted anywhere outside the calls that write it
	# (has_flag, get_flag, a list such as FOURTEENTH_CLUES, a "flag:" requirement of the places
	# graph, a required_flag in a generator, bump_flag). A flag set with "on_use_flag" is read by
	# the Interactable itself (it hides a pickup). tools/tests do not count: a flag only a test
	# reads is dead for the player. Flags the run report lists by name count as read.
	var write_counts := {}
	var implicit_read := {}
	var re_on_use := RegEx.create_from_string("\"on_use_flag\":\\s*\"([^\"%+]+)\"")
	for path in all_sources:
		for m in re_on_use.search_all(all_sources[path]):
			implicit_read[m.get_string(1)] = true
	for pattern in ["set_flag\\(\\s*\"([^\"%+]+)\"", "mark_today\\(\\s*\"([^\"%+]+)\"", "flags\\[\\s*\"([^\"%+]+)\"\\s*\\]\\s*="]:
		var re_w := RegEx.create_from_string(pattern)
		for path in all_sources:
			for m in re_w.search_all(all_sources[path]):
				write_counts[m.get_string(1)] = int(write_counts.get(m.get_string(1), 0)) + 1
	var world_data := FileAccess.get_file_as_string("res://tools/generators/write_world_data.js")
	var corpus := "\n".join(all_sources.values()) + "\n" + world_data.replace("\"flag:", "\"").replace("\"noflag:", "\"")
	var only_written := 0
	var written_names := written.keys()
	written_names.sort()
	for flag_name in written_names:
		var family := false
		for prefix in FLAG_FAMILIES + ["first_room_", "fever_"]:
			if flag_name.begins_with(prefix):
				family = true
		if family or implicit_read.has(flag_name):
			continue
		# Quoted occurrences, minus the ones that write it.
		var mentions := corpus.count("\"%s\"" % flag_name)
		if mentions - int(write_counts.get(flag_name, 0)) <= 0:
			only_written += 1
			print("   WARN the flag '%s' is set but nothing in the game reads it" % flag_name)
	_warnings += only_written
	print("   %d flags are written, %d of them never read" % [written.size(), only_written])

	print("--- warnings: a bare number before a noun in Polish player text (G-E2, K6)")
	var re_noun := RegEx.create_from_string("(?<!z )(?<!%)%d\\s+([A-Za-ząćęłńóśźżĄĆĘŁŃÓŚŹŻ]+)")
	var number_nouns := 0
	for path in all_sources:
		# The run report is for the developer, not the player (gra.md G3).
		if path.ends_with("run_report.gd") or path.ends_with("save_manager.gd"):
			continue
		for m in re_noun.search_all(all_sources[path]):
			var word := m.get_string(1)
			if word in ["min", "h", "z", "of", "x", "s", "ms"]:
				continue
			number_nouns += 1
			print("   WARN %s: \"%%d %s\" has a fixed noun after the number (use plural() / veins_acc() / days_left_text())" % [path, word])
	_warnings += number_nouns

	print("--- warnings: responses that gate only on an item (DIA-2)")
	var re_response := RegEx.create_from_string("^\\s*- .*\\[if (.+?) /\\]")
	var re_item_term := RegEx.create_from_string("^\\s*has_item\\(\"\\w+\"\\)\\s*$")
	var item_only := 0
	for path in sources:
		if not path.ends_with(".dialogue"):
			continue
		var line_no := 0
		for line in sources[path].split("\n"):
			line_no += 1
			var m := re_response.search(line)
			if m == null:
				continue
			var all_items := true
			for term in m.get_string(1).split(" and "):
				if re_item_term.search(term) == null:
					all_items = false
			if all_items:
				item_only += 1
				print("   WARN %s:%d: the condition '%s' gates only on an item; add a quest or event guard" % [path, line_no, m.get_string(1)])
	_warnings += item_only

	print("WARNINGS: %d (flags only written %d, number before a noun %d, item-only responses %d)" % [_warnings, only_written, number_nouns, item_only])

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
