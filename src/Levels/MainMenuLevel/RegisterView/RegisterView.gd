extends Control

onready var parent = get_parent()
onready var APIIntegration = get_node("/root/APIIntegration")
onready var email_input = $VBoxContainer/EmailBox/Email
onready var display_name_input = $VBoxContainer/DisplayNameBox/DisplayName
onready var password_input = $VBoxContainer/PasswordBox/Password
onready var confirm_password_input = $VBoxContainer/ConfirmPasswordBox/ConfirmPassword
onready var error_message_label = $VBoxContainer/ErrorMessageLabel

func _ready():
	APIIntegration.connect("register_success", self, "_register_success")
	APIIntegration.connect("register_failed", self, "_register_failed")
	email_input.grab_focus()
	
func _back():
	parent.current_state = parent.MENU_STATES.login
	pass


func _on_RegisterButton_pressed():
	var errors = ""
	
	if email_input.text.empty():
		errors = errors + "Email cannot be empty!\n"
		
	if display_name_input.text.empty():
		errors = errors + "Display name cannot be empty!\n"
	
	if password_input.text.empty() || confirm_password_input.text.empty():
		errors = errors + "Password fields cannot be empty!\n"
		
	if password_input.text != confirm_password_input.text:
		errors = errors + "Passwords don't match"
		
	if !errors.empty():
		error_message_label.text = errors        
		error_message_label.visible = true
		return
	else:
		error_message_label.visible = false        
		APIIntegration.register(email_input.text, display_name_input.text, password_input.text)

	pass # Replace with function body.

func _register_success():
	error_message_label.add_color_override("font_color", Color(0,1,0,1))
	error_message_label.text = "Registration successful! Redirecting to login"
	error_message_label.visible = true
	
	yield(get_tree().create_timer(2.0), "timeout")
	parent.current_state = parent.MENU_STATES.login
	pass
	
func _register_failed(message):
	error_message_label.text = "Registration failed: %s" % [message]
	error_message_label.visible = true
	pass

func _exit_tree():
	APIIntegration.disconnect("register_success", self, "_register_success")
	APIIntegration.disconnect("register_failed", self, "_register_failed")

func _quit_game():
	get_tree().quit()
	pass # Replace with function body.


func _on_form_submitted(_new_text):
	_on_RegisterButton_pressed()
	pass # Replace with function body.
