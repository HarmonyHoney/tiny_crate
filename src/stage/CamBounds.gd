tool
extends Node2D

export var bounds := Rect2(0, 0, 0, 0) setget _set_bounds

var cam
var rect : Rect2
var screen = Vector2(228, 128)

func _ready():
	rect = Rect2(-screen/2, screen)
	
	if (!Shared.is_level_select or get_parent().name == "Select") and is_instance_valid(Shared.cam):
		cam = Shared.cam
		cam.bounds_upper = position - bounds.position
		cam.bounds_lower = bounds.size + position
		
		cam.set_pos(global_position)
		cam.zoom = scale
		
		print("CamBounds upper: ", cam.bounds_upper, " lower: ", cam.bounds_lower)

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
