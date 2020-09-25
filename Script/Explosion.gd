extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var node_audio : AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	node_audio = $AudioStreamPlayer2D
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func anim_finish():
	queue_free()
