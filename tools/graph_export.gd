extends SceneTree
## Usage: godot --headless --path . --script res://tools/graph_export.gd [-- --out=<file.json>]
## Exports the game side of the relationship graph the spec dashboard shows (view "Graf", D-36.13):
## quests and their entries, flags (set / read, with payload), items, notes, characters and their states,
## places, roads and veins, dialogue files, titles and jumps, and the night / morning code of the
## StoryDirector (marked approximate). Read only: nothing in data/ or scene/ is touched; the one output is
## reports/graph/game-graph.json (outside git, rebuilt on demand). The dashboard joins it with the graph it
## computes from the specification. Same sources and patterns as tools/data_lint.gd; ~2 s.
##
## Node ids are stable and readable (flag:west_blasted, quest:ryba, entry:ryba/od_tekli, place:west,
## npc:tekla, dialogue:tekla, title:tekla/hub, night:5), because the comparison of two revisions depends on them.
## An edge `approx: true` comes from a regular expression over StoryDirector code, never from a rule.

const SCHEMA := 1
const DEFAULT_OUT := "res://reports/graph/game-graph.json"
const DIALOGUE_DIR := "res://dialogue"
const SCRIPT_DIR := "res://script"
const GENERATORS_DIR := "res://tools/generators"
const DIRECTOR := "script/story_director.gd"
## StoryDirector functions that are the nights and mornings (design: "przybliżenie z kodu").
const NIGHT_FUNCS := ["_resolve_night", "_resolve_new_people", "_morning_events", "_morning_subtitle", "_week_end", "_sleep", "_miroslaw_breaks", "_blast", "_hrapek_on_the_way_back"]

var gs
var _nodes := {}
var _edges: Array = []
var _edge_keys := {}
var _flags_set := {}
var _flags_read := {}

func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	gs = root.get_node("GameState")
	_registries()
	_places()
	var sources := _read_sources()
	for rel in sources:
		_scan(rel, sources[rel])
	_nights()
	var data := {
		"schema": SCHEMA,
		"generator": "tools/graph_export.gd",
		"generatedAt": Time.get_datetime_string_from_system(true) + "Z",
		"rev": _git(["rev-parse", "HEAD"]).strip_edges(),
		"dirty": _git(["status", "--porcelain"]).strip_edges() != "",
		"nodes": _nodes.values(),
		"edges": _edges,
	}
	var out_path := DEFAULT_OUT
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_path = arg.substr(6)
	var abs_path := ProjectSettings.globalize_path(out_path) if out_path.begins_with("res://") else out_path
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var file := FileAccess.open(abs_path, FileAccess.WRITE)
	if file == null:
		print("RESULT: FAILED (cannot write %s)" % abs_path)
		quit(1)
		return
	file.store_string(JSON.stringify(data))
	file.close()
	print("GRAPH nodes=%d edges=%d flags=%d (set %d, read %d) -> %s" % [_nodes.size(), _edges.size(), _count_type("flag"), _flags_set.size(), _flags_read.size(), abs_path])
	print("RESULT: ALL PASSED")
	quit(0)

# ---------------------------------------------------------------- nodes and edges

func _node(type: String, id: String, label: String, file := "", line := 0, meta := {}) -> String:
	var key := "%s:%s" % [type, id]
	if not _nodes.has(key):
		var n := {"id": key, "type": type, "label": label if label != "" else id}
		if file != "":
			n["file"] = file
		if line > 0:
			n["line"] = line
		if not meta.is_empty():
			n["meta"] = meta
		_nodes[key] = n
	elif not meta.is_empty():
		var current: Dictionary = _nodes[key].get("meta", {})
		current.merge(meta, false)
		_nodes[key]["meta"] = current
	return key

func _edge(from: String, to: String, kind: String, file := "", line := 0, note := "", approx := false) -> void:
	var key := "%s|%s|%s|%s|%d" % [from, to, kind, file, line]
	if _edge_keys.has(key):
		return
	_edge_keys[key] = true
	var e := {"from": from, "to": to, "kind": kind}
	if file != "":
		e["file"] = file
	if line > 0:
		e["line"] = line
	if note != "":
		e["note"] = note
	if approx:
		e["approx"] = true
	_edges.append(e)

