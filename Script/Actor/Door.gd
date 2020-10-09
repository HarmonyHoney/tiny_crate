extends Actor
class_name Door

export var map_name := "hub"

var node_sprite_door : Sprite
var node_sprite_arrow : Sprite
var node_label : Label

func _ready():
	node_sprite_door = $SpriteDoor
	node_sprite_arrow = $SpriteArrow
	node_sprite_arrow.visible = true
	
	node_label = $Label
	node_label.visible = true
	align_text()

func _process(delta):
	show_hint(check_area_actors("player", position.x, position.y, hitbox_x, hitbox_y).size())

func open():
	Shared.start_reset(map_name)
	Shared.hub_pos = position
	node_sprite_door.frame = 0

func show_hint(arg := false):
	node_sprite_arrow.visible = arg
	node_label.visible = arg

func align_text():
	if node_label:
		node_label.text = map_name
		node_label.rect_size = Vector2.ZERO
		node_label.rect_position = Vector2(4 - (node_label.rect_size.x / 2), -16)



