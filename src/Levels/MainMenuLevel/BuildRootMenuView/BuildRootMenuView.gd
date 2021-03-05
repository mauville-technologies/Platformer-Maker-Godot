extends Control

const UUID = preload("res://src/Utils/uuid.gd")

onready var parent = get_parent()
onready var level_container = $ScrollContainer/LevelContainer
onready var new_level_button = $NewLevelButton
onready var config = get_node("/root/Config")
onready var global_state = get_node("/root/GlobalState")
onready var api = get_node("/root/APIIntegration")
onready var tilemap = get_node("/root/Tilemap")

const builder_level_path = "res://src/Levels/BuilderLevel/BuilderLevel.tscn"

func _ready():
	var given_focus = false
	
	var local_levels = config.get_level_files()
	var online_levels = null
	
	if global_state.currentPlayer.has('level_list'):
		online_levels = global_state.currentPlayer.level_list
	
	if online_levels != null:
		for online_level in online_levels:
			# check if exists in local levels
			for index in range(0, local_levels.size()):
				if online_level.id == local_levels[index].id:
					# remove from local_levels
					online_level.meta_data = local_levels[index]               
					local_levels.remove(index)
					break
				pass
			
			if !given_focus:
				_add_level_to_list(online_level.meta_data, true, true)
				given_focus = true
			else:
				_add_level_to_list(online_level.meta_data, true)
				
			pass
	
	for local_level in local_levels:
		if !given_focus:
			_add_level_to_list(local_level, false, true)
			given_focus = true
		else:
			_add_level_to_list(local_level, false)

	if !given_focus:
		new_level_button.grab_focus()
		given_focus = true
		
	# wire up the new level button to create a new level with a UUID
	new_level_button.connect("pressed", self, "_open_level", [GlobalState.get_new_level(UUID.v4()), false])
	pass
	
func _add_level_to_list(file, is_online=false, grabFocus=false):
	var button = Button.new()
		
	button.rect_min_size.y = 64
	
	var label = Label.new()
	
	label.text = file.name
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.anchor_right = 0.85
	label.anchor_bottom = 1

	var falabel = load("res://addons/FontAwesome/FontAwesome.gd").new()
	falabel._set_size(32)
	
	if file.completed:
		falabel.icon = "check"
		falabel.add_color_override("font_color", Color(0,1,0,1))
	else:
		falabel.icon = "times"
		falabel.add_color_override("font_color", Color(1,0,0,1))

	falabel.align = Label.ALIGN_CENTER
	falabel.valign = Label.VALIGN_CENTER
	falabel.anchor_left = 0.85
	falabel.anchor_right = 0.9
	falabel.anchor_bottom = 1

	button.add_child(label)
	button.add_child(falabel)
	if is_online:
		var falabel_online = load("res://addons/FontAwesome/FontAwesome.gd").new()
		falabel_online._set_size(32)
		falabel_online.align = Label.ALIGN_CENTER
		falabel_online.valign = Label.VALIGN_CENTER
		falabel_online.anchor_left = 0.9
		falabel_online.anchor_right = 1
		falabel_online.anchor_bottom = 1
		falabel_online.icon = "globe"
		falabel_online.add_color_override("font_color", Color(0,0,1,1))
		button.add_child(falabel_online)
			 
	level_container.add_child(button)
		
	if grabFocus:
		button.grab_focus()
		
	button.connect("pressed", self, "_open_level", [file, is_online && file.completed])
	
	pass
	
func _back_button():
	parent.current_state = parent.MENU_STATES.main_menu
	pass # Replace with function body.

func _open_level(map, is_online):
	if is_online:
		# load level from file
		api.connect("get_level_success", self, "_get_level_success")
		api.connect("get_level_failed", self, "_get_level_failed")
		api.get_levels_by_id(map.id)
		return
	
	# Local Load
	var map_file = File.new()
	
	if map_file.open("%s%s.json" % [config._get_setting("LEVEL_DIR"), map.id], File.READ) != 0:
		print("Error opening local file -- assuming new level")
#        if map_file.open("res://assets/Levels/new_level.json", File.READ) != 0:
#            print("Failed to create new level")
		map.id = UUID.v4()
		map.start_position_x = 2
		map.start_position_y = 14
	
	global_state.current_map = {
		'tile_information': parse_json(map_file.get_as_text()),
		'meta_data': map
	}
	
	if get_tree().change_scene(builder_level_path) == OK:
		return
		
	pass # Replace with function body.

func _get_level_success(level):
	global_state.current_map = level
	
	if get_tree().change_scene(builder_level_path) == OK:
		return
	pass
	
func _get_level_failed(_errorMsg):
	print("error opening level!")    
	pass
