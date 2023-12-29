extends Node2D

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("action"):
		Shared.wipe_scene(Shared.main_menu_path)
		set_process_input(false)
		Audio.play("menu_back", 0.9, 1.1)
