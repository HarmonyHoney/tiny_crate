extends Node2D

func act():
	Shared.wipe_scene(Shared.main_menu_path)
	Audio.play("menu_back", 0.9, 1.1)
