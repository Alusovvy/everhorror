extends Control

## Grandfather's map on the map screen: the camp at the top, known places below it (deeper =
## lower), the tunnels between them. Visited places are filled, places only seen from a
## neighbour are hollow, locked ones faint. The chosen route is drawn in red ink; in the field a
## ring marks where the hero stands. Blue ticks show the veins already marked.

const INK := Color(0.2, 0.13, 0.07, 0.9)
const INK_FAINT := Color(0.2, 0.13, 0.07, 0.3)
const BLOOD := Color(0.55, 0.1, 0.06, 0.9)
const BLUE := Color(0.12, 0.28, 0.62, 0.95)
const PAPER := Color(0.78, 0.69, 0.52)
const PAPER_EDGE := Color(0.72, 0.62, 0.45)
const CAMP_POS := Vector2(0.5, 0.08)
const MARGIN := Vector2(34, 26)

var origin: StringName = &"oboz"
var selected: StringName = &""
var route: Array[StringName] = []
var field_mode := false
## Rectangles already used on the paper this frame (dots, vein ticks, names): names keep clear.
var _taken: Array[Rect2] = []
## Small boxes along the tunnel lines: a name may cross a line, but only if nothing better fits.
var _lines: Array[Rect2] = []
## Air kept around every name, so two names never touch.
const LABEL_PAD := 4.0
## How much crossing a tunnel line counts against a spot, compared with covering a name.
const LINE_WEIGHT := 0.25
## Every place's dot this frame: a name must sit closer to its own dot than to any other.
var _dots: Array[Vector2] = []

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, PAPER)
	draw_rect(r.grow(-6), PAPER_EDGE, false, 2.0)
	var font := get_theme_default_font()
	var known := Expeditions.known_places()
	var shown: Array[StringName] = [Expeditions.CAMP]
	shown.append_array(known)
	# tunnels between everything that is on the map
	_lines.clear()
	var drawn := {}
	for id in shown:
		for key in Expeditions.neighbours(id):
			var other: StringName = key
			if not other in shown:
				continue
			var pair := [String(id), String(other)]
			pair.sort()
			if drawn.has(pair):
				continue
			drawn[pair] = true
			var both_seen: bool = (id == Expeditions.CAMP or Expeditions.is_visited(id)) and (other == Expeditions.CAMP or Expeditions.is_visited(other))
			var locked: bool = Expeditions.own_lock(id) != "" or Expeditions.own_lock(other) != ""
			var a := _point(id)
			var b := _point(other)
			_note_line(a, b)
			if both_seen and not locked:
				draw_line(a, b, INK, 3.0)
			else:
				draw_dashed_line(a, b, INK_FAINT if locked else INK, 2.0, 7.0)
	# the chosen way, in red ink
	for i in range(1, route.size()):
		draw_line(_point(route[i - 1]), _point(route[i]), BLOOD, 4.0)
	# places: dots and vein ticks first, so the names can keep clear of all of them
	_taken.clear()
	_dots.clear()
	for id in shown:
		var p := _point(id)
		_dots.append(p)
		if id == Expeditions.CAMP:
			draw_circle(p, 10.0, INK)
			_taken.append(Rect2(p - Vector2(11, 11), Vector2(22, 22)))
			continue
		var color := INK_FAINT if Expeditions.own_lock(id) != "" else INK
		if Expeditions.is_visited(id):
			draw_circle(p, 7.0, color)
			_vein_ticks(p + Vector2(11, 12), id)
			_taken.append(Rect2(p + Vector2(10, 11), Vector2(Expeditions.veins_total(id) * 6.0 + 2.0, 9)))
		else:
			draw_arc(p, 7.0, 0.0, TAU, 20, color, 2.0)
		_taken.append(Rect2(p - Vector2(8, 8), Vector2(16, 16)))
	for id in shown:
		if id == Expeditions.CAMP:
			_label(font, _point(id), 14.0, "Obóz", 15, INK)
		else:
			var color := INK_FAINT if Expeditions.own_lock(id) != "" else INK
			_label(font, _point(id), 11.0, Expeditions.display_name(id), 13, color)
	# where the hero stands and where he is going
	if field_mode:
		draw_arc(_point(origin), 13.0, 0.0, TAU, 28, BLOOD, 3.0)
	if selected != &"" and selected != origin:
		draw_arc(_point(selected), 12.0, 0.0, TAU, 24, Color(0.85, 0.45, 0.1, 0.95), 2.5)
	# grandfather's mark: two crossing lines and a dot
	var mark := Vector2(size.x - 34, 30)
	draw_line(mark + Vector2(-9, -9), mark + Vector2(9, 9), BLOOD, 2.0)
	draw_line(mark + Vector2(-9, 9), mark + Vector2(9, -9), BLOOD, 2.0)
	draw_circle(mark + Vector2(13, -11), 3.0, BLOOD)

