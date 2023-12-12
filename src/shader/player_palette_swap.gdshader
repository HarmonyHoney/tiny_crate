shader_type canvas_item;

uniform vec4 hat : hint_color = vec4(0.0);
uniform vec4 eye : hint_color = vec4(0.0);
uniform vec4 skin : hint_color = vec4(0.0);
uniform vec4 suit : hint_color = vec4(0.0);
uniform vec4 shoe : hint_color = vec4(0.0);

uniform vec4 hat_swap : hint_color = vec4(0.0);
uniform vec4 eye_swap : hint_color = vec4(0.0);
uniform vec4 skin_swap : hint_color = vec4(0.0);
uniform vec4 suit_swap : hint_color = vec4(0.0);
uniform vec4 shoe_swap : hint_color = vec4(0.0);


void fragment(){
	vec4 col = texture(TEXTURE, UV);
	
	if (col == hat){
		col = hat_swap;
	}
	else if (col == eye){
		col = eye_swap;
	}
	else if (col == skin){
		col = skin_swap;
	}
	else if (col == suit){
		col = suit_swap;
	}
	else if (col == shoe){
		col = shoe_swap;
	}
	
	COLOR = col;
}