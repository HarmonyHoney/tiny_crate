extends Node2D

func act():
	Shared.scene_path = Shared.main_menu_path
	Shared.do_reset()
	owner.set_process_input(false)
	Audio.play("menu_back", 0.9, 1.1)
