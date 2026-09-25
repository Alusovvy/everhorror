// Blurred, darkened copy of the game view behind the VN screen, with a soft vignette.
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_lod = 3.0;
uniform float darkness = 0.45;
uniform float fade = 1.0;

void fragment() {
	vec3 scene = textureLod(screen_texture, SCREEN_UV, blur_lod).rgb;
	vec2 centered = SCREEN_UV - 0.5;
	float vignette = 1.0 - smoothstep(0.25, 0.85, length(centered * vec2(1.4, 1.0)));
	COLOR = vec4(scene * darkness * (0.55 + 0.45 * vignette), fade);
}
