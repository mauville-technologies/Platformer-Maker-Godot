extends Control

signal tile_selected
signal close_requested

var wheels : Array
var selected_wheel = -1
var enabled = false setget _enabled

var base_wheel_scale = Vector2(0.65,0.65)

# Called when the node enters the scene tree for the first time.
func _ready():
    wheels = []
    pass # Replace with function body.

func add_wheel(wheel : Node2D):
    self.add_child(wheel)
    wheel.scale = base_wheel_scale
    wheel.position = Vector2(wheels.size() * 512, 0)
    wheels.append(wheel)
    if selected_wheel == -1:
        _change_to_wheel(0)
    _tween_to_new_positions()
    _enabled(false)
    
func _physics_process(delta):

    pass
    
func scroll_right():
    if enabled:
        _change_to_wheel(clamp(selected_wheel + 1, 0, wheels.size() -1))
    pass
    
func scroll_left():
    if enabled:
        _change_to_wheel(clamp(selected_wheel - 1, 0, wheels.size() -1))
    pass


func _change_to_wheel(new_index : int):
    # stop input on original wheel and disconnect selection signal
    if selected_wheel != -1:
        var old_wheel = wheels[selected_wheel]
        
        old_wheel.disconnect("option_selected", self, "_option_selected")
        old_wheel.enabled = false
              
    # start input on new wheel and connect selection signal    
    var new_wheel = wheels[new_index]
    new_wheel.connect("option_selected", self, "_option_selected")
    new_wheel.enabled = true
    
    selected_wheel = clamp(new_index, 0, wheels.size() - 1)
    
    _tween_to_new_positions()
    pass

func _enabled(new_val):
    enabled = new_val
    
    if selected_wheel != -1:
        var wheel = wheels[selected_wheel]
        if new_val && wheel.get_signal_connection_list("option_selected").size() == 0:
            wheel.connect("option_selected", self, "_option_selected")
            wheel.enabled = true && enabled
        elif !new_val && wheel.get_signal_connection_list("option_selected").size() != 0:
            wheel.disconnect("option_selected", self, "_option_selected")
            wheel.enabled = false
    pass
    
func _option_selected(tile):
    emit_signal("tile_selected", tile)
    pass

func _tween_to_new_positions():
    for index in range(wheels.size()):
        var wheel = wheels[index]
        
        var diff = selected_wheel - index
        
        var new_pos = Vector2(0,0)
        
        var scale_reduction = Vector2(0,0)
        
        if diff > 2:
            new_pos = get_node("%s" % [-3]).position
        elif diff < -2:
            new_pos = get_node("%s" % [3]).position
        else:
            new_pos = get_node("%s" % [diff * -1]).position
            
            scale_reduction = Vector2(1,1) * (0.2 * abs(diff))
            
        wheel.tween_to_new_position_and_scale(new_pos, base_wheel_scale - scale_reduction)
        pass
    pass


func _exit_selector():
    emit_signal("close_requested")
    pass # Replace with function body.
