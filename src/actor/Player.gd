tool
extends Actor

var move_speed = 1
var move_slow = 0.75
var move_accel = 0.12
var move_last = 0
var push_speed = 0.3

var jump_speed = 2
var jump_frames = 10
var jump_count = 0
var is_jump = false
var coyote_time = 5

var is_pickup = false
var pickup_frames = 8
var pickup_count = 0
var pickup_start := Vector2.ZERO
var pickup_box : Actor
var pickup_offset := Vector2(0, -8)

export var speed_drop := Vector2(1, -1)

export var speed_throw := Vector2(1, -2.3)

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
	node_sprite = $Sprite
	node_anim = $AnimationPlayer
	node_audio_jump = $AudioJump
	node_audio_pickup = $AudioPickup
	node_audio_drop = $AudioDrop
	node_audio_throw = $AudioThrow
	
	# assign camera target
	if Shared.node_camera_game:
		node_camera_game = Shared.node_camera_game
		node_camera_game.node_target = self
		node_camera_game.pos_offset = Vector2(4, 4)

func just_moved():
	# move box
	if is_pickup:
		var diff = position + pickup_offset - pickup_box.position
		if diff != Vector2.ZERO:
			pickup_box.move(diff)
			if pickup_box.has_hit_down:
				box_release()
			elif (pickup_box.has_hit_left or pickup_box.has_hit_right) and abs(pickup_box.center().x - center().x) > 4:
				box_release()
	# ignore actor until not overlapping
	elif is_instance_valid(ignore_actor):
		if !is_overlapping(ignore_actor):
			ignore_actor.ignore_actor = null
			ignore_actor = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	
	# joystick axis
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	# pickup box // returns from func while picking up
	if is_pickup:
		pass
	
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
	
	# fall out of stage
	if position.y > 100:
		death()
		return
	
	# hit spike
	if speed.y > -1:
		for a in check_area_actors("spike"):
			dev.out(name + " hit spike")
			death()
			return
	
	# anim
	if is_on_floor:
		if btnx == 0:
			try_anim("idle")
		else:
			try_anim("run")
	
	# walking
	if btnx == 0:
		speed.x *= move_slow
	else:
		speed.x += move_accel * btnx
		speed.x = clamp(speed.x, -move_speed, move_speed)
		dir = btnx
		node_sprite.flip_h = btnx == -1
	
	# start jump
	if btn.p("jump") and time_since_floor <= coyote_time:
		is_jump = true
		jump_count = 0
		node_audio_jump.play()
		node_anim.play("jump")
		#Shared.stage.metric_jump += 1
	
	# jump height
	if is_jump:
		if has_hit_up:
			is_jump = false
		elif btn.d("jump"):
			speed.y = -jump_speed
			jump_count += 1
			if jump_count > jump_frames:
				is_jump = false
		else:
			is_jump = false
	
	# box pickup / throw
	if btn.p("action"):
		if is_pickup:
			if btn.d("down"):
				box_release(speed_drop.x * dir, speed_drop.y)
				node_audio_drop.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_drop.play()
			else:
				box_release(speed_throw.x * dir, speed_throw.y)
				node_audio_throw.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_throw.play()
		else:
			if btn.d("up"):
				box_pickup(0, -1)
			elif btn.d("down"):
				box_pickup(0, 1)
			else:
				box_pickup(dir * 4, 0)
			
	
	# push box
	if is_on_floor and move_get_dist().x != 0 and not is_pickup:
		for a in check_area_actors("box", position.x + dir):
			a.push(dir)
			# slow movement when pushing
			if abs(speed.x) > push_speed:
				speed.x = push_speed * sign(speed.x)
			move_x(dir)
			break

func box_release(sx := 0.0, sy := 0.0):
	is_pickup = false
	pickup_box.speed = Vector2(sx, sy)
	pickup_box.is_moving = true

func box_pickup(dx := 0, dy := 0):
	for a in check_area_actors("box", position.x + dx, position.y + dy):
		var offset_x = box_find_space(0, -8, a)
		if offset_x != null:
			position.x += offset_x
			
			node_audio_pickup.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_pickup.play()
			
			is_pickup = true
			pickup_box = a
			pickup_box.is_moving = false
			pickup_box.position = position + pickup_offset
			ignore_actor = pickup_box
			pickup_box.ignore_actor = self
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
