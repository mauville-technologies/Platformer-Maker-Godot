extends Area2D


func _input_event(viewport, event, shape_idx):
    get_parent().on_click(viewport, event, shape_idx)
# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

