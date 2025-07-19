shader_type spatial;
render_mode unshaded;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform sampler3D noise;

varying float lookDot;

void vertex() {

	// stole code from https://godotshaders.com/shader/stylized-metal/
	vec3 worldNormal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	vec3 lookDir = normalize((MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz - (INV_VIEW_MATRIX * vec4(EYE_OFFSET, 1.0)).xyz);

	lookDot = abs(dot(lookDir, worldNormal));
}

void fragment() {

	// sample texture (VERTEX is in view space, must go to world space)
	float sample = texture(noise, (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz - NODE_POSITION_WORLD + vec3(TIME * 0.03, 0, 0)).x;

	// two color areas
	vec4 color = mix(color1, color2, step(0.5, sample));

	// white band between colors
	color = mix(color, vec4(1,1,1,0.5), clamp(1.0 - 1000.0 * pow(sample - 0.5, 2), 0.0, 1.0));

	// rim light
	color = mix(vec4(1,1,1,0.2), color, clamp((1.0 - 4.0 * pow(lookDot - 0.5, 2)), 0.0, 1.0));

	ALBEDO = vec3(color.r, color.g, color.b);
	ALPHA = color.a;
}
