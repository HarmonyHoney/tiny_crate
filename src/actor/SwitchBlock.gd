@tool
extends Actor
class_name SwitchBlock

@export var color := "red"
@export var frame_on := 10
@export var frame_off := 8

@onready var node_sprite : Sprite2D = $Sprite2D

var is_switch = false

func _ready():
	if Engine.is_editor_hint():
		return
	
	add_to_group("switch_block_" + color)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	if is_switch and !is_solid and !is_area_solid_actor(position.x, position.y):
		is_solid = true
		node_sprite.frame = frame_on

func switch_on():
	is_switch = true

func switch_off():
	is_switch = false
	is_solid = false
	node_sprite.frame = frame_off


