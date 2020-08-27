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
var coyote_time = 3

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

var node_sprite : Sprite
var node_anim : AnimationPlayer

var scene_box = load("res://Scene/Box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# ref nodes
	node_sprite = get_node("Sprite")
	node_anim = get_node("AnimationPlayer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if btn.p("reset"):
		get_tree().reload_current_scene()
	
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	# open door
	if btn.p("up"):
		for a in check_area_actors(position.x, position.y, hitbox_x, hitbox_y, "door"):
			a.open()
			return
	
	# hit spike
	if speed_y > -1:
		for a in check_area_actors(position.x, position.y, hitbox_x, hitbox_y, "spike"):
			print("hit spike")
			death()
			return
	
	# anim
	if is_on_floor:
		if btnx == 0:
			if is_pickup:
				try_anim("box_idle")
			else:
				try_anim("idle")
		else:
			if is_pickup:
				try_anim("box_run")
			else:
				try_anim("run")
	
	# walking
	if btnx == 0:
		speed_x *= move_slow
	else:
		speed_x += move_accel * btnx
		speed_x = clamp(speed_x, -move_speed, move_speed)
		dir = btnx
		node_sprite.flip_h = btnx == -1
	
	# start jump
	if btn.p("jump") and time_since_floor <= coyote_time:
		is_jump = true
		jump_count = 0
		if is_pickup:
			node_anim.play("box_jump")
		else:
			node_anim.play("jump")
	
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
		for a in check_area_actors(position.x + dir, position.y, hitbox_x, hitbox_y, "box"):
			a.push(dir)
			# slow movement when pushing
			if abs(speed_x) > push_speed:
				speed_x = push_speed * sign(speed_x)
			move_x(dir)
			break

func box_release(sx : int, sy : int):
	is_pickup = false
	hitbox_y = 8
	position.y += 8
	var box = scene_box.instance()
	box.position = Vector2(position.x, position.y - 8)
	box.speed_x = sx
	box.speed_y = sy
	get_parent().add_child(box)
	node_sprite.position.y = -4

func box_pickup(dx : int, dy : int):
	var offset_y = 0 if btn.d("down") else -8
	
	# pick crate on x axis
	for a in check_area_actors(position.x + dx, position.y + dy, hitbox_x, hitbox_y, "box"):
		var offset_x = box_find_space(0, offset_y, a)
		if offset_x != null:
			is_pickup = true
			a.queue_free()
			position.y += offset_y
			position.x += offset_x
			hitbox_y = 16
			node_sprite.position.y = 4
		break

# ox, oy = offset x and y
func box_find_space(ox, oy, ignore : Actor):
	# wiggle around and look for an open space
	for i in [0, 1, -1, 2, -2, 3, -3, 4, -4]:
		if not is_area_solid(position.x + ox + i, position.y + oy, 8, 16, ignore):
			return i
	return null

func death():
	get_tree().reload_current_scene()

func try_anim(arg : String):
	if node_anim.current_animation != arg:
		node_anim.play(arg)


