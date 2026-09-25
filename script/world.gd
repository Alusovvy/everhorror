extends Node3D

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var story: StoryDirector = $Story
@onready var world_environment: WorldEnvironment = $Environment

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.connect_player(player)
	Settings.changed.connect(_apply_brightness)
	_apply_brightness()
	var is_new_game := not SaveManager.has_pending()
	SaveManager.restore_pending(self)
	story.begin(is_new_game)

## The brightness option from Settings (the game is dark, players' screens differ).
func _apply_brightness() -> void:
	var env := world_environment.environment
	env.adjustment_enabled = not is_equal_approx(Settings.brightness, 1.0)
	env.adjustment_brightness = Settings.brightness
