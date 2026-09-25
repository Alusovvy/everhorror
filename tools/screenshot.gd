extends SceneTree
## Usage: godot --path <proj> --script shot.gd -- <views.json> <out_dir>
## views.json: {"scene": "res://...", "flags": {…optional GameState flags…}, "views": [{"name": "a", "pos": [x,y,z], "look": [x,y,z], "fov": 75, "top": false}]}

var cfg: Dictionary
var out_dir: String
var cam: Camera3D
var idx := -1
var wait := 0

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	cfg = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	out_dir = args[1]
	# Autoloads (GameState…) exist only after the first frame.
	process_frame.connect(_load_scene, CONNECT_ONE_SHOT)
	wait = 1000000

func _load_scene() -> void:
	var game_state := root.get_node_or_null("GameState")
	if game_state:
		game_state.set_flag("intro_done")
		for key in cfg.get("flags", {}):
			game_state.set_flag(key, cfg["flags"][key])
		if cfg.has("day"):
			game_state.day = int(cfg["day"])
		if cfg.has("hour"):
			game_state.hour = float(cfg["hour"])
	var scene: Node = load(cfg["scene"]).instantiate()
	root.add_child(scene)
	for n in ["HUD", "PauseMenu"]:
		if scene.has_node(n):
			scene.get_node(n).visible = false
	if scene.has_node("Player"):
		scene.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
		scene.get_node("Player/MeshInstance3D").visible = false
	cam = Camera3D.new()
	scene.add_child(cam)
	cam.current = true
	var player_lamp := OmniLight3D.new()
	player_lamp.position = Vector3(0.3, -0.35, -0.2)
	player_lamp.light_color = Color(1, 0.66, 0.38)
	player_lamp.light_energy = 0.75
	player_lamp.omni_range = 6.0
	player_lamp.omni_attenuation = 1.6
	player_lamp.shadow_enabled = true
	cam.add_child(player_lamp)
	if scene.has_node("Player/Head/EyeCamera/Lamp"):
		scene.get_node("Player/Head/EyeCamera/Lamp").visible = false
	wait = 30

func _process(_d: float) -> bool:
	if wait > 0:
		wait -= 1
		return false
	if idx >= 0:
		var img := root.get_texture().get_image()
		img.save_png("%s/%s.png" % [out_dir, cfg["views"][idx]["name"]])
	idx += 1
	if idx >= cfg["views"].size():
		return true
	var v: Dictionary = cfg["views"][idx]
	var p: Array = v["pos"]
	var l: Array = v["look"]
	cam.fov = v.get("fov", 75.0)
	if v.get("top", false):
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = v.get("size", 100.0)
		cam.far = 500.0
	else:
		cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.global_position = Vector3(p[0], p[1], p[2])
	var up := Vector3.FORWARD if v.get("top", false) else Vector3.UP
	cam.look_at(Vector3(l[0], l[1], l[2]), up)
	wait = 20
	return false
