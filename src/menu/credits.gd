extends Node2D

func _input(event):
	if event.is_action_pressed("action"):
		Shared.scene_path = Shared.main_menu_path
		Shared.do_reset()
		set_process_input(false)
		$AudioBack.play()
