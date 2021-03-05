extends Node2D

onready var config = get_node("/root/Config")

var desired_zoom : Vector2 = Vector2(1,1)
export(Vector2) var current_zoom : Vector2 = Vector2(1,1)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
    var longest_length = 1080
    
    # find the longest length
    for child in get_children():
        if !child.is_class("Camera2D") && !child.is_class("Tween"):
            var new_length = 0.0
            
            for raycast in child.get_children():
                
                if raycast.is_colliding():
                    var origin = raycast.global_transform.origin
                    var collision_point = raycast.get_collision_point()
                    new_length += origin.distance_to(collision_point)
                    
                pass    
                
            if new_length < longest_length && new_length != 0:
                longest_length = new_length + 64
            pass
        pass
        
    longest_length = clamp(longest_length, 450, 1080)
    
    var ratio = stepify(longest_length / config._get_setting("RESOLUTION").y, 0.01)
    
    # here we'll bound the player camera to either the top or bottom half of the worlds.
    if ($Camera2D):
        var new_zoom = Vector2(ratio,ratio);
        
        if desired_zoom.y != new_zoom.y:
            desired_zoom = new_zoom
            $Camera2D.tween_zoom(desired_zoom)
            
        if (get_parent().position.y > 0):
            $Camera2D.limit_top = 32
            $Camera2D.limit_bottom = 10000000
        else:
            $Camera2D.limit_top = -10000000
            $Camera2D.limit_bottom = 32
    pass
