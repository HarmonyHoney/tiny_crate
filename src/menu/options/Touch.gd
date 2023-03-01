extends Node2D

@onready var fill = $Box/Fill

var is_selected = false

func _ready():
	fill.visible = TouchScreen.visible

func act():
	var is_touch = !TouchScreen.visible
	TouchScreen.visible = is_touch
	fill.visible = is_touch
