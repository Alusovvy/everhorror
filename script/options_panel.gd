extends VBoxContainer
class_name OptionsPanel

## Options screen shared by the main menu and the pause menu.

signal back_pressed

## Slider value 1..20 maps to mouse sensitivity in radians per pixel.
const SENSITIVITY_SCALE := 0.0002

@onready var sensitivity_slider: HSlider = $Grid/SensitivitySlider
@onready var volume_slider: HSlider = $Grid/VolumeSlider
@onready var fullscreen_toggle: CheckButton = $Grid/FullscreenToggle
@onready var back_button: Button = $BackButton

func _ready() -> void:
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back)

func open() -> void:
	sensitivity_slider.set_value_no_signal(Settings.mouse_sensitivity / SENSITIVITY_SCALE)
	volume_slider.set_value_no_signal(Settings.master_volume)
	fullscreen_toggle.set_pressed_no_signal(Settings.fullscreen)
	show()
	sensitivity_slider.grab_focus()

func _on_sensitivity_changed(value: float) -> void:
	Settings.mouse_sensitivity = value * SENSITIVITY_SCALE
	Settings.apply()

func _on_volume_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.apply()

func _on_fullscreen_toggled(on: bool) -> void:
	Settings.fullscreen = on
	Settings.apply()

func _on_back() -> void:
	Settings.save_settings()
	back_pressed.emit()
