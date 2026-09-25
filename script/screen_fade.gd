extends CanvasLayer
class_name ScreenFade

## Full-screen fades, title cards ("Dzień 2") and the end-of-demo screen.
## All methods are awaitable: `await fade.fade_out()`.

@onready var black: ColorRect = $Black
@onready var card: VBoxContainer = $Card
@onready var card_title: Label = $Card/Title
@onready var card_subtitle: Label = $Card/Subtitle
@onready var end_panel: Control = $EndPanel
@onready var end_summary: Label = $EndPanel/Center/VBox/Summary
@onready var menu_button: Button = $EndPanel/Center/VBox/Buttons/MenuButton
@onready var quit_button: Button = $EndPanel/Center/VBox/Buttons/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	black.modulate.a = 0.0
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.modulate.a = 0.0
	end_panel.hide()
	menu_button.pressed.connect(SaveManager.go_to_main_menu)
	quit_button.pressed.connect(get_tree().quit)

func fade_out(seconds: float = 0.8) -> void:
	black.mouse_filter = Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(black, "modulate:a", 1.0, seconds).finished

func fade_in(seconds: float = 0.8) -> void:
	await create_tween().tween_property(black, "modulate:a", 0.0, seconds).finished
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Shows a title card on black (call after fade_out).
func show_card(title: String, subtitle: String = "", hold: float = 2.2) -> void:
	card_title.text = title
	card_subtitle.text = subtitle
	card_subtitle.visible = subtitle != ""
	var tween := create_tween()
	tween.tween_property(card, "modulate:a", 1.0, 0.7)
	tween.tween_interval(hold)
	tween.tween_property(card, "modulate:a", 0.0, 0.7)
	await tween.finished

func show_end(summary: String) -> void:
	await fade_out(1.2)
	end_summary.text = summary
	end_panel.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameState.push_modal()
	menu_button.grab_focus()
