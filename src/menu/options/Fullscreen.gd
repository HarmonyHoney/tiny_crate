extends CanvasItem

onready var label := $Label2
var cursor = 0
var text = ["windowed", "win no border", "full no border", "fullscreen"]

func _ready():
	yield(get_tree(), "idle_frame")
	cursor = Shared.window_option
	label.text = text[cursor]

func act():
	scroll()

func scroll(arg := 1):
	cursor = wrapi(cursor + arg, 0, 4)
	label.text = text[cursor]
	Shared.window_option = cursor
	Audio.play("menu_pause", 0.7, 1.3)
