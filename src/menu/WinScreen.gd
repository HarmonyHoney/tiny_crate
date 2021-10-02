extends Node2D

onready var p = $Player

func _physics_process(delta):
	if p.position.y > 128:
		Shared.scene_path = Shared.splash_path
		Shared.do_reset()
		p.is_attract_mode = true
		set_physics_process(false)
