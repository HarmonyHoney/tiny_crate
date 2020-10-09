extends Node2D
class_name Stage

var timer := 0.0
var is_timer = true

func _ready():
	Shared.stage = self

func _process(delta):
	if is_timer:
		timer += delta
		HUD.node_timer.text = "timer: " + str(timer)

func stop_timer():
	is_timer = false
