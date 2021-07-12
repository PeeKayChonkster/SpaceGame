shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise;
uniform float xRotation: hint_range(0.0, 0.5);
uniform float yRotation: hint_range(0.0, 0.5);
uniform vec4 color: hint_color;
uniform float brightness: hint_range(0.0, 1.0);

void fragment()
{
	vec2 uv = vec2(UV.x + xRotation * TIME, UV.y + yRotation * TIME);
	COLOR = texture(TEXTURE, UV);
	float a = COLOR.a;
	COLOR *= texture(noise, uv) + (color * brightness);
	COLOR.a = a;
}