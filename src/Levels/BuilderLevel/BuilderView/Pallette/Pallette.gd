extends CanvasLayer

signal object_selected
signal searching_changed
signal toggle_search

const wheel_asset = preload("res://src/Levels/BuilderLevel/BuilderView/TileWheel/TileWheel.tscn")

onready var data = get_node("/root/Data")

onready var wheel_controller = $WheelController
onready var current_tile = $SearchAndSelect/ColorRect/CurrentTile
onready var search_button = $SearchAndSelect/SearchButton

var tile_wheels = {}
var selected_tile = null
var _is_searching = false

onready var dimmer = $Dimmer

func search_button():
	emit_signal("toggle_search")
	
func toggle_search():
	search_button.visible = _is_searching
	_set_searching(!_is_searching)
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_load_tiles()
	wheel_controller.connect("tile_selected", self, "_tile_selected")
	wheel_controller.connect("close_requested", self, "_close_wheel_controller")
	pass # Replace with function body.


func _process(delta):
	# let's monitor for bumper controls
	if Input.is_action_just_pressed("builder_scroll_pallette_right"):
		wheel_controller.scroll_right()
		pass
	if Input.is_action_just_pressed("builder_scroll_pallette_left"):
		wheel_controller.scroll_left()
		pass
	
  
	pass

func _input(event):
	if _is_searching:
		if event.is_pressed():
			if event is InputEventKey:
				if event.scancode == KEY_A:
					wheel_controller.scroll_left()
				if event.scancode == KEY_D:
					wheel_controller.scroll_right()
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_WHEEL_UP:
					wheel_controller.scroll_right()
				if event.button_index == BUTTON_WHEEL_DOWN:
					wheel_controller.scroll_left()
		pass
	pass
	
# Loads all tiles from json files
func _load_tiles():
	var tiles = _load_pallette_list()

	if tiles != null:
		var section_names = tiles.keys()
		
		if self:
			for section_name in section_names:
				# create tile wheels
				_build_tile_wheel(section_name, tiles[section_name].tiles, tiles[section_name].color)
				
	pass

func _build_tile_wheel(section_name : String, tiles : Array, color: Color):
	tile_wheels[section_name] = {} 
	tile_wheels[section_name].wheels = []
	
	for i in range(0, tiles.size()):
		var current_wheel = int(i / 8)
		
		# if the wheel doesn't exist yet, create it
		if tile_wheels[section_name].wheels.size() < current_wheel + 1:
			var new_wheel =  wheel_asset.instance()
			new_wheel.section_name = section_name
			new_wheel.set_color(color)
			tile_wheels[section_name].wheels.insert(current_wheel, new_wheel)
			wheel_controller.add_wheel(new_wheel)
		
		var wheel = tile_wheels[section_name].wheels[current_wheel]
		
		# add the tile to the wheel
		wheel.add_tile(tiles[i])
	pass

# loads tiles from json file
func _load_pallette_list():
	
	var pallette_list = {}
	print(data.customizationitems.get("hat_ozzadar").item_type == data.customizationitems.ItemType.SHIRT)
	var section_keys = data.pallettes.index.keys()
	
	for section_key in section_keys:
		var section = data.pallettes.get(section_key)
		var tiles = section.tiles
		
		pallette_list[section_key] = {
			"color": section.color,
			"tiles": []
		}
		
		for tile in tiles:
			var tile_from_db = data.tilelist.get(tile['tile_name']).as_dictionary()
			pallette_list[section_key].tiles.append(tile_from_db)
			

	return pallette_list

func _set_searching(is_searching : bool):
	wheel_controller.visible = is_searching
	wheel_controller.enabled = is_searching
	if is_searching:
		dimmer.play("Fade In")
	else:
		dimmer.play("Fade_Out")
		
	_is_searching = is_searching
	
	emit_signal("searching_changed", _is_searching)
	pass

func _tile_selected(tile):
	current_tile.texture = load(tile.thumbnailPath)
	selected_tile = tile
	search_button()
	pass

func _close_wheel_controller():
	search_button()
