extends Node2D

onready var audio := $AudioStreamPlayer

func act():
	Shared.scene_path = Shared.main_menu_path
	Shared.do_reset()
	owner.set_process_input(false)
	audio.play()
