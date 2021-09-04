tool
extends ColorRect

export var cam_pos := Vector2.ZERO setget _set_cam_pos
export var draw_color := Color(1, 1, 1, 0.5)
var cam_size := Vector2(228, 128)

func _set_cam_pos(arg):
	cam_pos = arg
	update()


func _draw():
	draw_circle(cam_pos, 3, draw_color)
	#draw_rect(Rect2(cam_pos - cam_size / 2, cam_size), draw_color)
