extends CanvasLayer
class_name Hud

## In-game HUD: crosshair, interaction prompt, description panel, clock and short messages.

@onready var crosshair: ColorRect = $Crosshair
@onready var prompt: Label = $Prompt
@onready var description_panel: PanelContainer = $DescriptionPanel
@onready var description_title: Label = $DescriptionPanel/VBox/Title
@onready var description_body: Label = $DescriptionPanel/VBox/Body
@onready var clock: Label = $Clock
@onready var toasts: VBoxContainer = $Toasts

const CROSSHAIR_IDLE := Color(1, 1, 1, 0.5)
const CROSSHAIR_FOCUSED := Color(1.0, 0.72, 0.38, 0.95)
const TOAST_SECONDS := 4.0
const PICKUP_SECONDS := 7.0

var _focused: Interactable
var _described: Interactable
## A description that stays on screen for a while (pickups vanish when used).
var _pinned_title := ""
var _pinned_body := ""
var _pinned_until := 0.0

func _ready() -> void:
	GameState.time_advanced.connect(_on_time_advanced)
	GameState.day_started.connect(func(_d): _update_clock())
	GameState.state_replaced.connect(_update_clock)
	GameState.message.connect(show_toast)
	GameState.quest_updated.connect(_on_quest_updated)
	_update_clock()
	_refresh()

func _process(_delta: float) -> void:
	# Hide the in-world HUD while a modal screen (dialogue, map, notebook) is open.
	var modal := GameState.is_modal()
	crosshair.visible = not modal
	clock.visible = not modal
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
	if target.remove_after_use:
		_pinned_title = target.display_name
		_pinned_body = target.description
		_pinned_until = Time.get_ticks_msec() / 1000.0 + PICKUP_SECONDS
		_described = null
	else:
		_described = null if _described == target else target
	_refresh()

func _on_time_advanced(hours: float, reason: String) -> void:
	_update_clock()
	var amount := str(int(hours)) if is_equal_approx(hours, floor(hours)) else "%.1f" % hours
	show_toast("−%s h · %s" % [amount, reason] if reason != "" else "−%s h" % amount)
	if GameState.is_day_over():
		show_toast("Robi się późno. Pora wracać na posłanie.")

func _on_quest_updated(quest: QuestData, entry_text: String) -> void:
	if entry_text != "":
		show_toast("Notes: %s  [J]" % quest.title)

func _update_clock() -> void:
	clock.text = GameState.clock_text()

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
