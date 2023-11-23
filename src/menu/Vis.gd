extends VisibilityNotifier2D

func _ready():
	connect("screen_entered", self, "enter")
	connect("screen_exited", self, "enter")
	pass # Replace with function body.

func enter():
	visible = is_on_screen()
