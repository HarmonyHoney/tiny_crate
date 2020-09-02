tool
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

var is_pickup = false

export var speed_drop_x = 1.0
export var speed_drop_y = -1.0

export var speed_throw_x = 1.0
export var speed_throw_y = -2.3

var pickup_frames = 8
var pickup_count = 0

var dir = 1

var node_sprite : Sprite
var node_anim : AnimationPlayer
var node_audio_jump : AudioStreamPlayer2D
var node_audio_pickup : AudioStreamPlayer2D
var node_audio_drop : AudioStreamPlayer2D
var node_audio_throw : AudioStreamPlayer2D

var node_camera_game : Camera2D

var scene_box = preload("res://Scene/Box.tscn")
var scene_explosion = preload("res://Scene/Explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	
	# ref nodes
	node_sprite = get_node("Sprite")
	node_anim = get_node("AnimationPlayer")
	node_audio_jump = get_node("AudioJump")
	node_audio_pickup = get_node("AudioPickup")
	node_audio_drop = get_node("AudioDrop")
	node_audio_throw = get_node("AudioThrow")
	
	# assign camera target
	if Shared.node_camera_game:
		node_camera_game = Shared.node_camera_game
		node_camera_game.node_target = self
		node_camera_game.pos_offset = Vector2(4, 4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	
	# debug
	if btn.p("ui_cancel"):
		get_tree().quit()
	
	if btn.p("reset"):
		get_tree().reload_current_scene()
	# spawn box
	if btn.p("debug_spawn_box"):
		var box = scene_box.instance()
		box.position = Vector2(position.x, position.y - 8)
		get_parent().add_child(box)
	
	
	# joystick axis
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	# open door
	if btn.p("up"):
		for a in check_area_actors("door"):
			a.open()
			return
	
	# hit exit
	for a in check_area_actors("exit"):
		print("hit exit")
		death()
		return
	
	# hit spike
	if speed_y > -1:
		for a in check_area_actors("spike"):
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
		node_audio_jump.play()
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
	
	# box pickup / throw
	if btn.p("action"):
		if is_pickup:
			if btn.d("down"):
				box_release(speed_drop_x * dir, speed_drop_y)
				node_audio_drop.play()
			else:
				box_release(speed_throw_x * dir, speed_throw_y)
				node_audio_throw.play()
		else:
			if btn.d("down"):
				box_pickup(0, 1)
			else:
				box_pickup(dir * 4, 0)
			
	
	# push box
	if is_on_floor and move_get_dist().x != 0 and not is_pickup:
		for a in check_area_actors("box", position.x + dir):
			a.push(dir)
			# slow movement when pushing
			if abs(speed_x) > push_speed:
				speed_x = push_speed * sign(speed_x)
			move_x(dir)
			break

func box_release(sx : float, sy : float):
	is_pickup = false
	hitbox_y = 8
	position.y += 8
	var box = scene_box.instance()
	box.position = Vector2(position.x, position.y - 8)
	box.speed_x = sx
	box.speed_y = sy
	get_parent().add_child(box)
	node_sprite.position.y = -4
	node_camera_game.pos_offset = Vector2(4, 4)
	if is_on_floor:
		try_anim("idle")
	else:
		try_anim("jump")
#	if sx != 0 or sy != 0:
#		node_audio_throw.play()
#	else:
#		node_audio_drop.play()

func box_pickup(dx : int, dy : int):
	var offset_y = 0 if btn.d("down") else -8
	
	# pick crate on x axis
	for a in check_area_actors("box", position.x + dx, position.y + dy):
		var offset_x = box_find_space(0, offset_y, a)
		if offset_x != null:
			is_pickup = true
			a.queue_free()
			position.y += offset_y
			position.x += offset_x
			hitbox_y = 16
			node_sprite.position.y = 4
			node_camera_game.pos_offset = Vector2(4, 12)
			node_audio_pickup.play()
			if is_on_floor:
				try_anim("box_idle")
			else:
				try_anim("box_jump")
		break

# ox, oy = offset x and y
func box_find_space(ox, oy, ignore : Actor):
	# wiggle around and look for an open space
	for i in [0, 1, -1, 2, -2, 3, -3, 4, -4]:
		if not is_area_solid(position.x + ox + i, position.y + oy, 8, 16, ignore):
			return i
	return null

func death():
	var inst = scene_explosion.instance()
	inst.position = position + Vector2(0, 4)
	get_parent().add_child(inst)
	Shared.start_reset()
	queue_free()

func try_anim(arg : String):
	if node_anim.current_animation != arg:
		node_anim.play(arg)


