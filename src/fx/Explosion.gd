extends Node2D

onready var node_audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()

func anim_finish():
	queue_free()
