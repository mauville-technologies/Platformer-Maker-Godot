extends CanvasLayer


onready var _anchor = $Anchor

onready var _top = $Anchor/Top
onready var _bottom = $Anchor/Bottom

# Called when the node enters the scene tree for the first time.
func _ready():
    for child in _top.get_children():
        if child.has_method('set_pan'):
            child.set_pan(Vector2(0,0))
    
    for child in _bottom.get_children():
        if child.has_method('set_pan'):
            child.set_pan(Vector2(0,0))   
    pass # Replace with function body.


func set_anchor(_new_pos : Vector2):
    int(_new_pos.y) % 1080
    # I can do autoscrolling here with real position
    var pan_uv_x = _new_pos.x / 1920.0
    var pan_uv_y = _new_pos.y / 1080.0
    
    for child in _top.get_children():
        if child.has_method('set_pan'):
            child.set_pan(Vector2(-pan_uv_x, -pan_uv_y))
    
    for child in _bottom.get_children():
        if child.has_method('set_pan'):
            child.set_pan(Vector2(-pan_uv_x, -pan_uv_y))
            
    # then set the component
    if (_new_pos.y < 0):
        _anchor.position = Vector2(0, clamp(int(572+_new_pos.y), 0, 1080))
        
        return

    _anchor.position = Vector2(0, clamp(int(_new_pos.y+572), 0, 1080))
    pass 
