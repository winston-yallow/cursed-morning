shader_type canvas_item;

// Using an expression here doesn't work in godot 4.0.rc2 with
// the code "sqrt(2.0) / 2.0" so I pre-calculated the value.
// The original error message was: "Expected constant expression."
// TODO: Report as issue on github
const float max_dist = 0.7071067812;

const float border_start = 0.005;
const float border_end = 0.003;

uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D vp : hint_default_white;
uniform sampler2D noise_texture : hint_default_white, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec2 noise_uv;

void vertex() {
	noise_uv = VERTEX / 512.0;
}

void fragment() {
	float noise = textureLod(noise_texture, noise_uv, 2.0).x;
	vec4 color = texture(vp, SCREEN_UV);
	float center_distance_normalized = distance(UV, vec2(0.5, 0.5)) / max_dist;
	float factor = (center_distance_normalized + noise * 0.3) / 1.3;
	COLOR.rgb = color.rgb;
	COLOR.a = step(factor, progress);
	
	float border = smoothstep(border_start, border_end, abs(progress - factor));
	COLOR = mix(COLOR, border_color, border);
}
