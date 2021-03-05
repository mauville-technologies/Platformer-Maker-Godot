extends "res://src/Objects/Actors/Actor.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	#_crouching_polygon = [Vector2(-5,9),Vector2(5,9),Vector2(5,-1.5),Vector2(-5,-1.5)]
	#_standing_polygon = [Vector2(-32,32),Vector2(0,-32),Vector2(32,32)]
	pass
	
func collide_with_player(player):
	player.recoil(player.position - position, 500)
	player.take_damage()

	pass
