shader_type canvas_item;
uniform float pan_x;
uniform float pan_y;

void fragment() {
    vec2 shifted_uv = UV;
    shifted_uv.x = shifted_uv.x + pan_x;
    shifted_uv.y = shifted_uv.y + pan_y ;
    
    vec4 col = texture(TEXTURE, shifted_uv);
    
    COLOR = col;    
}