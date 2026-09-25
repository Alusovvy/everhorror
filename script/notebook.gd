extends CanvasLayer
class_name Notebook

## The hero's notebook [J]: quests (in the hero's own words), found documents and the people
## met so far, with how they seem to be doing, in words (MECHANICS §13 pkt 4).

@onready var tabs: TabContainer = $Root/Center/Panel/Margin/VBox/Tabs
@onready var quests_text: RichTextLabel = $Root/Center/Panel/Margin/VBox/Tabs/Zadania
@onready var notes_list: ItemList = $Root/Center/Panel/Margin/VBox/Tabs/Notatki/List
@onready var note_text: RichTextLabel = $Root/Center/Panel/Margin/VBox/Tabs/Notatki/Text
@onready var header: Label = $Root/Center/Panel/Margin/VBox/Header
@onready var people_list: ItemList = $Root/Center/Panel/Margin/VBox/Tabs/Ludzie/List
@onready var person_text: RichTextLabel = $Root/Center/Panel/Margin/VBox/Tabs/Ludzie/Text

func _ready() -> void:
	hide()
	notes_list.item_selected.connect(_show_note)
	people_list.item_selected.connect(_show_person)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"notebook"):
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
	header.text = "Notes   ·   %s" % GameState.clock_text()
	_build_quests()
	_build_notes()
	_build_people()
	show()

func close() -> void:
	hide()
	GameState.pop_modal()

func _build_quests() -> void:
	var active := []
	var done := []
	for quest_id in GameState.quests:
		(active if GameState.quests[quest_id]["state"] == "active" else done).append(quest_id)
	var text := ""
	for quest_id in active + done:
		var data: QuestData = GameState.QUESTS[quest_id]
		var state: String = GameState.quests[quest_id]["state"]
		var mark := "" if state == "active" else "  [color=#8a7f70](zakończone)[/color]"
		text += "[font_size=21][color=#ffb861]%s[/color][/font_size]%s\n" % [data.title, mark]
		text += "[font_size=14][color=#8a7f70]%s[/color][/font_size]\n" % data.giver
		for entry_id in GameState.quests[quest_id]["entries"]:
			text += "• %s\n" % data.entries.get(entry_id, entry_id)
		if quest_id == &"zloza" and state == "active":
			text += "[color=#9ec3ff]• %s.[/color]\n" % GameState.quota_text()
		text += "\n"
	quests_text.text = text if text != "" else "[i]Na razie pusto.[/i]"

func _build_notes() -> void:
	notes_list.clear()
	for note_id in GameState.notes:
		var data: NoteData = GameState.NOTES[note_id]
		notes_list.add_item(data.title)
		notes_list.set_item_metadata(notes_list.item_count - 1, note_id)
	if notes_list.item_count > 0:
		notes_list.select(notes_list.item_count - 1)
		_show_note(notes_list.item_count - 1)
	else:
		note_text.text = "[i]Nie znalazłeś jeszcze żadnych zapisków.[/i]"

func _show_note(index: int) -> void:
	var data: NoteData = GameState.NOTES[notes_list.get_item_metadata(index)]
	note_text.text = "[font_size=21][color=#ffb861]%s[/color][/font_size]\n\n%s" % [data.title, data.text]

func _build_people() -> void:
	people_list.clear()
	for npc_id in GameState.NPCS:
		if not _met(npc_id):
			continue
		var data: NpcData = GameState.NPCS[npc_id]
		people_list.add_item(data.display_name)
		people_list.set_item_metadata(people_list.item_count - 1, npc_id)
	if people_list.item_count > 0:
		people_list.select(0)
		_show_person(0)
	else:
		person_text.text = "[i]Jeszcze z nikim nie rozmawiałeś.[/i]"

func _met(npc_id: StringName) -> bool:
	if GameState.has_flag("met_%s" % npc_id):
		return true
	return npc_id in FieldSchedule.DRUDZY and GameState.has_flag("drudzy_met")

func _show_person(index: int) -> void:
	var npc_id: StringName = people_list.get_item_metadata(index)
	var data: NpcData = GameState.NPCS[npc_id]
	var text := "[font_size=21][color=#ffb861]%s[/color][/font_size]\n[color=#8a7f70]%s[/color]\n\n" % [data.display_name, data.role]
	var status := GameState.npc_status(npc_id)
	if status == "dead":
		text += "Nie żyje."
	elif status == "gone":
		text += "Nie ma %s już w kopalni." % ("jej" if data.female else "go")
	else:
		text += "[color=#ffb861]Zdrowie:[/color] %s\n" % _health_line(npc_id, data.female)
		text += "[color=#ffb861]Głowa:[/color] %s\n" % _mind_line(npc_id, data.female)
		text += "[color=#ffb861]Do ciebie:[/color] %s" % _trust_line(npc_id, data.female)
	person_text.text = text

func _health_line(npc_id: StringName, female: bool) -> String:
	if GameState.has_fever(npc_id):
		return "Trawi %s gorączka. Trzęsie się pod kocami, choć czoło ma rozpalone." % ("ją" if female else "go")
	var health := GameState.npc_health(npc_id)
	if health >= 75:
		return "Wygląda na zdrową." if female else "Wygląda na zdrowego."
	if health >= 45:
		return "Widać, że coś %s dolega." % ("jej" if female else "mu")
	return "Ledwo trzyma się na nogach."

func _mind_line(npc_id: StringName, female: bool) -> String:
	match GameState.sanity_band(npc_id):
		"spokojny":
			return "Trzyma się. Na tyle, na ile można się tu trzymać."
		"niespokojny":
			return "Ostatnio zachowuje się nerwowo. Łatwo %s wystraszyć." % ("ją" if female else "go")
		"na_krawedzi":
			return "Mówi do siebie i nie śpi po nocach. Coś w %s pęka." % ("niej" if female else "nim")
	return "Nie poznaje ludzi. Patrzy przez nich jak przez szybę."

func _trust_line(npc_id: StringName, female: bool) -> String:
	var trust := GameState.rep(npc_id)
	if trust >= 20:
		return "Ufa ci."
	if trust >= 5:
		return "Lubi cię, choć tego nie okazuje."
	if trust < 0:
		return "Nie ufa ci. Pilnuje się przy tobie."
	return "Trzyma dystans. Jeszcze nie wie, co o tobie myśleć."
