extends Node2D

@onready var audio := $AudioStreamPlayer

func act():
	audio.play()
	Shared.delete_save()
	Shared.node_camera_game.shake(5)
