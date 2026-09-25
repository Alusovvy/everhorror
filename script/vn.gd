extends Node

## Autoload "VN": opens the visual-novel dialogue screen (scene/vn/vn_balloon.tscn).
## While it is open the game counts as modal: the player can't move or interact.

signal started(npc_id: StringName)
signal finished(npc_id: StringName)

const BALLOON := preload("res://scene/vn/vn_balloon.tscn")

## Opening a conversation is free. The first response that isn't a farewell (a response
## tagged [#leave] in the .dialogue file) costs this much, once per conversation.
## Scene dialogues (dreams, the wall, the campfire, Racibor's announcements) never charge.
const TALK_HOURS := 0.5

## The NPC the player is talking to (empty for narration, e.g. sleep or dreams).
var current_npc: StringName = &""
var _balloon: Node
## True until this conversation's talk cost has been charged (or waived).
var _charge_pending := false

func is_active() -> bool:
	return is_instance_valid(_balloon)

func start(resource: DialogueResource, cue: String = "start", npc_id: StringName = &"", charge_talk := false) -> void:
	if is_active() or resource == null:
		return
	current_npc = npc_id
	_charge_pending = charge_talk and npc_id != &""
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

## The balloon reports every picked response; the first one that isn't a farewell
## costs the talk time (task_06, user decision: peeking in and leaving is free).
func response_picked(response: DialogueResponse) -> void:
	if not _charge_pending or response.tags.has("leave"):
		return
	_charge_pending = false
	var data: NpcData = GameState.NPCS.get(current_npc)
	var who := data.display_name_instrumental if data else String(current_npc)
	GameState.advance_time(TALK_HOURS, "Rozmowa z %s" % who)

func _on_closed() -> void:
	if not is_inside_tree():
		return
	var npc_id := current_npc
	current_npc = &""
	_charge_pending = false
	_balloon = null
	GameState.pop_modal()
	finished.emit(npc_id)
