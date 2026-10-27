extends CanvasLayer
class_name MapScreen

## Grandfather's map (spec 03_mechaniki/wyprawy.md, WYP-3, WYP-5), in two modes:
## - at the map table in the camp: every known place, the way there and back, the veins found
##   against the Kniaź's quota, and "WYRUSZ" to set off;
## - in the field [M] (or at a signpost): the neighbouring places ("IDŹ DALEJ") or the way back
##   to the camp ("WRACAJ DO OBOZU").
## Travel costs time (GDD: "Podróż do pomieszczenia do eksploracji przesuwa czas"); the world
## scene does the travelling (StoryDirector).

signal destination_chosen(place_id: StringName)

enum Mode { TABLE, FIELD }

@export var destination_group: ButtonGroup

@onready var title: Label = $Root/Center/Panel/Margin/VBox/TitleRow/Title
@onready var clock_label: Label = $Root/Center/Panel/Margin/VBox/TitleRow/Clock
@onready var quota_label: Label = $Root/Center/Panel/Margin/VBox/Quota
@onready var drawing: Control = $Root/Center/Panel/Margin/VBox/HBox/Drawing
@onready var list_title: Label = $Root/Center/Panel/Margin/VBox/HBox/Side/ListTitle
@onready var list: VBoxContainer = $Root/Center/Panel/Margin/VBox/HBox/Side/Scroll/Destinations
@onready var details: RichTextLabel = $Root/Center/Panel/Margin/VBox/HBox/Side/Details
@onready var go_button: Button = $Root/Center/Panel/Margin/VBox/HBox/Side/GoButton
@onready var hint: Label = $Root/Center/Panel/Margin/VBox/Footer/Hint
@onready var close_button: Button = $Root/Center/Panel/Margin/VBox/Footer/CloseButton

var mode := Mode.TABLE
## Where the trip starts: the camp at the table, the current place in the field.
var origin: StringName = Expeditions.CAMP
var selected: StringName = &""

func _ready() -> void:
	hide()
	close_button.pressed.connect(close)
	go_button.pressed.connect(_go)

## At the map table in the camp.
func open_table() -> void:
	_open(Mode.TABLE, Expeditions.CAMP)

## In the field: [M] or a signpost.
func open_field() -> void:
	_open(Mode.FIELD, GameState.current_place())

func _open(new_mode: Mode, from: StringName) -> void:
	if visible:
		return
	mode = new_mode
	origin = from
	GameState.push_modal()
	title.text = "Mapa dziadka" if mode == Mode.TABLE else "Dokąd dalej?"
	list_title.text = "Dokąd wyruszyć:" if mode == Mode.TABLE else "Jesteś tu: %s" % Expeditions.display_name(origin)
	close_button.text = "ZAMKNIJ  [Esc]" if mode == Mode.TABLE else "ZOSTAŃ TUTAJ  [Esc]"
	hint.text = "Wybierz miejsce, przeczytaj opis i wyrusz." if mode == Mode.TABLE else "[M] / [Esc] zostań i szukaj dalej"
	clock_label.text = "%s   ·   do wieczora: %s" % [GameState.clock_text(), GameState.hours_left_text()]
	quota_label.text = GameState.quota_text()
	_build()
	show()

func close() -> void:
	if not visible:
		return
	hide()
	GameState.pop_modal()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"field_map"):
		get_viewport().set_input_as_handled()
		if visible:
			if mode == Mode.FIELD:
				close()
		elif not GameState.is_modal() and not get_tree().paused:
			if GameState.is_away():
				open_field()
			else:
				GameState.message.emit("Wyprawy planujesz przy stole z mapą, w zagrodzie Racibora. [M] działa w chodnikach.")
	elif visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()

## Places listed in this mode, nearest first (in the field the camp comes first).
func _choices() -> Array[StringName]:
	var result: Array[StringName] = []
	if mode == Mode.TABLE:
		result = Expeditions.known_places()
	else:
		result.append(Expeditions.CAMP)
		for id in Expeditions.neighbours(origin):
			if id != Expeditions.CAMP:
				result.append(id)
	var hours := {}
	for id in result:
		hours[id] = Expeditions.walk_hours(Expeditions.path(origin, id))
	var camp_first := func(a: StringName, b: StringName) -> bool:
		if a == Expeditions.CAMP or b == Expeditions.CAMP:
			return a == Expeditions.CAMP
		if not is_equal_approx(hours[a], hours[b]):
			return hours[a] < hours[b]
		return String(a) < String(b)
	result.sort_custom(camp_first)
	return result

