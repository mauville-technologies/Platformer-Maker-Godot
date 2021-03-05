extends Node2D
class_name LevelMarker

var radius = 8
var color = 'white'

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_circle(Vector2(0,0), radius, ColorN(color))