func _point(id: StringName) -> Vector2:
	var at := CAMP_POS if id == Expeditions.CAMP else Expeditions.place(id).map_pos
	return MARGIN + at * (size - MARGIN * 2.0)

## One short blue stroke per vein there: full for marked, faint for not yet.
func _vein_ticks(at: Vector2, id: StringName) -> void:
	var marked := Expeditions.veins_marked(id)
	for i in Expeditions.veins_total(id):
		var x := at.x + i * 6.0
		var color := BLUE if i < marked else Color(BLUE, 0.3)
		draw_line(Vector2(x, at.y), Vector2(x + 3.0, at.y + 7.0), color, 2.0)

## Boxes every few pixels along a tunnel, so names can tell where the lines run.
func _note_line(a: Vector2, b: Vector2) -> void:
	var steps := int(a.distance_to(b) / 6.0)
	for i in range(2, steps - 1):
		var at := a.lerp(b, float(i) / steps)
		_lines.append(Rect2(at - Vector2(3, 3), Vector2(6, 6)))

## A place's name next to its dot ("Stare wyrobisko" and "Kaplica" used to run into each other).
## Spots around the dot are scored and the cheapest wins:
## - covering another name, a dot or vein ticks costs the covered area, crossing a tunnel line a
##   quarter of it (with a little air around the name, so names never touch),
## - a spot that would have to be pushed back onto the paper, or that sits nearer another dot
##   than its own, is out unless nothing else is left (a name must read as that place's),
## - right of the dot is preferred, then below, above, left, the diagonals.
func _label(font: Font, dot: Vector2, gap: float, text: String, font_size: int, color: Color) -> void:
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var ascent := font.get_ascent(font_size)
	var candidates: Array[Vector2] = [
		dot + Vector2(gap, 5),
		dot + Vector2(-text_size.x * 0.5, gap + ascent + 2.0),
		dot + Vector2(-text_size.x * 0.5, -gap - 4.0),
		dot + Vector2(-gap - text_size.x, 5),
		dot + Vector2(gap, -gap - 2.0),
		dot + Vector2(gap, gap + ascent),
		dot + Vector2(-gap - text_size.x, -gap - 2.0),
		dot + Vector2(-gap - text_size.x, gap + ascent),
	]
	var best := Vector2.ZERO
	var best_cost := INF
	for i in candidates.size():
		var candidate := candidates[i]
		var pos := Vector2(clampf(candidate.x, 10.0, size.x - text_size.x - 10.0), clampf(candidate.y, 10.0 + ascent, size.y - 10.0))
		var rect := Rect2(pos - Vector2(0, ascent), text_size)
		var padded := rect.grow(LABEL_PAD)
		var cost := i * 20.0
		if pos.distance_to(candidate) > 1.0:
			cost += 100000.0
		var own := _distance_to_rect(dot, rect)
		for other_dot in _dots:
			if other_dot != dot and _distance_to_rect(other_dot, rect) < own + 4.0:
				cost += 5000.0
		for other in _taken:
			cost += padded.intersection(other).get_area()
		for line_box in _lines:
			cost += padded.intersection(line_box).get_area() * LINE_WEIGHT
		if cost < best_cost:
			best = pos
			best_cost = cost
	_taken.append(Rect2(best - Vector2(0, ascent), text_size))
	draw_string(font, best, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

static func _distance_to_rect(point: Vector2, rect: Rect2) -> float:
	var dx := maxf(maxf(rect.position.x - point.x, 0.0), point.x - rect.end.x)
	var dy := maxf(maxf(rect.position.y - point.y, 0.0), point.y - rect.end.y)
	return Vector2(dx, dy).length()
