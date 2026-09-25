extends CanvasLayer
class_name MapScreen

## The map table: choose where the next expedition goes. Travel costs time (GDD: "Podróż do
## pomieszczenia do eksploracji przesuwa czas"), the way back costs the same. The world scene
## performs the actual travel (StoryDirector).

signal destination_chosen(destination_id: String)

## "requires": all must hold ("flag:<name>" or "item:<id>"); "locked" gives the reason shown
## for the first one that doesn't. "unknown_name" is shown until the place is unlocked.
const DESTINATIONS: Array[Dictionary] = [
	{
		"id": "east", "name": "Stara sztolnia", "direction": "wschód", "hours": 2.0, "entry": "EastEntry",
		"text": "Sztolnia po starej ekipie. Pochylnia prowadzi w dół, do jaskini. Mirosław wspominał, że był tam skład.",
	},
	{
		"id": "west", "name": "Zawalony chodnik", "direction": "zachód", "hours": 2.0, "entry": "WestEntry",
		"requires": ["flag:west_blasted"],
		"locked": {"flag:west_blasted": "Zasypane. Bez prochu się nie przebijesz, może Mirosław coś poradzi."},
		"text": "Ulubiona droga dziadka. Na jego mapach zaznaczona podwójną kreską.",
	},
	{
		"id": "rzapie", "name": "Rząpie starego szybu", "direction": "północ", "hours": 2.0, "entry": "RzapieEntry",
		"text": "Dno starego szybu. Tędy spuszczano zapasy, zanim na dole zebrała się woda.",
	},
	{
		"id": "upadowa", "name": "Upadowa", "direction": "zachód, w dół", "hours": 3.0, "entry": "UpadowaEntry",
		"requires": ["flag:west_blasted", "item:lina"],
		"locked": {
			"flag:west_blasted": "Upadowa zaczyna się dopiero za zawałem w zachodnim chodniku.",
			"item:lina": "Za połamanymi stemplami chodnik stromo opada w ciemność. Bez liny nie zejdziesz.",
		},
		"text": "Stromy chodnik za połamanymi stemplami. Na mapie dziadka trzy grube kreski i nic więcej.",
	},
	{
		"id": "kaplica", "name": "Kaplica", "unknown_name": "Znak zapytania", "direction": "wschód, w dół", "hours": 3.0, "entry": "KaplicaEntry",
		"requires": ["flag:kaplica_known"],
		"locked": {"flag:kaplica_known": "Na mapie dziadka pod jaskinią jest tylko znak zapytania. Nie wiesz, czego tam szukać."},
		"text": "Znak zapytania z mapy dziadka, pod jaskinią. W dół prowadzi wąskie przejście z wykutymi stopniami.",
	},
]

@onready var clock_label: Label = $Root/Center/Panel/Margin/VBox/Clock
@onready var list: VBoxContainer = $Root/Center/Panel/Margin/VBox/HBox/Destinations
@onready var drawing: Control = $Root/Center/Panel/Margin/VBox/HBox/Drawing
@onready var close_button: Button = $Root/Center/Panel/Margin/VBox/CloseButton

static func destination(destination_id: String) -> Dictionary:
	for d in DESTINATIONS:
		if d["id"] == destination_id:
			return d
	return {}

## Empty when the place can be visited, otherwise why not.
static func locked_reason(destination_data: Dictionary) -> String:
	for requirement: String in destination_data.get("requires", []):
		var kind := requirement.get_slice(":", 0)
		var value := requirement.get_slice(":", 1)
		var ok := GameState.has_flag(value) if kind == "flag" else GameState.has_item(value)
		if not ok:
			return destination_data["locked"].get(requirement, "Jeszcze nie.")
	return ""

static func display_name(destination_data: Dictionary) -> String:
	if destination_data.has("unknown_name") and locked_reason(destination_data) != "":
		return destination_data["unknown_name"]
	return destination_data["name"]

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
	for d in DESTINATIONS:
		var reason := locked_reason(d)
		var affordable := GameState.can_afford(d["hours"])
		var button := Button.new()
		var visited := "  · byłeś tu" if GameState.has_flag("visited_%s" % d["id"]) else ""
		button.text = "%s (%s) · %d h%s" % [display_name(d), d["direction"], int(d["hours"]), visited]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = reason != "" or not affordable
		button.pressed.connect(_choose.bind(d["id"]))
		list.add_child(button)
		var info := Label.new()
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.custom_minimum_size = Vector2(340, 0)
		info.add_theme_font_size_override(&"font_size", 14)
		info.add_theme_color_override(&"font_color", Color(0.78, 0.72, 0.62))
		if reason != "":
			info.text = reason
		elif not affordable:
			info.text = "Na tę wyprawę już za późno. Wróć jutro."
		else:
			info.text = d["text"]
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
