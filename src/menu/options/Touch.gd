extends CanvasItem

onready var fill = $Box/Fill
var is_selected = false

func _ready():
	yield(get_tree(), "idle_frame")
	fill.visible = TouchScreen.visible

func act():
	var is_touch = !TouchScreen.visible
	TouchScreen.visible = is_touch
	fill.visible = is_touch
	Audio.play("menu_pause", 0.9, 1.1)
