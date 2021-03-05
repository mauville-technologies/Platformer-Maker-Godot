extends CanvasLayer

onready var tilemap = get_node("/root/Tilemap")
onready var countdown_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_game()
	pass # Replace with function body.

func _go_to_builder():
	get_parent().go_to_builder()
	pass

func count_down_done():
	tilemap.resume()    
	pass
	
func pause(is_paused):
	if is_paused:
		tilemap.pause()
	else:
		tilemap.resume()
	pass

func _start_game():
	tilemap.reset()
	tilemap.pause()
	countdown_player.play("count_down")

func _process(delta):
	_check_for_return_to_builder()
	pass

func _check_for_return_to_builder():
	if Input.is_action_just_pressed("builder_test_mode"):
		_go_to_builder()
		
	pass

func reset_level():
	_start_game()
	
func _physics_process(delta):
	pass
