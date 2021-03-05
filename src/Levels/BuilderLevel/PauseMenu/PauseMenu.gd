extends CanvasLayer

signal pause_menu_closed
signal complete_requested
signal return_to_builder

onready var main_panel = $MainPanel
onready var save_panel = $SavePanel
onready var save_success = $SaveSuccessful
onready var upload_failed = $UploadFailed
onready var upload_success = $UploadSuccessful
onready var autosave = $AutoSave

onready var save_level_name
onready var tilemap = get_node("/root/Tilemap")
onready var global_state = get_node("/root/GlobalState")
onready var api = get_node("/root/APIIntegration")
onready var config = get_node("/root/Config")

var showing_menu = false

func name_changed(new_name):   
	tilemap.level_name_changed(new_name)
	pass
	
func get_time_label(time):
	var minutes = time / 60
	var seconds = int(time) % 60
	var milliseconds = int(time * 1000) % 1000        
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	show_menu(false)
	
	pass # Replace with function body.

func _process(delta):
	if upload_success.visible:
		var level_name = upload_success.get_node("LevelName/Value")
		var clear_time = upload_success.get_node("ClearTime/Value")
		
		clear_time.text = get_time_label(tilemap.play_time)
		level_name.text = tilemap._map.meta_data.name
		pass
	pass

func _go_to_autosave():
	autosave.visible = true
	autosave.get_node("SaveButton").grab_focus()    
	upload_success.visible = false    
	upload_failed.visible = false
	main_panel.visible = false
	save_panel.visible = false
	save_success.visible = false
	
func _go_to_save():
	autosave.visible = false    
	var name_edit = save_panel.get_node("NameEdit")
	name_edit.text = tilemap._map.meta_data.name
	upload_success.visible = false    
	upload_failed.visible = false
	main_panel.visible = false
	save_panel.visible = true
	save_panel.get_node("SaveButton").grab_focus()
	save_success.visible = false

func _go_to_upload():
	autosave.visible = false        
	upload_success.visible = false    
	upload_failed.visible = false    
	main_panel.visible = false
	save_panel.visible = false
	save_success.visible = true
	save_success.get_node("UploadButton").disabled = global_state.offline_mode
	
	if !global_state.offline_mode:
		save_success.get_node("UploadButton").grab_focus()
	else:
		save_success.get_node("BackButton").grab_focus()
	
func _go_to_main():
	autosave.visible = false        
	upload_failed.visible = false    
	upload_success.visible = false
	main_panel.visible = true
	main_panel.get_node("SaveButton").grab_focus()
	save_panel.visible = false
	save_success.visible = false

func open_to_upload_failed():
	autosave.visible = false        
	main_panel.visible = false
	save_panel.visible = false
	save_success.visible = false
	upload_success.visible = false    
	upload_failed.visible = true
	
	upload_failed.get_node("UploadButton").grab_focus()
	
	pass

func open_to_upload_success():
	api.connect("upload_success", self, "_upload_success")
	api.connect("upload_failed", self, "_upload_failed")
	autosave.visible = false        
	main_panel.visible = false
	save_panel.visible = false
	save_success.visible = false
	upload_failed.visible = false    
	upload_success.visible = true
	upload_success.get_node("UploadButton").grab_focus()
	upload_success.get_node("ErrorLabel").visible = false
	
	
func show_menu(new_val):
	if !new_val:
		upload_success.visible = false    
		main_panel.visible = false
		save_panel.visible = false
		save_success.visible = false
		upload_failed.visible = false
		autosave.visible = false    
		
	else:
		_go_to_main()
		
	showing_menu = new_val
	
func _quit():
	get_tree().change_scene("res://src/Levels/MainMenuLevel/MainMenuLevel.tscn")
	pass

func _save(go_to_upload = true):
	tilemap.save()
	if go_to_upload:
		_go_to_upload()
	else:
		close_menu()
		
	pass
	
func close_menu():
	emit_signal("pause_menu_closed")
	
func _begin_upload():
	emit_signal("complete_requested")
	pass


func _return_to_builder():
	emit_signal("return_to_builder")
	pass # Replace with function body.

func _upload_success():
	get_parent().go_to_builder()
	api.disconnect("upload_success", self, "_upload_success")
	api.disconnect("upload_failed", self, "_upload_failed")
	pass
	
func _upload_failed(msg):
	upload_success.get_node("ErrorLabel").visible = true
	upload_success.get_node("ErrorLabel").text = msg if msg != null else "No response from server"
	pass


func upload_level():
	upload_success.get_node("ErrorLabel").visible = false
	tilemap.save()
	
	var payload = {
		'encrypted_metadata': config.get_file_as_byte_array(tilemap._map.meta_data.id, 'meta'),
		'tile_information': tilemap._map.tile_information,
	}
	
	api.uploadLevel(payload)
	pass # Replace with function body.
