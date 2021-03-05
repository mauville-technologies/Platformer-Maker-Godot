extends Node2D

onready var tilemap = get_node("/root/Tilemap")

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_game()
	pass # Replace with function body.

func _go_to_builder():
	get_parent().go_to_builder()
	pass

func pause(is_paused):
	if is_paused:
		tilemap.pause()
	else:
		tilemap.resume()

func _start_game():
	tilemap.reset()
	tilemap.resume()

func _physics_process(delta):
	pass
	
func _process(delta):
	_check_for_return_to_builder()

func _check_for_return_to_builder():
	if Input.is_action_just_pressed("builder_test_mode"):
		_go_to_builder()
		
