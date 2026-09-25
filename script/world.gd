extends Node3D

@onready var player: Player = $Player
@onready var hud: Hud = $HUD
@onready var story: StoryDirector = $Story

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.connect_player(player)
	var is_new_game := not SaveManager.has_pending()
	SaveManager.restore_pending(self)
	story.begin(is_new_game)
