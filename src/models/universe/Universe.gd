extends Node
class_name Universe

var _entry_point : String
var _points_on_map : Dictionary = {}
var _universe_data : Dictionary = {}

var _initalized : bool = false
var _root_universe_node : Node2D = null
var _selected_point = null

var _player_position = Vector2.ZERO

# Creates a new universe
func init(parent : Node, universe : Dictionary, initial_state = null):
	if (_initalized):
		print('Cannot create universe as one has already been initialized')        
	
		
	_root_universe_node = Node2D.new()
	parent.add_child(_root_universe_node)
	
	_load_universe(universe, initial_state)
	
	reset()
	pass

func reset():
	
	pass
	
func _load_universe(universe : Dictionary, initial_state = null):
	_universe_data = universe
	
	_entry_point = universe['entry_point']
	_build_points_on_map(universe['points'])
	_build_paths(universe['paths'])

	_root_universe_node.set_name("root_universe")
	
func _get_next_level_in_direction(current_level : String, direction : String):
	if _points_on_map[current_level].connections.has(direction) && \
	_points_on_map.has(_points_on_map[current_level].connections[direction]):
		return _points_on_map[_points_on_map[current_level].connections[direction]]
	return null
	
func _build_points_on_map(points : Dictionary):
	if _root_universe_node.get_node("LevelsContainer"):
		_root_universe_node.remove_child(_root_universe_node.get_node("LevelsContainer"))
		
	var levels_container = Node.new()
	levels_container.name = "LevelsContainer"

	for point_key in points.keys():
		var new_point_data = points[point_key]
		var new_point = null
		
		match(new_point_data['type']):
			'level':
				new_point = Level.new()
				pass
			'path':
				new_point = PointOnMap.new()			
				pass
	
		_points_on_map[point_key] = new_point
		new_point.init(point_key, levels_container, new_point_data)
	
	_root_universe_node.add_child(levels_container)

func _build_paths(paths : Dictionary):
	if _root_universe_node.get_node("PathContainer"):
		_root_universe_node.remove_child(_root_universe_node.get_node("PathContainer"))
		
	var path_container = Node.new()
	path_container.name = "PathContainer"
	
	for src_dir in paths.keys():
		var dest_dir = PointOnMap.get_opposite_direction(src_dir)
		for level_key in paths[src_dir]:
			var src_level : PointOnMap = _points_on_map[level_key]
			var dest_level : PointOnMap = _points_on_map[paths[src_dir][level_key]['dest']]
			
			if src_level && dest_level:
				
				src_level.connections[src_dir] = dest_level.id
				dest_level.connections[dest_dir] = src_level.id
				
				var src_anchor = src_level.get_direction_anchor(src_dir)
				var dest_anchor = dest_level.get_direction_anchor(dest_dir)
				
				var new_path = Line2D.new()
				new_path.points = PoolVector2Array([src_anchor, dest_anchor])
				path_container.add_child(new_path)
	
	## Edge condition: 2 connections in the same direction; enforce this not to happen?
	## or fix the algorithm? I think the algorithm is possibly good for now and I can start
	## building the Builder part.

	_root_universe_node.add_child(path_container)
