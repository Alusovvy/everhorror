// Still, dark water (the flooded sump): two slowly drifting normal maps, glossy and almost opaque.
shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque, specular_schlick_ggx;

uniform vec4 color : source_color = vec4(0.03, 0.05, 0.06, 0.9);
uniform sampler2D ripples_a : hint_normal;
uniform sampler2D ripples_b : hint_normal;
uniform float tiling = 5.0;
uniform float drift = 0.015;

void fragment() {
	vec2 uv = UV * tiling;
	vec3 a = texture(ripples_a, uv + vec2(TIME * drift, 0.0)).rgb;
	vec3 b = texture(ripples_b, uv * 1.37 - vec2(0.0, TIME * drift * 1.4)).rgb;
	NORMAL_MAP = normalize(mix(a, b, 0.5));
	NORMAL_MAP_DEPTH = 0.35;
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ROUGHNESS = 0.05;
	SPECULAR = 0.75;
	METALLIC = 0.1;
}
