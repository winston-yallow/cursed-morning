shader_type canvas_item;

uniform sampler2D vp : hint_default_white;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(vp, SCREEN_UV);
	COLOR.rgb = color.rgb;
	COLOR.a = progress;
}
