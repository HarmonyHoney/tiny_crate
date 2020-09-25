tool
extends Actor
class_name SwitchBlock

export var color := "red"

var node_sprite : Sprite

func _ready():
	if Engine.editor_hint:
		return
	
	add_to_group("switch_block_" + color)
	
	node_sprite = $Sprite


func _process(delta):
	if Engine.editor_hint:
		return
