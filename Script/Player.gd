extends Actor


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if btn.p("reset"):
		Shared.reload()
	
	var btnx = btn.d("right") - btn.d("left")
	var btny = btn.d("down") - btn.d("up")
	
	speed_x = btnx * 0.5
	#speed_y = btny * 3
	
	if btn.p("jump") and is_on_floor:
		speed_y = -3
	
	


