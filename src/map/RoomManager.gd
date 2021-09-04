extends Node2D

var rooms = []
var player
var active
var cam

func _ready():
	visible = false
	
	cam = get_parent().get_node("GameCamera")
	
	rooms = get_children()
	for i in get_tree().get_nodes_in_group("player"):
		player = i
		break
	
	find_room()

func _process(delta):
	if !is_player_inside(active):
		find_room()

func aabb(x1 : int, y1 : int, w1 : int, h1 : int, x2 : int, y2 : int, w2 : int, h2 : int) -> bool:
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1

func is_player_inside(room) -> bool:
	return aabb(player.center().x, player.center().y, 0, 0, room.rect_position.x, room.rect_position.y, room.rect_size.x, room.rect_size.y)

func set_active(arg):
	active = arg
	
	cam.limit_left = active.rect_position.x
	cam.limit_top = active.rect_position.y
	cam.limit_right = active.rect_position.x + active.rect_size.x
	cam.limit_bottom = active.rect_position.y + active.rect_size.y
	#cam.position = active.rect_position + active.rect_size / 2
	
	print("active room: ", active.name, " left: ", cam.limit_left, " right: ", cam.limit_right, " top: ", cam.limit_top, " bottom: ", cam.limit_bottom)

func find_room():
	for i in rooms:
		if i != active and is_player_inside(i):
			set_active(i)
			break
