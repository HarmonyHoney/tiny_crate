shader_type canvas_item;

uniform vec2 offset  = vec2(0.0);

uniform vec2 size  = vec2(16, 9);
uniform sampler2D tex;
uniform vec2 frames = vec2(4, 4);
uniform int frame = 0;


void fragment(){
	vec2 fv = vec2(float(frame % int(frames.x)), floor(float(frame) / frames.y));
	
	COLOR = texture(tex, (mod(UV * size - offset, 1.0) + fv) / frames);
}