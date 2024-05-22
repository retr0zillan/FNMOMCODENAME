
#pragma header
uniform float iTime;
mat2 rot_dist(float s, float d)
{
    float angularspeed = s * pow(d, 8.0);
    float cas = cos(angularspeed);
    float sas = sin(angularspeed);
    return mat2(vec2(cas, -sas), vec2(sas, cas));
}

void main()
{
    vec3 ring_color = vec3(0.976, 0.200, 0.023);
	vec2 iResolution = openfl_TextureSize;
    vec2 fragCoord = openfl_TextureCoordv * iResolution;
    vec2 uv = fragCoord/iResolution.xy;
    float ratio = iResolution.y/iResolution.x;
    uv.y *= ratio;



    vec2 center = (iResolution.xy * .5f) / iResolution.xy;
    center.y *= ratio;

    float _dist = distance(uv, center);
    float _s = .15;
    float _a = .005;
    vec2 uvp = uv + min(textureCam(bitmap, _s * vec2(uv.x + iTime * .1, uv.y + iTime * -.3)).r,
                        textureCam(bitmap, _s * vec2(uv.x + iTime * -.3, uv.y + iTime * .2)).r) * _a * pow(1. - _dist, 5.);
    
    float dist = distance(uvp, center);
    float idist = 1.0 - dist;
    vec2 dir =openfl_TextureCoordv*2;
    
    // Mask
    float m = step(.06, dist);
    m *= smoothstep(.065, .08, dist);
    m = (1.0 - dist * 1.6) * 2. * m;
	float mask = m;
    
    // Phases
    float speed = -0.06;
    float phase1 = fract(iTime * speed + .5);
    float phase2 = fract(iTime * speed);
    
    float pidist = pow(idist, 2.3);
    vec2 uv1 = (dir * pidist * .2) + phase1 * dir;
    vec2 uv2 = (dir * pidist * .2) + phase2 * dir;
    
    // Samplings
    float lerp = abs((.5 - phase1) / .5);
    float sampling1 = textureCam(bitmap, uv1 * rot_dist(2.4, idist)).r;
    float sampling2 = textureCam(bitmap, uv2 * rot_dist(2.4, idist)).r;
    
    float sampling3 = textureCam(bitmap, uv1 * 2. * rot_dist(2.6, idist)).g;
    float sampling4 = textureCam(bitmap, uv2 * 2. * rot_dist(2.6, idist)).g;
    
    float sampling5 = textureCam(bitmap, uv1 * rot_dist(4.6, idist) * .4).r;
    float sampling6 = textureCam(bitmap, uv2 * rot_dist(4.6, idist) * .6).r;
    
    float stars = (1. - smoothstep(0.22, 0.34, mix(sampling3, sampling4, lerp))) * 0.4;
    
    vec3 sp = mix(sampling1, sampling2, lerp) * vec3(1.);
    sp *= 0.2;
   	
		vec4 sprite = textureCam(bitmap, openfl_TextureCoordv);

    sp += smoothstep(0.26, 0.14, mix(sampling5, sampling6, lerp))  * pow(idist, 8.) * ring_color;
    
    vec3 finalSamp = sp;
    vec3 col = ring_color * pow(1.0 - dist, 7.);
    float ring = pow(smoothstep(.32, .08, dist * 1.5) * 3.5, 2.8) + 1.;

    
    gl_FragColor = vec4(finalSamp * mask + 1.2 * ring * mask  * col * sprite.rgb, sprite.a);
}