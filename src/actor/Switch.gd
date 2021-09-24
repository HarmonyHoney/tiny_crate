tool
extends Actor
class_name Switch

export var color := "red"

var is_on := false
var is_last := false

onready var node_sprite : Sprite = $Sprite
onready var node_audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	if Engine.editor_hint:
		return
	
	add_to_group("switch_" + color)


func _process(delta):
	if Engine.editor_hint:
		return
	
	is_last = is_on
	is_on = is_area_solid_actor(position.x, position.y)
	
	if is_on:
		if is_last:
			pass
		else:
			press()
	else:
		if is_last:
			release()
		else:
			pass

func noise():
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()

func press():
	noise()
	node_sprite.position.y = 2
	for a in get_tree().get_nodes_in_group("switch_block_" + color):
		a.switch_on()

func release():
	noise()
	node_sprite.position.y = 0
	for a in get_tree().get_nodes_in_group("switch_block_" + color):
		a.switch_off()






