extends Node

## Autoload "VN": opens the visual-novel dialogue screen (scene/vn/vn_balloon.tscn).
## While it is open the game counts as modal: the player can't move or interact.

signal started(npc_id: StringName)
signal finished(npc_id: StringName)

const BALLOON := preload("res://scene/vn/vn_balloon.tscn")

## Every response picked in a conversation with an NPC costs this much (task_09, DIA-5).
## Free: opening the conversation, farewells ([#leave]), simple hand-overs of an item ([#free]),
## a response already picked before with the same person (GameState.asked, factcheck 10),
## and responses whose follow-up spends time of its own (dice, the pumps, fishing): their 5
## minutes are given back, so the cost is what the player sees. Scene dialogues (dreams, the
## wall, the campfire, announcements, Hrapek) never charge.
const TALK_MINUTES := 5

## The NPC the player is talking to (empty for narration, e.g. sleep or dreams).
var current_npc: StringName = &""
var _balloon: Node
## True when this conversation charges for its responses.
var _charging := false
## Minutes charged so far in this conversation, and the hour it started at.
var _talk_minutes := 0
var _talk_from := 0.0
## The last picked response was charged and nothing else has happened since.
var _last_charge_open := false

func _ready() -> void:
	GameState.time_advanced.connect(_on_time_advanced)
	# "Wysadź zawał (4 h)": the world runs the action after the dialogue closes, same rule.
	GameState.action_requested.connect(func(_action): _on_time_advanced(0.0, ""))

func is_active() -> bool:
	return is_instance_valid(_balloon)

func start(resource: DialogueResource, cue: String = "start", npc_id: StringName = &"", charge_talk := false) -> void:
	if is_active() or resource == null:
		return
	current_npc = npc_id
	_charging = charge_talk and npc_id != &""
	_talk_minutes = 0
	_talk_from = GameState.hour
	_last_charge_open = false
	GameState.push_modal()
	_balloon = BALLOON.instantiate()
	get_tree().current_scene.add_child(_balloon)
	_balloon.tree_exited.connect(_on_closed, CONNECT_ONE_SHOT)
	started.emit(npc_id)
	_balloon.start(resource, cue)

## Awaitable helper: `await VN.play(resource, cue)` returns when the dialogue closes.
func play(resource: DialogueResource, cue: String = "start", npc_id: StringName = &"") -> void:
	start(resource, cue, npc_id)
	if is_active():
		await finished

## The balloon reports every picked response: each one costs TALK_MINUTES unless it is a
## farewell or a hand-over. The clock moves at once (the VN clock follows); the toast and the
## time-log entry come once, when the conversation closes.
func response_picked(response: DialogueResponse) -> void:
	_last_charge_open = false
	if not _charging or response.tags.has("leave") or response.tags.has("free"):
		return
	# factcheck 10: the same option asked again of the same person costs nothing.
	if GameState.was_asked(current_npc, response.text):
		return
	GameState.mark_asked(current_npc, response.text)
	_talk_minutes += TALK_MINUTES
	_last_charge_open = true
	GameState.add_quiet_time(TALK_MINUTES / 60.0)

## Minutes this conversation has cost so far (tests, the VN clock).
func talk_minutes() -> int:
	return _talk_minutes

## A response led to an action with its own cost ("Kości z Sobkiem · 1 h"): give back its
## 5 minutes, so the player pays what the action says.
func _on_time_advanced(_hours: float, _reason: String) -> void:
	if is_active() and _last_charge_open:
		_last_charge_open = false
		_talk_minutes -= TALK_MINUTES
		GameState.hour -= TALK_MINUTES / 60.0
		GameState.clock_changed.emit()

func _on_closed() -> void:
	if not is_inside_tree():
		return
	var npc_id := current_npc
	var minutes := _talk_minutes if _charging else 0
	current_npc = &""
	_charging = false
	_talk_minutes = 0
	_last_charge_open = false
	_balloon = null
	if minutes > 0:
		var data: NpcData = GameState.NPCS.get(npc_id)
		var who := data.display_name_instrumental if data else String(npc_id)
		GameState.commit_time(minutes / 60.0, "Rozmowa z %s" % who, _talk_from)
	GameState.pop_modal()
	finished.emit(npc_id)
