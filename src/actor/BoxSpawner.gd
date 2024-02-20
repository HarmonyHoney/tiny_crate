tool
extends Actor

var is_hit := false
var is_done := false

onready var node_sprite : Sprite = $Sprite
onready var node_audio : AudioStreamPlayer2D = $Audio

export var color := "red"

var box = preload("res://src/actor/Box.tscn")

func _ready():
	for i in get_tree().get_nodes_in_group("switch_" + color):
		i.connect("press", self, "release")

func release():
	if is_area_solid_actor(position.x, position.y): return
	var b = box.instance()
	b.position = position
	get_parent().add_child(b)

