tool
extends Actor

export var move_speed = 0.75
var move_slow = 0.75
var move_accel = 0.12
var move_last = 0
var push_speed = 0.3

export var jump_speed = 1.5
export var jump_frames = 15
var jump_count = 0
var is_jump = false
var coyote_time = 5

var is_pickup = false
var pickup_box : Actor

var pickup_offset := -5
var pickup_target := Vector2.ZERO
var pickup_lerp := 0.3

export var speed_throw := Vector2(1, -2.6)

var dir = 1

var node_sprite : Sprite
var node_anim : AnimationPlayer
var node_audio_jump : AudioStreamPlayer2D
var node_audio_pickup : AudioStreamPlayer2D
var node_audio_drop : AudioStreamPlayer2D
var node_audio_throw : AudioStreamPlayer2D

var scene_box = preload("res://src/actor/Box.tscn")
var scene_explosion = preload("res://src/fx/Explosion.tscn")
var scene_explosion2 = preload("res://src/fx/Explosion2.tscn")

var btnx = 0
var btny = 0
var btnx_last = 0
var btnx_array = []
var btnp_jump = false
var btnd_jump = false
var btnp_pick = false

export var is_attract_mode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint or Shared.is_level_select:
		set_process(false)
		return
	
	#btnx_array size
	for i in 8:
		btnx_array.append(0)
	
	# ref nodes
	node_sprite = $Sprite
	node_anim = $AnimationPlayer
	node_audio_jump = $AudioJump
	node_audio_pickup = $AudioPickup
	node_audio_drop = $AudioDrop
	node_audio_throw = $AudioThrow
	
	# assign camera target
	if Shared.node_camera_game:
		Shared.node_camera_game.node_target = self
		Shared.node_camera_game.pos_target_offset = Vector2(4, 4)

# holding pickup
func just_moved():
	if is_pickup:
		move_box()
	elif is_instance_valid(ignore_actor):
		if !is_overlapping(ignore_actor):
			ignore_actor.ignore_actor = null
			ignore_actor = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	
	# input
	if is_attract_mode:
		attract_mode()
	else:
		btnx = btn.d("right") - btn.d("left")
		btny = btn.d("down") - btn.d("up")
		btnp_jump = btn.p("jump")
		btnd_jump = btn.d("jump")
		btnp_pick = btn.p("action")
	
	btnx_array.push_front(btnx)
	btnx_array.pop_back()
	if btnx:
		btnx_last = btnx
	
	# hit exit
	for a in check_area_actors("exit"):
		dev.out(name + " hit exit")
		win()
		return
	
	# hit spike
	if speed.y > -1 and is_area_actor("spike"):
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
	if btnp_jump and time_since_floor <= coyote_time:
		is_jump = true
		jump_count = 0
		node_audio_jump.play()
		try_anim("jump")
	
	# jump height
	if is_jump:
		if has_hit_up:
			is_jump = false
		elif btnd_jump:
			speed.y = -jump_speed
			jump_count += 1
			if jump_count > jump_frames:
				is_jump = false
		else:
			is_jump = false
	
	# box pickup / throw
	if btnp_pick:
		if is_pickup:
			if btnx_array.has(-1) or btnx_array.has(1):
				box_release(speed_throw.x * btnx_last, speed_throw.y)
				node_audio_throw.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_throw.play()
			else:
				box_release(0, 0)
				node_audio_drop.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_drop.play()
		else:
			if btny:
				box_pickup(0, btny)
			else:
				box_pickup(dir * 4, 0)
	
	# push box
	if !is_pickup and is_on_floor and move_get_dist().x:
		var a = check_area_actors("box", position.x + dir)
		if a.size():
			a.sort_custom(self, "sort_y_ascent")
			var b = a.front()
			if is_instance_valid(b) and b != ignore_actor:
				b.push(dir)
				# slow movement when pushing
				speed.x = clamp(speed.x, -push_speed, push_speed)
				move_x(dir)

