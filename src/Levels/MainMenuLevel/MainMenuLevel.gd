extends Node

onready var main_menu_state_machine = $MainMenuStateMachine
onready var global_state = get_node("/root/GlobalState")

enum MENU_STATES {
	main_menu,
	build_root,
	play_root,
	signed_out,
	login,
	register
}

onready var current_state = MENU_STATES.signed_out

export(Dictionary) var views = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
		
	main_menu_state_machine.add_state("main_menu")
	main_menu_state_machine.add_state("build_root")
	main_menu_state_machine.add_state("play_root")
	main_menu_state_machine.add_state("login")
	main_menu_state_machine.add_state("register")
	
	if global_state.currentPlayer.currentToken.empty() && !global_state.offline_mode:
		main_menu_state_machine.call_deferred("set_state", main_menu_state_machine.states.login)
	else:
		main_menu_state_machine.call_deferred("set_state", main_menu_state_machine.states.main_menu)
