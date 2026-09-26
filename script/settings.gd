extends Node

## Autoload "Settings": player options, persisted to user://settings.cfg.

signal changed

const PATH := "user://settings.cfg"
## Original miner line -> the same line with Silesian flavour (tools/generators/write_gwara.js).
const GWARA_PATH := "res://dialogue/gwara_slaska.json"

var mouse_sensitivity: float = 0.001
## Linear 0..1, applied to the Master bus.
var master_volume: float = 0.8
## Linear 0..1, applied to the Ambience / SFX buses (music-less game: these two cover it).
var ambience_volume: float = 1.0
var sfx_volume: float = 1.0
## 0.6..1.4, applied as the WorldEnvironment adjustment (the game is dark; see world.gd).
var brightness: float = 1.0
var fullscreen: bool = false
## Miners (Mirosław, Bolko) speak with Silesian dialect elements. Off = the original lines
## from the .dialogue files.
var silesian_dialect: bool = true
## Dialogue responses locked only by trust or a missing item are shown greyed out with the
## reason (DIA-2, task_09). On for the demo and playtests.
var show_locked_choices: bool = true

var _gwara: Translation
var _gwara_loaded := false

func _ready() -> void:
	load_settings()
	apply()

func _exit_tree() -> void:
	if _gwara_loaded:
		TranslationServer.remove_translation(_gwara)
		_gwara_loaded = false

func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	_apply_bus("Ambience", ambience_volume)
	_apply_bus("SFX", sfx_volume)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
	_apply_dialect()
	changed.emit()

func _apply_bus(bus_name: String, volume: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		AudioServer.set_bus_volume_db(index, linear_to_db(volume))

## The .dialogue files keep the original lines. The Silesian versions are registered as a
## translation, which Dialogue Manager looks up by line text (context "dialogue").
func _apply_dialect() -> void:
	if _gwara == null:
		_gwara = _load_gwara()
		# The game is Polish only; a fixed locale keeps the lookup independent of the OS language.
		TranslationServer.set_locale("pl")
	if silesian_dialect and not _gwara_loaded:
		TranslationServer.add_translation(_gwara)
	elif not silesian_dialect and _gwara_loaded:
		TranslationServer.remove_translation(_gwara)
	_gwara_loaded = silesian_dialect

func _load_gwara() -> Translation:
	var gwara := Translation.new()
	gwara.locale = "pl"
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(GWARA_PATH))
	if data is Dictionary:
		for original: String in data:
			gwara.add_message(original, data[original], &"dialogue")
	else:
		push_error("Could not read %s" % GWARA_PATH)
	return gwara

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "ambience_volume", ambience_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("video", "brightness", brightness)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("dialogue", "silesian_dialect", silesian_dialect)
	config.set_value("dialogue", "show_locked_choices", show_locked_choices)
	var err := config.save(PATH)
	if err != OK:
		push_error("Could not save settings: %s" % error_string(err))

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
	master_volume = config.get_value("audio", "master_volume", master_volume)
	ambience_volume = config.get_value("audio", "ambience_volume", ambience_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)
	brightness = config.get_value("video", "brightness", brightness)
	fullscreen = config.get_value("video", "fullscreen", fullscreen)
	silesian_dialect = config.get_value("dialogue", "silesian_dialect", silesian_dialect)
	show_locked_choices = config.get_value("dialogue", "show_locked_choices", show_locked_choices)
