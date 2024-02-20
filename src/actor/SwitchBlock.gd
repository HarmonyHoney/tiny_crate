tool
extends Actor
class_name SwitchBlock

export var color := "red"
export var frame_on := 10
export var frame_off := 8

onready var node_sprite : Sprite = $Sprite

var is_switch = false

func _ready():
	if Engine.editor_hint: return
	
	for i in get_tree().get_nodes_in_group("switch_" + color):
		i.connect("press", self, "switch_on")
		i.connect("release", self, "switch_off")
		break

func _physics_process(delta):
	if Engine.editor_hint: return
	
	if is_switch and !is_solid and !is_area_solid_actor(position.x, position.y):
		is_solid = true
		node_sprite.frame = frame_on

func switch_on():
	is_switch = true

func switch_off():
	is_switch = false
	is_solid = false
	node_sprite.frame = frame_off


