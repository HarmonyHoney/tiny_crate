extends Node2D

func _ready():
	yield(get_tree(), "idle_frame")
	Music.play()
	Audio.play("menu_bell")
	yield(get_tree().create_timer(1.5), "timeout")
	Shared.wipe_scene(Shared.main_menu_path)
