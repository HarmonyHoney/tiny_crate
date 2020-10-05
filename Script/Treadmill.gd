tool
extends Actor
class_name Treadmill

export var tread_speed := -1.0 setget _set_tread_speed
export var length := 1 setget _set_length
export var editor_move := 0 setget _set_editor_move

var node_sprite : Sprite

func _ready():
	# editor and game code
	node_sprite = $Sprite
	node_sprite.material = node_sprite.material.duplicate(true)
	#node_sprite.material = node_sprite.get_material().duplicate(true)
	#node_sprite.set_material(node_sprite.get_material().duplicate(true))
	print(node_sprite.material)
	
	_set_tread_speed(tread_speed)
	_set_length(length)
	
	if Engine.editor_hint:
		return
	
	# game only code

func _process(delta):
	if Engine.editor_hint:
		return


func _set_tread_speed(value):
	tread_speed = value
	if node_sprite:
		node_sprite.flip_h = tread_speed > 0
		node_sprite.material.set_shader_param("speed", abs(tread_speed * 8))

func _set_length(value):
	length = max(1, value)
	_set_hit_x(8 * length)
	if node_sprite:
		node_sprite.region_rect = Rect2(Vector2.ZERO, Vector2(8 * length, 8))

func _set_editor_move(value):
	position.x += value * 8
