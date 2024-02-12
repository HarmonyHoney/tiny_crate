shader_type canvas_item;

uniform vec4 c0 : hint_color = vec4(0.0);
uniform vec4 s0 : hint_color = vec4(0.0);
uniform vec4 c1 : hint_color = vec4(0.0);
uniform vec4 s1 : hint_color = vec4(0.0);
uniform float flip : hint_range(0.0, 1.0) = 0.0;

void fragment(){
	vec4 col = texture(TEXTURE, UV);
	
	if (col == c0){
		col = mix(s0, s1, flip);
	}
	else if (col == c1){
		col = mix(s1, s0, flip);
	}
	
	COLOR = col;
}