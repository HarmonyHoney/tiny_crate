extends CanvasLayer

var node_timer : Label
var node_death : Label


func _ready():
	node_timer = $Timer/Label
	node_death = $Death


func _process(delta):
	pass

func _input(event):
	if dev.is_open:
		return


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
