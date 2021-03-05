extends Node2D
class_name UniverseBuilder

const UNIVERSE_TYPE ="res://src/models/universe/Universe.gd"
const universe_payload = preload("res://config/TemporaryJson.gd")
const player_asset = preload("res://src/Components/Universe/UniversePlayer/UniversePlayer.tscn")

var universe : Universe = null
var _player : UniversePlayer = null
var _current_level : String = ""

func _ready():
	_load_universe()
	pass

func _load_universe():
	universe = load(UNIVERSE_TYPE).new()

	universe.init(self, universe_payload.get_universe(""))
	universe.set_name("universe")
	
	_player = player_asset.instance()
	_current_level = universe._entry_point
	_player.global_position = universe._universe_data['points'][universe._entry_point].position
	add_child(_player)
	_player.connect('request_player_move', self, "_player_request_move")

func _player_request_move(direction : String):
	var next_level : PointOnMap = universe._get_next_level_in_direction(_current_level, direction)
	if next_level:
		_player.goTo(next_level._point_on_map)
		_current_level = next_level.id
	
	pass	
