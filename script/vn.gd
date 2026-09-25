extends Node

## Autoload "VN": opens the visual-novel dialogue screen (scene/vn/vn_balloon.tscn).
## While it is open the game counts as modal: the player can't move or interact.

signal started(npc_id: StringName)
signal finished(npc_id: StringName)

const BALLOON := preload("res://scene/vn/vn_balloon.tscn")

## The NPC the player is talking to (empty for narration, e.g. sleep or dreams).
var current_npc: StringName = &""
var _balloon: Node

func is_active() -> bool:
	return is_instance_valid(_balloon)

func start(resource: DialogueResource, cue: String = "start", npc_id: StringName = &"") -> void:
	if is_active() or resource == null:
		return
	current_npc = npc_id
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

func _on_closed() -> void:
	if not is_inside_tree():
		return
	var npc_id := current_npc
	current_npc = &""
	_balloon = null
	GameState.pop_modal()
	finished.emit(npc_id)