func _count_type(type: String) -> int:
	var n := 0
	for k in _nodes:
		if _nodes[k]["type"] == type:
			n += 1
	return n

func _git(args: Array) -> String:
	var output: Array = []
	var full: Array = ["-C", ProjectSettings.globalize_path("res://")]
	full.append_array(args)
	var code := OS.execute("git", full, output, true)
	return String(output[0]) if code == 0 and output.size() > 0 else ""

# ---------------------------------------------------------------- registries

func _registries() -> void:
	for id in gs.QUESTS:
		var q = gs.QUESTS[id]
		var qid := _node("quest", String(id), String(q.title), "data/quests/%s.tres" % id, 0, {"giver": String(q.giver)})
		_node_source_line(qid, "tools/generators/write_story_data.js", "quest(\"%s\"" % id)
		for entry in q.entries:
			var eid := _node("entry", "%s/%s" % [id, entry], String(entry), "data/quests/%s.tres" % id, 0, {"text": String(q.entries[entry]).left(140)})
			_edge(qid, eid, "contains")
	for id in gs.ITEMS:
		var it = gs.ITEMS[id]
		_node("item", String(id), String(it.display_name), "data/items/%s.tres" % id, 0, {"heal": it.heal, "sanity": it.sanity, "consumable": it.consumable})
	for id in gs.NOTES:
		var note = gs.NOTES[id]
		_node("note", String(id), String(note.title), "data/notes/%s.tres" % id)
	for id in gs.NPCS:
		var npc = gs.NPCS[id]
		var meta := {"faction": npc.faction, "role": String(npc.role), "maxSanity": npc.max_sanity, "startSanity": npc.start_sanity}
		var nid := _node("npc", String(id), String(npc.display_name), "data/npc/%s.tres" % id, 0, meta)
		_node_source_line(nid, "tools/generators/write_story_data.js", "npc({id: \"%s\"" % id)
		for status in ["camp", "field", "gone", "dead"]:
			_edge(nid, _node("npcstate", "%s/%s" % [id, status], "%s: %s" % [npc.display_name, status]), "contains")
	for id in gs.ARRIVAL_FLAG:
		_edge(_node("flag", String(gs.ARRIVAL_FLAG[id]), String(gs.ARRIVAL_FLAG[id])), "npc:%s" % id, "arrival", "script/game_state.gd", _line_of("script/game_state.gd", "ARRIVAL_FLAG"), "przybycie")

func _places() -> void:
	_node("place", "oboz", "Obóz")
	for id in gs.LOCATIONS:
		var loc = gs.LOCATIONS[id]
		var pid := _node("place", String(id), String(loc.display_name), "data/locations/%s.tres" % id, 0, {"depth": loc.depth, "dread": loc.dread, "direction": String(loc.direction)})
		_node_source_line(pid, "tools/generators/write_world_data.js", "id: \"%s\"" % id)
		for target in loc.links:
			var other := _node("place", String(target), String(target))
			var pair := [pid, other]
			pair.sort()
			_edge(pair[0], pair[1], "road", "", 0, "%s h" % str(loc.links[target]))
		var req_line := _line_of("data/locations/%s.tres" % id, "requires =")
		for req in loc.requires:
			var parts: PackedStringArray = String(req).split(":", true, 1)
			if parts.size() < 2:
				continue
			match parts[0]:
				"item":
					_edge(pid, _node("item", parts[1], parts[1]), "requires", "data/locations/%s.tres" % id, req_line)
				"flag":
					_edge(pid, _node("flag", parts[1], parts[1]), "requires", "data/locations/%s.tres" % id, req_line)
				"noflag":
					_edge(pid, _node("flag", parts[1], parts[1]), "requires_not", "data/locations/%s.tres" % id, req_line)
		for vein in loc.veins:
			_edge(pid, _node("vein", String(vein), String(vein)), "contains")

