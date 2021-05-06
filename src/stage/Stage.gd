extends Node2D
class_name Stage

export var stage_name := "unnamed"

var timer := 0.0
var is_timer = true
var metric_pickup := 0
var metric_jump := 0
var metric_death := 0
var is_complete = false

func _ready():
	Shared.stage = self
	
	
	for i in Shared.stage_data:
		if i.has("file") and i.file == filename:
			if i.has("death"):
				metric_death = i.death

func _process(delta):
	if is_timer:
		timer += delta
		HUD.set_time(timer)

func stop_timer():
	is_timer = false

func death():
	metric_death += 1
	Shared.save_file
	pass