extends CanvasLayer
class_name Hud

## In-game HUD: crosshair, interaction prompt, description panel, the hero's condition and short
## messages. No clock since task_09: the time is in the notebook [J] (and in the dialogue window).

@onready var vignette: ColorRect = $Vignette
@onready var crosshair: ColorRect = $Crosshair
@onready var prompt: Label = $Prompt
@onready var description_panel: PanelContainer = $DescriptionPanel
@onready var description_title: Label = $DescriptionPanel/VBox/Title
@onready var description_body: Label = $DescriptionPanel/VBox/Body
## The hero's state in the corner, only when something is wrong ("ranny · gorączka").
@onready var condition: Label = $Condition
@onready var toasts: VBoxContainer = $Toasts

const CROSSHAIR_IDLE := Color(1, 1, 1, 0.5)
const CROSSHAIR_FOCUSED := Color(1.0, 0.72, 0.38, 0.95)
const TOAST_SECONDS := 4.0
const PICKUP_SECONDS := 12.0

var _focused: Interactable
var _described: Interactable
## A description that stays on screen for a while (pickups vanish when used).
var _pinned_title := ""
var _pinned_body := ""
var _pinned_until := 0.0

func _ready() -> void:
	GameState.time_advanced.connect(_on_time_advanced)
	GameState.message.connect(show_toast)
	GameState.quest_updated.connect(_on_quest_updated)
	GameState.player_changed.connect(_update_condition)
	GameState.state_replaced.connect(_update_condition)
	_update_condition()
	_refresh()

func _process(_delta: float) -> void:
	# Hide the in-world HUD while a modal screen (dialogue, map, notebook) is open.
	var modal := GameState.is_modal()
	crosshair.visible = not modal
	condition.visible = not modal
	vignette.visible = not modal and _vignette_strength() > 0.0
	if modal:
		prompt.hide()
		description_panel.hide()
	elif _pinned_until > 0.0 and Time.get_ticks_msec() / 1000.0 > _pinned_until:
		_pinned_until = 0.0
		_refresh()
	elif not modal:
		_refresh()

func connect_player(player: Player) -> void:
	player.focus_changed.connect(show_focus)
	player.interacted.connect(_on_interacted)

func _unhandled_input(event: InputEvent) -> void:
	# "[E] zamknij": with a description on screen, E only closes it. It never uses the object
	# again (no second time cost, no repeated effects). The HUD comes after the player in the
	# scene tree, so it gets the key first.
	if description_panel.visible and event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		close_description()

func close_description() -> void:
	_described = null
	_pinned_until = 0.0
	_refresh()

func show_focus(target: Interactable) -> void:
	_focused = target
	# Looking away closes the description.
	if _described != target:
		_described = null
	_refresh()

func show_toast(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", 17)
	label.add_theme_color_override(&"font_color", Color(1.0, 0.86, 0.66))
	label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	label.add_theme_constant_override(&"outline_size", 5)
	toasts.add_child(label)
	var tween := label.create_tween()
	tween.tween_interval(TOAST_SECONDS)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

func _on_interacted(target: Interactable) -> void:
	if target.action != Interactable.Action.DESCRIBE:
		return
	# Objects that disappear once used (pickups, a vein after marking) can't stay in focus,
	# so their text is pinned for a while instead (E closes it earlier).
	var vanishes := target.remove_after_use or (target.hidden_by_flag != "" and target.hidden_by_flag == target.on_use_flag)
	if vanishes:
		_pinned_title = target.display_name
		_pinned_body = target.description
		_pinned_until = Time.get_ticks_msec() / 1000.0 + PICKUP_SECONDS
		_described = null
	else:
		_described = target
	_refresh()

func _on_time_advanced(hours: float, reason: String) -> void:
	var amount := GameState.duration_text(int(round(hours * 60.0)))
	show_toast("−%s · %s" % [amount, reason] if reason != "" else "−%s" % amount)
	if GameState.is_day_over():
		show_toast("Robi się późno. Pora wracać na posłanie.")

func _on_quest_updated(quest: QuestData, entry_text: String) -> void:
	if entry_text != "":
		show_toast("Notes: %s  [J]" % quest.title)

func _update_condition() -> void:
	var parts: Array[String] = []
	if GameState.health_band() != "zdrowy":
		parts.append(GameState.health_text())
	if GameState.mind_band() in ["na_krawedzi", "zalamany"]:
		parts.append(GameState.mind_text())
	if GameState.player_fever:
		parts.append("gorączka")
	# task_12: fatigue only once it matters (75%+), in words.
	if GameState.fatigue_text() != "":
		parts.append(GameState.fatigue_text())
	condition.text = "  ·  ".join(parts)
	_update_vignette()

## A subtle dark vignette when the hero's mind frays: none while calm or uneasy,
## creeping in and slowly pulsing on the edge, strongest just before the breakdown.
func _vignette_strength() -> float:
	if GameState.mind_band() != "na_krawedzi":
		return 0.0
	return lerpf(0.3, 0.7, 1.0 - float(GameState.player_sanity) / 35.0)

func _update_vignette() -> void:
	var strength := _vignette_strength()
	var material := vignette.material as ShaderMaterial
	material.set_shader_parameter("strength", strength)
	material.set_shader_parameter("pulse_amount", 1.0 if strength > 0.0 else 0.0)

func _refresh() -> void:
	crosshair.color = CROSSHAIR_FOCUSED if _focused else CROSSHAIR_IDLE
	var pinned := _pinned_until > 0.0
	prompt.visible = _focused != null and _described == null and not pinned
	if _focused:
		prompt.text = "[E] %s" % _focused.get_prompt()
	description_panel.visible = _described != null or pinned
	if pinned:
		description_title.text = _pinned_title
		description_body.text = _pinned_body
	elif _described:
		description_title.text = _described.display_name
		description_body.text = _described.description