func box_release(sx := 0.0, sy := 0.0):
	is_pickup = false
	pickup_box.speed = Vector2(sx, sy)
	pickup_box.is_moving = true
	pickup_box.shake_dist = 2
	pickup_box.position = pickup_box.position.round()

func box_pickup(dx := 0, dy := 0):
	if !is_area_solid():
		var a = ignore_actor if is_instance_valid(ignore_actor) else check_area_first_actor("box", position.x + dx, position.y + dy)
		if !is_instance_valid(a):
			var b = check_area_actors("box", position.x - 2, position.y - 2, hitbox_x + 4, hitbox_y + 4)
			b.sort_custom(self, "sort_x")
			b.sort_custom(self, "sort_y_descent")
			a = b.front()
		if is_instance_valid(a):
			is_pickup = true
			a.ignore_actor = self
			ignore_actor = a
			a.is_moving = false
			pickup_box = a
			move_box()
			
			node_audio_pickup.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_pickup.play()

# custom array sorting for boxes
func sort_x(a, b):
	if abs(a.position.x - position.x) < abs(b.position.x - position.x):
		return true
	return false

func sort_y_ascent(a, b):
	if a.position.y - position.y > b.position.y - position.y:
		return true
	return false

func sort_y_descent(a, b):
	if a.position.y - position.y < b.position.y - position.y:
		return true
	return false

func move_box():
	for i in abs(pickup_offset) + 1:
		var p = position + Vector2(0, pickup_offset + i)
		if !is_area_solid(p.x, p.y):
			pickup_target = p
			break
	pickup_box.position = pickup_box.position.linear_interpolate(pickup_target, pickup_lerp)

func remove_player():
	# drop box
	if is_pickup:
		box_release()
	queue_free()

func death():
	# explosion
	var inst = scene_explosion.instance()
	inst.position = center()
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(8)
	
	# reset scene
	Shared.start_reset()
	remove_player()
	dev.out(name + " died")

func win():
	# explosion
	var inst = scene_explosion2.instance()
	inst.position = position + (Vector2(4, 8) if is_pickup else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(4)
	
	# win scene
	Shared.win()
	remove_player()

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

var a_step := -1 # attract step
var at := 0 # attract timer

func attract_mode():
	btnp_jump = false
	btnp_pick = false
	
	if at > 0:
		at -= 1
	else:
		a_step += 1
		match a_step:
			0:
				btnx = 1
				at = 49
			1:
				btnp_jump = true
				at = 30
			2:
				btnd_jump = false
				btnx = 0
				at = 10
			3:
				btnp_pick = true # pick
				at = 10
			4:
				btnx = -1
				at = 16
			5:
				btnx = 0
				at = 5
			6:
				btnp_pick = true # throw
				at = 40
			7:
				btnx = 1
				at = 12
			8:
				btnx = 0
				btnp_pick = true # pick
				at = 20
			9:
				btnx = -1
				at = 18
			10:
				btnx = 0
				at = 3
			11:
				btnp_pick = true # throw
				at = 30
			12:
				btnx = 1
				at = 25
			13:
				btnx = 0
				btnp_pick = true # pick
				at = 20
			14:
				btnx = -1
				at = 20
			15:
				btnp_jump = true
				at = 34
			16:
				btnd_jump = false
				btnx = 0
				at = 10
			17:
				btnp_pick = true # drop
				at = 10
			18:
				btnp_jump = true
				at = 10
			19:
				btnd_jump = false
				at = 20
			20:
				btnx = -1
				at = 5
			21:
				btnp_jump = true
				at = 35
			22:
				btnd_jump = false
				btnx = 0
				at = 10
			23:
				btnp_pick = true # pick
				at = 10
			24:
				btnx = 1
				at = 24
			25:
				btnx = 0
				at = 30
			26:
				btnx = -1
				at = 7
			27:
				btnp_pick = true # throw
				btnx = 0
				get_parent().set_box_stack()
				at = 50
			28:
				get_parent().set_button_box()
				at = 30
			29:
				remainder = Vector2.ZERO
				a_step = -1
	
	if btnp_jump:
		btnd_jump = true
