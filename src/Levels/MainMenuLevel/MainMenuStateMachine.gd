extends "res://src/Levels/StateMachine.gd"
class_name MainMenuStateMachine

var currentViewNode = null;

const MAIN_MENU_PATH = 'res://src/Levels/MainMenuLevel/RootMenuView/RootMenuView.tscn'
const PLAY_ROOT_VIEW_PATH = 'res://src/Levels/MainMenuLevel/PlayRootMenuView/PlayRootMenuView.tscn'
const BUILD_ROOT_VIEW_PATH = 'res://src/Levels/MainMenuLevel/BuildRootMenuView/BuildRootMenuView.tscn'
const REGISTER_VIEW_PATH = "res://src/Levels/MainMenuLevel/RegisterView/RegisterView.tscn"
const LOGIN_VIEW_PATH = "res://src/Levels/MainMenuLevel/LoginView/LoginView.tscn"

func _state_logic(_delta):
	if currentViewNode != null:
		#currentViewNode.process(parent)
		pass


func _get_transition(_delta):
	match state:
		states.main_menu:
			if parent.current_state == parent.MENU_STATES.build_root:
				return states.build_root
				pass
			if parent.current_state == parent.MENU_STATES.play_root:
				return states.play_root
				pass    
			pass
		states.build_root:
			if parent.current_state == parent.MENU_STATES.main_menu:
				return states.main_menu
				pass
			if parent.current_state == parent.MENU_STATES.play_root:
				return states.play_root
				pass    
			pass
		states.play_root:
			if parent.current_state == parent.MENU_STATES.main_menu:
				return states.main_menu
				pass
			if parent.current_state == parent.MENU_STATES.build_root:
				return states.build_root
				pass  
		states.login:
			if parent.current_state == parent.MENU_STATES.main_menu:
				return states.main_menu
			if parent.current_state == parent.MENU_STATES.register:
				return states.register
		states.register:
			if parent.current_state == parent.MENU_STATES.login:
				return states.login
			pass
	return null

func _enter_state(_new_state, _old_state):
	match state:
		states.main_menu:
			currentViewNode = preload(MAIN_MENU_PATH).instance()
			get_parent().add_child(currentViewNode)
			pass
		states.build_root:
			currentViewNode = preload(BUILD_ROOT_VIEW_PATH).instance()
			get_parent().add_child(currentViewNode)
			pass
		states.play_root:
			currentViewNode = preload(PLAY_ROOT_VIEW_PATH).instance()
			get_parent().add_child(currentViewNode)
			pass
		states.login:
			currentViewNode = preload(LOGIN_VIEW_PATH).instance()
			get_parent().add_child(currentViewNode)
			pass
		states.register:
			currentViewNode = preload(REGISTER_VIEW_PATH).instance()
			get_parent().add_child(currentViewNode)
			pass

func _exit_state(_old_state, _new_state):
	get_parent().remove_child(currentViewNode)
	currentViewNode.queue_free()
