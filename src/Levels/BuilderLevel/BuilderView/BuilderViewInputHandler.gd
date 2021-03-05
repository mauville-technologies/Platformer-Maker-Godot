extends Area2D
signal tilemap_clicked;
signal tilemap_right_clicked
signal tilemap_middle_clicked
signal help_changed

const PAN_SPEED = 20
const cursorSpeed = 10
const testingRestartSpeed = 1
const cant_click_timeout = 0.1

onready var builder_view = get_parent()
onready var input_manager = get_node("/root/InputManager")
onready var cursor = $UILayer/Cursor
onready var cursorPosition = get_viewport().get_mouse_position()
onready var test_progress_bar = $UILayer/TestProgressBar

var pan_position = Vector2(0,-1080)
var is_left_mouse_down = false
var is_right_mouse_down = false
var is_middle_mouse_down = false
var _is_cursor_mode = true
var _last_cursor_mode = false
var _time_holding_down_testing = 0
var _is_going_to_testing = false
var _current_cant_click_timeout = 0
var enabled = true

# Called sn the node enters the scene tree for the first time.
func _ready():
	test_progress_bar.visible = false
	pass # Replace with function body.


func start_cant_click_timeout():
	_current_cant_click_timeout = cant_click_timeout
	
func _handle_joypad_input(delta):
	
	# Pallette view
	if builder_view.searching:
		cursor.visible = false
	else:    
		# both modes
		_handle_pan()
		_joypad_check_for_testing(delta)  
		
		# SELECT WILL GO HERE
		if Input.is_action_just_pressed("builder_toggle_ui_mode") && !builder_view.searching:
			#_is_cursor_mode = !_is_cursor_mode
			pass
			
		if _is_cursor_mode:
			cursor.visible = true
			_joypad_move_cursor(delta)
			
			if Input.is_action_just_pressed("builder_cursor_click"):
				_click_down()
				pass
			if Input.is_action_just_released("builder_cursor_click"):
				_click_up()
				pass
			if Input.is_action_just_pressed("builder_cursor_right_click"):
				_right_click_down()
			if Input.is_action_just_released("builder_cursor_right_click"):
				_right_click_up()
				
			if Input.is_action_just_pressed("builder_cursor_middle_click"):
				_middle_click_down()
			if Input.is_action_just_released("builder_cursor_middle_click"):
				_middle_click_up()
			pass
		else:
			cursor.visible = false
			
		if is_left_mouse_down:
			emit_signal("tilemap_clicked", pan_position)
		if is_right_mouse_down:
			emit_signal("tilemap_right_clicked", pan_position)
		if is_middle_mouse_down:
			emit_signal("tilemap_middle_clicked", pan_position)
			
func _handle_mouse_input(delta):
	cursor.visible = true
	cursorPosition = get_viewport().get_mouse_position()
	cursor.position = cursorPosition
	
	if builder_view.searching:
		
		pass
	else:
		_handle_pan()
		if is_left_mouse_down:
			emit_signal("tilemap_clicked", pan_position)
		if is_right_mouse_down:
			emit_signal("tilemap_right_clicked", pan_position)
		if is_middle_mouse_down:
			emit_signal("tilemap_middle_clicked", pan_position)
	
func _handle_keyboard_input(delta):
	_joypad_check_for_testing(delta)  
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _current_cant_click_timeout > 0:
		_current_cant_click_timeout = _current_cant_click_timeout - delta
		return
	
	_current_cant_click_timeout = 0
	if enabled:
		emit_signal("help_changed", Input.is_action_pressed("help"))
		
		if input_manager.is_joypad:
			_handle_joypad_input(delta)
		else:
			_handle_mouse_input(delta)
			
		_handle_keyboard_input(delta)
	else:
		if input_manager.is_joypad:
			cursor.visible = false
		else:
			_handle_mouse_input(delta)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_RIGHT \
		and event.is_pressed() \
		and !is_right_mouse_down:
			is_right_mouse_down = true
			return
	
	if event is InputEventMouseButton \
		and event.button_index == BUTTON_RIGHT \
		and !event.is_pressed() \
		and is_right_mouse_down:
			is_right_mouse_down = false
			return

	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed() \
	and !is_left_mouse_down:
		is_left_mouse_down = true
		return

	if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and !event.is_pressed() \
		and is_left_mouse_down:
			is_left_mouse_down = false
			return
			
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_MIDDLE \
	and event.is_pressed() \
	and !is_middle_mouse_down:
		is_middle_mouse_down = true
		return

	if event is InputEventMouseButton \
		and event.button_index == BUTTON_MIDDLE \
		and !event.is_pressed() \
		and is_middle_mouse_down:
			is_middle_mouse_down = false
			return
			
