extends HBoxContainer

# All property controls should have this signal
signal property_changed

var _val = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func set_value(new_value):
	_val = new_value
	
func _rotate(rotation):
	_val += rotation
	
	_val = clamp(_val, -360, 360)
	emit_signal("property_changed", {"key": "rotation", "value": _val})
	pass # Replace with function body.