# ---------------------------------------------------------------- sources

func _read_sources() -> Dictionary:
	var sources := {}
	for file in DirAccess.get_files_at(DIALOGUE_DIR):
		if file.ends_with(".dialogue"):
			sources["dialogue/" + file] = FileAccess.get_file_as_string(DIALOGUE_DIR + "/" + file)
	for file in DirAccess.get_files_at(SCRIPT_DIR):
		if file.ends_with(".gd"):
			sources["script/" + file] = FileAccess.get_file_as_string(SCRIPT_DIR + "/" + file)
	for file in DirAccess.get_files_at(GENERATORS_DIR):
		if file.ends_with(".gd"):
			sources["tools/generators/" + file] = FileAccess.get_file_as_string(GENERATORS_DIR + "/" + file)
	return sources

func _re(pattern: String) -> RegEx:
	return RegEx.create_from_string(pattern)

func _scan(rel: String, text: String) -> void:
	var is_dialogue := rel.ends_with(".dialogue")
	var base := rel.get_file().get_basename()
	var lines := text.split("\n")
	var file_node := ""
	if is_dialogue:
		var npc_meta := {}
		file_node = _node("dialogue", base, base, rel, 0, npc_meta)
		if gs.NPCS.has(StringName(base)):
			_edge("npc:" + base, file_node, "has_dialogue", rel)
	else:
		file_node = _node("script", rel.get_file(), rel.get_file(), rel)
	var consts := {}
	var re_const := _re("const (\\w+)\\s*:?=\\s*preload\\(\"res://dialogue/(\\w+)\\.dialogue\"\\)")
	for m in re_const.search_all(text):
		consts[m.get_string(1)] = m.get_string(2)

	# Patterns: [regex, kind, target type, edge kind]
	var flag_set := [_re("set_flag\\(\\s*\"([^\"%+]+)\""), _re("mark_today\\(\\s*\"([^\"%+]+)\""), _re("bump_flag\\(\\s*\"([^\"%+]+)\""), _re("flags\\[\\s*\"([^\"%+]+)\"\\s*\\]\\s*="), _re("\"on_use_flag\":\\s*\"([^\"%+]+)\"")]
	var flag_clear := _re("clear_flag\\(\\s*\"([^\"%+]+)\"")
	var flag_read := [_re("has_flag\\(\\s*\"([^\"%+]+)\""), _re("done_today\\(\\s*\"([^\"%+]+)\""), _re("get_flag\\(\\s*\"([^\"%+]+)\""), _re("\"required_flag\":\\s*\"([^\"%+]+)\""), _re("\"hidden_by_flag\":\\s*\"([^\"%+]+)\"")]
	var simple := [
		[_re("give_item\\(\\s*\"(\\w+)\""), "item", "gives"],
		[_re("take_item\\(\\s*\"(\\w+)\""), "item", "takes"],
		[_re("give_to_npc\\(\\s*\"\\w+\",\\s*\"(\\w+)\""), "item", "takes"],
		[_re("has_item\\(\\s*\"(\\w+)\""), "item", "reads"],
		[_re("item_count\\(\\s*\"(\\w+)\""), "item", "reads"],
		[_re("\"required_item\":\\s*\"(\\w+)\""), "item", "reads"],
		[_re("start_quest\\(&?\"(\\w+)\""), "quest", "starts"],
		[_re("complete_quest\\(&?\"(\\w+)\""), "quest", "completes"],
		[_re("fail_quest\\(&?\"(\\w+)\""), "quest", "fails"],
		[_re("quest_state\\(&?\"(\\w+)\""), "quest", "reads"],
		[_re("add_note\\(&?\"(\\w+)\""), "note", "gives"],
		[_re("has_note\\(&?\"(\\w+)\""), "note", "reads"],
	]
	var re_entry := _re("quest_log\\(&?\"(\\w+)\",\\s*\"(\\w+)\"")
	var re_rep := _re("change_rep\\(&?\"(\\w+)\",\\s*(-?\\d+)")
	var re_sanity := _re("change_sanity\\(&?\"(\\w+)\",\\s*(-?\\d+)")
	var re_status_set := _re("set_npc_status\\(&?\"(\\w+)\",\\s*\"(\\w+)\"")
	var re_status_read := _re("npc_status\\(&?\"(\\w+)\"\\)\\s*(?:==|!=|in)\\s*\\[?\"(\\w+)\"")
	var re_play := _re("VN\\.play\\(\\s*(\\w+),\\s*\"(\\w+)\"")
	var re_title := _re("^~\\s*(\\w+)")
	var re_jump := _re("=>!?\\s*(\\w+)")
	var re_cond := _re("(night|day)\\s*(==|>=|<=|>|<)\\s*(\\d+)")
	var re_func := _re("^(?:static )?func (\\w+)")
	var re_response := _re("^\\s*- ")

	var title := ""
	var func_name := ""
	var responses := 0
	var cond_stack: Array = []
	for i in lines.size():
		var raw: String = lines[i]
		var line_no := i + 1
		var stripped := raw.strip_edges()
		if stripped == "" or (stripped.begins_with("#") and not is_dialogue):
			continue
		var indent := raw.length() - raw.lstrip("\t").length()
		var actor := file_node
		var approx := false
		if is_dialogue:
			var mt := re_title.search(raw)
			if mt != null:
				title = mt.get_string(1)
				var tid := _node("title", "%s/%s" % [base, title], "%s: %s" % [base, title], rel, line_no)
				_edge(file_node, tid, "contains")
			if title != "":
				actor = "title:%s/%s" % [base, title]
			if re_response.search(raw) != null:
				responses += 1
		else:
			var mf := re_func.search(raw)
			if mf != null:
				func_name = mf.get_string(1)
				cond_stack.clear()
			if rel == DIRECTOR and func_name in NIGHT_FUNCS:
				actor = _node("night", "director/" + func_name.trim_prefix("_"), "StoryDirector." + func_name, rel, line_no, {"approx": true})
				approx = true
				while cond_stack.size() > 0 and cond_stack[-1][0] >= indent:
					cond_stack.pop_back()
				var mc := re_cond.search(raw)
				if mc != null and (stripped.begins_with("if ") or stripped.begins_with("elif ")):
					cond_stack.append([indent, mc.get_string(0), mc.get_string(1), mc.get_string(2), mc.get_string(3)])
				if cond_stack.size() > 0:
					var top: Array = cond_stack[-1]
					if top[3] == "==" and top[4].to_int() > 0:
						actor = _node("night", "%s:%s" % [top[2], top[4]], ("Noc %s" if top[2] == "night" else "Dzień %s") % top[4], "", 0, {"approx": true})
		var note := ""
		if approx and cond_stack.size() > 0:
			note = String((cond_stack[-1] as Array)[1])
		# Flags written.
		for re: RegEx in flag_set:
			for m in re.search_all(raw):
				var fname := m.get_string(1)
				var payload := ""
				if re == flag_set[0]:
					payload = _payload_after(raw, m.get_end())
				elif re == flag_set[2]:
					payload = "+1"
				_flag_edge(actor, fname, "sets", rel, line_no, note, approx, payload)
		for m in flag_clear.search_all(raw):
			_flag_edge(actor, m.get_string(1), "clears", rel, line_no, note, approx, "")
		for re: RegEx in flag_read:
			for m in re.search_all(raw):
				_flag_edge(actor, m.get_string(1), "reads", rel, line_no, note, approx, "")
		for entry in simple:
			for m in (entry[0] as RegEx).search_all(raw):
				_edge(actor, _node(entry[1], m.get_string(1), m.get_string(1)), entry[2], rel, line_no, note, approx)
		for m in re_entry.search_all(raw):
			var quest := m.get_string(1)
			var eid := _node("entry", "%s/%s" % [quest, m.get_string(2)], m.get_string(2))
			_node("quest", quest, quest)
			_edge(actor, eid, "quest_entry", rel, line_no, note, approx)
		for m in re_rep.search_all(raw):
			_edge(actor, _node("npc", m.get_string(1), m.get_string(1)), "trust", rel, line_no, m.get_string(2), approx)
		for m in re_sanity.search_all(raw):
			_edge(actor, _node("npc", m.get_string(1), m.get_string(1)), "sanity", rel, line_no, m.get_string(2), approx)
		for m in re_status_set.search_all(raw):
			_edge(actor, _node("npcstate", "%s/%s" % [m.get_string(1), m.get_string(2)], "%s: %s" % [m.get_string(1), m.get_string(2)]), "sets", rel, line_no, note, approx)
		for m in re_status_read.search_all(raw):
			_edge(actor, _node("npcstate", "%s/%s" % [m.get_string(1), m.get_string(2)], "%s: %s" % [m.get_string(1), m.get_string(2)]), "reads", rel, line_no, note, approx)
		for m in re_play.search_all(raw):
			if consts.has(m.get_string(1)):
				var target_file: String = consts[m.get_string(1)]
				var tt := _node("title", "%s/%s" % [target_file, m.get_string(2)], "%s: %s" % [target_file, m.get_string(2)])
				_edge(actor, tt, "plays", rel, line_no, note, approx)
		if is_dialogue and (stripped.begins_with("=>") or stripped.contains(" => ")):
			var mj := re_jump.search(raw)
			if mj != null and mj.get_string(1) != "END":
				_edge(actor, _node("title", "%s/%s" % [base, mj.get_string(1)], "%s: %s" % [base, mj.get_string(1)]), "jump", rel, line_no)
	if is_dialogue:
		_nodes[file_node]["meta"] = {"responses": responses, "titles": _count_prefix("title:%s/" % base)}

