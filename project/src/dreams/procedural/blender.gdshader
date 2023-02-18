shader_type canvas_item;
render_mode unshaded;

uniform vec3 border : source_color = vec3(0.15);

void vertex() {
	vec4 center = inverse(SCREEN_MATRIX) * vec4(0.0, 0.0, 0.0, 1.0);
	vec2 expand = VERTEX - center.xy;
	VERTEX += expand;
	UV += (UV - vec2(0.5, 0.5));
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = tex;
	COLOR.rgb = mix(COLOR.rgb, border, step(1.0, UV.x));
	COLOR.rgb = mix(COLOR.rgb, border, step(UV.x, 0.0));
	COLOR.rgb = mix(COLOR.rgb, border, step(1.0, UV.y));
	COLOR.rgb = mix(COLOR.rgb, border, step(UV.y, 0.0));
}
