extends Node
class_name Input_Manager

var is_joypad = true

func _input(event):
    if event is InputEventMouseButton:
        is_joypad = false
        pass

    if event is InputEventJoypadButton || event is InputEventJoypadMotion:
        is_joypad = true
        pass

    pass
