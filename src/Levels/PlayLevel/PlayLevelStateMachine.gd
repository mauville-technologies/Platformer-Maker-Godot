extends "res://src/Levels/StateMachine.gd"
class_name PlayLevelStateMachine

const LOADING_VIEW_PATH = 'res://src/Levels/PlayLevel/LoadingView/LoadingView.tscn'
const PLAY_VIEW_PATH = 'res://src/Levels/PlayLevel/PlayView/PlayView.tscn'
const COUNTDOWN_VIEW_PATH = 'res://src/Levels/PlayLevel/CountdownView/CountdownView.tscn'
const WIN_VIEW_PATH = 'res://src/Levels/PlayLevel/WinView/WinView.tscn'
const LOSE_VIEW_PATH = 'res://src/Levels/PlayLevel/LoseView/LoseView.tscn'

onready var tilemap = "/root/Tilemap"
var currentTile = ''
var currentViewNode = null;

func _state_logic(delta):
	if currentViewNode != null:
		#currentViewNode.process(parent)
		pass


func _get_transition(delta):
	match state:
		states.enter:
			if !parent.is_loading:
				if (states.has('count_down')):
					return states.count_down
		states.count_down:
			if parent.is_playing:
				if (states.has('play')):
					return states.play
		states.play:
			if !parent.is_playing:
				return states.count_down
			if parent.player_won:
				return states.win
			if parent.player_dead:
				return states.lose
		states.lose:
			if !parent.is_playing:
				return states.count_down
		states.win:
			if !parent.is_playing:
				return states.count_down
				
	return null

func _enter_state(new_state, old_state):
	match state:
		states.enter:
			currentViewNode = preload(LOADING_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.count_down:
			currentViewNode = preload(COUNTDOWN_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.play:
			currentViewNode = preload(PLAY_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.lose:
			currentViewNode = preload(LOSE_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.win:
			currentViewNode = preload(WIN_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
			

func _exit_state(old_state, new_state):
	if old_state != states.count_down:
		get_parent().remove_child(currentViewNode)
		currentViewNode.queue_free()
