extends Node2D

func _ready():
	UI.keys(false, true)
	TouchScreen.show_keys(false, true, false)

func _input(event):
	if event.is_action_pressed("action"):
		Shared.wipe_scene(Shared.main_menu_path)
		set_process_input(false)
		$AudioBack.play()
