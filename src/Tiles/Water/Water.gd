extends "res://src/Objects/Actors/Actor.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_collision_node = "BodyCollision"
	
	pass # Replace with function body.



func _player_entered(body):
	if body.has_method('enter_water'):
		body.enter_water(name)


func _player_exit(body):
	if body.has_method('exit_water'):
		body.exit_water(name)
