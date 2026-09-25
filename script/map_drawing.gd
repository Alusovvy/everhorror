extends Control

## Schematic "grandfather's map" drawn on the map screen: camp in the middle, the Old Adit to
## the east (with the chamber below), the collapsed western tunnel, the way to the surface.

const INK := Color(0.2, 0.13, 0.07, 0.9)
const INK_FAINT := Color(0.2, 0.13, 0.07, 0.35)
const BLOOD := Color(0.55, 0.1, 0.06, 0.9)

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0.78, 0.69, 0.52))
	draw_rect(r.grow(-6), Color(0.72, 0.62, 0.45), false, 2.0)
	var font := get_theme_default_font()
	var c := size * Vector2(0.5, 0.42)
	var east := c + Vector2(size.x * 0.34, 0)
	var chamber := east + Vector2(0, size.y * 0.34)
	var west := c - Vector2(size.x * 0.34, 0)
	var up := c - Vector2(0, size.y * 0.3)
	# tunnels
	draw_line(c, east, INK, 4.0)
	draw_line(east, chamber, INK, 4.0)
	draw_dashed_line(chamber, chamber + Vector2(0, size.y * 0.12), INK_FAINT, 3.0, 6.0)
	draw_line(c, up, INK, 3.0)
	var open := GameState.has_flag("west_blasted")
	draw_line(c, west, INK if open else INK_FAINT, 4.0)
	# collapse mark
	var mid_w := c.lerp(west, 0.55)
	if not open:
		draw_line(mid_w + Vector2(-9, -9), mid_w + Vector2(9, 9), BLOOD, 3.0)
		draw_line(mid_w + Vector2(-9, 9), mid_w + Vector2(9, -9), BLOOD, 3.0)
	# camp and places
	draw_circle(c, 9.0, INK)
	draw_circle(east, 6.0, INK)
	draw_circle(chamber, 6.0, Color(0.15, 0.25, 0.55, 0.9))
	draw_circle(west, 6.0, INK if open else INK_FAINT)
	_label(font, c + Vector2(-22, 26), "Obóz")
	_label(font, east + Vector2(-60, -14), "Stara sztolnia")
	_label(font, chamber + Vector2(12, 5), "jaskinia")
	_label(font, west + Vector2(-20, -14), "Zachodni chodnik")
	_label(font, up + Vector2(10, 4), "na powierzchnię")
	_label(font, chamber + Vector2(10, size.y * 0.12), "?")
	# grandfather's mark: two crossing lines and a dot
	var mark := Vector2(size.x - 40, 34)
	draw_line(mark + Vector2(-10, -10), mark + Vector2(10, 10), BLOOD, 2.0)
	draw_line(mark + Vector2(-10, 10), mark + Vector2(10, -10), BLOOD, 2.0)
	draw_circle(mark + Vector2(14, -12), 3.0, BLOOD)

func _label(font: Font, at: Vector2, text: String) -> void:
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, INK)
