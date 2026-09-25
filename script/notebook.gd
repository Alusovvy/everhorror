extends CanvasLayer
class_name Notebook

## The hero's notebook [J]: quests (in the hero's own words) and found documents.

@onready var tabs: TabContainer = $Root/Center/Panel/Margin/VBox/Tabs
@onready var quests_text: RichTextLabel = $Root/Center/Panel/Margin/VBox/Tabs/Zadania
@onready var notes_list: ItemList = $Root/Center/Panel/Margin/VBox/Tabs/Notatki/List
@onready var note_text: RichTextLabel = $Root/Center/Panel/Margin/VBox/Tabs/Notatki/Text
@onready var header: Label = $Root/Center/Panel/Margin/VBox/Header

func _ready() -> void:
	hide()
	notes_list.item_selected.connect(_show_note)

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
