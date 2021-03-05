extends "res://src/Objects/Actors/Actor.gd"

func _ready():

	pass

func _physics_process(delta):

	pass

func collide_with_player(player):
	player.win()
	pass
