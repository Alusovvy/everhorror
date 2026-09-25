extends Node

## Autoload "Settings": player options, persisted to user://settings.cfg.

signal changed

const PATH := "user://settings.cfg"

var mouse_sensitivity: float = 0.001
## Linear 0..1, applied to the Master bus.
var master_volume: float = 0.8
var fullscreen: bool = false

func _ready() -> void:
	load_settings()
	apply()

func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
	changed.emit()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("video", "fullscreen", fullscreen)
	var err := config.save(PATH)
	if err != OK:
		push_error("Could not save settings: %s" % error_string(err))

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) != OK:
		return
	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)
	master_volume = config.get_value("audio", "master_volume", master_volume)
	fullscreen = config.get_value("video", "fullscreen", fullscreen)
