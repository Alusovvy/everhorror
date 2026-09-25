extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/gen_sanctin_textures.gd
## Then import (godot --headless --path . --import) before running gen_locations.gd.
## Draws the textures used in the new locations (deterministic, seeded):
## - assets/textures/sanctin_wall.png: glyph mask for the carved wall in the chapel
##   (white = carved line), three rows of sanctin "words",
## - assets/textures/sanctin_portrait.png: the same kind of glyphs, glowing, for the VN portrait,
## - assets/textures/tally_marks.png: scratches in the flooded sump (14 strokes and a broken word).

const DIR := "res://assets/textures/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	seed(1313)   # the year of the first Drugi
	_wall()
	_portrait()
	_tally()
	quit()

## A glyph: strokes between points of a 3×4 grid inside the cell, often mirrored
## (LoreDoc: the lines the Machine burns into the Drudzy are always symmetric).
func _glyph_strokes() -> Array:
	var strokes := []
	var count := randi_range(3, 5)
	for i in count:
		var a := Vector2(randi_range(0, 2), randi_range(0, 3))
		var b := a + Vector2(randi_range(-1, 1), randi_range(-2, 2))
		b = b.clamp(Vector2.ZERO, Vector2(2, 3))
		if a == b:
			b.y = 3 - a.y
		strokes.append([a, b])
	if randf() < 0.55:
		for s in strokes.duplicate():
			strokes.append([Vector2(2 - s[0].x, s[0].y), Vector2(2 - s[1].x, s[1].y)])
	if randf() < 0.4:
		strokes.append(["ring", Vector2(randi_range(0, 2), randi_range(0, 3))])
	if randf() < 0.35:
		strokes.append(["dot", Vector2(1, randi_range(0, 3))])
	return strokes

func _draw_glyph(img: Image, strokes: Array, origin: Vector2, cell: Vector2, radius: float, color: Color) -> void:
	var step := Vector2(cell.x / 2.0, cell.y / 3.0)
	for s in strokes:
		if s[0] is String:
			var centre: Vector2 = origin + s[1] * step
			if s[0] == "ring":
				_ring(img, centre, step.x * 0.42, radius * 0.8, color)
			else:
				_disc(img, centre, radius * 1.6, color)
		else:
			_line(img, origin + s[0] * step, origin + s[1] * step, radius, color)

func _line(img: Image, a: Vector2, b: Vector2, radius: float, color: Color) -> void:
	var length := a.distance_to(b)
	var steps := int(max(length, 1.0))
	for i in steps + 1:
		_disc(img, a.lerp(b, float(i) / steps), radius, color)

func _ring(img: Image, centre: Vector2, ring_radius: float, radius: float, color: Color) -> void:
	for i in 64:
		var t := TAU * i / 64.0
		_disc(img, centre + Vector2(cos(t), sin(t)) * ring_radius, radius, color)

func _disc(img: Image, centre: Vector2, radius: float, color: Color) -> void:
	var r := int(ceil(radius))
	for y in range(int(centre.y) - r, int(centre.y) + r + 1):
		for x in range(int(centre.x) - r, int(centre.x) + r + 1):
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
				continue
			var d := Vector2(x, y).distance_to(centre)
			if d <= radius:
				var a: float = color.a * clampf(radius - d + 0.5, 0.0, 1.0)
				img.set_pixel(x, y, img.get_pixel(x, y).blend(Color(color, a)))

func _wall() -> void:
	var img := Image.create(1024, 372, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	var cell := Vector2(62, 74)
	for row in 3:
		var y := 40.0 + row * 112.0
		var x := 70.0
		for word in 3:
			for letter in randi_range(2, 3):
				_draw_glyph(img, _glyph_strokes(), Vector2(x, y), cell, 4.5, Color.WHITE)
				x += cell.x + 26.0
			x += 42.0
	# a frame line under each row, like a ruled tablet
	for row in 3:
		_line(img, Vector2(50, 128 + row * 112.0), Vector2(974, 128 + row * 112.0), 1.6, Color(1, 1, 1, 0.6))
	img.save_png(ProjectSettings.globalize_path(DIR + "sanctin_wall.png"))
	print("sanctin_wall.png written")

func _portrait() -> void:
	var img := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for y in 512:
		for x in 512:
			var v := 1.0 - Vector2(x - 256, y - 256).length() / 420.0
			img.set_pixel(x, y, Color(0.07, 0.08, 0.1).lerp(Color(0.16, 0.17, 0.21), clampf(v, 0.0, 1.0)))
	var cell := Vector2(64, 84)
	for row in 3:
		for col in 4:
			var strokes := _glyph_strokes()
			var origin := Vector2(62 + col * 106, 70 + row * 130)
			_draw_glyph(img, strokes, origin, cell, 9.0, Color(0.3, 0.5, 1.0, 0.35))
			_draw_glyph(img, strokes, origin, cell, 4.0, Color(0.72, 0.86, 1.0, 1.0))
	img.save_png(ProjectSettings.globalize_path(DIR + "sanctin_portrait.png"))
	print("sanctin_portrait.png written")

func _tally() -> void:
	var img := Image.create(256, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))
	var scratch := Color(0.85, 0.82, 0.76, 0.9)
	var x := 16.0
	for i in 14:
		if i % 5 == 4:
			_line(img, Vector2(x - 58, 58), Vector2(x - 2, 22), 1.6, scratch)
			x += 14
		else:
			_line(img, Vector2(x + randf_range(-2, 2), 16), Vector2(x + randf_range(-3, 3), 62), 1.5, scratch)
			x += 12
	# three letters of a name, then nothing
	_line(img, Vector2(30, 84), Vector2(30, 112), 1.4, scratch)
	_line(img, Vector2(22, 84), Vector2(40, 84), 1.4, scratch)
	_line(img, Vector2(52, 84), Vector2(52, 112), 1.4, scratch)
	_line(img, Vector2(52, 84), Vector2(64, 92), 1.4, scratch)
	_line(img, Vector2(64, 92), Vector2(52, 100), 1.4, scratch)
	_line(img, Vector2(52, 100), Vector2(66, 112), 1.4, scratch)
	_line(img, Vector2(78, 112), Vector2(86, 84), 1.4, scratch)
	_line(img, Vector2(86, 84), Vector2(94, 112), 1.4, scratch)
	_line(img, Vector2(81, 102), Vector2(91, 102), 1.4, scratch)
	img.save_png(ProjectSettings.globalize_path(DIR + "tally_marks.png"))
	print("tally_marks.png written")
