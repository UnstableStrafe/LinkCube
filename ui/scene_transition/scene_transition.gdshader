shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.05);
uniform float screen_width;
uniform float screen_height;
uniform vec2 pos = vec2(0.5, 0.5);

void fragment() {
	float ratio = screen_width / screen_height;
	float dist = distance(pos, vec2(mix(pos.x, UV.x, ratio), UV.y));
	COLOR.a = step(circle_size, dist);
}