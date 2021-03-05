extends Panel

signal property_changed

onready var rotation_control = $VBoxContainer/RotationControl

func _ready():
	rotation_control.connect("property_changed", self, "_property_changed")
	rotation_control.set_value(0)
	pass # Replace with function body.

func _property_changed(property : Dictionary):
	emit_signal("property_changed", property)

func set_properties(properties : Dictionary): 
	for key in properties.keys():
		var value = properties[key]
		match key:
			"rotation":
				rotation_control.set_value(value)
	pass
	
func reset(properties):
	rotation_control.set_value(0)    
	set_properties(properties)
