extends CanvasLayer

var node_timer : Label
var node_death : Label
var control : Control
var wipe : Node2D

var buttons : Node2D

func _ready():
	node_timer = $Control/Timer/Label
	node_death = $Control/Death
	control = $Control
	wipe = $Wipe
	#buttons = $Buttons

func _process(delta):
	pass

func _input(event):
	if dev.is_open:
		return

func hide():
	control.visible = false

func show():
	control.visible = true



func set_time(arg):
	var _min = str(int(arg / 60))
	if _min.length() == 1:
		_min = "0" + _min
	
	var _sec = str(int(arg) % 60)
	if _sec.length() == 1:
		_sec = "0" + _sec
	
	#var _msec = str(fmod(arg, 1))
	#_msec = _msec.substr(1, 2)
	
	node_timer.text = _min + ":" + _sec


