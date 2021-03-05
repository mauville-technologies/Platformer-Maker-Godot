extends Node

onready var path = "user://config.ini"

var _ascii = """
*****************************
*	Platformer Mission
*	Mauville Technologies Incorporated. (c) 2020
*	v.0.0                   
*****************************
"""
	  
var _goodbyeMessage = """
*****************************	
*	
*	Thanks for playing!
*	
*****************************
*	Platformer Mission
*	Mauville Technologies Incorporated. (c) 2020
*	v.0.0                   
*****************************
"""                                                                              

var _settings = {}
const BASIC_SECTION_NAME = 'Base Configuration'
const ENABLE_FILE_CONFIG = false;

var default_settings = {
	'RESOLUTION': Vector2(1920, 1080),
	'LEVEL_DIR': 'user://levels/',
	'TILE_SIZE_PX': Vector2(32, 32),
	'GRAVITY': 35,
	'JUMP_STRENGTH': -1000,
	'BASE_TILE_SIZE': 64,
	'PLAYER_MAX_SPEED': 700,
	'PLAYER_WALK_SPEED': 400,
	'PLAYER_ACCELERATION': 30,
	'PLAYER_WEIGHT': 0.2,
	'PLAYER_AIR_TURN_SPEED': 0.92,
	'PLAYER_GROUND_TURN_SPEED': 0.85,
	'PLAYER_STATES': {
		'dead': {
			'resource':'res://assets/Player/dead.png'
		},
		'mini': {
			'resource':'res://assets/Player/mini.png',
			'revertTo': 'dead'
		},
		'mushroom': {
			'resource':'res://assets/Player/mushroom.png',
			'revertTo': 'mini'
		},
	}
}

# Currently being use to shut down the program.
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		print(_goodbyeMessage);
		yield(get_tree().create_timer(.1), "timeout");      
		get_tree().quit();
		
func _ready():
	get_tree().set_auto_accept_quit(false);
	print(_ascii)
	load_config()
	save_config()

func _get_setting(settingName):
	return _settings[settingName]

func save_config():
	if ENABLE_FILE_CONFIG:
		var config = ConfigFile.new()
		
		for setting in default_settings:
			config.set_value(BASIC_SECTION_NAME, setting, _settings[setting])
		
		var err = config.save(path)
		
		if err != OK:
			print("** FAILED TO SAVE CONFIG **")
		
func load_config():
	var config = ConfigFile.new()
	
	var err = config.load(path)
	
	if err != OK || !ENABLE_FILE_CONFIG:
		print("*** NO CONFIG FILE FOUND ***\n *** USING DEFAULT VALUES *** " if ENABLE_FILE_CONFIG else "*** CONFIG FILES DISABLED ***")
		
		for setting in default_settings:
			_settings[setting] = default_settings[setting]
	else:
		for setting in default_settings:
			_settings[setting] = config.get_value(BASIC_SECTION_NAME, setting, default_settings[setting])
			print('*** LOADED SETTING: %s\t\t\t\tVALUE: %s' % [setting, _settings[setting]])
		
	return _settings
	
func get_file_as_byte_array(levelId, extension):
	var encrypted_meta_file = File.new()
	
	var _path = "%s%s.%s" % [_get_setting("LEVEL_DIR"), levelId, extension]
	
	if encrypted_meta_file.open(_path, File.READ) != 0:
		pass
		
	var byte_array = []
	while !encrypted_meta_file.eof_reached():
		byte_array.append(encrypted_meta_file.get_8())
		pass
		
	return byte_array
	pass
	
func get_level_files():
	var files = []
	var dir = Directory.new()
	if dir.open(_settings['LEVEL_DIR']) == OK:
		dir.list_dir_begin(true, true)
		
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif !dir.current_is_dir() && file.get_extension() == "meta":
				# Open and read the meta file
				var metaFile = File.new()

				var path = "%s%s" % [_get_setting("LEVEL_DIR"), file]
				if metaFile.open_encrypted_with_pass(path, File.READ, get_encryption_password()) != OK:
					print('Failed to open metadata file for level %s' % [file])
					continue

				var metadata = parse_json(metaFile.get_as_text())

				if metadata == null: 
					print('Failed to read metadata file for level %s' % [file])
					metaFile.close()
					continue
					pass

				metaFile.close()
				
				files.append(metadata)
	
	files.sort_custom(self, "sort_levels")
	return files
	pass

func get_encryption_password():
	return "thing"
	pass

func sort_levels(a, b):
	if typeof(a.name) == typeof(b.name):
		return a.name < b.name
	else:
		if a.name == null:
			return false
		return true
	pass
