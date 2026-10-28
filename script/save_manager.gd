extends Node

## Autoload "SaveManager": save slots as JSON in user://saves.
##
## Any node in the "persist" group that implements save_state() -> Dictionary
## and load_state(data: Dictionary) is saved, keyed by its path from the scene
## root. Gameplay scenes call restore_pending(self) in _ready to apply a load.
## GameState (day, time, flags, NPCs…) is saved too and restored before the scene loads,
## so every node can read the loaded state in its own _ready.
## Besides the slots there is a "morning" snapshot, taken at the start of each day:
## after the hero dies the player can try the day again (MECHANICS §13 pkt 3). The same
## snapshot also goes to disk as the AUTO slot (slot 0), so a crash or quitting the game
## loses at most the current day. Manual saves never overwrite it.
## Version 3 (task_05) added the hero's health and the expedition; older saves still load.

const GAME_SCENE := "res://scene/world.tscn"
const MAIN_MENU_SCENE := "res://scene/main_menu.tscn"
const DEFAULT_SAVE_DIR := "user://saves"
const DEFAULT_REPORT_DIR := "user://raporty"
## Test isolation (tools only, the game never sets it): a folder given by this environment
## variable or by the user arg `--test-dir=<path>` holds the saves (`saves/`) and the run reports
## (`raporty/`) instead of the player's folders. Test scripts without one use
## `user://test-runs/<pid>` (isolate_for_tests()).
const TEST_DIR_ENV := "EVERHORROR_TEST_DIR"
const TEST_DIR_ARG := "--test-dir="
const SLOT_COUNT := 3
## The dawn autosave, load-only in the UI.
const AUTO_SLOT := 0
## 4: the time log (task_09). Older saves load with an empty log.
## 5: options already asked (task_11) and the hero's fatigue (task_12). Older saves: none asked,
## rested.
## 6: the dawn log and the vein log for the run report (task_14, ZAP-12). Older saves load with
## empty logs; the report then says "brak danych" for the days before.
const SAVE_VERSION := 6
const PERSIST_GROUP := "persist"

var save_dir := DEFAULT_SAVE_DIR
var report_dir := DEFAULT_REPORT_DIR
## The isolated folder in use ("" = the player's folders).
var test_dir := ""
var _test_dir_owned := false
var _pending: Dictionary = {}
var _morning: Dictionary = {}

func _init() -> void:
	var folder := OS.get_environment(TEST_DIR_ENV)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(TEST_DIR_ARG):
			folder = arg.trim_prefix(TEST_DIR_ARG)
	if folder != "":
		use_test_dir(folder)

## Points saves and run reports at `folder` (`saves/` and `raporty/` inside it).
func use_test_dir(folder: String) -> void:
	test_dir = folder.replace("\\", "/").trim_suffix("/")
	save_dir = test_dir + "/saves"
	report_dir = test_dir + "/raporty"

## For test scripts: when no folder was given, use a fresh `user://test-runs/<pid>` of this process
## (removed by remove_test_dir()). Returns the folder in use.
func isolate_for_tests() -> String:
	if test_dir == "":
		use_test_dir("user://test-runs/%d" % OS.get_process_id())
		_test_dir_owned = true
	return test_dir

## Deletes the folder isolate_for_tests() made (a folder given from outside belongs to whoever
## gave it) and goes back to the player's folders.
func remove_test_dir() -> void:
	if not _test_dir_owned:
		return
	_remove_recursive(test_dir)
	_test_dir_owned = false
	test_dir = ""
	save_dir = DEFAULT_SAVE_DIR
	report_dir = DEFAULT_REPORT_DIR

func _remove_recursive(folder: String) -> void:
	if not DirAccess.dir_exists_absolute(folder):
		return
	for sub in DirAccess.get_directories_at(folder):
		_remove_recursive(folder + "/" + sub)
	for file in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute(folder + "/" + file)
	DirAccess.remove_absolute(folder)

func slot_path(slot: int) -> String:
	if slot == AUTO_SLOT:
		return "%s/auto.json" % save_dir
	return "%s/slot_%d.json" % [save_dir, slot]

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))

func has_any_save() -> bool:
	for slot in range(0, SLOT_COUNT + 1):
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

## task_37 (OTW-1): a new game is the three-day opening; `full_week` starts the old week instead
## (the second menu entry, the balance bot's week and most world scenarios).
func new_game(full_week := false) -> void:
	_pending = {}
	_morning = {}
	GameState.reset()
	if not full_week:
		GameState.set_flag("opening")
	_change_scene(GAME_SCENE)

func go_to_main_menu() -> void:
	_pending = {}
	_change_scene(MAIN_MENU_SCENE)

func save_game(slot: int) -> bool:
	return _write(slot, _collect())

func _write(slot: int, data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(save_dir)
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

## Remembers the current state as this morning's (the StoryDirector calls it at dawn)
## and autosaves it to disk (the AUTO slot).
func capture_morning() -> void:
	if get_tree().current_scene:
		_morning = _collect()
		_write(AUTO_SLOT, _morning)

func has_morning() -> bool:
	return not _morning.is_empty()

## Starts the day again from this morning's snapshot.
func retry_morning() -> void:
	if _morning.is_empty():
		go_to_main_menu()
		return
	_pending = _morning.duplicate(true)
	GameState.load_state(_pending.get("game_state", {}))
	_change_scene(_pending["scene"])

func _collect() -> Dictionary:
	var scene := get_tree().current_scene
	var nodes := {}
	for node in get_tree().get_nodes_in_group(PERSIST_GROUP):
		if scene.is_ancestor_of(node):
			nodes[str(scene.get_path_to(node))] = node.save_state()
	return {
		"version": SAVE_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"scene": scene.scene_file_path,
		"nodes": nodes,
		"game_state": GameState.save_state(),
	}

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
