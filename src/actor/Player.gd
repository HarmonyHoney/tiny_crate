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
var scene_explosion_exit = preload("res://src/fx/ExplosionExit.tscn")
var scene_sword = preload("res://src/actor/Sword.tscn")

var sword

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
	
	#sword = $Sword
	call_deferred("holdupp")
	

func holdupp():
	sword = scene_sword.instance()
	get_parent().add_child(sword)
	sword.position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	
	# joystick axis
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	# open door
	if btn.p("up"):
		for a in check_area_actors("door"):
			a.open()
			open_door()
			return
	
	# hit exit, fixed when holding box
	for a in check_area_actors("exit", position.x, position.y + (8 if is_holding else 0), hitbox_x, 8):
		dev.out(name + " hit exit")
		win()
		return
	
	# fall out of stage
	if position.y > 100:
		death()
		return
	
	# hit spike
	if speed_y > -1:
		for a in check_area_actors("spike"):
			dev.out(name + " hit spike")
			death()
			return
	
	# anim
	if is_on_floor:
		if !is_on_floor_last:
			try_anim("land")
		if node_anim.current_animation != "land":
			if btnx == 0:
				try_anim("idle")
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
	if btn.p("pickup"):
		if is_holding:
			if btn.d("down"):
				release_pickup(speed_drop_x * dir, speed_drop_y)
				node_audio_drop.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_drop.play()
			else:
				release_pickup(speed_throw_x * dir, speed_throw_y)
				node_audio_throw.pitch_scale = 1 + rand_range(-0.1, 0.1)
				node_audio_throw.play()
		else:
			box_pickup(0, 1)
	
	if btn.p("attack"):
		sword.slash()

func box_pickup(dx := 0, dy := 0):
	for a in check_area_actors("", position.x + dx, position.y + dy):
		if a.is_pickup:
			pickup_actor(a)
			speed_x = 0
			node_audio_pickup.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_pickup.play()
			break

func death():
	# explosion
	var inst = scene_explosion.instance()
	inst.position = position + (Vector2(4, 8) if is_holding else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(8)
	
	# drop box
	if is_holding:
		release_pickup()
	
	# reset scene
	Shared.start_reset()
	queue_free()
	dev.out(name + " died")
	#Shared.stage.death()
	#Shared.death()

func win():
	# explosion
	var inst = scene_explosion_exit.instance()
	inst.position = position + (Vector2(4, 8) if is_holding else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(4)
	
	# drop box
	if is_holding:
		release_pickup()
	
	# win scene
	Shared.win()
	queue_free()

func open_door():
	# explosion
	var inst = scene_explosion_exit.instance()
	inst.position = position + (Vector2(4, 8) if is_holding else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(4)
	
	# drop box
	if is_holding:
		release_pickup()
	
	# reset scene
	# Shared.start_reset("hub")
	queue_free()
	dev.out("map complete")
	pass

# spawn box
func debug_box(arg = null):
	var box = scene_box.instance()
	box.position = arg if arg is Vector2 else Vector2(position.x, position.y - 8)
	get_parent().add_child(box)
	dev.out("(box) spawned at: " + str(box.position))

func try_anim(arg : String):
	if node_anim.current_animation != arg:
		node_anim.play(arg)
		# update the animationPlayer immediately
		node_anim.advance(0)

# when animation finishes
func _on_AnimationPlayer_animation_finished(anim_name):
	if !node_anim.get_animation(node_anim.assigned_animation).loop:
		match node_anim.assigned_animation:
			"land":
				try_anim("idle")
