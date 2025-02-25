tool
extends Node2D

export var bounds := Rect2(0, 0, 0, 0) setget _set_bounds

var bounds_upper := Vector2.ZERO
var bounds_lower := Vector2.ZERO

var rect : Rect2
var screen = Vector2(228, 128)

func _ready():
	rect = Rect2(-screen/2, screen)
	# set limits
	bounds_upper.x = -bounds.position.x + position.x
	bounds_upper.y = -bounds.position.y + position.y
	bounds_lower.x = bounds.size.x + position.x
	bounds_lower.y = bounds.size.y + position.y
	print("CamBounds upper: ", bounds_upper, " lower: ", bounds_lower)

func _set_bounds(arg):
	bounds.position.x = abs(arg.position.x)
	bounds.position.y = abs(arg.position.y)
	bounds.size.x = abs(arg.size.x)
	bounds.size.y = abs(arg.size.y)
	update()

func _draw():
	if Engine.editor_hint:
		draw_rect(Rect2(-bounds.position.x - (screen.x/2), -bounds.position.y - (screen.y/2), screen.x + bounds.size.x + bounds.position.x, screen.y + bounds.size.y + bounds.position.y), Color.red, false)
		draw_rect(rect, Color.yellow, false)
