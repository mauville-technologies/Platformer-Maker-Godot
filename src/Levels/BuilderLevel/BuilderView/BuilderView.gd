extends Node2D

onready var tilemap = get_node("/root/Tilemap")
onready var input_handler = $BuilderViewInputHandler
onready var pallette = $BuilderViewInputHandler/UILayer/Pallette
onready var ui_tween = $BuilderViewInputHandler/UILayer/UITween
onready var properties_panel = $BuilderViewInputHandler/UILayer/PropertiesPanel

const cursorSpeed = 10

var searching = false
var _paused = false

func pause(is_paused):
	_paused = is_paused
	
	input_handler.set_enabled(!_paused)
	
	if is_paused && searching:
		searching = false
		pallette.toggle_search()
	
	
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap.pause()
	tilemap.reset()
	tilemap.debug = true
	
	pallette.connect("searching_changed", self, "_searching_changed")
	pallette.connect("toggle_search", self, "toggle_search")
	
	tilemap.connect("tile_selected", self, "_tile_selected")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	properties_panel.connect("property_changed", self, "_property_changed")
	
	var half_screen = Vector2(1920 / 2, 1080 / 2)
	input_handler.pan_to_point(tilemap._current_player.position - half_screen)
	pass # Replace with function body.
	
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_search():
	if !_paused:
		searching = !searching
 
		pallette.toggle_search()
	
func _process(delta):
	
	
	if Input.is_action_just_pressed("builder_search"):
		toggle_search()
		pass
   
	pass

func _physics_process(delta):
	pass
func _button_clicked():
	pass

func _tile_selected(tile):
	if tile == null:
		# tween panel to off screen
		ui_tween.interpolate_property(properties_panel, "rect_position", properties_panel.rect_position, Vector2(-500, 250), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
		ui_tween.start()
		
	else:
		# tween panel to screen
		ui_tween.interpolate_property(properties_panel, "rect_position", properties_panel.rect_position, Vector2(0, 250), 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
		ui_tween.start()
		
		properties_panel.reset(tile.properties)
	 
	pass
	
func _on_tilemap_clicked(pan_position):
	if pallette.selected_tile != null:
		var cursorPosition = input_handler.cursorPosition
		var tilePosition = tilemap._screen_position_to_tile_position(cursorPosition + pan_position)
		tilemap.add_new_tile(pallette.selected_tile, tilePosition)

func _on_tilemap_right_clicked(pan_position):
	var cursorPosition = input_handler.cursorPosition
	var tilePosition = tilemap._screen_position_to_tile_position(cursorPosition + pan_position)
	tilemap._remove_from_map_if_exists(tilePosition)

func _on_tilemap_middle_clicked(pan_position):
	var cursorPosition = input_handler.cursorPosition
	var tilePosition = tilemap._screen_position_to_tile_position(cursorPosition + pan_position)
	
	tilemap.select_tile(tilePosition)
	pass
	
func _searching_changed(is_searching):
	searching = is_searching
	
	if !searching:
		input_handler.start_cant_click_timeout()

func _go_to_testing(should_restart):
	get_parent().go_to_testing(should_restart)
	pass # Replace with function body.


func _help_changed(wants_help):
	if wants_help && !get_node("BuilderControls/Controls").visible:
		get_node("BuilderControls/Controls").visible = true
	elif !wants_help && get_node("BuilderControls/Controls").visible:
		get_node("BuilderControls/Controls").visible = false
		
	pass

func _property_changed(property : Dictionary):
	tilemap.update_property_on_selected_tile(property)
	pass
