extends Node

## Autoload "SaveManager": save slots as JSON in user://saves.
##
## Any node in the "persist" group that implements save_state() -> Dictionary
## and load_state(data: Dictionary) is saved, keyed by its path from the scene
## root. Gameplay scenes call restore_pending(self) in _ready to apply a load.
## GameState (day, time, flags, NPCs…) is saved too and restored before the scene loads,
## so every node can read the loaded state in its own _ready.

const GAME_SCENE := "res://scene/world.tscn"
const MAIN_MENU_SCENE := "res://scene/main_menu.tscn"
const SAVE_DIR := "user://saves"
const SLOT_COUNT := 3
const SAVE_VERSION := 2
const PERSIST_GROUP := "persist"

var _pending: Dictionary = {}

func slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))

func has_any_save() -> bool:
	for slot in range(1, SLOT_COUNT + 1):
		if has_save(slot):
			return true
	return false

## Returns the save's data, or an empty Dictionary if the slot is empty or unreadable.
func read_slot(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(slot_path(slot)))
	if data is Dictionary and data.has("scene"):
		return data
	push_warning("Save slot %d is corrupted." % slot)
	return {}

func new_game() -> void:
	_pending = {}
	GameState.reset()
	_change_scene(GAME_SCENE)

func go_to_main_menu() -> void:
	_pending = {}
	_change_scene(MAIN_MENU_SCENE)

func save_game(slot: int) -> bool:
	var scene := get_tree().current_scene
	var nodes := {}
	for node in get_tree().get_nodes_in_group(PERSIST_GROUP):
		if scene.is_ancestor_of(node):
			nodes[str(scene.get_path_to(node))] = node.save_state()
	var data := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"scene": scene.scene_file_path,
		"nodes": nodes,
		"game_state": GameState.save_state(),
	}
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file := FileAccess.open(slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("Could not write save slot %d: %s" % [slot, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true

func load_game(slot: int) -> bool:
	var data := read_slot(slot)
	if data.is_empty():
		return false
	_pending = data
	GameState.load_state(data.get("game_state", {}))
	_change_scene(data["scene"])
	return true

## True while a loaded save is waiting to be applied by the gameplay scene.
func has_pending() -> bool:
	return not _pending.is_empty()

## Applies the state from the last load_game() to the freshly loaded scene.
func restore_pending(scene: Node) -> void:
	if _pending.is_empty():
		return
	var nodes: Dictionary = _pending.get("nodes", {})
	for path in nodes:
		var node := scene.get_node_or_null(NodePath(path))
		if node and node.has_method("load_state"):
			node.load_state(nodes[path])
	_pending = {}

func _change_scene(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
