extends Node2D

onready var p : Player = $Player
var box := []

var a_step := -1 # attract step
var at := 0 # attract timer
var loop := 1

func _ready():
	box.append($Box0)
	box.append($Box1)
	box.append($Box2)
	box.append($Box3)

func _physics_process(delta):
	p.btnp_jump = false
	p.btnp_pick = false
	if !p.is_jump:
		p.btnd_jump = false
	
	if at > 0:
		at -= 1
	else:
		a_step += 1
		match loop:
			0:
				loop0()
			1:
				loop1()
			2:
				pass
	
	if p.btnp_jump:
		p.btnd_jump = true

func set_button_box():
	box[3].position = Vector2(64, -16)
	box[3].speed = Vector2.ZERO
	box[3].remainder = Vector2.ZERO
	box[3].pick_frame()

func set_box_stack():
	box[0].position = Vector2(160, -16)
	box[1].position = Vector2(164, -32)
	box[2].position = Vector2(160, -48)
	
	for i in 3: # 0, 1, 2
		box[i].speed = Vector2.ZERO
		box[i].remainder = Vector2.ZERO
		box[i].pick_frame()

func btnx(arg : int):
	p.btnx = arg

func jump():
	p.btnp_jump = true

func jump_stop():
	p.btnd_jump = false

func pick():
	p.btnp_pick = true

func set_loop(arg):
	a_step = -1
	loop = arg

func loop0():
	match a_step:
		0:
			btnx(1)
			at = 49
		1:
			jump()
			at = 30
		2:
			btnx(0)
			at = 10
		3:
			pick()
			at = 10
		4:
			btnx(-1)
			at = 16
		5:
			btnx(0)
			at = 5
		6:
			pick()
			at = 40
		7:
			btnx(1)
			at = 12
		8:
			btnx(0)
			pick()
			at = 20
		9:
			btnx(-1)
			at = 18
		10:
			btnx(0)
			at = 3
		11:
			pick()
			at = 30
		12:
			btnx(1)
			at = 25
		13:
			btnx(0)
			pick()
			at = 20
		14:
			btnx(-1)
			at = 20
		15:
			jump()
			at = 34
		16:
			btnx(0)
			at = 10
		17:
			pick()
			at = 10
		18:
			jump()
			at = 10
		19:
			jump_stop()
			at = 20
		20:
			btnx(-1)
			at = 5
		21:
			jump()
			at = 35
		22:
			btnx(0)
			at = 10
		23:
			pick()
			at = 10
		24:
			btnx(1)
			at = 24
		25:
			btnx(0)
			at = 30
		26:
			btnx(-1)
			at = 7
		27:
			pick()
			btnx(0)
			set_box_stack()
			at = 50
		28:
			set_button_box()
			p.remainder = Vector2.ZERO
			set_loop(1)
			at = 30

func loop1():
	match a_step:
		1:
			btnx(1)
			at = 50
		2:
			jump()
			at = 44
		3:
			btnx(0)
			at = 18
		4:
			btnx(-1)
			at = 150
		5:
			btnx(0)
			at = 6
		6:
			btnx(1)
			at = 15
		7:
			btnx(-1)
			jump()
			at = 32
		8:
			btnx(0)
			at = 6
		9:
			btnx(-1)
			jump()
			at = 116
		10:
			btnx(0)
			set_box_stack()
			at = 30
		11:
			btnx(1)
			at = 44
		12:
			btnx(0)
			set_button_box()
			at = 30
		13:
			p.remainder = Vector2.ZERO
			set_loop(0)
			at = 30

