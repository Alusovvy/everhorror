shader_type canvas_item;

// Darkens the screen edges when the hero's mind frays (docs_v2/systemy/zdrowie_i_poczytalnosc.md).
// strength 0 = invisible; pulse_amount adds a slow breathing of the edge.
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 centered = UV - vec2(0.5);
	// Slightly widescreen-shaped falloff so the corners close in evenly.
	centered.x *= 1.15;
	float pulse = 1.0 + pulse_amount * 0.22 * sin(TIME * 1.3);
	float edge = smoothstep(0.36, 0.74, length(centered) * pulse);
	COLOR = vec4(0.015, 0.0, 0.02, edge * strength);
}
