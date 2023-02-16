shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap_anisotropic, repeat_disable;

void fragment() {
	vec4 screen = textureLod(screen_texture, SCREEN_UV, 2.0);
	COLOR.rgb = mix(screen.rgb, COLOR.rgb, COLOR.a);
	COLOR.a = 1.0;
}
