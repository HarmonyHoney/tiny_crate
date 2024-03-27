tool
extends TouchScreenButton

export var radius := 60.0 setget set_radius
export var points := 5 setget set_points
export var angle := 0.0 setget set_angle
export var deadzone := 3.0 setget set_deadzone

func set_radius(arg := radius):
	radius = arg
	act()

func set_points(arg := points):
	points = arg
	act()

func set_angle(arg := angle):
	angle = arg
	act()

func set_deadzone(arg := deadzone):
	deadzone = arg
	act()

func act():
	var r = Vector2(radius, 0)
	var vec = PoolVector2Array()
	
	for i in [1, 0, -1]:
		vec.append(Vector2(deadzone, 0).rotated(deg2rad(angle + (i * 45))))
	
	for i in points:
		var f = i / float(points - 1)
		vec.append(r.rotated(deg2rad(angle + lerp(-45, 45, f))))
	
	shape = ConvexPolygonShape2D.new()
	shape.points = vec
	
