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
var pickup_frames = 8
var pickup_count = 0
var pickup_start := Vector2.ZERO
var pickup_box : Actor

export var speed_drop_x = 1.0
export var speed_drop_y = -1.0

export var speed_throw_x = 1.0
export var speed_throw_y = -2.3

var dir = 1

var node_sprite : Sprite
var node_anim : AnimationPlayer
var node_audio_jump : AudioStreamPlayer2D
var node_audio_pickup : AudioStreamPlayer2D
var node_audio_drop : AudioStreamPlayer2D
var node_audio_throw : AudioStreamPlayer2D

var node_camera_game : Camera2D

var scene_box = preload("res://src/actor/Box.tscn")
var scene_explosion = preload("res://src/fx/Explosion.tscn")
var scene_explosion2 = preload("res://src/fx/Explosion2.tscn")

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
	
	# joystick axis
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	# pickup box // returns from func while picking up
	if is_pickup:
		if pickup_count < pickup_frames:
			pickup_count += 1
			if pickup_count < pickup_frames:
				pickup_box.position = pickup_start.linear_interpolate(position, float(pickup_count + 1) / pickup_frames).round()
				return
			else:
				is_moving = true
				pickup_box.queue_free()
				if is_on_floor:
					try_anim("box_idle")
				else:
					try_anim("box_jump")
				return
	
	
	# open door
	if btn.p("up"):
		for a in check_area_actors("door"):
			a.open()
			open_door()
			return
	
	# hit exit, fixed when holding box
	for a in check_area_actors("exit", position.x, position.y + (8 if is_pickup else 0), hitbox_x, 8):
		dev.out(name + " hit exit")
		win()
		return
	
	# hit spike
	if speed_y > -1:
		for a in check_area_actors("spike"):
			dev.out(name + " hit spike")
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
		#Shared.stage.metric_jump += 1
	
	# jump height
	if is_jump:
		if has_hit_up:
			is_jump = false
		elif btn.d("jump"):
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
				node_audio_drop.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_drop.play()
			else:
				box_release(speed_throw_x * dir, speed_throw_y)
				node_audio_throw.pitch_scale = 1 + rand_range(-0.1, 0.1)
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

func box_release(sx := 0.0, sy := 0.0):
	is_pickup = false
	#hitbox_y = 8
	_set_hit_y(8)
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

func box_pickup(dx := 0, dy := 0):
	var offset_y = 0 if btn.d("down") else -8
	
	# pick crate on x axis
	for a in check_area_actors("box", position.x + dx, position.y + dy):
		var offset_x = box_find_space(0, offset_y, a)
		if offset_x != null:
			#a.queue_free()
			position.y += offset_y
			position.x += offset_x
			#hitbox_y = 16
			_set_hit_y(16)
			node_sprite.position.y = 4
			node_camera_game.pos_offset = Vector2(4, 12)
			
			node_audio_pickup.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_pickup.play()
			
			is_moving = false
			is_pickup = true
			pickup_count = 0
			pickup_box = a
			pickup_box.is_moving = false
			pickup_box.is_solid = false
			pickup_start = pickup_box.position
			
			#Shared.stage.metric_pickup += 1
		break

# ox, oy = offset x and y
func box_find_space(ox, oy, ignore : Actor):
	# wiggle around and look for an open space
	for i in [0, 1, -1, 2, -2, 3, -3, 4, -4]:
		if not is_area_solid(position.x + ox + i, position.y + oy, 8, 16, ignore):
			return i
	return null

func death():
	# explosion
	var inst = scene_explosion.instance()
	inst.position = position + (Vector2(4, 8) if is_pickup else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(8)
	
	# drop box
	if is_pickup:
		box_release()
	
	# reset scene
	Shared.start_reset()
	queue_free()
	dev.out(name + " died")
	#Shared.stage.death()
	#Shared.death()

func win():
	# explosion
	var inst = scene_explosion2.instance()
	inst.position = position + (Vector2(4, 8) if is_pickup else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(4)
	
	# drop box
	if is_pickup:
		box_release()
	
	# win scene
	Shared.win()
	queue_free()

func open_door():
	# explosion
	var inst = scene_explosion2.instance()
	inst.position = position + (Vector2(4, 8) if is_pickup else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(4)
	
	# drop box
	if is_pickup:
		box_release()
	
	# reset scene
	# Shared.start_reset("hub")
	queue_free()
	dev.out("map complete")
	pass

func try_anim(arg : String):
	if node_anim.current_animation != arg:
		node_anim.play(arg)
		# update the animationPlayer immediately
		node_anim.advance(0)

# spawn box
func debug_box(arg = null):
	var box = scene_box.instance()
	box.position = arg if arg is Vector2 else Vector2(position.x, position.y - 8)
	get_parent().add_child(box)
	dev.out("(box) spawned at: " + str(box.position))