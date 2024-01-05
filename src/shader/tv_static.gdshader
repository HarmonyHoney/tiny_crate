shader_type canvas_item;

uniform vec2 mouse_pos;
uniform float vsync_issues;

float noise(float time, vec2 st) {
	return fract(sin(dot(st.xy * vsync_issues, vec2(time, time * 13352.0) * mouse_pos)) * 8282.0);
}

void fragment() {
	vec2 st = UV.xy / (1.0 / SCREEN_PIXEL_SIZE.xy);
	vec4 random = vec4(vec3(noise(TIME, st)), 1.0);
	COLOR = random;
}