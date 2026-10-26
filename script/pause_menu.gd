extends CanvasLayer

## In-game menu on Escape. Pauses the tree while open (this node processes always).

@onready var root: Control = $Root
@onready var main_buttons: VBoxContainer = $Root/Center/Content/MainButtons
@onready var resume_button: Button = $Root/Center/Content/MainButtons/ResumeButton
@onready var save_button: Button = $Root/Center/Content/MainButtons/SaveButton
@onready var load_button: Button = $Root/Center/Content/MainButtons/LoadButton
@onready var options_button: Button = $Root/Center/Content/MainButtons/OptionsButton
@onready var report_button: Button = $Root/Center/Content/MainButtons/ReportButton
@onready var main_menu_button: Button = $Root/Center/Content/MainButtons/MainMenuButton
@onready var exit_button: Button = $Root/Center/Content/MainButtons/ExitButton
@onready var report_status: Label = $Root/ReportStatus
@onready var options_panel: OptionsPanel = $Root/Center/Content/OptionsPanel
@onready var save_slots_panel: SaveSlotsPanel = $Root/Center/Content/SaveSlotsPanel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(close)
	save_button.pressed.connect(_open_slots.bind(SaveSlotsPanel.Mode.SAVE))
	load_button.pressed.connect(_open_slots.bind(SaveSlotsPanel.Mode.LOAD))
	options_button.pressed.connect(_open_options)
	report_button.pressed.connect(_save_report)
	main_menu_button.pressed.connect(SaveManager.go_to_main_menu)
	exit_button.pressed.connect(get_tree().quit)
	options_panel.back_pressed.connect(_show_main)
	save_slots_panel.back_pressed.connect(_show_main)
	root.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if not root.visible and GameState.is_modal():
		return
	get_viewport().set_input_as_handled()
	if not root.visible:
		open()
	elif not main_buttons.visible:
		_show_main()
	else:
		close()

func open() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	root.show()
	_show_main()

func close() -> void:
	root.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _show_main() -> void:
	options_panel.hide()
	save_slots_panel.hide()
	main_buttons.show()
	report_status.hide()
	load_button.disabled = not SaveManager.has_any_save()
	resume_button.grab_focus()

func _open_options() -> void:
	main_buttons.hide()
	report_status.hide()
	options_panel.open()

func _open_slots(mode: SaveSlotsPanel.Mode) -> void:
	main_buttons.hide()
	report_status.hide()
	save_slots_panel.open(mode)

## UI-7 / ZAP-11: writes the run report now ("w trakcie") and shows where it went. The HUD toasts
## are not visible while the game is paused, so the menu says it itself, in English like the
## rest of the menu. The text sits to the right of the buttons (the button column already fills
## most of the screen's height, so a line under it would run off the screen).
func _save_report() -> void:
	var path := RunReport.write(RunReport.ENDING_IN_PROGRESS)
	if path == "":
		report_status.text = "Could not save the report."
	else:
		# A zero-width space after each backslash lets a long path wrap between folders, not in
		# the middle of a name.
		report_status.text = "Report saved:\n%s" % RunReport.display_path(path).replace("\\", "\\​")
	report_status.show()
