extends Node2D

func act():
	Audio.play("menu_delete", 0.9, 1.1)
	Shared.delete_save()
	Shared.cam.shake(5)
