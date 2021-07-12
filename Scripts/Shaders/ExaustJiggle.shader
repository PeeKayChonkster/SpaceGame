shader_type canvas_item;
render_mode unshaded;

uniform float jiggle: hint_range(0.0, 10.0);
uniform float seed: int = 0;

void vertex()
{
	VERTEX += vec2(cos(TIME * jiggle * 10.0 + seed) * sqrt(UV.y * 0.1), sin(TIME * jiggle * 10.0 + seed) * UV.y) * jiggle;
}