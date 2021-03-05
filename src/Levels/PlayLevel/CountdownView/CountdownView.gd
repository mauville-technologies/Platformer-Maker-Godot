extends CanvasLayer


onready var play_level = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func count_down_done():
	play_level.is_playing = true
	pass
