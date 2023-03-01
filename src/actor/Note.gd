@tool
extends Actor

@onready var sprite := $Sprite2D

var bounce := 0.0

var explosion := preload("res://src/fx/Explosion.tscn")

@export var palette : PackedColorArray

func _ready():
	if Engine.editor_hint: return
	
	if Shared.notes.has(Shared.current_map):
		modulate = palette[1]

func _physics_process(delta):
	if Engine.editor_hint: return
	
	bounce += delta * 2.5
	sprite.offset.y = sin(bounce) * 1.5
	
	if is_instance_valid(Shared.player) and is_overlapping(Shared.player):
		collect()

func collect():
	var e = explosion.instantiate()
	e.position = center()
	get_parent().add_child(e)
	
	Shared.is_note = true
	queue_free()
