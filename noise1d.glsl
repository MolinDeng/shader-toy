float hash_1d(int x) {
    return fract(sin(float(x) * 17.9898) * 43758.5453);
}

float noise_linear(float x) {
    int i = int(x);
    float f = fract(x);
    float h0 = hash_1d(i);
    float h1 = hash_1d(i+1);
    float h = mix(h0, h1, f);
    
    return h;
} 

float noise_smooth(float x) {
    int i = int(x);
    float f = fract(x);
    float h0 = hash_1d(i);
    float h1 = hash_1d(i+1);

    f = smoothstep(0.0, 1.0, f);
    float h = mix(h0, h1, f);
    
    return h;
}

float noise_gradient(float x) {
    int i = int(x);
    float f = fract(x);
    float s = smoothstep(0.0, 1.0, f);

    float g0 = hash_1d(i);
    float g1 = hash_1d(i+1);

    float h = mix(f * g0, (f - 1.0) * g1, s);
    return h;
}


float noise_octave(float x) {
	float sum = 0.0;
	for(int i = 0; i < 5; i++)
		sum += pow(2.0, -1.0*float(i)) * noise_gradient(pow(2.0, float(i)) * x);

    return sum;
}

vec4 step1(vec2 uv) {
    float h = noise_linear(uv.x);
    h = 0.3 + 0.4 * h; // map to [0.3, 0.7]
    vec3 col = vec3(step(h, uv.y));
    return vec4(col, 1.0);
}

vec4 step2(vec2 uv) {
    float h = noise_smooth(uv.x);
    h = 0.3 + 0.4 * h; // map to [0.3, 0.7]
    vec3 col = vec3(step(h, uv.y));
    return vec4(col, 1.0);
}

vec4 step3(vec2 uv) {
    float h = noise_gradient(uv.x);
    h += 0.5; // level up it a bit
    vec3 col = vec3(step(h, uv.y));
    return vec4(col, 1.0);
}

vec4 step4(vec2 uv) {
    float h = noise_octave(uv.x);
    h += 0.5; // level up it a bit
    vec3 col = vec3(step(h, uv.y));
    return vec4(col, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv.x = uv.x * 5.0;
    // linear interpolation
    fragColor = step1(uv);
    // smooth interpolation
    fragColor = step2(uv);
    // gradient interpolation
    fragColor = step3(uv);
    // octave
    fragColor = step4(uv);
}