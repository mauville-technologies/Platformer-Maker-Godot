extends "res://src/Levels/StateMachine.gd"

const BUILDING_VIEW_PATH = 'res://src/Levels/BuilderLevel/BuilderView/BuilderView.tscn'
const TESTING_VIEW_PATH = 'res://src/Levels/BuilderLevel/TestingView/TestingView.tscn'
const UPLOADING_VIEW_PATH = 'res://src/Levels/BuilderLevel/UploadingView/UploadingView.tscn'

var currentViewNode = null;

func _state_logic(delta):
	if currentViewNode != null:
		#currentViewNode.process(parent)
		pass

func _get_transition(delta):
	match state:
		states.building:
			if get_parent()._testing:
				return states.testing
			if get_parent()._uploading:
				return states.uploading
		states.testing:
			if !get_parent()._testing:
				return states.building
		states.uploading:
			if !get_parent()._uploading && get_parent().building:
				return states.building
			pass
				
	return null

func _enter_state(new_state, old_state):
	match state:
		states.building:
			currentViewNode = load(BUILDING_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.testing:
			currentViewNode = load(TESTING_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.uploading:
			currentViewNode = load(UPLOADING_VIEW_PATH).instance();
			get_parent().add_child(currentViewNode)
		states.uploading:
			
			pass

func _exit_state(old_state, new_state):
	get_parent().remove_child(currentViewNode)
	currentViewNode.queue_free()

func pause_current_view(is_paused : bool):
	if currentViewNode.has_method("pause"):
		currentViewNode.pause(is_paused)
	pass

func reset_level():
	if currentViewNode.has_method("reset_level"):
		currentViewNode.reset_level()
	pass
