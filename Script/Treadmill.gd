tool
extends Actor
class_name Treadmill

export var tread_speed := -1.0 setget _set_tread_speed

var node_sprite : Sprite


func _ready():
	
	node_sprite = $Sprite
	
	if Engine.editor_hint:
		return

func _process(delta):
	if Engine.editor_hint:
		return


func _set_tread_speed(value):
	tread_speed = value
	
	if node_sprite:
		node_sprite.flip_h = tread_speed > 0
	
