extends "res://src/Objects/Actors/Actor.gd"


var _used : bool = false;
var _items_on_top = {}
var selected setget set_selected
var edit_mode setget set_edit_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	_floating = true
	reset()
	pass # Replace with function body.
	
func hit_from_under(other_body : Node):
	if !_used:
		
		_play_animation("Hit", 1)
		_used = true
		
		for key in _items_on_top:
			if _items_on_top[key].has_method('hit_from_under'):
				_items_on_top[key].hit_from_under(self)
		
		_update_collision()
	pass
			
func _update_collision():
	var collision = get_node(_collision_node)
	
	if collision == null:
		return
		
	if !_used:
		collision.rotation_degrees = 180
		collision.set_deferred("one_way_collision", true)
	else:
		collision.set_deferred("one_way_collision", false)
		
	pass
	
func reset():
	_play_animation("Init")
	_used = false
	_update_collision()

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
