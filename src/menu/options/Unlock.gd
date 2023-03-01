extends Node2D

@onready var audio := $AudioStreamPlayer

func act():
	audio.play()
	false # Shared.unlock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	Shared.node_camera_game.shake(10)
