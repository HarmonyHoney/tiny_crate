extends Node2D

func act():
	Shared.wipe_scene(Shared.main_menu_path)
	owner.set_process_input(false)
	Audio.play("menu_back", 0.9, 1.1)
