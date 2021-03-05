class_name Actor

extends KinematicBody2D

onready var config = get_node("/root/Config")

export(bool) var _floating : bool = false
export(bool) var _static : bool = false
export(float) var gravity_multiplier = 1.0
export(float) var bounce_coefficient = 0.0
export(float) var friction_multiplier = 1.0

# TODO: These will need to be defined as components that can be inherited by objects in the future
var _default_properties = ['rotation', 'scale']

var is_paused = false
var last_ground_position = null
var death_position = null
var time_since_on_floor = 0
var _velocity : Vector2 = Vector2()
var _crouching : bool = false
var _directional_inputs : Vector2 = Vector2(0, 0)
var _running = false
var _uncrouch_detector : RayCast2D
var _collision_node : String = "BodyCollision"
var _sprite_node : String = "Sprite"
var _floor_detector : RayCast2D

var _crouching_polygon : Array = [Vector2(-5,9),Vector2(5,9),Vector2(5,-1.5),Vector2(-5,-1.5)]
var _standing_polygon : Array = [Vector2(-5,9),Vector2(5,9),Vector2(5,-6.5),Vector2(-5,-6.5)]

var _dying = false

var _last_frame_jump : bool = false
var _jump_cancelled : bool = false
var _holding_jump : bool = false

var walk_speed : int = 300
var run_speed : int = 600
var jump_strength : int = 200

var _is_in_water : bool = false

var _touching_water_tiles : Array

func _ready():
	walk_speed = config._get_setting("PLAYER_WALK_SPEED")
	run_speed = config._get_setting("PLAYER_MAX_SPEED")
	jump_strength = config._get_setting("JUMP_STRENGTH")
	
	pass
	
func _physics_process(delta):
	if !is_paused:
		_process_play(delta)
	pass

func _process_play(delta):
	_check_if_in_water()
	_check_if_crouching()
	_update_collision_polygon()
	_apply_gravity()
	_move()
	
	if !is_on_floor():
		time_since_on_floor += delta
	else:
		time_since_on_floor = 0

	if !_static:
		if bounce_coefficient != 0:
			var collision = move_and_collide(_velocity * delta)
			if collision:
				_velocity = _velocity.bounce(collision.normal) * bounce_coefficient
				collision = move_and_collide(_velocity * delta)
				if collision:
					_velocity = _velocity.slide(collision.normal)
		else:
			_velocity = move_and_slide_with_snap(_velocity, -_floor_detector.get_collision_normal() if _floor_detector != null else Vector2.UP, Vector2.UP, !_crouching)
	
	pass
	
func _check_if_in_water():
	_is_in_water = _touching_water_tiles.size() != 0
	
	pass
	
func _move():
	if !is_paused:
		if !_last_frame_jump && _holding_jump:
			start_jump()
			
		var friction = _directional_inputs.x == 0 || (_crouching && is_on_floor())
		if !is_on_floor():
			if _directional_inputs.x != 0:
				_velocity.x += (_directional_inputs.x * config._get_setting("PLAYER_ACCELERATION"))
				
			if friction:
				_velocity.x = lerp(_velocity.x, 0, (config._get_setting("PLAYER_WEIGHT") / 4))
				
			if _velocity.y < 0 && !_jump_cancelled:
				if !_holding_jump && bounce_coefficient == 0:
					_velocity.y = _velocity.y / 2
					_jump_cancelled = true
				
		else:
			if _directional_inputs.x != 0 && !_crouching:
				_velocity.x += _directional_inputs.x * config._get_setting("PLAYER_ACCELERATION")
			
			if friction && _crouching:
				_velocity.x = lerp(_velocity.x, 0, config._get_setting("PLAYER_WEIGHT")/6)
								
			elif friction:
				_velocity.x = lerp(_velocity.x, 0, config._get_setting("PLAYER_WEIGHT"))
				
		var max_speed = run_speed if _running and not _is_in_water else walk_speed
		
		_velocity.x = clamp(_velocity.x, -max_speed, max_speed)
	pass

func _check_if_crouching():
	if _uncrouch_detector != null:
		if is_on_floor():
			_crouching = _uncrouch_detector.is_colliding() || _directional_inputs.y > 0
		else:
			_crouching = (_uncrouch_detector.is_colliding() || _directional_inputs.y > 0) && _crouching       

		
	pass

func _update_collision_polygon():
	if _collision_node == "":
		return
	
	var collision = get_node(_collision_node)
	
	if collision != null && collision is CollisionPolygon2D:
		if _crouching:
			collision.set_polygon(_crouching_polygon)
		else:
			collision.set_polygon(_standing_polygon)
	
func stop_physics(stop : bool):
	is_paused = stop
	
func _apply_gravity():
	if _is_in_water && !_floating:
		_velocity.y += config._get_setting("GRAVITY") * gravity_multiplier * 0.3
		_velocity.y = clamp(_velocity.y, config._get_setting("GRAVITY") * -15, config._get_setting("GRAVITY") *  10)
		return
		
	if (!is_on_floor() || _crouching) && !_floating:
		_velocity.y += config._get_setting("GRAVITY") * gravity_multiplier
		
	pass    

func can_jump():
	return is_on_floor() || time_since_on_floor <= 0.075

func should_fall():
	return !is_on_floor() && time_since_on_floor > 0.075

func start_jump(force : bool = false):
	if !is_paused:
		if _is_in_water:
			paddle()
			_jump_cancelled = false
			_velocity.y = jump_strength
			return
		if can_jump() || force:
			_jump_cancelled = false
			_velocity.y = jump_strength

func end_jump():
	if !is_paused:
		pass

func reset():
	_velocity = Vector2(0,0)
	
	_touching_water_tiles = []

	_dying = false
	if _collision_node != "":
		var collision = get_node(_collision_node)
		
		if collision != null:
			collision.set_deferred("disabled", false)
	visible = true
	
func recoil(direction_vector : Vector2, strength : int):
	_velocity = direction_vector * strength
	pass

func _start_death():
	_dying = true
	
	var collision = get_node(_collision_node)
	
	if collision != null:    
		collision.set_deferred("disabled", true)
	_die()
	pass
	
func _die():
	visible = false
	pass

func move_y(direction):
	_directional_inputs.y = direction
	pass
	
func move_x(direction):
	_directional_inputs.x = direction
	
func jump_changed(is_holding_jump):
	_last_frame_jump = _holding_jump
	_holding_jump = is_holding_jump
	pass

func init_properties(properties : Dictionary):
	for key in properties.keys():
		var property = properties[key]
		update_property({"key": key, "value": property})
	
func update_property(property : Dictionary):
	match property.key:
		"rotation":
			rotation_degrees = property.value
	pass

func enter_water(water_object_name : String):
	_touching_water_tiles.append(water_object_name)
		
	pass

func paddle():
	
	pass
	
func exit_water(water_object_name):
	var index = _touching_water_tiles.find(water_object_name)
	if index != -1:
		_touching_water_tiles.remove(index)
		
	pass


func _play_animation(animation_name : String, loop : int = -1, restart := false): 
	var sprite_node = get_node(_sprite_node)
	if sprite_node is GDDragonBones && (sprite_node.get("playback/curr_animation") != animation_name || restart):
			sprite_node.stop_all()
			sprite_node.set("playback/curr_animation", animation_name)                
			sprite_node.set("playback/loop", loop)                
			sprite_node.play(true)

func _stop_all_animations():
	var sprite_node = get_node(_sprite_node)
	
	if sprite_node is GDDragonBones:
		sprite_node.stop_all()
