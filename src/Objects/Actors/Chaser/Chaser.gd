extends "res://src/Objects/Actors/Actor.gd"

onready var rng = RandomNumberGenerator.new()
onready var roll = $AnimationPlayer
onready var _ground_checker = $GroundChecker

func _ready():
	reset()

func _physics_process(delta):
	._physics_process(delta)
	
	if !is_paused && !_dying:
		
		if _velocity.x != 0:
			var sprite = get_node("Sprite")
			$GroundChecker.scale.x = abs($GroundChecker.scale.x) if _velocity.x > 0 else abs($GroundChecker.scale.x) * -1
		
		if is_on_floor() and !_ground_checker.is_colliding():
			_holding_jump = true
		elif is_on_floor():
			_holding_jump = false
			
			
		var jumpRand = rng.randf_range(0, 1)
		if (jumpRand < 0.01):
			#start_jump()
			pass
		if is_on_wall():
			_directional_inputs.x = -_directional_inputs.x
			_start_roll()

		if !roll.is_playing() && !is_paused:
			_start_roll()
		
				
func get_stomped(player : Node):
   # player.recoil(Vector2.UP, 600)
	_start_death()
	pass
	
func collide_with_player(player):
	if !_dying:
		player.recoil(player.position - position, 600)
		recoil((position - player.position) * 2, 600)
		player.take_damage()

	pass
	
func _start_roll():
	if _directional_inputs.x < 0:
		roll.play("Roll Left")
	else:
		roll.play("Roll")
	
func stop_physics(stop : bool):
	.stop_physics(stop)
	
	if roll == null:
		return
		
	if stop:
		roll.stop()
	else:
		_start_roll()
			
	pass
	
func reset():
	.reset()
	
	rng.randomize()
	walk_speed = 100
	jump_strength = -500
	gravity_multiplier = 0.3
	var directionRand = rng.randi_range(0, 99)
	var isLeft = directionRand % 2 == 0

	if isLeft:
		_directional_inputs.x = -1
	else:
		_directional_inputs.x = 1

	pass
