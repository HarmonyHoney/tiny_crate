@tool
extends Actor
class_name Player

@export var move_speed = 0.75
var move_slow = 0.75
var move_accel = 0.12
var move_last = 0
var push_speed = 0.3

@export var jump_speed = 1.5
@export var jump_frames = 15
var jump_count = 0
var is_jump = false
var coyote_time = 5

var is_pickup = false
var pickup_box : Actor

var pickup_offset := -5
var pickup_target := Vector2.ZERO
var pickup_lerp := 0.3

@export var speed_throw := Vector2(1, -2.6)

var dir = 1

@onready var node_sprite : Sprite2D = $Sprite2D
@onready var node_anim : AnimationPlayer = $AnimationPlayer
@onready var node_audio_jump : AudioStreamPlayer2D = $AudioJump
@onready var node_audio_pickup : AudioStreamPlayer2D = $AudioPickup
@onready var node_audio_drop : AudioStreamPlayer2D = $AudioDrop
@onready var node_audio_throw : AudioStreamPlayer2D = $AudioThrow
@onready var node_audio_push : AudioStreamPlayer2D = $AudioPush

var is_push = false
var push_clock = 0.0
var push_fade = 0.0

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

@export var is_attract_mode = false

func _enter_tree():
	if Engine.is_editor_hint(): return
	
	Shared.player = self

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint() or Shared.is_level_select:
		set_physics_process(false)
		return
	
	#btnx_array size
	for i in 8:
		btnx_array.append(0)
	
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
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	# input
	if !is_attract_mode:
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
		print(name + " hit exit")
		win()
		return
	
	# hit spike
	if speed.y > -1 and is_area_actor("spike"):
		print(name + " hit spike")
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
				node_audio_throw.pitch_scale = 1 + randf_range(-0.1, 0.1)
				node_audio_throw.play()
			else:
				box_release(0, 0)
				node_audio_drop.pitch_scale = 1 + randf_range(-0.1, 0.1)
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
			a.sort_custom(Callable(self,"sort_y_ascent"))
			var b = a.front()
			if is_instance_valid(b) and b != ignore_actor:
				b.push(dir)
				# slow movement when pushing
				speed.x = clamp(speed.x, -push_speed, push_speed)
				move_x(dir)
				push_clock = 0.1
				push_fade = 0.2
				node_audio_push.volume_db = 0
				if !node_audio_push.playing:
					node_audio_push.play()
	
	# push audio
	push_clock = max(0, push_clock - delta)
	if push_clock == 0 and node_audio_push.playing:
		push_fade = max(0, push_fade - delta)
		node_audio_push.volume_db = linear_to_db(push_fade / 0.2)
		if push_fade == 0:
			node_audio_push.stop()

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
			if b.size() > 0:
				b.sort_custom(Callable(self,"sort_x"))
				b.sort_custom(Callable(self,"sort_y_descent"))
				a = b.front()
		if is_instance_valid(a):
			is_pickup = true
			a.ignore_actor = self
			ignore_actor = a
			a.is_moving = false
			pickup_box = a
			move_box()
			
			node_audio_pickup.pitch_scale = 1 + randf_range(-0.2, 0.2)
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
	pickup_box.position = pickup_box.position.lerp(pickup_target, pickup_lerp)

func remove_player():
	# drop box
	if is_pickup:
		box_release()
	queue_free()

func death():
	print(name + " died")
	
	# explosion
	var inst = scene_explosion.instantiate()
	inst.position = center()
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(8)
	
	# reset scene
	remove_player()
	Shared.start_reset()

func win():
	# explosion
	var inst = scene_explosion2.instantiate()
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
	var box = scene_box.instantiate()
	box.position = arg if arg is Vector2 else Vector2(position.x, position.y - 8)
	get_parent().add_child(box)
	print("(box) spawned at: " + str(box.position))
