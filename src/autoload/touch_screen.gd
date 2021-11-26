extends CanvasLayer

onready var node : Node2D = $Node2D
onready var pause : TouchScreenButton = $Node2D/Pause

export var vis := false setget set_vis, get_vis

func _ready():
	set_vis(OS.has_touchscreen_ui_hint() and OS.get_name() == "HTML5")

func set_vis(arg := false):
	node.visible = arg

func get_vis():
	return node.visible
