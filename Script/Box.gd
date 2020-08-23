extends Actor
class_name Box


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_pushed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if speed_x != 0 and is_on_floor:
		speed_x = 0
	
	is_pushed = false


# push box
func push(dir : int):
	if is_pushed:
		return
	is_pushed = true
	
	# check for box at destination
	if is_area_solid(position.x + dir, position.y):
		for a in check_area_actors(position.x + dir, position.y, hitbox_x, hitbox_y, "box"):
			a.push(dir)
	
	# check for box above
	if not is_area_solid(position.x + dir, position.y):
		for a in check_area_actors(position.x, position.y - 1, hitbox_x, hitbox_y, "box"):
			a.push(dir)
		move_x(dir)