func set_enabled(is_enabled):
	enabled = is_enabled

	
func _click_down():
	var ev = InputEventMouseButton.new()
	ev.button_index=BUTTON_LEFT
	ev.pressed = true
	ev.global_position = cursorPosition
	ev.position = cursorPosition
	get_tree().input_event(ev)
	
func _click_up():
	var ev = InputEventMouseButton.new()
	ev.button_index=BUTTON_LEFT
	ev.pressed = false
	ev.global_position = cursorPosition
	ev.position = cursorPosition
	get_tree().input_event(ev)
	  
func _right_click_down():
	var ev = InputEventMouseButton.new()
	ev.button_index=BUTTON_RIGHT
	ev.pressed = true
	ev.global_position = cursorPosition
	ev.position = cursorPosition
	get_tree().input_event(ev)
	
func _right_click_up():
	var ev = InputEventMouseButton.new()
	ev.button_index=BUTTON_RIGHT
	ev.pressed = false
	ev.global_position = cursorPosition
	ev.position = cursorPosition
	get_tree().input_event(ev)

func _middle_click_down():
	var ev = InputEventMouseButton.new()
	ev.button_index=BUTTON_MIDDLE
	ev.pressed = true
	ev.global_position = cursorPosition
	ev.position = cursorPosition
	get_tree().input_event(ev)
	
func _middle_click_up():
	var ev = InputEventMouseButton.new()
	ev.button_index=BUTTON_MIDDLE
	ev.pressed = false
	ev.global_position = cursorPosition
	ev.position = cursorPosition
	get_tree().input_event(ev)

func _move_mouse_to_cursor():
	get_viewport().warp_mouse(cursorPosition)
	
func _joypad_move_cursor(delta):
	var move_x = Input.get_action_strength('builder_move_cursor_right') - Input.get_action_strength("builder_move_cursor_left")
	var move_y = Input.get_action_strength('builder_move_cursor_down') - Input.get_action_strength("builder_move_cursor_up")

	cursorPosition = cursorPosition + (Vector2(move_x, move_y) * cursorSpeed)
	cursorPosition.x = clamp(cursorPosition.x,0, get_viewport().get_visible_rect().size.x)
	cursorPosition.y = clamp(cursorPosition.y,0, get_viewport().get_visible_rect().size.y)
	cursor.position = cursorPosition
	
	_move_mouse_to_cursor()
	
func _joypad_check_for_testing(delta):
	if _time_holding_down_testing != 0:
		test_progress_bar.visible = true
		test_progress_bar.value = (_time_holding_down_testing / testingRestartSpeed) * 100
	else:
		test_progress_bar.visible = false
		
	if _is_going_to_testing:
		_time_holding_down_testing = _time_holding_down_testing + delta
	else:
		_time_holding_down_testing = 0
		
	if Input.is_action_just_pressed("builder_test_mode"):
		_is_going_to_testing = true
		pass
		
	if !Input.is_action_pressed("builder_test_mode"):
		if _is_going_to_testing:
			if _time_holding_down_testing >= testingRestartSpeed:
				builder_view._go_to_testing(true)
			else:
				builder_view._go_to_testing(false)
				
		_is_going_to_testing = false
		_time_holding_down_testing = 0

func _handle_pan():
	if enabled:
		if Input.is_action_pressed("builder_pan_left"):
			pan_position.x = pan_position.x - PAN_SPEED;
			pass
		if Input.is_action_pressed("builder_pan_right"):
			pan_position.x = pan_position.x + PAN_SPEED;
			pass
		if Input.is_action_pressed("builder_pan_up"):
			pan_position.y = pan_position.y - PAN_SPEED;
			pass
		if Input.is_action_pressed("builder_pan_down"):
			pan_position.y = pan_position.y + PAN_SPEED;
			pass
		
		self.position = pan_position

func pan_to_point(new_position : Vector2):
	pan_position = new_position