## The second argument of set_flag("name", <payload>), read up to its closing parenthesis; "" for a plain true.
func _payload_after(raw: String, from: int) -> String:
	var depth := 0
	var start := -1
	for i in range(from, raw.length()):
		var c := raw[i]
		if c == " " and start < 0:
			continue
		if start < 0:
			if c != ",":
				return ""
			start = i + 1
			continue
		if c == "(" or c == "[":
			depth += 1
		elif c == ")" or c == "]":
			if depth == 0:
				var value := raw.substr(start, i - start).strip_edges()
				return "" if value == "true" else value
			depth -= 1
	return ""

func _count_prefix(prefix: String) -> int:
	var n := 0
	for k in _nodes:
		if String(k).begins_with(prefix):
			n += 1
	return n

func _flag_edge(actor: String, fname: String, kind: String, file: String, line: int, note: String, approx: bool, payload: String) -> void:
	var meta := {}
	if payload != "":
		meta["payload"] = payload
	var flag_id := _node("flag", fname, fname, "", 0, meta)
	if kind == "sets":
		_flags_set[fname] = true
		if payload != "":
			_nodes[flag_id]["meta"]["payload"] = payload
	elif kind == "reads":
		_flags_read[fname] = true
	_edge(actor, flag_id, kind, file, line, payload if payload != "" and note == "" else note, approx)

## The nodes of the week: nights 1..LAST_DAY-1 and days 1..LAST_DAY exist even when no code names them.
func _nights() -> void:
	var last: int = gs.LAST_DAY
	for n in range(1, last + 1):
		_node("night", "day:%d" % n, "Dzień %d" % n, "", 0, {"approx": true})
		if n < last:
			_node("night", "night:%d" % n, "Noc %d" % n, "", 0, {"approx": true})

func _node_source_line(node_id: String, rel: String, needle: String) -> void:
	var line := _line_of(rel, needle)
	if line > 0 and _nodes.has(node_id):
		_nodes[node_id]["file"] = rel
		_nodes[node_id]["line"] = line

var _file_cache := {}
func _line_of(rel: String, needle: String) -> int:
	if not _file_cache.has(rel):
		_file_cache[rel] = FileAccess.get_file_as_string("res://" + rel).split("\n")
	var lines: PackedStringArray = _file_cache[rel]
	for i in lines.size():
		if lines[i].contains(needle):
			return i + 1
	return 0
