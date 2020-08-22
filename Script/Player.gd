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

var is_holding_crate = false

var speed_drop_x = 1
var speed_drop_y = -1

var speed_throw_x = 1.0
var speed_throw_y = -2.3

var pickup_frames = 8
var pickup_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if btn.p("reset"):
		Shared.reload()
	
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	
	# walking
	if btnx == 0:
		speed_x *= move_slow
	else:
		speed_x += move_accel * btnx
		#speed_x = mid(-move_speed, speed_x, move_speed)
		speed_x = clamp(speed_x, -move_speed, move_speed)
		#flip_x = btn(0)
	
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



func check_jump():
	return is_on_floor or is_on_floor_2 or is_on_floor_3

