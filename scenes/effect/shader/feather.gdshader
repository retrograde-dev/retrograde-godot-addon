shader_type canvas_item;

uniform float position_x : hint_range(0.0, 1.0); // normalized [0-1]
uniform float position_y : hint_range(0.0, 1.0); // normalized [0-1]
uniform float radius : hint_range(0.0, 1.0);
uniform float feather : hint_range(0.0, 1.0); // softness at edge

void fragment() {
	vec2 dir = UV - vec2(position_x, position_y);
	float dist = length(dir);

	float mask = smoothstep(radius - feather, radius, dist);

	COLOR = texture(TEXTURE, UV);
	COLOR.a *= 1.0 - mask; // fade out at edge
}