extends CanvasLayer

onready var tilemap = get_node("/root/Tilemap")
onready var parent = get_parent()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap.resume()
	

	parent.start_timer()
	pass # Replace with function body.