func _build() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var first_open: StringName = &""
	var first_any: StringName = &""
	for id in _choices():
		var route := Expeditions.path(origin, id)
		var button := Button.new()
		button.toggle_mode = true
		button.button_group = destination_group
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = _button_text(id, route)
		button.set_meta(&"place", id)
		var blocked := _blocked_reason(id, route) != ""
		if blocked:
			button.add_theme_color_override(&"font_color", Color(0.55, 0.5, 0.45))
		button.pressed.connect(_select.bind(id))
		button.focus_entered.connect(_select.bind(id))
		list.add_child(button)
		if first_any == &"":
			first_any = id
		if not blocked and first_open == &"":
			first_open = id
	var pick := first_open if first_open != &"" else first_any
	if selected != &"" and _choices().has(selected) and mode == Mode.TABLE:
		pick = selected
	if pick != &"":
		_select(pick)
		for button in list.get_children():
			if button.get_meta(&"place") == pick:
				button.button_pressed = true
				button.grab_focus.call_deferred()
	else:
		selected = &""
		details.text = "[i]Nie znasz jeszcze żadnej drogi.[/i]"
		go_button.disabled = true
	drawing.set("origin", origin)
	drawing.set("field_mode", mode == Mode.FIELD)
	drawing.queue_redraw()

## "1 h 15 min" (the way back is often not a whole hour).
static func _duration(hours: float) -> String:
	return GameState.duration_text(int(round(hours * 60.0)))

func _button_text(id: StringName, route: Array[StringName]) -> String:
	if id == Expeditions.CAMP:
		return "Obóz  ·  %s drogi" % _duration(Expeditions.return_hours())
	var text := "%s  ·  %s" % [Expeditions.display_name(id), GameState.hours_text(Expeditions.trip_hours(route))]
	if GameState.is_exhausted():
		text += "  ·  zmęczenie ×2"
	if not Expeditions.is_visited(id):
		text += "  ·  nowe"
	elif Expeditions.veins_marked(id) < Expeditions.veins_total(id):
		text += "  ·  żyły %d/%d" % [Expeditions.veins_marked(id), Expeditions.veins_total(id)]
	return text

## Why the trip can't start ("" = it can). Going back to the camp is always possible.
func _blocked_reason(id: StringName, route: Array[StringName]) -> String:
	if id == Expeditions.CAMP:
		return ""
	var lock := Expeditions.route_lock(route)
	if lock != "":
		return lock
	if not GameState.can_afford(Expeditions.trip_hours(route)):
		return "Na to już za późno. Nie zdążysz przed nocą." if mode == Mode.FIELD else "Na tę wyprawę już za późno. Wróć jutro."
	return ""

func _select(id: StringName) -> void:
	selected = id
	var route := Expeditions.path(origin, id)
	var reason := _blocked_reason(id, route)
	details.text = _details_text(id, route, reason)
	go_button.disabled = reason != ""
	if id == Expeditions.CAMP:
		go_button.text = "WRACAJ DO OBOZU"
	else:
		go_button.text = "WYRUSZ" if mode == Mode.TABLE else "IDŹ DALEJ"
	drawing.set("selected", id)
	drawing.set("route", route)
	drawing.queue_redraw()

func _details_text(id: StringName, route: Array[StringName], reason: String) -> String:
	var walk := Expeditions.walk_hours(route)
	var arrive := GameState.hour + Expeditions.trip_hours(route)
	if id == Expeditions.CAMP:
		# task_12: half of the way walked since leaving the camp, never doubled by fatigue.
		var home := Expeditions.return_hours()
		var back := "[b]Powrót do obozu[/b]\nDroga: %s (znaną drogą idzie się szybciej: połowa tego, co przeszedłeś od obozu), w obozie będziesz ok. %s." % [_duration(home), GameState.time_text(GameState.hour + home)]
		if GameState.hour + home > GameState.DAY_START_HOUR + GameState.DAY_LENGTH_HOURS:
			back += "\n[color=#ff8a66]Wrócisz po nocy, ledwo żywy ze zmęczenia.[/color]"
		return back
	var data := Expeditions.place(id)
	var text := "[b]%s[/b]  [color=#8a7f70](%s)[/color]\n" % [Expeditions.display_name(id), data.direction]
	var way := "Droga: %s" % GameState.hours_text(walk)
	if not Expeditions.is_visited(id):
		way += " + %s na rozpoznanie" % GameState.hours_text(Expeditions.SCOUTING_HOURS)
	if GameState.is_exhausted():
		way += " (padasz z nóg: każdy odcinek idziesz dwa razy dłużej)"
	if GameState.is_badly_hurt():
		way += " (z ranami idziesz wolniej)"
	text += "%s, na miejscu ok. %s.\n" % [way, GameState.time_text(arrive)]
	if route.size() > 2:
		var through: Array[String] = []
		for i in range(1, route.size() - 1):
			through.append(Expeditions.display_name(route[i]))
		text += "[color=#8a7f70]Przez: %s.[/color]\n" % ", ".join(through)
	text += "[color=#9ec3ff]%s[/color]\n\n" % _sentence(Expeditions.veins_text(id))
	# An unknown place ("Znak zapytania") keeps its description secret until it is unlocked.
	if Expeditions.own_lock(id) == "" or data.unknown_name == "":
		text += data.text
	if reason != "":
		text += "\n\n[color=#ff8a66]%s[/color]" % reason
	return text

func _sentence(line: String) -> String:
	return line.left(1).to_upper() + line.substr(1) + "."

func _go() -> void:
	if selected == &"" or go_button.disabled:
		return
	var target := selected
	close()
	destination_chosen.emit(target)
