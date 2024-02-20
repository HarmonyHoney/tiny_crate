tool
extends Actor
class_name Switch

export var color := "red"

var is_on := false
var is_last := false

onready var node_sprite : Sprite = $Sprite
onready var node_audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

signal press
signal release

func _enter_tree():
	if Engine.editor_hint: return
	add_to_group("switch_" + color)

func _physics_process(delta):
	if Engine.editor_hint: return
	
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
	emit_signal("press")

func release():
	noise()
	node_sprite.position.y = 0
	emit_signal("release")






