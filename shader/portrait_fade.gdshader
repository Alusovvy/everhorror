// Soft edges for the VN portrait so cropped arms/shoulders fade out instead of ending in a hard line.
shader_type canvas_item;

uniform float side_fade = 0.16;
uniform float bottom_fade = 0.2;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float a = smoothstep(0.0, side_fade, UV.x) * smoothstep(1.0, 1.0 - side_fade, UV.x);
	a *= smoothstep(1.0, 1.0 - bottom_fade, UV.y);
	COLOR = vec4(c.rgb, c.a * a) * COLOR;
}
