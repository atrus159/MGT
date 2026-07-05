shader_type spatial;
render_mode unshaded;

uniform vec4 wire_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float wire_width = 2.0;

varying vec3 bary;


void vertex() {
	vec2 bary_xy = UV;
    bary = vec3(bary_xy.x, bary_xy.y, 1.0 - bary_xy.x - bary_xy.y);

}

void fragment() {
    vec3 d = fwidth(bary);
    vec3 a3 = smoothstep(vec3(0.0), d * wire_width, bary);

    float edge = min(a3.x, a3.z);//min(min(a3.x, a3.y), a3.z);
	
	float lineAlpha = 0.3;
	float surfaceAlpha = 0.1;
	ALPHA = mix(lineAlpha, surfaceAlpha, edge);
    ALBEDO = wire_color.rgb;

}
