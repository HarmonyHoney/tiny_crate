extends CanvasItem

onready var label_scale := $Scale
onready var label_res := $Resolution

var cursor = 0

func _ready():
	get_tree().connect("screen_resized", self, "size_changed")
	yield(get_tree(),"idle_frame")
	
	size_changed()

func scroll(arg = 1):
	cursor = clamp(cursor + arg, 1, 32)
	OS.window_size = Shared.view_size * cursor
	Shared.set_window_option()
	Audio.play("menu_scroll2", 0.7, 1.4)

func size_changed():
	var view_size = OS.window_size
	label_res.text = str(view_size.x) + " x " + str(view_size.y)
	
	cursor = floor(view_size.y / Shared.view_size. y)
	label_scale.text = str(cursor) + "x" if OS.window_size == Shared.view_size * cursor else ""
