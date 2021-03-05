extends Node

var current_map = {}

var currentPlayer = {
	'currentToken' : '',
	'id': ''
}

var offline_mode = false
var guest_mode = false

func get_current_token():
	return currentPlayer.currentToken
	
func get_new_level(uuid):
	return {
		"id": uuid,
		"name": "New Level",
		'start_position_x': 4,
		'start_position_y': 4,
		'map_size_x': 500,
		'map_size_y': 500,
		'completed' : false
	}
