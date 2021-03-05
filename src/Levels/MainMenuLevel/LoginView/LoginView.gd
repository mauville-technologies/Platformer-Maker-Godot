extends Control

onready var parent = get_parent()
onready var global_state = get_node("/root/GlobalState")

onready var email_input = $VBoxContainer/EmailBox/Email
onready var password_input = $VBoxContainer/PasswordBox/Password
onready var error_message = $VBoxContainer/ErrorMessage

func _ready():
	APIIntegration.connect("login_success", self, "_login_success")
	APIIntegration.connect("login_failed", self, "_login_failed")
	email_input.grab_focus()
	
func _login():
	var errors = ""
	
	if email_input.text.empty():
		errors = "%sEmail cannot be empty\n" % [errors]
	
	if password_input.text.empty():
		errors = "%sPassword cannot be empty\n" % [errors]
	
	if !errors.empty():
		error_message.text = errors
		error_message.visible = true
	else:
		error_message.visible = false
		APIIntegration.login(email_input.text, password_input.text)
		
	pass

func _login_success(user_id, token):
	error_message.text = 'Login Successful, redirecting to main menu...'
	error_message.add_color_override("font_color", Color(0,1,0,1))
	error_message.visible = true
	
	global_state.currentPlayer.currentToken = token
	global_state.currentPlayer.id = user_id
	
	yield(get_tree().create_timer(2.0), "timeout")
	parent.current_state = parent.MENU_STATES.main_menu
	
	print('successsful login user: %s' % [user_id])

func _login_failed(message):
	error_message.text = 'Login Failed: %s' % [message]
	error_message.visible = true
	
func _exit_tree():
	APIIntegration.disconnect("login_success", self, "_login_success")
	APIIntegration.disconnect("login_failed", self, "_login_failed")
	
func _quit_game():
	get_tree().quit()
	pass # Replace with function body.


func _on_RegisterButton_pressed():
	parent.current_state = parent.MENU_STATES.register
	pass # Replace with function body.


func _on_form_submit(_new_text):
	_login()
	pass # Replace with function body.


func _offline_mode():
	global_state.offline_mode = true
	parent.current_state = parent.MENU_STATES.main_menu
	
	pass # Replace with function body.
