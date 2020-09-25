tool
extends Actor
class_name Switch

export var color := "red"

var is_on := false
var is_last := false

var node_sprite : Sprite
var node_audio : AudioStreamPlayer2D

func _ready():
	if Engine.editor_hint:
		return
	
	add_to_group("switch_" + color)
	
	node_sprite = $Sprite
	node_audio = $AudioStreamPlayer2D
	


func _process(delta):
	if Engine.editor_hint:
		return
	
	is_last = is_on
	is_on = is_area_solid_actor(position.x, position.y)
	
	if is_on:
		if is_last:
			pass
		else:
			node_sprite.position.y = 2
			noise()
	else:
		if is_last:
			node_sprite.position.y = 0
			noise()
		else:
			pass


func noise():
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()

