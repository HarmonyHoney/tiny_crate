tool
extends CanvasItem


export var radius := 16.0 setget set_radius
export var offset := Vector2.ZERO
export var is_solid := false
export var points := 16
export var width := 1.0

func _draw():
	if is_solid:
		draw_circle(offset, radius, Color.white)
	else:
		draw_arc(offset, radius, 0, TAU, points, Color.white, width, false)

func set_radius(arg := radius):
	radius = arg
	update()
