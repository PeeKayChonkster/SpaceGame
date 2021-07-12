shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D atmoNoise;

uniform float xRotation: hint_range(0.0, 0.5);
uniform float yRotation: hint_range(0.0, 0.5);
uniform float waterLevel: hint_range(0.0, 1.0);
uniform float atmoLevel: hint_range(0.0, 1.0);
uniform vec4 waterColor: hint_color;
uniform vec4 landColor: hint_color;
uniform vec4 atmoColor: hint_color;
uniform float brightness: hint_range(0.0, 1.0);
//uniform float seed;

/*
float Noise(vec2 uv)
{
	uv = mod(uv, 10000.0);
	float s = seed + 1.0;
	return fract(sin(dot(uv, vec2(s + 12.48, s + 44.15)))* s * 27.458);
}
*/

void fragment()
{
	vec2 uv1 = vec2(UV.x + xRotation * TIME, UV.y + yRotation * TIME);
	vec2 uv2 = vec2(UV.x - xRotation * TIME, UV.y - yRotation * TIME);
	COLOR = texture(TEXTURE, UV);
	float a = COLOR.a;
	vec4 noiseVec = texture(noise, uv1);
	vec4 atmoNoiseVec = texture(atmoNoise, uv2);
	COLOR = (step(noiseVec.x, waterLevel)) * (waterColor * brightness) + (1.0-step(noiseVec.x, waterLevel)) * (landColor * brightness);	// water and land
	COLOR += (1.0 - step(atmoNoiseVec.x, atmoLevel)) * (atmoColor * brightness);	// atmosphere
	COLOR.a = a;
}