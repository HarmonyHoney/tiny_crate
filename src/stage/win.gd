extends Node2D

onready var p = $Player

func _ready():
	if Shared.is_level_select: return
	Audio.play("menu_pick")

func _physics_process(delta):
	if p.position.y > 128:
		Shared.wipe_scene(Shared.level_select_path)
		p.is_attract_mode = true
		set_physics_process(false)
