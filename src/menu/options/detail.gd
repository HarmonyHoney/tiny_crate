extends CanvasItem

onready var label := $Label2
var text = ["full", "dark", "none"]

func _ready():
	yield(get_tree(), "idle_frame")
	text()

func scroll(arg := 1):
	Shared.background_option += arg
	text()
	Audio.play("menu_pause", 0.9, 1.1)

func text():
	label.text = str(int(Shared.background_option) * 10) + "%"

func act():
	scroll(1)
