// Overlay glow for aimed-at interactables: warm fresnel rim with a slow pulse.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back;

uniform vec4 glow_color : source_color = vec4(1.0, 0.72, 0.38, 1.0);
uniform float rim_power = 2.0;
uniform float base_strength = 0.12;
uniform float pulse_speed = 3.0;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	float pulse = 0.75 + 0.25 * sin(TIME * pulse_speed);
	ALBEDO = glow_color.rgb * (fresnel + base_strength) * pulse;
}
