tool
extends Actor
class_name Passthrough

var is_hit := false
var is_done := false

onready var node_sprite : Sprite = $Sprite
onready var node_audio : AudioStreamPlayer2D = $Audio

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if is_done:
		pass
	else:
		if is_hit:
			is_done = not is_area_solid_actor(position.x, position.y)
			if is_done:
				node_sprite.frame += 1
				is_solid = true
				node_audio.play()
		else:
			is_hit = is_area_solid_actor(position.x, position.y)

