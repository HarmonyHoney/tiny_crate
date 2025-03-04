extends VisibilityNotifier2D

var node_list = [self]

func _ready():
	connect("screen_entered", self, "enter")
	connect("screen_exited", self, "enter")

func enter():
	for i in node_list:
		i.visible = is_on_screen()
