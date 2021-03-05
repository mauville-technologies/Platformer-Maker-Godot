extends Control

onready var parent = get_parent()
onready var global_state = get_node("/root/GlobalState")
onready var api = get_node("/root/APIIntegration")
onready var play_button = $PlayButton
onready var build_button = $BuildButton

onready var current_filter = 0

onready var filter_options = [$HBoxContainer/Random/RandomCheckBox, $HBoxContainer/Best/BestCheckBox ]

func _ready():

		
	api.get_levels_for_user()
	play_button.grab_focus()
	
	if global_state.offline_mode:
		play_button.disabled = true
		build_button.grab_focus()
		
	filter_options[current_filter].pressed = true
	
func _build_button():
	parent.current_state = parent.MENU_STATES.build_root
	pass # Replace with function body.

func _quit_game():
	get_tree().quit()
	pass # Replace with function body.


func _play_button():
	parent.current_state = parent.MENU_STATES.play_root
	pass # Replace with function body.

func _process(_delta):
	pass

func _on_option_selection(option_button):
	var checkbox = filter_options[option_button]
	var currentcheckbox = filter_options[current_filter]
	
	if current_filter == option_button:
		currentcheckbox.pressed = true
		return
	else:
		if (checkbox.pressed == true):
			currentcheckbox.pressed = false
		
	current_filter = option_button
		 
	pass # Replace with function body.
