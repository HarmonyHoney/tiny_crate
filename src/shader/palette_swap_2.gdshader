shader_type canvas_item;

uniform vec4 c0 : hint_color = vec4(0.0);
uniform vec4 s0 : hint_color = vec4(0.0);
uniform vec4 c1 : hint_color = vec4(0.0);
uniform vec4 s1 : hint_color = vec4(0.0);

void fragment(){
	vec4 col = texture(TEXTURE, UV);
	
	if (col == c0){
		col = s0;
	}
	else if (col == c1){
		col = s1;
	}
	
	COLOR = col;
}