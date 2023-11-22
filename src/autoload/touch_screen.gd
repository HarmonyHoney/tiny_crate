extends CanvasLayer

onready var pause : TouchScreenButton = $Control/HBoxTop/Pause/Control/Button

func _ready():
	connect("visibility_changed", self, "vis")
	
	visible = (OS.has_touchscreen_ui_hint() and OS.get_name() == "HTML5") or OS.get_name() == "Android"
	vis()

func vis():
	UI.visible = !visible
