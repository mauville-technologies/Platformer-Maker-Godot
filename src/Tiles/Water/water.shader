shader_type canvas_item;

// Gonkee's water shader for Godot 3 - full tutorial https://youtu.be/uhMAHpV_cDg
// If you use this shader, I would prefer if you gave credit to me and my channel

uniform vec4 blue_tint : hint_color;

uniform vec2 sprite_scale;
uniform float scale_x = 0.47;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

void fragment(){
	
	vec2 noisecoord1 = UV * sprite_scale * scale_x;
	vec2 noisecoord2 = UV * sprite_scale * scale_x + 4.0;
	vec2 noisecoord3 = UV * sprite_scale * scale_x + 7.0;
	vec2 noisecoord4 = UV * sprite_scale * scale_x - 7.0;
    vec2 noisecoord5 = UV * sprite_scale * scale_x + 1.0;
	vec2 noisecoord6 = UV * sprite_scale * scale_x - 1.0;
    
	vec2 motion1 = vec2(TIME * 0.66, TIME * -0.7);
	vec2 motion2 = vec2(TIME * 0.75, TIME * 2.5);
    vec2 motion3 = vec2(TIME * -0.66, TIME * -0.7);
	vec2 motion4 = vec2(TIME * 1.75, TIME * 0.5);
    vec2 motion5 = vec2(TIME * 1.66, TIME * -2.7);
	vec2 motion6 = vec2(TIME * 3.75, TIME * 1.5);
	
	vec2 distort1 = vec2(noise(noisecoord1 + motion1), noise(noisecoord2 + motion1)) - vec2(0.5);
	vec2 distort2 = vec2(noise(noisecoord1 + motion2), noise(noisecoord2 + motion2)) - vec2(0.5);
	vec2 distort3 = vec2(noise(noisecoord3 + motion3), noise(noisecoord4 + motion3)) - vec2(0.5);
	vec2 distort4 = vec2(noise(noisecoord3 + motion4), noise(noisecoord4 + motion4)) - vec2(0.5);
	vec2 distort5 = vec2(noise(noisecoord5 + motion5), noise(noisecoord6 + motion5)) - vec2(0.5);
	vec2 distort6 = vec2(noise(noisecoord5 + motion6), noise(noisecoord6 + motion6)) - vec2(0.5);
	
	vec2 distort_sum = (distort1 + distort2 + distort3 + distort4 + distort5 + distort6) / 180.0;
	
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV + distort_sum, 0.0);
	
	color = mix(color, blue_tint, 0.3);
	color.rgb = mix(vec3(0.5), color.rgb, 1.4);


	
	COLOR = color;
}