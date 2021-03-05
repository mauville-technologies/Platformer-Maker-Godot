extends Node

signal jump_changed
signal move_x
signal move_y
signal running

onready var config = get_node("/root/Config")

var disabled = false

func _process(delta):
    _handle_input()
    pass

func _handle_input():
    if !disabled && get_parent().death_position == null:
        emit_signal('jump_changed', Input.is_action_pressed('jump'))
        
        if Input.is_action_pressed('move_right'):
            emit_signal('move_x', 1)
            pass
        elif Input.is_action_pressed('move_left'):
            emit_signal('move_x', -1)
            pass
        else:
            emit_signal('move_x', 0)
            pass
        
        if Input.is_action_pressed('move_up'):
            emit_signal('move_y', -1)
            pass
        elif Input.is_action_pressed('move_down'):
            emit_signal('move_y', 1)
            pass
        else:
            emit_signal('move_y', 0)
            pass
            
        emit_signal('running', Input.is_action_pressed('use'))
        
    else:
        emit_signal('move_x', 0)
    pass
