extends Node

signal tilemap_loaded
signal tilemap_reset
signal tilemap_uploaded
signal tilemap_saved
signal tile_selected
signal on_off_changed

const SpawnLocation = preload("res://src/Tiles/SpawnLocation.gd")
const NOT_A_TILE_POSITION : Vector2 = Vector2(-999.5, -999.5)
const background_resource = "res://src/Components/ParallaxBackgroundComponent/ParallaxBackgroundComponent.tscn"
const weather_resource = "res://src/MapSettings/Weather/Rain/Rain.tscn"

# ************************************
# *********  PUBLIC MEMBERS  *********
# ************************************

# Global Variables
onready var config = get_node("/root/Config")
onready var global_state = get_node("/root/GlobalState")
onready var api = get_node("/root/APIIntegration")
onready var statics = get_node("/root/Statics")

var debug = false setget _set_debug
var play_time : float = 0

# ************************************
# ********  PRIVATE MEMBERS  *********
# ************************************

var _initalized = false
var _selected_tile : Vector2 = NOT_A_TILE_POSITION

var _map = null
var _on_off_switch : bool = false
var _tile_nodes_dict = {}
var _tile_resources = {}
var _background = null
var _weather = null
var _root_tile_node = null
var _internal_objects = null
var _current_player = null
var _player_ghost = null
var _paused = false

# ***********************************
# ********  PUBLIC FUNCTIONS ********
# ***********************************

# Creates a new tilemap instance and attaches it to the parent object
func new(obj : Node, map : Dictionary, player : Node):
	if (_initalized):
		print('Cannot start a tilemap as one has already been initialized')        
		return
	_current_player = player
	
	_connect_signals(obj)
		
	_root_tile_node = Node2D.new()
	_internal_objects = Node2D.new()
	
	obj.add_child(_root_tile_node)
	obj.add_child(_internal_objects)
	
	_load_map(map)
	pause()
	reset()
	pass

# Ends the current tilemap, freeing all resources
func end(obj):
	if (!_initalized):
		print('Cannot end tilemap that has not been initialized')
		return
		
	_unload_map()
	
	obj.remove_child(obj)
	_root_tile_node.queue_free()
	_root_tile_node = null
	
	_disconnect_signals(obj)    
	pass
	
# Saves the map
func save():
	var levels_path = config._get_setting("LEVEL_DIR")
	var d = Directory.new()
	if !(d.dir_exists(levels_path)):
		print("ERR: dir does not exist ")
		d.open("user://")
		d.make_dir(levels_path)
		
	_save_map()
	_save_metadata()
	
	global_state.current_map = _map
	
	emit_signal("tilemap_saved")
	
	pass

# Resets the map to its original parameters
func reset():
	_on_off_switch = false
	var keys = _tile_nodes_dict.keys()
	for key in keys: 
		var tile = _tile_nodes_dict[key]
		
		if tile != null:
			var position = key.split(',', key)
			tile.position = _tile_position_to_screen_position(Vector2(position[0], position[1]))

	for child in _root_tile_node.get_children():
		if child.has_method('reset'):
			child.reset()
		pass
		
	_reset_player_to_start_position()
	play_time = 0
	emit_signal('on_off_changed', _on_off_switch)
	
	pass

func report_player_position(_new_pos : Vector2):
	if (_background == null):
		print('background null')
		return
	#print(_new_pos)
	
	_background.set_anchor(_new_pos)
	_background.layer = -10
	pass
	
func start():
	
	pass
	
func resume():
	_paused = false
	for child in _root_tile_node.get_children():
		if child.has_method('stop_physics'):
			child.stop_physics(false)
		pass
	
	if _current_player != null:
		_current_player.stop_physics(false)
	pass

func pause():
	_paused = true
	for child in _root_tile_node.get_children():
		if child.has_method('stop_physics'):
			child.stop_physics(true)
		pass
	
	if _current_player != null:
		_current_player.stop_physics(true)
	pass

