extends Node2D

func _input(event):
	if Wipe.is_wipe: return
	
	if event.is_action_pressed("ui_no"):
		Shared.wipe_scene(Shared.main_menu_path)
		Audio.play("menu_back", 0.9, 1.1)
