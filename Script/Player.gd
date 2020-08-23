extends Actor

var move_speed = 1
var move_slow = 0.75
var move_accel = 0.15
var move_last = 0
var push_speed = 0.3

var jump_speed = 2
var jump_frames = 10
var jump_count = 0
var is_jump = false

var anim_frame = 0
var anim_step_run = 0.2
var anim_step_idle = 0.04

var is_pickup = false

var speed_drop_x = 1
var speed_drop_y = -1

var speed_throw_x = 1.0
var speed_throw_y = -2.3

var pickup_frames = 8
var pickup_count = 0

var dir = 1


var node_sprites : Node2D
var node_sprite_guy : Sprite
var node_sprite_box : Sprite

var scene_box = load("res://Scene/Box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# ref nodes
	node_sprites = get_node("Sprites")
	node_sprite_guy = node_sprites.get_node("SpriteGuy")
	node_sprite_box = node_sprites.get_node("SpriteBox")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if btn.p("reset"):
		get_tree().reload_current_scene()
	
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	
	# walking
	if btnx == 0:
		speed_x *= move_slow
	else:
		speed_x += move_accel * btnx
		speed_x = clamp(speed_x, -move_speed, move_speed)
		dir = btnx
		node_sprite_guy.flip_h = btnx == -1
	
	# start jump
	if btn.p("jump") and check_jump():
		is_jump = true
		jump_count = 0
	
	# jump height
	if is_jump:
		if btn.d("jump"):
			speed_y = -jump_speed
			jump_count += 1
			if jump_count > jump_frames:
				is_jump = false
		else:
			is_jump = false
	
	# pickup box
	if btn.p("action"):
		if is_pickup:
			if btn.d("down"):
				box_release(speed_drop_x * dir, speed_drop_y)
			else:
				box_release(speed_throw_x * dir, speed_throw_y)
		else:
			if btn.d("down"):
				box_pickup(0, 1)
			else:
				box_pickup(dir * 4, 0)
			
	
	# push box
	if is_on_floor and move_get_dist().x != 0 and not is_pickup:
		for a in overlapping_actors(dir, 0, null):
			if a.tag == "box":
				a.push(dir)
				# slow movement when pushing
				if abs(speed_x) > push_speed:
					speed_x = push_speed * sign(speed_x)
				move_x(dir)
				break
	

func box_release(sx : int, sy : int):
	is_pickup = false
	node_sprite_box.visible = false
	hitbox_y = 8
	py += 8
	apply_pos()
	var box = scene_box.instance()
	box.position = Vector2(px, py - 8)
	box.speed_x = sx
	box.speed_y = sy
	get_parent().add_child(box)
	node_sprites.position.y = 0

func box_pickup(dx : int, dy : int):
	var offset_y = 0 if btn.d("down") else -8
	
	# pick crate on x axis
	for a in overlapping_actors(dx, dy, null):
		if a.tag == "box":
			var offset_x = box_find_space(0, offset_y, a)
			if offset_x != null:
				is_pickup = true
				node_sprite_box.visible = true
				#a.remove()
				a.queue_free()
				py += offset_y
				px += offset_x
				hitbox_y = 16
				apply_pos()
				node_sprites.position.y = 8
			break


# ox, oy = offset x and y
func box_find_space(ox, oy, ignore : Actor):
	# wiggle around and look for an open space
	for i in [0, 1, -1, 2, -2, 3, -3, 4, -4]:
		if not check_area_solid(px + ox + i, py + oy, 8, 16, ignore):
			return i
	return null



func check_jump():
	return is_on_floor or is_on_floor_2 or is_on_floor_3

