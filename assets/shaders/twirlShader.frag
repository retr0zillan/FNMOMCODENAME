#pragma header

#define PI 3.1416
uniform float iTime;
void main()
{
	vec2 iResolution = openfl_TextureSize;
	vec2 fragCoord = openfl_TextureCoordv * iResolution;

	//map the xy pixel co-ordinates to be between -1.0 to +1.0 on x and y axes
	//and alter the x value according to the aspect ratio so it isn't 'stretched'
	vec2 p = (2.0 * fragCoord.xy / iResolution.xy - 1.0) 
			* vec2(iResolution.x / iResolution.y, 1.0);

	//now, this is the usual part that uses the formula for texture mapping a ray-
	//traced cylinder using the vector p that describes the position of the pixel
	//from the centre.
	vec2 uv = vec2(atan(p.y, p.x) * 1.0/PI, 1.0 / sqrt(dot(p, p))) * vec2(2.0, 1.0);
	
	
	//now this just 'warps' the texture read by altering the u coordinate depending on
	//the val of the v coordinate and the current time
	uv.x += sin(2.0 * uv.y + iTime * 0.5);
		
	vec3 c = flixel_texture2D(bitmap, uv).xyz
		
	//this divison makes the color value 'darker' into the distance, otherwise
    //everything will be a uniform brightness and no sense of depth will be present.
			/ (uv.y * 0.5 + 1.0);
	vec4 sprite = flixel_texture2D(bitmap, openfl_TextureCoordv);
	gl_FragColor = vec4(c, 0.5);
}