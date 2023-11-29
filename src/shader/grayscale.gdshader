shader_type canvas_item;

void fragment(){
	vec4 c = texture(TEXTURE, UV);
	float average = (c.r + c.g + c.b) / 3.0;
	COLOR = vec4(vec3(average), c.a);
}