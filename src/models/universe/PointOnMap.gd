extends Node2D
class_name PointOnMap
const level_marker : PackedScene = preload("res://src/models/universe/level/LevelMarker.tscn")

var _initialized : bool = false
var _point_on_map : Vector2 = Vector2.ZERO
var next_point = null
var _cleared : bool = true
var _paths : Dictionary = {}
var _display_node : LevelMarker = null
var id : String = ""

var connections = {
	'right': '',
	'up': '',
	'left': '',
	'down': ''
}

func init(key : String, parent : Node, point_info):
	_point_on_map = point_info['position']
	parent.add_child(self)
	id = key
	set_name(id)
	
	_display_node = level_marker.instance()
	_display_node.global_position = _point_on_map
	
	self.add_child(_display_node)
	_initialized = true

func get_class():
	return "PointOnMap"

func get_direction_anchor(direction : String) -> Vector2:
	var anchor : Vector2 = _point_on_map;
	
	match(direction):
		'right':
			anchor.x += _display_node.radius / 2
		'left':
			anchor.x -= _display_node.radius / 2
		'up':
			anchor.y -= _display_node.radius / 2
		'down':
			anchor.y += _display_node.radius / 2
	
	return anchor

static func get_opposite_direction(direction : String) -> String:
	match(direction):
		'right':
			return 'left'
		'left':
			return 'right'
		'up':
			return 'down'
		'down':
			return 'up'
	print_debug("Invalid direction, no opposite direction")
	return ""
	
