extends Node2D

signal level_paused
signal restart_view


const pause_menu_resource = "res://src/Levels/BuilderLevel/PauseMenu/PauseMenu.tscn"
const AUTOSAVE_TIMEOUT = 300

onready var statics = get_node("/root/Statics")

onready var builderStateMachine = $BuilderStateMachine
onready var tilemap = get_node("/root/Tilemap")
onready var global_state = get_node("/root/GlobalState")
onready var pause_menu = preload(pause_menu_resource).instance()
onready var player = load(statics.player_resource).instance()

var building = true
var _paused = false
var _testing = false
var _uploading = false
var _time_since_last_save = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	builderStateMachine.add_state("building")
	builderStateMachine.add_state("testing")
	builderStateMachine.add_state("uploading")
	builderStateMachine.call_deferred("set_state", builderStateMachine.states.building)
	
	self.add_child(player)
	tilemap.new(self, global_state.current_map, player)
	tilemap.connect("tilemap_saved", self, "_tilemap_saved")
	
	self.add_child(pause_menu)
	pause_menu.connect("pause_menu_closed", self, "_pause_menu_closed")
	pause_menu.connect("complete_requested", self, "_begin_upload")
	pause_menu.connect("return_to_builder", self, "_return_to_builder")
	
	pause_menu.show_menu(false)
	
	_connect_player_signals()
	pass # Replace with function body.

func _tilemap_saved():
	_time_since_last_save = 0
	pass
	
func togglePause():
	_show_pause_menu(!_paused)

func _return_to_builder():
	go_to_builder()
	pass
	
func _pause_menu_closed():
	_show_pause_menu(false)

func go_to_builder():
	tilemap.debug = true
	_testing = false
	_uploading = false
	building = true
	_show_pause_menu(false)

func go_to_testing(should_restart):
	tilemap.debug = false
	if should_restart:
		clear_ghost()   
	_testing = true
	_uploading = false
	building = false
	
	_show_pause_menu(false)

func _begin_upload():
	if _uploading:
		clear_ghost()        
		_show_pause_menu(false)
		builderStateMachine.reset_level()
	else:
		clear_ghost()
		tilemap.debug = false
		_show_pause_menu(false)
		building = false
		_testing = false
		_uploading = true
		
	pass
	
func _show_pause_menu(shown : bool):
	_paused = shown
	
	pause_menu.show_menu(shown)
	
	builderStateMachine.pause_current_view(_paused)
	
	emit_signal("level_paused", _paused)
		
func _process(delta):
	OS.set_window_title("Platformer Mission" + " | fps: " + str(Engine.get_frames_per_second()))
	if !_paused:
		if building:
			_time_since_last_save = _time_since_last_save + delta
			
			if _time_since_last_save > AUTOSAVE_TIMEOUT:            
				_show_pause_menu(true)
				pause_menu._go_to_autosave()
			
	if !_paused && Input.is_action_just_pressed('pause_game'):
		togglePause()
		pass
	elif _paused && (Input.is_action_just_pressed('pause_game') || Input.is_action_just_pressed('ui_cancel')):
		togglePause() 
		
		
func _connect_player_signals():
	player.connect("player_died", self, "_lose")
	player.connect("player_won", self, "_win")
	pass

func _lose():
	if _testing:
		go_to_builder()
	
	if _uploading:
		_paused = true
		builderStateMachine.pause_current_view(_paused)
		emit_signal("level_paused", _paused)
		pause_menu.open_to_upload_failed()
		
	pass
	
func _win():
	
	if _testing:
		clear_ghost()        
		go_to_builder()
		
	if _uploading:
		tilemap._map.meta_data.completed = true
		
		if tilemap._map.meta_data.has('owner_time'):
			tilemap._map.meta_data.owner_time = tilemap.play_time if tilemap._map.meta_data.owner_time > tilemap.play_time else tilemap._map.meta_data.owner_time
		else:
			tilemap._map.meta_data.owner_time = tilemap.play_time
			
		_paused = true
		builderStateMachine.pause_current_view(_paused)
		emit_signal("level_paused", _paused)
		pause_menu.open_to_upload_success()

func clear_ghost():
	player.last_ground_position = null
	tilemap._remove_player_ghost()
	pass
		
func _tilemap_loaded():
	pass


