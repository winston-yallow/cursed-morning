shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform float smoothing = 0.02;

void fragment() {
	COLOR.a *= smoothstep(1.0 - UV.y - smoothing, 1.0 - UV.y + smoothing, progress);
	COLOR *= texture(TEXTURE, UV);
}
