extends CanvasLayer
class_name InventoryScreen

## The hero's pack [I] (docs_v2/systemy/ekwipunek.md): what he carries, what each thing is for,
## "UŻYJ" for medicine, drink and candles, and how he is doing. Health and sanity are told in
## words, never numbers (MECHANICS §13 pkt 4). Giving things to people happens in dialogues.

const HEALTH_LINES := {
	"zdrowy": "Cały i zdrowy.",
	"poobijany": "Poobijany: siniaki, zadrapania, nic, co by cię zatrzymało.",
	"ranny": "Ranny. Rany pieką przy każdym kroku, droga zajmuje ci więcej czasu.",
	"ciezko_ranny": "Ciężko ranny. Ledwo trzymasz się na nogach. Jeszcze jedna rana może cię zabić.",
	"martwy": "",
}
const MIND_LINES := {
	"spokojny": "W głowie spokój, na ile to możliwe pod ziemią.",
	"niespokojny": "Niespokojny. Kątem oka widzisz ruch tam, gdzie nic się nie rusza.",
	"na_krawedzi": "Na krawędzi. Słyszysz szepty i nie zawsze wiesz, czy to twoje myśli.",
	"zalamany": "Załamany.",
}
## task_12: fatigue in words (no numbers, NPC-13).
const FATIGUE_LINES := {
	"wypoczety": "",
	"zmeczony": "Jesteś zmęczony. Jeszcze trochę chodzenia po chodnikach i zaczniesz padać z nóg.",
	"ledwo_idzie": "Ledwo idziesz. Pora odpocząć: przy ognisku albo na posłaniu.",
	"wyczerpany": "Padasz z nóg. Każda droga w głąb zajmie ci dwa razy dłużej (powrót do obozu nie).",
}
const CATEGORY_ORDER := [ItemData.Category.MEDICINE, ItemData.Category.TOOL, ItemData.Category.SUPPLY, ItemData.Category.QUEST, ItemData.Category.VALUABLE]

@onready var header: Label = $Root/Center/Panel/Margin/VBox/Header
@onready var status: RichTextLabel = $Root/Center/Panel/Margin/VBox/Status
@onready var list: ItemList = $Root/Center/Panel/Margin/VBox/HBox/List
@onready var title: Label = $Root/Center/Panel/Margin/VBox/HBox/Detail/Title
@onready var kind: Label = $Root/Center/Panel/Margin/VBox/HBox/Detail/Kind
@onready var text: RichTextLabel = $Root/Center/Panel/Margin/VBox/HBox/Detail/Text
@onready var use_button: Button = $Root/Center/Panel/Margin/VBox/HBox/Detail/UseButton
@onready var use_hint: Label = $Root/Center/Panel/Margin/VBox/HBox/Detail/UseHint

func _ready() -> void:
	hide()
	list.item_selected.connect(_show_item)
	use_button.pressed.connect(_use_selected)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"inventory"):
		get_viewport().set_input_as_handled()
		if visible:
			close()
		elif not GameState.is_modal() and not get_tree().paused:
			open()
	elif visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()

func open() -> void:
	GameState.push_modal()
	_refresh()
	show()
	list.grab_focus()

func close() -> void:
	if not visible:
		return
	hide()
	GameState.pop_modal()

func _refresh(select_id: String = "") -> void:
	header.text = "Ekwipunek   ·   %s" % GameState.clock_text()
	status.text = _status_text()
	list.clear()
	for item_id in _sorted_items():
		var count := GameState.item_count(item_id)
		list.add_item("%s%s" % [GameState.item_name(item_id), "  ×%d" % count if count > 1 else ""])
		list.set_item_metadata(list.item_count - 1, item_id)
	if list.item_count == 0:
		title.text = "Pusto"
		kind.text = ""
		text.text = "[i]Masz przy sobie tylko lampę i nóż.[/i]"
		use_button.hide()
		use_hint.text = ""
		return
	var index := 0
	for i in list.item_count:
		if list.get_item_metadata(i) == select_id:
			index = i
	list.select(index)
	_show_item(index)

func _sorted_items() -> Array[String]:
	var result: Array[String] = []
	for category in CATEGORY_ORDER:
		for item_id in GameState.items:
			var data := GameState.item_data(item_id)
			var item_category: int = data.category if data else ItemData.Category.QUEST
			if item_category == category:
				result.append(item_id)
	return result

func _status_text() -> String:
	var lines := "[color=#ffb861]Ty:[/color] %s %s" % [HEALTH_LINES[GameState.health_band()], MIND_LINES[GameState.mind_band()]]
	if GameState.player_fever:
		lines += " [color=#ff8a66]Masz gorączkę.[/color]"
	var tired: String = FATIGUE_LINES[GameState.fatigue_band()]
	if tired != "":
		lines += " [color=#ffb861]%s[/color]" % tired
	lines += "\n[color=#8a7f70]%s[/color]" % GameState.quota_text()
	return lines

func _show_item(index: int) -> void:
	var item_id: String = list.get_item_metadata(index)
	var data := GameState.item_data(item_id)
	if data == null:
		title.text = item_id
		kind.text = ""
		text.text = ""
		use_button.hide()
		return
	title.text = data.display_name
	kind.text = data.category_name()
	text.text = data.description + _effects_line(data)
	use_button.visible = data.is_usable()
	var blocker := GameState.item_use_blocker(item_id)
	use_button.disabled = blocker != ""
	if not data.is_usable():
		use_hint.text = ""
	elif blocker != "":
		use_hint.text = blocker
	elif data.use_hours > 0.0:
		use_hint.text = "Zajmie ci to %s." % GameState.hours_text(data.use_hours)
	else:
		use_hint.text = ""

func _effects_line(data: ItemData) -> String:
	var parts: Array[String] = []
	if data.heal > 0:
		parts.append("leczy rany")
	if data.cures_fever:
		parts.append("zbija gorączkę")
	if data.sanity > 0:
		parts.append("koi nerwy")
	if data.category == ItemData.Category.TOOL:
		parts.append("narzędzie, nie zużywa się")
	if parts.is_empty():
		return ""
	return "\n\n[color=#8a7f70]%s.[/color]" % _sentence(", ".join(parts))

func _sentence(line: String) -> String:
	return line.left(1).to_upper() + line.substr(1)

func _use_selected() -> void:
	var selected := list.get_selected_items()
	if selected.is_empty():
		return
	var item_id: String = list.get_item_metadata(selected[0])
	if GameState.use_item(item_id):
		_refresh(item_id)
