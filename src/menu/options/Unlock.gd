extends Node2D

func act():
	Audio.play("menu_pick", 0.9, 1.1)
	Shared.unlock()
	Shared.node_camera_game.shake(10)
