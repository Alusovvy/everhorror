// Overlay for rock meshes: thin glowing blue-iron veins in world space, slowly pulsing.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back;

uniform vec4 vein_color : source_color = vec4(0.25, 0.55, 1.0, 1.0);
uniform float intensity = 3.5;
uniform float vein_scale = 1.2;
uniform float vein_width = 0.13;
uniform float pulse_speed = 0.7;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float band(vec3 p, vec3 dir, float warp) {
	float v = sin(dot(p, dir) + sin(p.y * 2.3 + p.x * 1.1) * warp);
	return 1.0 - smoothstep(0.0, vein_width, abs(v));
}

void fragment() {
	vec3 p = world_pos * vein_scale;
	float veins = max(band(p, vec3(1.3, 0.7, 0.9), 1.4), band(p * 0.7, vec3(-0.6, 1.1, 1.4), 2.0) * 0.8);
	float pulse = 0.65 + 0.35 * sin(TIME * pulse_speed + world_pos.x * 0.3);
	ALBEDO = vein_color.rgb * veins * intensity * pulse;
}
