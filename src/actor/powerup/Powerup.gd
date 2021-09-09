tool
extends Actor
class_name Powerup

export var powerup_name = "push"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func collect():
	queue_free()
