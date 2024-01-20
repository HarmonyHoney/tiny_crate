extends Node2D

func act():
	Audio.play("menu_pick", 0.9, 1.1)
	Shared.unlock()
	Shared.cam.shake(10)
