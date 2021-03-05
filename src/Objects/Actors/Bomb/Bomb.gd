extends "res://src/Objects/Actors/Actor.gd"

# imports
const Player = preload("res://src/Objects/Actors/Player/Player.gd")

onready var sprite = $Sprite
onready var rng = RandomNumberGenerator.new()

export(float) var explode_radius = 96

var player_ref : Player = null
var should_chase : bool = true

func _ready():
	sprite.connect("dragon_anim_snd_event", self, '_handle_snd_event')
	sprite.connect("dragon_anim_event", self, '_handle_custom_event')
	pass

func _physics_process(delta):
	if player_ref != null && should_chase:
		var direction : Vector2 = player_ref.position - position
		direction = direction.normalized()
		
		_velocity = direction * walk_speed
	pass

func collide_with_player(player):
	should_chase = false
	gravity_multiplier = 1
	player.recoil(player.position - position, 10)
	recoil((position - player.position), 5)
	
	$Sprite.get_armature().play('Explode', 1)
	pass

func _handle_snd_event(animation_name : String, sound_name: String):
	if sound_name == "fuse_burning":
		get_node("Fuse").play(0)
		pass
	
	if sound_name == "explosion":
		get_node("Bomb").play(0)

		pass

func _handle_custom_event(event : Dictionary):
	if event['event_name'] == "destroy":
		if player_ref != null:
			if (player_ref.position - position).length() <= explode_radius:
				player_ref.take_damage()
		_start_death()

	pass
	
func reset():
	.reset()
	should_chase = true
	gravity_multiplier = 0	
	friction_multiplier = 0.0
	
	bounce_coefficient = 0.8    
	$Sprite.get_armature().stop_all_animations(true, true)
	$Sprite.get_armature().play("Idle", -1)
	get_node("Fuse").stop()
	get_node("Bomb").stop()


func _on_body_entered(body):
	if body is Player:
		player_ref = body


func _on_body_exited(body):
	if body is Player:
		player_ref = null
		_velocity = Vector2.ZERO
		
func get_stomped(player : Node):
	
	pass
