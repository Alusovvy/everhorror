extends SceneTree
## Performance probe (audit G6, G-E6, N5): frame time and light counts at three fixed views of the
## real world scene. It MEASURES: a number is only red when it passes a budget you give it or 1.5x
## the baseline saved on this machine. Run it with tools/run_tests.sh perf (not part of unit/lint).
##
## Usage: godot --path . --resolution 1280x720 --script res://tools/perf_probe.gd -- [options]
##   --frames=N          measured frames per view (default 600)
##   --warmup=N          frames thrown away after the camera moves (default 120)
##   --budget-ms=X       red when a view's p95 passes X ms (default: no absolute budget)
##   --save-baseline     write the p95 of each view to reports/perf-baseline.json (this machine)
##   --views=a,b         only these views (oboz, chodnik, galeria)
## Output, one line per view:
##   PERF[oboz]: p50 9.8 ms p95 14.1 ms max 20.2 ms | draws 812 objects 3100 prims 120000 | lights 15 (shadows 9, within 30 m 8) | 600 frames
## Needs a window (a real GPU): the headless renderer draws nothing, so under --headless the probe
## only counts lights (lines say "headless, no timing") and passes. Frame time is measured with vsync
## off. Compare numbers only between runs on the same machine and the same window size.

const BASELINE_PATH := "res://reports/perf-baseline.json"
## Name, camera position, look-at, the hour (the camp is laid out for it), day.
const VIEWS := [
	{"name": "oboz", "pos": Vector3(8.0, 1.7, 0.0), "look": Vector3(14.0, 1.2, 0.2)},
	{"name": "chodnik", "pos": Vector3(36.0, 1.7, 3.0), "look": Vector3(48.0, 1.3, 3.0)},
	{"name": "galeria", "pos": Vector3(104.0, 1.6, 150.0), "look": Vector3(112.0, 1.4, 150.0)},
]

var _frames := 600
var _warmup := 120
var _budget_ms := 0.0
var _save_baseline := false
var _only: PackedStringArray = []
var _failures := 0
var _headless := false
var _cam: Camera3D
var _baseline := {}
var _measured := {}

func _initialize() -> void:
	# Autoloads (GameState…) exist only after the first frame.
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--frames="):
			_frames = int(arg.trim_prefix("--frames="))
		elif arg.begins_with("--warmup="):
			_warmup = int(arg.trim_prefix("--warmup="))
		elif arg.begins_with("--budget-ms="):
			_budget_ms = float(arg.trim_prefix("--budget-ms="))
		elif arg == "--save-baseline":
			_save_baseline = true
		elif arg.begins_with("--views="):
			_only = arg.trim_prefix("--views=").split(",")
	_headless = DisplayServer.get_name() == "headless"
	var save_manager = root.get_node("SaveManager")
	save_manager.isolate_for_tests()
	var game_state = root.get_node("GameState")
	game_state.reset()
	game_state.set_flag("intro_done")
	game_state.set_flag("west_blasted")
	game_state.hour = 18.0
	if not _headless:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
	if FileAccess.file_exists(BASELINE_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(BASELINE_PATH))
		if parsed is Dictionary:
			_baseline = parsed

	var scene: Node = load("res://scene/world.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for node_name in ["HUD", "PauseMenu"]:
		if scene.has_node(node_name):
			scene.get_node(node_name).visible = false
	if scene.has_node("Player"):
		scene.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
		scene.get_node("Player/MeshInstance3D").visible = false
	_cam = Camera3D.new()
	scene.add_child(_cam)
	_cam.current = true
	print("--- perf probe: %s, %d warm-up + %d measured frames per view, window %s" % ["HEADLESS (no timing)" if _headless else "windowed", _warmup, _frames, root.size])
	for _i in 30:
		await process_frame

	for view in VIEWS:
		if not _only.is_empty() and not view["name"] in _only:
			continue
		await _measure(view)

	if _save_baseline and not _headless:
		var file := FileAccess.open(BASELINE_PATH, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(_measured, "\t"))
			print("baseline written to reports/perf-baseline.json for this machine")
	save_manager.remove_test_dir()
	print("\nRESULT: %s" % ("ALL PASSED" if _failures == 0 else "%d FAILED" % _failures))
	quit(0 if _failures == 0 else 1)

func _measure(view: Dictionary) -> void:
	_cam.global_position = view["pos"]
	_cam.look_at(view["look"], Vector3.UP)
	var times := PackedFloat64Array()
	if not _headless:
		for _i in _warmup:
			await process_frame
		var last := Time.get_ticks_usec()
		for _i in _frames:
			await process_frame
			var now := Time.get_ticks_usec()
			times.append((now - last) / 1000.0)
			last = now
	else:
		for _i in 5:
			await process_frame
	var lights := _count_lights(view["pos"])
	var light_text := "lights %d (shadows %d, within 30 m %d)" % [lights["total"], lights["shadows"], lights["near"]]
	if _headless:
		print("PERF[%s]: headless, no timing | %s" % [view["name"], light_text])
		return
	times.sort()
	var p50 := times[int(times.size() * 0.5)]
	var p95 := times[int(times.size() * 0.95)]
	var worst := times[times.size() - 1]
	var draws := int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	var objects := int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME))
	var prims := int(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
	print("PERF[%s]: p50 %.1f ms p95 %.1f ms max %.1f ms | draws %d objects %d prims %d | %s | %d frames" % [view["name"], p50, p95, worst, draws, objects, prims, light_text, times.size()])
	_measured[view["name"]] = {"p95_ms": snappedf(p95, 0.1), "p50_ms": snappedf(p50, 0.1), "draws": draws}
	if _budget_ms > 0.0 and p95 > _budget_ms:
		print("   [FAIL] PERF[%s]: p95 %.1f ms is over the %.1f ms budget" % [view["name"], p95, _budget_ms])
		_failures += 1
	var reference: Variant = _baseline.get(view["name"])
	if reference is Dictionary and p95 > 1.5 * float(reference.get("p95_ms", 1.0e9)):
		print("   [FAIL] PERF[%s]: p95 %.1f ms is over 1.5x the baseline of this machine (%.1f ms)" % [view["name"], p95, float(reference["p95_ms"])])
		_failures += 1

func _count_lights(from: Vector3) -> Dictionary:
	var total := 0
	var shadows := 0
	var near := 0
	for node in root.find_children("*", "Light3D", true, false):
		var light := node as Light3D
		if not light.is_visible_in_tree():
			continue
		total += 1
		if light.shadow_enabled:
			shadows += 1
		if light.global_position.distance_to(from) <= 30.0:
			near += 1
	return {"total": total, "shadows": shadows, "near": near}