func add_new_tile(tile_information : Dictionary, tile_position : Vector2):
	var tile_name = tile_information.name
	var tile_resource = tile_information.resourcePath
	var layer = tile_information.layer
	
	# Add default properties here
	
	_map.tile_information.tile_list[tile_name] = {
		"resource": tile_resource,
		"layer": layer
	}
	
	var tile_position_str = '%s,%s' % [tile_position.x, tile_position.y]
	if !_map.tile_information.tiles.has(tile_position_str) || _map.tile_information.tiles[tile_position_str].tile_name != tile_name:
		_add_tile_to_map(tile_name, tile_position, tile_information.defaultProperties.duplicate() if tile_information.has('defaultProperties') else {})
	pass

func select_tile(tile_position: Vector2):
	if tile_position != _selected_tile:
		if _selected_tile != NOT_A_TILE_POSITION:
			deselect()
			
		_selected_tile = tile_position
		var key = _key_from_position(_selected_tile)
		
		if _tile_nodes_dict.has(key):
			emit_signal("tile_selected", _map.tile_information.tiles[key])
	
			if _tile_nodes_dict[key].has_method('set_selected'):
				_tile_nodes_dict[key].set_selected(true)
		
	pass

func deselect():
	if _selected_tile == NOT_A_TILE_POSITION:
		return
		
	var key = _key_from_position(_selected_tile)
	
	if _tile_nodes_dict.has(key) && _tile_nodes_dict[key].has_method('set_selected'):
		_tile_nodes_dict[key].set_selected(false)
		pass
	
	_selected_tile = NOT_A_TILE_POSITION
	
	emit_signal("tile_selected", null)
	pass

func update_property_on_selected_tile(property : Dictionary):
	if _selected_tile == NOT_A_TILE_POSITION:
		return
		
	var key = _key_from_position(_selected_tile)
	
	if _tile_nodes_dict.has(key) && _tile_nodes_dict[key].has_method('update_property'):
		_tile_nodes_dict[key].update_property(property)
		
		_map.tile_information.tiles[key].properties[property.key] = property.value

func get_selected_tile():
	if _selected_tile == NOT_A_TILE_POSITION:
		return null
		
	var key = _key_from_position(_selected_tile)
	
	if _tile_nodes_dict.has(key) && _tile_nodes_dict[key].has_method('update_property'):       
		return _map.tile_information.tiles[key]

func toggle_on_off():
	_on_off_switch = !_on_off_switch
	emit_signal('on_off_changed', _on_off_switch)
	
# ***********************************
# ******** PRIVATE FUNCTIONS ********
# ***********************************

func _ready():
	pass # Replace with function body.

func _process(delta):
	if !_paused:
		play_time = play_time + delta
			   
func _unload_map():
	_tile_resources = null
	_map = null
	_tile_nodes_dict = null
	_initalized = false
	pass
	
func _load_map(map : Dictionary):
	
	_tile_nodes_dict = {}
	
	if map.tile_information == null:
		map.tile_information = {
			"tile_list": {},
			"tiles": {}    
		}
		
		
	_map = map
	
	# load background    
	_load_background()
	#_load_weather()
	
	# build the map from the provided data
	var tile_information = map.tile_information
	var keys = tile_information.tiles.keys();
	
	for key in keys: 
		var val = tile_information.tiles[key];
		var position = key.split(',', key)
		var tile_name = val.tile_name

		_add_tile_to_map(tile_name, Vector2(position[0], position[1]), val.properties.duplicate() if val.has('properties') else {})
		 
	emit_signal("tilemap_loaded")
	pass

func _load_background():
	_background = load(background_resource).instance()
	_internal_objects.add_child(_background)
	pass

func _load_weather():
	_weather = load(weather_resource).instance()
	_internal_objects.add_child(_weather)
	
