extends Actor

var folder = "Map"
export var map_name := "hubworld"

var node_sprite_arrow : Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	node_sprite_arrow = get_node("SpriteArrow")
	pass # Replace with function body.


func _process(delta):
	node_sprite_arrow.visible = check_area_actors(position.x, position.y, hitbox_x, hitbox_y, "player").size()


func open():
	get_tree().change_scene("res://Map/" + map_name + ".tscn")
