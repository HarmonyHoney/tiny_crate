extends Node2D

var p

# Called when the node enters the scene tree for the first time.
func _ready():
	
	p = $Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if p.position.y > 128:
		Shared.scene_path = Shared.main_menu_path
		Shared.do_reset()
		p.is_attract_mode = true
		set_process(false)