# Adds a tile to scene at specified map position
# TODO: Enhance this to support multiple layers
func _add_tile_to_map(tile_name : String, map_position: Vector2, properties : Dictionary = {}):
	
	var resource_path = _map.tile_information.tile_list[tile_name].resource
	var new_tile = _load_tile_resource(resource_path).instance()
	new_tile.z_index = _map.tile_information.tile_list[tile_name].layer
	
	if new_tile is SpawnLocation:
		_current_player.last_ground_position = null
		
		_set_start_pos(map_position, true)
		
		if _player_ghost != null:
			_remove_player_ghost()
			
		new_tile.queue_free()
		return
		
	_remove_from_map_if_exists(map_position)  
	var key = '%s,%s' % [map_position.x, map_position.y]
	
	_map.tile_information.tiles[key] = {
		"tile_name": tile_name,
		"properties": properties
	}
	
	_tile_nodes_dict[key] = new_tile
	new_tile.position = _tile_position_to_screen_position(map_position)
	
	if new_tile.has_method('stop_physics'):
		new_tile.stop_physics(_paused)
		
	_update_autotiles(map_position)
	
	_root_tile_node.add_child(new_tile)
	
	# set edit mode
	if new_tile.has_method('set_edit_mode'):
		new_tile.set_edit_mode(debug)
	
	if new_tile.has_method('init_properties'):
		new_tile.init_properties(properties)
	
	if new_tile.has_method('reset'):
		new_tile.reset()
		
	return true

func _update_autotiles(map_position : Vector2):
	
	# Update center
	
	for i in range(9):
		var position_to_update = Vector2((map_position.x - 1) + (i % 3), (map_position.y - 1) + (i / 3))
		var key = '%s,%s' % [position_to_update.x, position_to_update.y]
		if (_tile_nodes_dict.has(key)):
			var node = _tile_nodes_dict[key]
			
			if node.has_method("update_autotile"):
				var node_map = _generate_autotile_map(node.set_name, position_to_update)
				
				node.update_autotile(node_map)
	pass

func _generate_autotile_map(set_name : String, map_position : Vector2):
	var map = {}
	var key
	var node
	
	# North
	var north = map_position + Vector2(0, -1)
	if _tile_nodes_dict.has(_key_from_position(north)):
		node = _tile_nodes_dict[_key_from_position(north)]
	
		if node != null:
			if node.has_method("update_autotile"):
				if node.set_name == set_name:
					map.north = true
	
	# West    
	var west = map_position + Vector2(-1, 0)
	if _tile_nodes_dict.has(_key_from_position(west)):
		node = _tile_nodes_dict[_key_from_position(west)]
	
		if node != null:
			if node.has_method("update_autotile"):
				if node.set_name == set_name:
					map.west = true
	# East
	var east = map_position + Vector2(1, 0)
	if _tile_nodes_dict.has(_key_from_position(east)):
		node = _tile_nodes_dict[_key_from_position(east)]
	
		if node != null:
			if node.has_method("update_autotile"):
				if node.set_name == set_name:
					map.east = true
				
	# South
	var south = map_position + Vector2(0, 1)
	if _tile_nodes_dict.has(_key_from_position(south)):
		node = _tile_nodes_dict[_key_from_position(south)]
	
		if node != null:
			if node.has_method("update_autotile"):
				if node.set_name == set_name:
					map.south = true
	
	return map

func _key_from_position(map_position : Vector2):
	return '%s,%s' % [map_position.x, map_position.y]
	pass
	
func _would_be_same_tile(tile_name : String, position : Vector2) -> bool:
	return _map.tile_information.tiles['%s,%s' % [position.x, position.y]]  == tile_name
	
func _remove_from_map_if_exists(position : Vector2) -> bool:
	var key = "%s,%s" % [position.x, position.y]
		
	if _map.tile_information.tiles.has(key):
		# tile should exist, let's clear it
		_map.tile_information.tiles.erase(key)

		if _tile_nodes_dict.has(key) && weakref(_tile_nodes_dict[key]).get_ref():
			_map.meta_data.completed = false
			_root_tile_node.remove_child(_tile_nodes_dict[key])
			_tile_nodes_dict[key].queue_free()
			_tile_nodes_dict.erase(key)
			pass
			
		_update_autotiles(position)
		# Remove the tile from the root node if it exists
		return true
		
	return false        
			
func _create_tile_nodes(size_x: int, size_y : int):
	

	pass
	
func _load_tile_resource(resourcePath : String):
	if !_tile_resources.has(resourcePath):
		_tile_resources[resourcePath] = load(resourcePath)
	
	return _tile_resources[resourcePath]
	
