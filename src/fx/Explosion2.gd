extends Node2D

onready var node_audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

var target_pos := Vector2.ZERO

export var lerp_speed := 0.1

func _ready():
	target_pos = position
	
	for a in Shared.actors:
		if a.tag == "exit":
			target_pos = a.position + Vector2(3, 3)
			break
	
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()

func _physics_process(delta):
	position = position.linear_interpolate(target_pos, lerp_speed)

func anim_finish():
	queue_free()
