extends KinematicBody2D
class_name AutoTile

const NORTH = 1
const WEST = 2
const EAST = 4
const SOUTH = 8

export(String) var set_name
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_autotile(map : Dictionary):
	
	if map == null:
		return
		
	var value = NORTH * int(map.has('north')) +  WEST * int(map.has('west')) +  EAST * int(map.has('east')) +  SOUTH * int(map.has('south'))
	
	var sprite = get_node("Sprite")
	if sprite != null:
		var cols = sprite.texture.get_width() / 64
		
		sprite.region_rect = Rect2(Vector2(value % cols * 64, value / cols * 64), Vector2(64,64))
	pass
