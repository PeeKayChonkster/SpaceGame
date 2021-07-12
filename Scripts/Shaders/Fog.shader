shader_type canvas_item;
render_mode unshaded;


uniform float PERIOD;
uniform float density : hint_range(0.0, 1.0);
uniform vec2 shift;
uniform vec4 color : hint_color;
uniform float speed : hint_range(0.0, 0.1);
uniform sampler2D noiseTex;


float noise(vec2 coord)
{
	return texture(noiseTex, coord).r;
}

void fragment()
{
	vec2 uv = vec2(SCREEN_UV.x, SCREEN_UV.y * (SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y));
	vec2 coord = uv * PERIOD;
	COLOR = vec4(color.rgb, noise(coord + shift + TIME * speed) * color.a - density);
}