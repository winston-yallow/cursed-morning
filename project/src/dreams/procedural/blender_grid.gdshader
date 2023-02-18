shader_type spatial;
render_mode unshaded, world_vertex_coords;

const float phi = 0.3;
const vec3 grid_color = vec3(0.15);
const vec3 x_color = vec3(0.609375, 0.234375, 0.2890625);
const vec3 y_color = vec3(0.359375, 0.49609375, 0.16796875);
const vec2 origin = vec2(15, -40);
varying vec2 pos;

void vertex() {
	mat2 rotation = mat2(
		vec2(cos(phi), -sin(phi)),
		vec2(sin(phi), cos(phi))
	);
	pos = rotation * VERTEX.xz;
}

void fragment() {
	vec2 repeating = abs(mod(pos + vec2(0.5), vec2(1.0)) - vec2(0.5));
	float edge_grid_a = 0.02;
	float edge_grid_b = 0.01;
	float grid_x = smoothstep(edge_grid_a, edge_grid_b, repeating.x);
	float grid_y = smoothstep(edge_grid_a, edge_grid_b, repeating.y);
	float grid = max(grid_x, grid_y);
	ALBEDO = grid_color;
	ALPHA = grid;
	
	float edge_axis_a = 0.03;
	float edge_axis_b = 0.02;
	float axis_x = smoothstep(edge_axis_a, edge_axis_b, abs(pos.x - origin.x));
	float axis_y = smoothstep(edge_axis_a, edge_axis_b, abs(pos.y - origin.y));
	float axis = max(axis_x, axis_y);
	ALBEDO = mix(ALBEDO, x_color, axis_x);
	ALBEDO = mix(ALBEDO, y_color, axis_y);
	ALPHA = max(axis, ALPHA);
	
	float circle = smoothstep(0.5, 0.0, distance(UV, vec2(0.5, 0.5)));
	ALPHA *= circle;
}
