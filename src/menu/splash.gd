extends Node2D

var timer = 0.7
var step = 0
onready var logo = $Logo
onready var audio = $AudioStreamPlayer

func _ready():
	logo.visible = false
	Music.play()

func _physics_process(delta):
	timer = max(0, timer - delta)
	if timer == 0:
		if step == 0:
			logo.visible = true
			audio.play()
			step = 1
			timer = 1.5
		else:
			Shared.wipe_scene(Shared.main_menu_path)
			set_physics_process(false)
