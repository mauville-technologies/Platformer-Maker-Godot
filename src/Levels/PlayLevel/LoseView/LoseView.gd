extends CanvasLayer

onready var parent = get_parent()
onready var retry_button = $Control/Panel/Buttons/RetryButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func quit():
	parent.quit_to_menu()
	pass


func retry():
	parent.retry()
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	parent.stop_timer()
	retry_button.grab_focus()
	
	pass # Replace with function body.
