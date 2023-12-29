extends Node2D

func act():
	Audio.play("menu_delete", 0.9, 1.1)
	Shared.delete_save()
	Shared.node_camera_game.shake(5)
