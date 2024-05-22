#pragma header

uniform float time;

vec4 color(vec2 uv)
{
    if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >=0.0 && uv.y <=1.0)
    {
      return flixel_texture2D(bitmap, uv);
    }
    return vec4(0.0, 0.0, 0.0, 0.0);
}

void main()
{
	vec2 resolution = openfl_TextureSize;
	vec2 fragCoord = openfl_TextureCoordv * resolution;

	vec2 absorb_pos = openfl_TextureSize/2;
	vec2 uv = openfl_TextureCoordv;
    vec2 target = absorb_pos.xy /  resolution.xy;    
    
    // Gradualmente aumenta la distancia desde uv hacia target
    float progress = clamp(time * 0.07, 0.0, 1.0); // Limita el progreso entre 0 y 1
    vec2 pos = uv + normalize(uv - target) * progress;

    vec4 sprite = flixel_texture2D(bitmap, openfl_TextureCoordv);
	gl_FragColor = color(pos);
}
