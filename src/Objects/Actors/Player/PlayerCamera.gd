extends Camera2D

onready var tween = $Tween
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func tween_zoom(new_zoom : Vector2):
    tween.stop(self, "zoom")
    tween.interpolate_property(self, "zoom", zoom, new_zoom, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.start()
