extends "res://src/Objects/Actors/Actor.gd"

func _ready():
	reset()

func _physics_process(delta):
	if is_on_floor():
		start_jump()
	pass

func collide_with_player(player):
	player.recoil(player.position - position, 600)
	recoil((position - player.position) * 2, 800)
	player.take_damage()
	pass


func reset():
	.reset()
	
	jump_strength = -1500
	pass

func get_stomped(player : Node):
	_start_death()
	pass
