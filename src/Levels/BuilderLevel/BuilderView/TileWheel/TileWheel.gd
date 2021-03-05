extends Node2D

signal option_selected

onready var input_manager = get_node("/root/InputManager")
onready var selection_sprite = $Selection
onready var label = $SectionNameLabel
onready var info_label = $Info/Node2D/InfoLabel

onready var info = $Info
onready var bg = $BG
onready var tween : Tween = $Tween

var current_anchor_index = 0
var is_joypad = false

var tiles = []
var section_name setget set_section_name
var r : float
var g : float
var b : float 

var enabled = false

var current_selection = 0;

func _ready():
	
	pass # Replace with function body.

func _process(delta):
	if enabled && selection_sprite.visible == false:
		selection_sprite.visible = true
	if !enabled && selection_sprite.visible == true:
		selection_sprite.visible = false
		
	if bg != null && info != null && selection_sprite != null:
		bg.self_modulate = Color(r, g, b, 1)
		info.self_modulate = Color(r, g, b, 1)
		selection_sprite.self_modulate = Color(r, g, b, 0.55)
		
	if label.text != section_name:
		label.text = section_name
		
	if enabled:
		var selection : Vector2
		
		if input_manager.is_joypad:
			selection = _handle_joypad()
		else:
			selection = _handle_mouse_and_keyboard()
			
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("option_selected", tiles[current_selection]) 
			pass
			
	info_label.text = tiles[current_selection].description
	pass

func set_section_name(new_val : String):
	section_name = new_val

func set_color(color : Color):
	self.r = color.r
	self.g = color.g
	self.b = color.b
		
func add_tile(tile : Dictionary):
	var latch_point = get_node("LatchPoints/%s" % [tiles.size()])
	
	latch_point.texture = load(tile.thumbnailPath)
	latch_point.scale = Vector2(1.5, 1.5)
	tiles.append(tile)

func tween_to_new_position_and_scale(new_pos : Vector2, new_scale : Vector2):
	tween.interpolate_property(self, "position", position, new_pos, 0.3, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.interpolate_property(self, "scale", scale, new_scale, 0.3, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()
	
func _handle_joypad():
	var move_x = Input.get_action_strength('builder_move_cursor_right') - Input.get_action_strength("builder_move_cursor_left")
	var move_y = Input.get_action_strength('builder_move_cursor_down') - Input.get_action_strength("builder_move_cursor_up")
		
	var selection = Vector2(move_x, move_y)
	
	var selection_in_radians = selection.angle()

	if selection_in_radians != 0:
		var degrees = rad2deg(selection_in_radians) 
		
		var old_selection = current_selection
		
		current_selection = int(degrees) / int(45)
		
		if current_selection < 0:
			current_selection = 8 + current_selection
			
		if current_selection >= tiles.size():
			current_selection = old_selection
		
		selection_sprite.set_rotation_degrees((current_selection * 45) -45)
	elif selection_in_radians == 0 && (selection.x != 0):
		current_selection = 0
		var degrees = 0
		
		selection_sprite.set_rotation_degrees(degrees -45)
		
	return selection
	
func _handle_mouse_and_keyboard():
	var selection = get_global_mouse_position() - global_position
		
	var selection_in_radians = selection.angle()
	
	if selection_in_radians != 0:
		var degrees = rad2deg(selection_in_radians) 
		
		var old_selection = current_selection
		
		current_selection = int(degrees) / int(45)
		
		if current_selection < 0:
			current_selection = 7 + current_selection
		elif current_selection == 0:
			if degrees < 0:
				current_selection = 7
				
		if current_selection >= tiles.size():
			current_selection = old_selection
		
		selection_sprite.set_rotation_degrees((current_selection * 45) - 45)
		 
	return selection       


func on_click(viewport, event, shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.is_pressed():
			emit_signal("option_selected", tiles[current_selection])
			
	pass # Replace with function body.
