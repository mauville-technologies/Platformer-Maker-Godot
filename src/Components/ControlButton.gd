extends TextureRect


export(Texture) var _joypad_texture
export(Texture) var _keyboard_texture

onready var input_manager = get_node("/root/InputManager")
# Called when the node enters the scene tree for the first time.
func _ready():

    pass # Replace with function body.

func _process(delta):
    if input_manager.is_joypad:
        if texture != _joypad_texture:
            texture = _joypad_texture
    else:
        if texture != _keyboard_texture:
            texture = _keyboard_texture
    pass