# Connects signals to parent object
func _connect_signals(obj : Node):
	self.connect("tilemap_loaded", obj, "_tilemap_loaded")
		
	pass

# Disconnects signals to parent object
func _disconnect_signals(obj : Node):
	self.disconnect("tilemap_loaded", obj, "_tilemap_loaded")
	pass

func _save_map():
	var map = File.new()

	if map.open("%s%s.json" % [config._get_setting("LEVEL_DIR"), _map.meta_data.id], File.WRITE) != 0:
		print("Error opening file")
		return

	map.store_line(to_json(_map.tile_information))
	map.close()
	pass

func _save_metadata():
	# save metadata
	var metaDataFile = File.new()

	if metaDataFile.open_encrypted_with_pass("%s%s.meta" % [config._get_setting("LEVEL_DIR"), _map.meta_data.id],
		 File.WRITE, config.get_encryption_password()) != 0:
		print('Error saving metadata file!')
		return
		pass

	metaDataFile.store_line(to_json(_map.meta_data))
	metaDataFile.close()
		
func _set_start_pos(newStartPos : Vector2, snap : bool):
	# we should keep a 'start Position object reference; and just move that around'
	_map.meta_data.start_position_x = newStartPos.x
	_map.meta_data.start_position_y = newStartPos.y
	if snap:
		_reset_player_to_start_position()
	pass
	
func _reset_player_to_start_position():
	if _current_player != null:
		var start_position : Vector2
		var start_x = 0
		var start_y = 0
		if _map.meta_data.has('start_position_x'):
			start_x = _map.meta_data.start_position_x
			
		if _map.meta_data.has('start_position_y'):
			start_y = _map.meta_data.start_position_y
			
		if _current_player.last_ground_position != null:
			start_position = _current_player.last_ground_position
			if debug:
				_draw_player_ghost(Vector2(start_x, start_y))
			pass
		else: 

				
			start_position = Vector2(start_x, start_y)
			if !debug:
				_remove_player_ghost()
			
		_current_player.position = _tile_position_to_screen_position(start_position)
		_current_player.reset()

func _draw_player_ghost(position : Vector2):
	if _player_ghost == null || !weakref(_player_ghost).get_ref():
		_player_ghost = load(statics.player_resource).instance()
		_internal_objects.add_child(_player_ghost)
		_player_ghost.set_ghost()        
		   
	
	_player_ghost.position = _tile_position_to_screen_position(position)
	_player_ghost.stop_physics(true)
	pass

func _remove_player_ghost():
	if  _player_ghost != null && weakref(_player_ghost).get_ref():
		_internal_objects.remove_child(_player_ghost)
		_player_ghost.queue_free()
		_player_ghost = null
		
func _set_debug(new_debug):
	if !new_debug:
		_remove_player_ghost()
	
	debug = new_debug
	
	_set_edit_mode_on_tiles(debug)
	pass

func _set_edit_mode_on_tiles(is_edit_mode):
	if _root_tile_node == null:
		return
		
	for child in _root_tile_node.get_children():
		if child.has_method('set_edit_mode'):
			child.set_edit_mode(is_edit_mode)
			
	pass
	
func level_name_changed(new_name):
	_map.meta_data.name = new_name
			 
			
# *******************************************
# ******** PRIVATE SIGNAL FUNCTIONS ********
# *******************************************


	
# *******************************************
# ******** PRIVATE UTILITY FUNCTIONS ********
# *******************************************

func _tile_position_to_screen_position(tilePosition): 
	var baseTileSize = config._get_setting("BASE_TILE_SIZE")

	return Vector2((tilePosition.x * (baseTileSize)) + (baseTileSize /2), \
		(tilePosition.y * (baseTileSize)) + (baseTileSize /2))
		
func _screen_position_to_tile_position(screenPosition):
	var baseTileSize = config._get_setting("BASE_TILE_SIZE")

	var mouseTileX = int(screenPosition.x) / baseTileSize
	var mouseTileY = int(screenPosition.y) / baseTileSize
	
	if (screenPosition.x < 0):
		mouseTileX -= 1
	
	if (screenPosition.y < 0):
		mouseTileY -= 1
		
	return Vector2(mouseTileX, mouseTileY)
