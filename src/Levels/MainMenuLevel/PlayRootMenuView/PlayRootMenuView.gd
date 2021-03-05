extends Control

onready var api = get_node("/root/APIIntegration")
onready var global_state = get_node("/root/GlobalState")
onready var parent = get_parent()
onready var loading = $Loading
onready var loaded = $Loaded
onready var loaded_play = $Loaded/LoadedPlayer

onready var level_buttons = [$Loaded/Level1, $Loaded/Level2,
 $Loaded/Level3, $Loaded/Level4, $Loaded/Level5]

func _ready():
	make_random_levels_call()
	pass
	
func _back_button():
	parent.current_state = parent.MENU_STATES.main_menu
	pass # Replace with function body.


func _get_levels_success(levels):
	disconnect_signals()
	
	var count = 0
	level_buttons[0].grab_focus()
	for level in levels:
		level_buttons[count].get_node("Label").text = level.meta_data.name
		level_buttons[count].connect("pressed", self, "_on_level_selection", [level])
		count += 1
		
	if count < 5:
		for i in range(count, 5):
			level_buttons[i].get_node("Label").text = ""
			
			level_buttons[i].disabled = true
			
	loading.visible = false
	loaded.visible = true
	
	loaded_play.play("buttons_fly_in")
	pass
	
func _get_levels_failed(errorMsg):
	disconnect_signals()
	print(errorMsg)
	pass

func make_random_levels_call():
	api.get_random_levels()
	api.connect("get_random_success", self, "_get_levels_success")
	api.connect("get_random_failed", self, "_get_levels_failed")
	
func disconnect_signals():
	api.disconnect("get_random_success", self, "_get_levels_success")
	api.disconnect("get_random_failed", self, "_get_levels_failed")
	
func _on_level_selection(level):
	global_state.current_map = level
	
	if get_tree().change_scene("res://src/Levels/PlayLevel/PlayLevel.tscn") == OK:
		return
	
	print("error opening level!")
	
	pass

