extends CanvasLayer

onready var parent = get_parent()
onready var rating_progress = $Control/Panel/TextureProgress
onready var rating_slider = $Control/Panel/TextureProgress/HSlider

onready var current_time_label = $Control/Panel/CurrentTime/ColorRect2/CurrentTimeLabel
onready var best_time_label = $Control/Panel/BestTime/ColorRect2/BestTimeLabel
onready var world_record_label = $Control/Panel/WorldRecord/ColorRect2/WorldRecordLabel

var _rating = 2.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func quit():
	parent.quit_to_menu()
	pass


func retry():
	parent.retry()
	pass
	

func next():
	pass 


# Called when the node enters the scene tree for the first time.
func _ready():
	parent.stop_timer()
	rating_slider.grab_focus()
	_update_rating()
	
	current_time_label.text = parent.get_time_label(parent._elapsed_time)
	pass # Replace with function body.

func _on_rating_change(value):
	_rating = value
	_update_rating()
	pass

func _update_rating():
	rating_slider.value = _rating
	rating_progress.value = _rating
