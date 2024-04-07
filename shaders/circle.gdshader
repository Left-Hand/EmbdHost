shader_type canvas_item;


float length(const vec2 uv){
	return sqrt(uv.x * uv.x + uv.y * uv.y);
}

float decrease(const float x, const float limit, const float k){
	return max(1.0 - max(x - limit, 0) * k, 0);
}

void fragment(){
	vec2 uv = UV * 2.0f - vec2(1.0f);
	COLOR.a *= decrease(length(uv), 0.98, 64.0);
}