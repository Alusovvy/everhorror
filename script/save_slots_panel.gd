extends VBoxContainer
class_name SaveSlotsPanel

## Save-slot list shared by the main menu (load) and the pause menu (save / load).

signal back_pressed

enum Mode { SAVE, LOAD }

@onready var title: Label = $Title
@onready var slot_list: VBoxContainer = $Slots
@onready var status: Label = $Status
@onready var back_button: Button = $BackButton

var mode: Mode = Mode.LOAD

func _ready() -> void:
	back_button.pressed.connect(func() -> void: back_pressed.emit())

func open(new_mode: Mode) -> void:
	mode = new_mode
	title.text = "SAVE GAME" if mode == Mode.SAVE else "LOAD GAME"
	status.text = ""
	_rebuild()
	show()
	for child in slot_list.get_children():
		var button := child as Button
		if button and not button.disabled:
			button.grab_focus()
			return
	back_button.grab_focus()

func _rebuild() -> void:
	for child in slot_list.get_children():
		slot_list.remove_child(child)
		child.queue_free()
	# The dawn autosave is load-only; manual saves cannot touch it.
	if mode == Mode.LOAD:
		var auto := SaveManager.read_slot(SaveManager.AUTO_SLOT)
		var auto_button := Button.new()
		auto_button.text = "AUTO     —   %s" % _describe(auto)
		auto_button.disabled = auto.is_empty()
		auto_button.pressed.connect(_on_slot_pressed.bind(SaveManager.AUTO_SLOT))
		slot_list.add_child(auto_button)
	for slot in range(1, SaveManager.SLOT_COUNT + 1):
		var data := SaveManager.read_slot(slot)
		var button := Button.new()
		button.text = "SLOT %d   —   %s" % [slot, _describe(data)]
		button.disabled = mode == Mode.LOAD and data.is_empty()
		button.pressed.connect(_on_slot_pressed.bind(slot))
		slot_list.add_child(button)

func _describe(data: Dictionary) -> String:
	if data.is_empty():
		return "empty"
	var local_offset: int = Time.get_time_zone_from_system()["bias"] * 60
	var when := Time.get_datetime_string_from_unix_time(int(data.get("saved_at", 0)) + local_offset, true)
	var game: Dictionary = data.get("game_state", {})
	if game.is_empty():
		return when.substr(0, 16)
	var hour := float(game.get("hour", 6.0))
	return "Dzień %d · %02d:%02d   (%s)" % [int(game.get("day", 1)), int(hour), int(round(fmod(hour, 1.0) * 60.0)) % 60, when.substr(0, 16)]

func _on_slot_pressed(slot: int) -> void:
	if mode == Mode.LOAD:
		if not SaveManager.load_game(slot):
			status.text = "Could not load slot %d." % slot
		return
	if SaveManager.save_game(slot):
		status.text = "Saved to slot %d." % slot
		_rebuild()
		(slot_list.get_child(slot - 1) as Button).grab_focus()
	else:
		status.text = "Could not save to slot %d." % slot
