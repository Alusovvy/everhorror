// The carved wall in the chapel: smooth silver-grey stone with sanctin glyphs that glow blue
// and slowly "breathe" (like the blue iron veins). `glyphs` is a mask: white = carved line.
shader_type spatial;

uniform sampler2D glyphs : source_color, hint_default_black;
uniform vec3 stone : source_color = vec3(0.24, 0.25, 0.29);
uniform vec3 glow : source_color = vec3(0.3, 0.58, 1.0);
uniform float energy = 2.2;
uniform float pulse_speed = 0.55;

void fragment() {
	float carved = texture(glyphs, UV).r;
	float pulse = 0.7 + 0.3 * sin(TIME * pulse_speed + UV.y * 4.0);
	ALBEDO = mix(stone, stone * 0.45, carved);
	ROUGHNESS = mix(0.32, 0.7, carved);
	METALLIC = 0.35;
	EMISSION = glow * carved * energy * pulse;
}
