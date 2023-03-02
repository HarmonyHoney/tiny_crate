extends Node2D

@onready var audio := $AudioStreamPlayer

func act():
	audio.play()
	Shared.unlock()
	Shared.node_camera_game.shake(10)
