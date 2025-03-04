extends CanvasItem

onready var label := $Label2
var text = ["toggle", "always"]

func _ready():
	yield(get_tree(), "idle_frame")
	label.text = text[int(TouchScreen.is_stay)]

func scroll(arg := 1):
	act()

func act():
	TouchScreen.is_stay = !TouchScreen.is_stay
	label.text = text[int(TouchScreen.is_stay)]
	Audio.play("menu_pause", 0.9, 1.1)
