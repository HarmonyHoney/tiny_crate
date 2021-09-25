extends Node2D

var timer = 0.7
var step = 0
onready var logo = $Logo
onready var audio = $AudioStreamPlayer

func _ready():
	logo.visible = false
	Music.play()

func _process(delta):
	timer = max(0, timer - delta)
	if timer == 0:
		if step == 0:
			logo.visible = true
			audio.play()
			step = 1
			timer = 1.5
		else:
			Shared.scene_path = Shared.main_menu_path
			Shared.do_reset()
			set_process(false)
