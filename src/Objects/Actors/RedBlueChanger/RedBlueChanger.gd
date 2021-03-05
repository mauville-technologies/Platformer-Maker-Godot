extends "res://src/Objects/Actors/Actor.gd"


onready var tilemap = get_node("/root/Tilemap")

var _used : bool = false;
var _items_on_top = {}
var selected setget set_selected
var edit_mode setget set_edit_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	pass # Replace with function body.

func hit_from_under(other_body : Node):
	if !_used:
		_play_animation("Hit", 1, true)
		#_used = true
		
		for key in _items_on_top:
			if _items_on_top[key].has_method('hit_from_under'):
				_items_on_top[key].hit_from_under(self)
				
		tilemap.toggle_on_off()
	pass

func _play_animation(animation_name : String, loop : int = -1, restart := false): 
	var sprite_node = get_node("Sprite")
	if sprite_node.get("playback/curr_animation") != animation_name || restart:
			sprite_node.stop_all()
			sprite_node.set("playback/curr_animation", animation_name)                
			sprite_node.set("playback/loop", loop)                
			sprite_node.play(true)

func reset():
	_play_animation("Init", 1)
	_used = false


func body_entered(body):
	_items_on_top[body.name] = body
	pass # Replace with function body.


func body_exit(body):
	_items_on_top.erase(body.name)
	pass # Replace with function body.

func set_selected(new_selected):
	if !edit_mode:
		return
		
	if selected != new_selected:
		selected = new_selected
		
		_play_animation("edit_select" if selected else "edit_deselect", 1)
	
func set_edit_mode(new_edit):
	edit_mode = new_edit
	
	_play_animation("edit_default" if edit_mode else "Init", 1)
	pass
