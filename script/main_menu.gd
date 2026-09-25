extends Control

@onready var logo: TextureRect = $Center/Content/Logo
@onready var main_buttons: VBoxContainer = $Center/Content/MainButtons
@onready var start_button: Button = $Center/Content/MainButtons/StartButton
@onready var options_button: Button = $Center/Content/MainButtons/OptionsButton
@onready var load_button: Button = $Center/Content/MainButtons/LoadButton
@onready var exit_button: Button = $Center/Content/MainButtons/ExitButton
@onready var options_panel: OptionsPanel = $Center/Content/OptionsPanel
@onready var save_slots_panel: SaveSlotsPanel = $Center/Content/SaveSlotsPanel

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_button.pressed.connect(SaveManager.new_game)
	options_button.pressed.connect(_open_options)
	load_button.pressed.connect(_open_load)
	exit_button.pressed.connect(get_tree().quit)
	options_panel.back_pressed.connect(_show_main)
	save_slots_panel.back_pressed.connect(_show_main)
	_show_main()
	_fade_in_logo()
	# Testing aid: "Everhorror.exe -- --new-game" skips the menu.
	if "--new-game" in OS.get_cmdline_user_args():
		SaveManager.new_game.call_deferred()

func _fade_in_logo() -> void:
	logo.modulate.a = 0.0
	create_tween().tween_property(logo, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not main_buttons.visible:
		get_viewport().set_input_as_handled()
		_show_main()

func _show_main() -> void:
	options_panel.hide()
	save_slots_panel.hide()
	main_buttons.show()
	load_button.disabled = not SaveManager.has_any_save()
	start_button.grab_focus()

func _open_options() -> void:
	main_buttons.hide()
	options_panel.open()

func _open_load() -> void:
	main_buttons.hide()
	save_slots_panel.open(SaveSlotsPanel.Mode.LOAD)
