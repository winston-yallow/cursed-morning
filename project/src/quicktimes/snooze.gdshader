shader_type canvas_item;


const float smoothing = 0.01;

uniform float top = 50;
uniform float bottom = 150;
uniform float progress : hint_range(-1.0, 2.0) = 0.5;
uniform vec3 base : source_color = vec3(0.6);
uniform vec3 overlay : source_color = vec3(1.0);

varying float height;

void vertex() {
	float diff = bottom - top;
	height = 1.0 - (VERTEX.y - top) / diff;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float factor = smoothstep(progress - smoothing, progress + smoothing, height);
	COLOR.rgb *= mix(overlay, base, factor);
	COLOR.a *= tex.a;
}
