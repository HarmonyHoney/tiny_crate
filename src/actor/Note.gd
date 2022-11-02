tool
extends Actor

onready var sprite := $Sprite

var bounce := 0.0

var explosion := preload("res://src/fx/Explosion.tscn")

func _physics_process(delta):
	if Engine.editor_hint: return
	
	bounce += delta * 2.5
	sprite.offset.y = sin(bounce) * 1.5
	
	if is_instance_valid(Shared.player) and is_overlapping(Shared.player):
		collect()

func collect():
	var e = explosion.instance()
	e.position = center()
	get_parent().add_child(e)
	queue_free()
