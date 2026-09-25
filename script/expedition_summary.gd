extends CanvasLayer
class_name ExpeditionSummary

## Shown when the hero gets back to the camp (docs_v2/systemy/eksploracja_kopalni.md): how long
## he was away, where he went, veins marked against the quota, what he brought back, what
## happened and how he is. `await summary.present(record)` returns when it is closed.

signal closed

@onready var title: Label = $Root/Center/Panel/VBox/Title
@onready var body: RichTextLabel = $Root/Center/Panel/VBox/Body
@onready var continue_button: Button = $Root/Center/Panel/VBox/ContinueButton

func _ready() -> void:
	hide()
	continue_button.pressed.connect(_close)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()

func present(record: Dictionary) -> void:
	if record.is_empty():
		return
	title.text = "Powrót do obozu · dzień %d" % int(record.get("day", GameState.day))
	body.text = describe(record)
	GameState.push_modal()
	show()
	continue_button.grab_focus()
	await closed

func _close() -> void:
	if not visible:
		return
	hide()
	GameState.pop_modal()
	closed.emit()

## The summary text; static so tests can check it without the UI.
static func describe(record: Dictionary) -> String:
	var lines: Array[String] = []
	var start: float = record.get("start", GameState.hour)
	var away := GameState.hour - start + (GameState.day - int(record.get("day", GameState.day))) * 24.0
	lines.append("Wyruszyłeś o %s, wróciłeś o %s. Poza obozem: %s." % [GameState.time_text(start), GameState.time_text(GameState.hour), GameState.hours_text(maxf(away, 0.0))])
	var places: Array[String] = []
	for id in record.get("places", []):
		places.append(Expeditions.display_name(StringName(id)))
	if not places.is_empty():
		lines.append("Byłeś w: %s." % ", ".join(places))
	var found := GameState.veins_mapped() - int(record.get("veins", GameState.veins_mapped()))
	var veins_line := "Nowe żyły na mapie: %d. " % found if found > 0 else "Ani jednej nowej żyły. "
	lines.append("[color=#9ec3ff]%s%s.[/color]" % [veins_line, GameState.quota_text()])
	var items: Dictionary = record.get("items", {})
	if not items.is_empty():
		var names: Array[String] = []
		for item_id in items:
			var count := int(items[item_id])
			names.append("%s%s" % [GameState.item_name(item_id), " ×%d" % count if count > 1 else ""])
		lines.append("Przyniosłeś: %s." % ", ".join(names))
	var events: Array = record.get("events", [])
	if not events.is_empty():
		lines.append("")
		for event_text in events:
			lines.append("• %s" % event_text)
	lines.append("")
	lines.append(_condition_line(record))
	lines.append("[i]%s[/i]" % _verdict(found))
	return "\n".join(lines)

static func _condition_line(record: Dictionary) -> String:
	var hurt := GameState.player_health < int(record.get("health", GameState.player_health))
	var shaken := GameState.player_sanity < int(record.get("sanity", GameState.player_sanity)) - 4
	var state := "Jesteś %s, %s." % [GameState.health_text(), GameState.mind_text()]
	if hurt and shaken:
		return "Wracasz poraniony i roztrzęsiony. " + state
	if hurt:
		return "Wracasz poraniony. " + state
	if shaken:
		return "Wracasz cały, ale coś zostało tam na dole z tobą. " + state
	return "Wracasz w jednym kawałku. " + state

static func _verdict(found: int) -> String:
	if GameState.quota_met():
		return "Norma Kniazia jest zrobiona. Racibor nie powie „dobrze”, ale przestanie patrzeć na ciebie jak na darmozjada."
	if found == 0:
		return "Racibor spojrzy na mapę, potem na ciebie. Nic nie powie. Nie musi."
	if found >= 3:
		return "Dobra wyprawa. Racibor pokiwa głową nad mapą, choć słowa pochwały i tak z niego nie wydusisz."
	return "Coś jest. Za mało, żeby spać spokojnie, dość, żeby jutro znowu zejść."
