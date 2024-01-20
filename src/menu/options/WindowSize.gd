extends CanvasItem

onready var label_scale := $Scale
onready var label_res := $Resolution

func _ready():
	set_text()

func scroll(arg = 1):
	Shared.set_window_scale(clamp(Shared.window_scale + arg, 1, 12))
	set_text()
	Audio.play("menu_scroll2", 0.7, 1.4)

func set_text():
	label_scale.text = str(Shared.window_scale) + "x"
	label_res.text = str(Shared.view_size.x * Shared.window_scale) + " x " + str(Shared.view_size.y * Shared.window_scale)
