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
	if speed_x != 0 and  is_on_floor:
		speed_x = 0
	
	is_pushed = false


# push box
func push(dir : int):
	if not move_x(dir):
		is_pushed = true
		for a in overlapping_actors(0, -1, null):
			if a.tag == "box":
				# only be pushed by one crate
				if not a.is_pushed:
					a.push(dir)
