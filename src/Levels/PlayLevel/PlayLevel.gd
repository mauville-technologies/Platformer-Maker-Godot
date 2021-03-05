extends Control

onready var playerStateMachine = $PlayLevelStateMachine
onready var tilemap = get_node("/root/Tilemap")
onready var global_state = get_node("/root/GlobalState")
onready var elapsed_time_label = $CanvasLayer/ElapsedTime
onready var pause_menu = $PauseMenu/PauseMenuPanel
onready var statics = get_node("/root/Statics")
onready var player = load(statics.player_resource).instance()

var is_loading = true
var is_playing = false
var player_dead = false
var player_won = false
var _elapsed_time = 0
var _is_ticking = false
var _paused = false

export(Dictionary) var views = {}

# ***********************************
# ********  PUBLIC FUNCTIONS ********
# ***********************************
	
func togglePause():
	if (!_paused):
		_show_pause_menu(true)
		stop_timer()
		tilemap.pause()
	else:
		_show_pause_menu(false)
		start_timer();
		tilemap.resume()
	
	_paused = !_paused
	pass

func start_timer():
	_is_ticking = true
	pass
	
func stop_timer():
	_is_ticking = false
	pass

func reset_timer():
	_is_ticking = false
	_elapsed_time = 0
	_update_elapsed_time_label()
	pass

func retry():
	player.last_ground_position = null
	_show_pause_menu(false)
	tilemap.reset()
	player_dead = false
	player_won = false
	is_playing = false
	reset_timer()
	pass

func quit_to_menu():
	get_tree().change_scene("res://src/Levels/MainMenuLevel/MainMenuLevel.tscn")
	pass
		
# ***********************************
# *******  PRIVATE FUNCTIONS ********
# ***********************************

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	playerStateMachine.add_state("enter")
	playerStateMachine.add_state("count_down")
	playerStateMachine.add_state("play")
	playerStateMachine.add_state("lose")
	playerStateMachine.add_state("win")
	
	playerStateMachine.call_deferred("set_state", playerStateMachine.states.enter)
	self.add_child(player)
	
	tilemap.new(self, global_state.current_map, player)
	
	_connect_player_signals()
	_update_elapsed_time_label()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
func _process(delta):
	if _is_ticking:
		_elapsed_time += delta
		_update_elapsed_time_label()
	
	if !_paused && Input.is_action_just_pressed('pause_game'):
		togglePause()
		pass
	elif _paused && (Input.is_action_just_pressed('pause_game') || Input.is_action_just_pressed('ui_cancel')):
		togglePause()   
		
	pass

func _lose():
	tilemap.pause()
	player_dead = true
	pass
	
func _win():
	tilemap.pause()
	player_won = true
	pass
	
func _show_pause_menu(shown : bool):
	pause_menu.visible = shown
	
	if (shown):
		pause_menu.get_node("RestartButton").grab_focus()
		return
	pause_menu.get_node("RestartButton").release_focus()
	pass
	
func _connect_player_signals():
	player.connect("player_died", self, "_lose")
	player.connect("player_won", self, "_win")
	pass

func _tilemap_loaded():
	is_loading = false

func get_time_label(time):
	var minutes = time / 60
	var seconds = int(time) % 60
	var milliseconds = int(time * 1000) % 1000        
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	pass
	
func _update_elapsed_time_label():
	var str_elapsed = get_time_label(_elapsed_time)
	
	elapsed_time_label.text = str_elapsed
	pass
