extends GDDragonBones
class_name UniversePlayer

signal cleared_level
signal cleared_secret
signal request_player_move

onready var movement_tween = $MovementTween

var tween_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	movement_tween.connect("tween_all_completed", self, '_tweenFinished')
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("move_right"):
		emit_signal("request_player_move", 'right')
	if event.is_action_pressed("move_left"):
		emit_signal("request_player_move", 'left')
	if event.is_action_pressed("ui_up"):
		emit_signal("request_player_move", 'up')
	if event.is_action_pressed("ui_down"):
		emit_signal("request_player_move", 'down')
		
func goTo(point : Vector2):
	tween_queue.push_back(point)
	
	if tween_queue.size() == 1:
		_processNextTween()
		
func _processNextTween():
	var next_point = tween_queue[0]
	
	if next_point:
		movement_tween.interpolate_property(self, 'global_position', global_position, next_point, 1.0)
		movement_tween.start()

func _tweenFinished():
	tween_queue.pop_front()
	if tween_queue.size() != 0:
		_processNextTween()
