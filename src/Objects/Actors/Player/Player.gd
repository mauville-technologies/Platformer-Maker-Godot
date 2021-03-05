extends "res://src/Objects/Actors/Actor.gd"
class_name Player

signal player_died
signal player_won

onready var sprite_node = $Sprite
onready var input = $PlayerInputHandler
onready var enemy_collision_node = $EnemyDetector.get_node('Collision')
onready var stomper = $Stomper
onready var header = $Header
onready var tilemap = get_node("/root/Tilemap")

var _items_on_top = {}

func _ready():
	_floor_detector = get_node("FloorDetector")
	_uncrouch_detector = get_node("UncrouchDetector")
	input.connect("jump_changed", self, "jump_changed")
	input.connect("move_x", self, "move_x")
	input.connect("move_y", self, "move_y")
	input.connect("running", self, "running")
	
	sprite_node.connect("dragon_anim_event", self, "_animation_event")
   # sprite_node.play_child_animation_on_slot("hat_spin", "hat")
	#sprite_node.set_slot_display_index("hat", 1)
	pass

func _animation_event(event_dict : Dictionary):
	if event_dict.event_name == 'paddledone':
		if sprite_node.get("playback/curr_animation") == "SwimPaddle":
			sprite_node.stop_all()
			sprite_node.set("playback/curr_animation", "SwimIdle")                
			sprite_node.set("playback/loop", 1)                
			sprite_node.play(true)
		
func _process_play(delta):
	._process_play(delta)
 
	_animate()
	pass

func _check_if_crouching():
	._check_if_crouching()
	
	if _crouching:
		enemy_collision_node.set_polygon([Vector2(-5.5,9.25),Vector2(5.5,9.25),Vector2(5.5,-1.75),Vector2(-5.5,-1.75)])
		header.get_node("Collision").set_polygon([Vector2(-4.5,-1.75),Vector2(4.5,-1.75),Vector2(4.5,-4.25),Vector2(-4.5,-4.25)])
	else:
		enemy_collision_node.set_polygon([Vector2(-6.5,9.25),Vector2(6.5,9.25),Vector2(6.5,-6.75),Vector2(-6.5,-6.75)])            
		header.get_node("Collision").set_polygon([Vector2(4.5,-6.75),Vector2(-4.5,-6.75),Vector2(-4.5,-9.25),Vector2(4.5,-9.25)])
		stomper.get_node("Collision").set_polygon([Vector2(5.5,9.25),Vector2(-5.5,9.25),Vector2(-5.5,13.75),Vector2(5.5,13.75)])
		pass
	pass
	
func _animate():
	if _directional_inputs.x != 0:
		sprite_node.scale.x = abs(sprite_node.scale.x) if _directional_inputs.x > 0 else abs(sprite_node.scale.x) * -1
		
	# crouch if on floor and holding down
	if _crouching:
		if sprite_node.get("playback/curr_animation") != "Crouch":
			sprite_node.stop_all()
			sprite_node.set("playback/curr_animation", "Crouch")                
			sprite_node.set("playback/loop", 1)                
			sprite_node.play(true)
		return
	
	if should_fall():        
		if _is_in_water:
			if not "Swim" in sprite_node.get("playback/curr_animation"):
				sprite_node.set("playback/curr_animation", "SwimIdle")
				sprite_node.set("playback/loop", 1)                                            
				sprite_node.play(true)
			return

			
		if _velocity.y < 0:               
			if (sprite_node.get("playback/curr_animation") != "Jump"):
				sprite_node.set("playback/curr_animation", "Jump")
				sprite_node.set("playback/loop", 1)                                            
				sprite_node.play(true)
			return
			# jump animation
			pass
		else:
			if (sprite_node.get("playback/curr_animation") != "Fall"):
				sprite_node.stop_all()
				sprite_node.set("playback/curr_animation", "Fall")
				sprite_node.set("playback/loop", 1)                                            
				sprite_node.play(true)
			# fall animation
			return
			pass
			
	if _directional_inputs.x != 0:
		if abs(_velocity.x) <= config._get_setting("PLAYER_WALK_SPEED"):
			if sprite_node.get("playback/curr_animation") != "Walk"  && is_on_floor():
				sprite_node.stop_all()
				sprite_node.set("playback/curr_animation", "Walk")
				sprite_node.set("playback/loop", -1)                
				sprite_node.play(true)
			
			
		elif abs(_velocity.x) > config._get_setting("PLAYER_WALK_SPEED") :
			if sprite_node.get("playback/curr_animation") != "Run"  && is_on_floor():
				sprite_node.stop_all()
				sprite_node.set("playback/curr_animation", "Run")
				sprite_node.set("playback/loop", -1)                
				sprite_node.play(true)
			pass

	else:
		if (sprite_node.get("playback/curr_animation") != "Idle" && is_on_floor()):
			sprite_node.stop_all()
			sprite_node.set("playback/curr_animation", "Idle")
			sprite_node.set("playback/loop", -1)                                            
			sprite_node.play(true)

func _on_enemy_body_entered(body):
	if body.has_method('collide_with_player'):
		body.collide_with_player(self)

	pass

func _on_enemy_body_exited(body):
	pass # Replace with function body.

func stomp_enter(body: Node):
	if _velocity.y > 0:
		if body.has_method('get_stomped'):
			start_jump(true)
			body.get_stomped(self)
		pass
	pass
	
func stomp_exit(body: Node):
	
	pass
	
func head_enter(body: Node):
	_items_on_top[body.name] = body
	if _velocity.y < 0:
		if body.has_method('hit_from_under'):
			body.hit_from_under(self)
		pass
	pass
	
func head_exit(body : Node):
	_items_on_top.erase(body.name)
	pass
	

	
func take_damage():
	die()
	pass

func running(is_running):
	_running = is_running
	pass
	
func start_jump(force : bool = false):
	.start_jump(force)
	if !is_paused && can_jump():
		for key in _items_on_top:
			if _items_on_top[key].has_method('hit_from_under'):
				_items_on_top[key].hit_from_under(self)



func reset():
	.reset()
	sprite_node.stop_all()
	sprite_node.set("playback/curr_animation", "Idle")                    
	
	pass

func win():
	emit_signal("player_won")
	pass

func die():
	emit_signal("player_died")
	

func paddle():
	sprite_node.set("playback/curr_animation", "SwimPaddle")
	sprite_node.set("playback/loop", 1)                                            
	sprite_node.play(true)
	pass



