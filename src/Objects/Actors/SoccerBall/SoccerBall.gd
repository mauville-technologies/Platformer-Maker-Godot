extends "res://src/Objects/Actors/Actor.gd"

func _ready():
	bounce_coefficient = 1.0
	pass

func _physics_process(delta):
	
	pass

func collide_with_player(player):
	player.recoil(player.position - position, 10)
	recoil((position - player.position), 15)
	
	pass
