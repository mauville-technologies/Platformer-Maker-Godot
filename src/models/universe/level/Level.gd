tool
extends PointOnMap
class_name Level

var level_id : String = ""
var next_point_secret = null
var _secret_cleared = false

func init(key : String, parent : Node, point_info):
	if _initialized:
		return
		
	.init(key, parent, point_info)
	_display_node.radius = 16

	if point_info['attributes']['secret_clear']:
		_display_node.color = "red"
	else:
		_display_node.color = "yellow"
		
	pass

		
func get_class(): return "Level"

