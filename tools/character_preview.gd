extends SceneTree
## Renders character model scenes side by side to a PNG (real GPU window, not headless).
## GODOT --path . --resolution 1400x700 --script res://tools/character_preview.gd -- <out.png> <id,id,...> [animation] [front|face|side|right]
## <id> is the model scene name without "_model", e.g. "sobek,sabina".
var frames := 0
var out := ""

func _initialize() -> void:
	process_frame.connect(_start, CONNECT_ONE_SHOT)

func _start() -> void:
	var args := OS.get_cmdline_user_args()
	out = args[0]
	var ids: PackedStringArray = args[1].split(",")
	var anim: String = args[2] if args.size() > 2 else "Idle"
	var view: String = args[3] if args.size() > 3 else "front"
	var stage := Node3D.new()
	root.add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.12, 0.11, 0.1)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.5, 0.48, 0.45)
	env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	stage.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, 30, 0)
	key.light_energy = 1.3
	stage.add_child(key)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 2.5, 3)
	fill.omni_range = 10
	fill.light_color = Color(1, 0.75, 0.5)
	stage.add_child(fill)
	var n := ids.size()
	for i in n:
		var model: Node3D = load("res://scene/characters/%s_model.tscn" % ids[i]).instantiate()
		model.set("animation", StringName(anim))
		model.position = Vector3((i - (n - 1) / 2.0) * 1.1, 0, 0)
		stage.add_child(model)
	var cam := Camera3D.new()
	stage.add_child(cam)
	var span := n * 1.1 + 0.5
	cam.fov = 24
	var dist := maxf(1.2 / tan(deg_to_rad(12.0)), span / 4.0 / tan(deg_to_rad(12.0)))
	match view:
		"face":
			cam.fov = 14
			cam.position = Vector3(0, 1.62, dist)
			cam.look_at(Vector3(0, 1.55, 0))
		"side":
			cam.position = Vector3(dist * 0.7, 1.2, dist * 0.7)
			cam.look_at(Vector3(0, 0.95, 0))
		"right":
			cam.position = Vector3(dist, 1.1, 0.3)
			cam.look_at(Vector3(0, 1.0, 0))
		_:
			cam.position = Vector3(0, 1.0, dist)
			cam.look_at(Vector3(0, 0.95, 0))
	cam.current = true
	process_frame.connect(_tick)

func _tick() -> void:
	frames += 1
	if frames == 45:
		root.get_texture().get_image().save_png(out)
		quit()
