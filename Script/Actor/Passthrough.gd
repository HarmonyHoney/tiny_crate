tool
extends Actor
class_name Passthrough

var is_hit := false
var is_done := false

var node_sprite : Sprite
var node_audio : AudioStreamPlayer2D

func _ready():
	if Engine.editor_hint:
		return
	
	node_sprite = $Sprite
	node_audio = $Audio
	

func _process(delta):
	if Engine.editor_hint:
		return
	
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
	
	
	
