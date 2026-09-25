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

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, PAPER)
	draw_rect(r.grow(-6), PAPER_EDGE, false, 2.0)
	var font := get_theme_default_font()
	var known := Expeditions.known_places()
	var shown: Array[StringName] = [Expeditions.CAMP]
	shown.append_array(known)
	# tunnels between everything that is on the map
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
			if both_seen and not locked:
				draw_line(a, b, INK, 3.0)
			else:
				draw_dashed_line(a, b, INK_FAINT if locked else INK, 2.0, 7.0)
	# the chosen way, in red ink
	for i in range(1, route.size()):
		draw_line(_point(route[i - 1]), _point(route[i]), BLOOD, 4.0)
	# places
	for id in shown:
		var p := _point(id)
		if id == Expeditions.CAMP:
			draw_circle(p, 10.0, INK)
			_label(font, p + Vector2(14, 5), "Obóz", 15, INK)
			continue
		var locked := Expeditions.own_lock(id) != ""
		var visited := Expeditions.is_visited(id)
		var color := INK_FAINT if locked else INK
		if visited:
			draw_circle(p, 7.0, color)
		else:
			draw_arc(p, 7.0, 0.0, TAU, 20, color, 2.0)
		_label(font, p + Vector2(11, 5), Expeditions.display_name(id), 13, color)
		if visited:
			_vein_ticks(p + Vector2(11, 12), id)
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

## A name to the right of its dot; if it doesn't fit on the paper, under the dot instead.
func _label(font: Font, at: Vector2, text: String, font_size: int, color: Color) -> void:
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var pos := at
	if at.x + width > size.x - 10.0:
		pos = Vector2(clampf(at.x - 11.0 - width * 0.5, 10.0, size.x - width - 10.0), at.y + 18.0)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
