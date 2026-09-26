extends SceneTree
## Usage: godot --headless --path . --script res://tools/data_lint.gd
## Static cross-checks between the content sources and the GameState registries:
## - every item / quest / note / npc id used in dialogues, generators and the StoryDirector
##   exists in ITEMS / QUESTS / NOTES / NPCS,
## - every quest_log entry exists in its QuestData (and every defined entry is used somewhere,
##   so a renamed key can't silently orphan a notebook line),
## - the vein ids built by the generators match LOCATIONS[*].veins exactly,
## - every camp NPC dialogue has a [#leave] farewell (the free exit),
## - [#free] (a response that costs no talk time) only on responses that hand over an item.
## Catches the typo class the scenario tests only hit when they walk the exact branch. ~2 s.

## Field-scene mages: every pick is meant to charge, so no [#leave] there.
const NO_LEAVE_EXEMPT := ["welf", "hieronim"]
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

	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(0 if _failures == 0 else 1)

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
