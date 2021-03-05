extends TextureRect

export(Vector2) var speed_multiplier = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
    self.material = self.material.duplicate()
    pass # Replace with function body.

func set_pan(_pan_position : Vector2):

    self.material.set_shader_param("pan_y", _pan_position.y * speed_multiplier.y)
    self.material.set_shader_param("pan_x", _pan_position.x * speed_multiplier.x)
    
    pass

