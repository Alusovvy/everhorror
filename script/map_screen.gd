extends CanvasLayer
class_name MapScreen

## The map table: choose where the next expedition goes. Travel costs time (GDD: "Podróż do
## pomieszczenia do eksploracji przesuwa czas"). The world scene performs the actual travel.

signal destination_chosen(destination_id: String)

const DESTINATIONS: Array[Dictionary] = [
	{
		"id": "east", "name": "Stara sztolnia", "direction": "wschód", "hours": 2.0,
		"text": "Sztolnia po starej ekipie. Pochylnia prowadzi w dół, do jaskini. Mirosław wspominał, że był tam skład.",
	},
	{
		"id": "west", "name": "Zawalony chodnik", "direction": "zachód", "hours": 2.0, "requires": "west_blasted",
		"text": "Ulubiona droga dziadka. Na jego mapach zaznaczona podwójną kreską.",
		"locked": "Zasypane. Bez prochu się nie przebijesz, może Mirosław coś poradzi.",
	},
]

@onready var clock_label: Label = $Root/Center/Panel/Margin/VBox/Clock
@onready var list: VBoxContainer = $Root/Center/Panel/Margin/VBox/HBox/Destinations
@onready var drawing: Control = $Root/Center/Panel/Margin/VBox/HBox/Drawing
@onready var close_button: Button = $Root/Center/Panel/Margin/VBox/CloseButton

func _ready() -> void:
	hide()
	close_button.pressed.connect(close)

func open() -> void:
	if visible:
		return
	GameState.push_modal()
	clock_label.text = "%s   ·   do wieczora: %s" % [GameState.clock_text(), GameState.hours_left_text()]
	_build()
	drawing.queue_redraw()
	show()

func close() -> void:
	if not visible:
		return
	hide()
	GameState.pop_modal()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()

func _build() -> void:
	for child in list.get_children():
		child.queue_free()
	var first_enabled: Button = null
	for destination in DESTINATIONS:
		var locked: bool = destination.has("requires") and not GameState.has_flag(destination["requires"])
		var affordable := GameState.can_afford(destination["hours"])
		var button := Button.new()
		button.text = "%s (%s) · %d h" % [destination["name"], destination["direction"], int(destination["hours"])]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = locked or not affordable
		button.pressed.connect(_choose.bind(destination["id"]))
		list.add_child(button)
		var info := Label.new()
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.custom_minimum_size = Vector2(340, 0)
		info.add_theme_font_size_override(&"font_size", 15)
		info.add_theme_color_override(&"font_color", Color(0.78, 0.72, 0.62))
		if locked:
			info.text = destination["locked"]
		elif not affordable:
			info.text = "Na wyprawę już za późno. Wróć jutro."
		else:
			info.text = destination["text"]
		list.add_child(info)
		if not button.disabled and first_enabled == null:
			first_enabled = button
	if first_enabled:
		first_enabled.grab_focus()
	else:
		close_button.grab_focus()

func _choose(destination_id: String) -> void:
	close()
	destination_chosen.emit(destination_id)
