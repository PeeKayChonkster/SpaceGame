shader_type canvas_item;
render_mode unshaded;

uniform float starLayers;
uniform float coloring;
uniform float scale;  // eats perfomance a bit, not as much as multiple layers

mat2 Rot(float a)
{
	float s = sin(a), c = cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

float Hash21(vec2 p)
{
	p = fract(p * vec2(452.58, 235.687));
	p += dot (p, p + 45.32);
	return fract(p.x * p.y);
}

float Star(vec2 uv, float flare)
{
	float dist = length(uv);
	float value = 0.03  / dist;
	float rays = max(0.0, 0.8 - abs(uv.x * uv.y * 1000.0));
	value += rays * flare;
	uv *= Rot(3.1415 / 4.0);
	rays = max(0.0, 0.8 - abs(uv.x * uv.y * 1000.0));
	value *= rays * 0.3 * flare;
	value *= smoothstep(0.2, 0.1, dist);
	return value;
}

vec3 StarLayer(vec2 uv)
{
	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv);
	vec3 value;
	//for(int x = -1; x <= 1; x++)
		//for(int y = -1; y <= 1; y++)
		//{
			vec2 offs;
			//offs.x = float(x);
			//offs.y = float(y);
			float n = Hash21(id); // random between 0 and 1
			float size = fract(n * 545.32);
			vec3 color = sin(vec3(0.2, 0.3, 0.9) * fract(n * 127.45) * coloring)*0.5 + 0.5;
			value += Star((gv /*- offs*/) - vec2(n, fract(n * 34.0)) + 0.5, 1.0);
			value *= size * 1.5;
			value *= color * vec3(1.0, 0.9, 1.3);
		//}
	return value;
}

void fragment()
{
	vec2 uv = SCREEN_UV * 2.0 - vec2(1.0);
	vec3 col = vec3(0.0);
	uv *= Rot(TIME / 2000.0);
	for(float i = 0.0; i < 1.0; i += 1.0 / starLayers)
	{
		col += StarLayer(uv * scale + i * 223.0);
	}
	//if(gv.x > 0.48 || gv.y > 0.48) value = 1.0;
	COLOR = vec4(col, 1.0);
}