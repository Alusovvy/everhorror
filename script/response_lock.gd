extends RefCounted
class_name ResponseLock

## DIA-2 for the demo (task_09): a dialogue response the player can't pick yet is shown greyed
## out, with the reason, only when it is blocked by trust or a missing item and by nothing else.
## Responses waiting for a later part of the story (flags, the day, quests, sanity…) stay hidden.
## Works on Dialogue Manager's `condition_as_text`, e.g. `quest_state("towar") == "active" and has_item("tobolek")`.

const ITEM_RE := "^has_item\\(\"([a-z_]+)\"\\)$"
const TRUST_RE := "^rep\\(\"([a-z_]+)\"\\)\\s*(>=|>)\\s*(-?\\d+)$"

## The reason to show in brackets ("potrzebne: lina", "Bolko jeszcze ci nie ufa"), or "" when
## the response should stay hidden. `gs` is the GameState.
static func reason(condition: String, gs: Node) -> String:
	var parts := split_and(condition.strip_edges())
	if parts.is_empty():
		return ""
	var item_re := RegEx.create_from_string(ITEM_RE)
	var trust_re := RegEx.create_from_string(TRUST_RE)
	var reasons: PackedStringArray = []
	for part in parts:
		var item := item_re.search(part)
		if item:
			var item_id := item.get_string(1)
			if not gs.has_item(item_id):
				reasons.append("potrzebne: %s" % item_label(gs.item_name(item_id)))
			continue
		var trust := trust_re.search(part)
		if trust:
			var npc_id := StringName(trust.get_string(1))
			var need := int(trust.get_string(3))
			var have: int = gs.rep(npc_id)
			if not (have >= need if trust.get_string(2) == ">=" else have > need):
				var data: NpcData = gs.npc_data(npc_id)
				reasons.append("%s jeszcze ci nie ufa" % (data.dialogue_name if data else String(npc_id)))
			continue
		# Anything else must already hold, or the response belongs to a later part of the story.
		if not evaluate(part, gs):
			return ""
	return ", ".join(reasons)

## Top-level `and` parts of a condition; [] when it has a top-level `or` (not worth guessing).
static func split_and(condition: String) -> PackedStringArray:
	var parts: PackedStringArray = []
	var depth := 0
	var in_string := false
	var start := 0
	var i := 0
	while i < condition.length():
		var c := condition[i]
		if c == "\"":
			in_string = not in_string
		elif not in_string:
			if c == "(" or c == "[":
				depth += 1
			elif c == ")" or c == "]":
				depth -= 1
			elif depth == 0 and _word_at(condition, i, " or "):
				return PackedStringArray()
			elif depth == 0 and _word_at(condition, i, " and "):
				parts.append(condition.substr(start, i - start).strip_edges())
				start = i + 5
				i += 4
		i += 1
	parts.append(condition.substr(start).strip_edges())
	return parts

static func _word_at(text: String, at: int, word: String) -> bool:
	return text.substr(at, word.length()) == word

## Evaluates one part against the GameState; false when it doesn't parse or run.
static func evaluate(part: String, gs: Node) -> bool:
	var expression := Expression.new()
	if expression.parse(part, ["day", "hour"]) != OK:
		return false
	var result: Variant = expression.execute([gs.day, gs.hour], gs, false)
	if expression.has_execute_failed():
		return false
	return result is bool and result

## "Lina" → "lina"; proper names keep their capitals ("Tobołek Tekli", "Daleki Klejnot").
static func item_label(item_name: String) -> String:
	var words := item_name.split(" ")
	for i in range(1, words.size()):
		if words[i] != "" and words[i].left(1) != words[i].left(1).to_lower():
			return item_name
	return item_name.left(1).to_lower() + item_name.substr(1)
