shader_type spatial;
render_mode unshaded, cull_disabled;

varying vec3 bary;
varying vec4 data;
varying vec3 world_normals;

const vec3 FORWARD = vec3(0.0,0.0,1.0);
const vec3 BACKARD = vec3(0.0,0.0,-1.0);
const vec3 LEFT = vec3(1.0,0.0,0.0);
const vec3 RIGHT = vec3(-1.0,0.0,0.0);
const vec3 UP = vec3(0.0,1.0,0.0);
const vec3 DOWN = vec3(0.0,-1.0,0.0);

const int UP_INDEX = 0;
const int DOWN_INDEX = 1;
const int LEFT_INDEX = 2;
const int RIGHT_INDEX = 3;
const int FORWARD_INDEX = 4;
const int BACK_INDEX = 5;

const int EMPTY = 0;
const int SURFACE = 1;
const int SELECTED = 2;
const int STARTING = 3;

uniform vec4 surface_wire_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 selected_wire_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 starting_wire_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float wire_width = 2.0;



int[6] process_faces(vec4 input_data){
	int[6] toReturn = int[6](0,0,0,0,0,0);
	int faces_mask = int(round(input_data.g * 63.0));
	toReturn[0] = (faces_mask>>0)&1;
	toReturn[1] = (faces_mask>>1)&1;
	toReturn[2] = (faces_mask>>2)&1;
	toReturn[3] = (faces_mask>>3)&1;
	toReturn[4] = (faces_mask>>4)&1;
	toReturn[5] = (faces_mask>>5)&1;
	return toReturn;
}

bool compareAngle(vec3 a, vec3 b){
	float d = dot(normalize(a), normalize(b));
	d = clamp(d, -1.0, 1.0);
	float angle = acos(d);
	if(angle <= 0.5){
		return true;
	}
	return false;
}

int getCurrentFace(vec3 normal){
	if(compareAngle(normal, UP)){
		return UP_INDEX;
	}
	if(compareAngle(normal, DOWN)){
		return DOWN_INDEX;
	}
	if(compareAngle(normal, LEFT)){
		return LEFT_INDEX;
	}
		if(compareAngle(normal, RIGHT)){
		return RIGHT_INDEX;
	}
	if(compareAngle(normal, FORWARD)){
		return FORWARD_INDEX;
	}
	return BACK_INDEX;
}


void vertex() {
	vec2 bary_xy = UV;
    bary = vec3(bary_xy.x, bary_xy.y, 1.0 - bary_xy.x - bary_xy.y);
	data = INSTANCE_CUSTOM;
	world_normals = normalize((mat3(MODEL_MATRIX) * NORMAL));
}

void fragment() {
    vec3 d = fwidth(bary);
    vec3 a3 = smoothstep(vec3(0.0), d * wire_width, bary);

    float edge = min(a3.x, a3.z);//min(min(a3.x, a3.y), a3.z);
	int style_mask = int(round(data.r*8.0));
	int[6] faces = process_faces(data);
	float alpha_mask = data.a;
	
	bool drawCurrentFace = faces[getCurrentFace(world_normals)] == 1;
	

    if(style_mask == EMPTY){
		drawCurrentFace = false;
	}else if(style_mask == SURFACE){
		ALBEDO = surface_wire_color.rgb;
	}else if(style_mask == SELECTED){
		ALBEDO = selected_wire_color.rgb;
	}else if(style_mask == STARTING){
		ALBEDO = starting_wire_color.rgb;
	}
	if(drawCurrentFace){
		ALPHA = alpha_mask - edge;
	}else{
		ALPHA = 0.0;
	}

}
