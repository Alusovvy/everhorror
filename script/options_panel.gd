extends VBoxContainer
class_name OptionsPanel

## Options screen shared by the main menu and the pause menu.

signal back_pressed

## Slider value 1..20 maps to mouse sensitivity in radians per pixel.
const SENSITIVITY_SCALE := 0.0002

@onready var sensitivity_slider: HSlider = $Grid/SensitivitySlider
@onready var brightness_slider: HSlider = $Grid/BrightnessSlider
@onready var volume_slider: HSlider = $Grid/VolumeSlider
@onready var ambience_slider: HSlider = $Grid/AmbienceSlider
@onready var sfx_slider: HSlider = $Grid/SfxSlider
@onready var fullscreen_toggle: CheckButton = $Grid/FullscreenToggle
@onready var dialect_toggle: CheckButton = $Grid/DialectToggle
@onready var back_button: Button = $BackButton

func _ready() -> void:
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	volume_slider.value_changed.connect(_on_volume_changed)
	ambience_slider.value_changed.connect(_on_ambience_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	dialect_toggle.toggled.connect(_on_dialect_toggled)
	back_button.pressed.connect(_on_back)

func open() -> void:
	sensitivity_slider.set_value_no_signal(Settings.mouse_sensitivity / SENSITIVITY_SCALE)
	brightness_slider.set_value_no_signal(Settings.brightness)
	volume_slider.set_value_no_signal(Settings.master_volume)
	ambience_slider.set_value_no_signal(Settings.ambience_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	fullscreen_toggle.set_pressed_no_signal(Settings.fullscreen)
	dialect_toggle.set_pressed_no_signal(Settings.silesian_dialect)
	show()
	sensitivity_slider.grab_focus()

func _on_sensitivity_changed(value: float) -> void:
	Settings.mouse_sensitivity = value * SENSITIVITY_SCALE
	Settings.apply()

func _on_brightness_changed(value: float) -> void:
	Settings.brightness = value
	Settings.apply()

func _on_volume_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.apply()

func _on_ambience_changed(value: float) -> void:
	Settings.ambience_volume = value
	Settings.apply()

func _on_sfx_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.apply()

func _on_fullscreen_toggled(on: bool) -> void:
	Settings.fullscreen = on
	Settings.apply()

func _on_dialect_toggled(on: bool) -> void:
	Settings.silesian_dialect = on
	Settings.apply()

func _on_back() -> void:
	Settings.save_settings()
	back_pressed.emit()
