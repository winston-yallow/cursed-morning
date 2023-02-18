shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;

void fragment() {
	float dist = distance(UV, vec2(0.5, 0.5));
	vec4 screen = textureLod(screen_texture, SCREEN_UV, 3.0);
	COLOR = screen;
	COLOR.a = smoothstep(0.5, 0.2, dist);
}
