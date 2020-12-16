tool
extends Node2D
class_name Actor

export var tag := "actor"

# hitbox
export var hitbox_x := 8 setget _set_hit_x
export var hitbox_y := 8 setget _set_hit_y

# speed
var speed_x := 0.0
var speed_y := 0.0
export var gravity := 0.2
var term_vel := 16

# remainder
var remainder_x := 0.0
var remainder_y := 0.0

# movement and collision
export var is_moving := false
export var is_solid := false
export var is_colliding := false
export var is_using_gravity := false

# has moved
var has_moved_x := false
var has_moved_y := false

# has hit
var has_hit_up := false
var has_hit_down := false
var has_hit_left := false
var has_hit_right := false

# air time
var is_on_floor := false
var time_since_floor := 0

# treadmill
export var is_using_tread := false
var is_on_tread := false

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = floor(position.x)
	position.y = floor(position.y)

func _process(delta):
	if Engine.editor_hint:
		return
	
	if is_moving:
		if is_using_tread:
			tread_move()
		
		move()
		
		if is_using_gravity:
			speed_y = min(speed_y + gravity, term_vel)
		if not is_on_floor:
			time_since_floor += 1
		
		# if outside map
		if position.y < -999 or position.y > 999:
			dev.out(name + " fell out of world")
			queue_free()

# update() the _draw() when hitbox values are changed (in the editor)
func _set_hit_x(value):
	hitbox_x = value
	update()

func _set_hit_y(value):
	hitbox_y = value
	update()

# draw hitbox in editor
func _draw():
	if Engine.editor_hint or dev.is_draw_collider:
		draw_rect(Rect2(0, 0, hitbox_x, hitbox_y), Color(1, 0, 0.75, 0.5))

# axis aligned bounding box
func aabb(x1 : int, y1 : int, w1 : int, h1 : int, x2 : int, y2 : int, w2 : int, h2 : int):
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1

# move actor
func move():
	# clear bools
	has_moved_x = false
	has_moved_y = false
	has_hit_up = false
	has_hit_down = false
	has_hit_left = false
	has_hit_right = false
	
	remainder_y += speed_y
	var dy = floor(remainder_y + 0.5) # distance y
	remainder_y -= dy
	if dy != 0:
		move_y(dy)
	
	remainder_x += speed_x
	var dx = floor(remainder_x + 0.5) # distance x
	remainder_x -= dx
	if dx != 0:
		move_x(dx)

# return distance of upcoming move
func move_get_dist():
	return Vector2(floor(remainder_x + speed_x + 0.5), floor(remainder_y + speed_y + 0.5))

# move x axis
func move_x(dist : int):
	has_moved_x = true
	
	if is_colliding:
		var step = sign(dist)
		for i in range(abs(dist)):
			if is_area_solid(position.x + step, position.y):
				if move_get_dist().y > -1 and wiggle_x(step):
					position.y += wiggle_x(step)
					position.x += dist
					continue
				speed_x = 0
				remainder_x = 0
				
				has_hit_left = (step == -1)
				has_hit_right = (step == 1)
				return true
			else:
				position.x += step
	else:
		position.x += dist
	return false

# move y axis
func move_y(dist : int):
	has_moved_y = true
	is_on_floor = false
	
	if is_colliding:
		var step = sign(dist)
		for i in range(abs(dist)):
			if is_area_solid(position.x, position.y + step):
				if step == -1 and wiggle_y(step):
					position.x += wiggle_y(step)
					position.y += step
					continue
				speed_y = 0
				remainder_y = 0
				
				has_hit_up = (step == -1)
				has_hit_down = (step == 1)
				is_on_floor = has_hit_down
				if is_on_floor:
					time_since_floor = 0
				return true
			else:
				position.y += step
	else:
		position.y += dist
	return false

func wiggle_x(step):
	# wiggle around and look for an open space
	for i in [1, -1, 2, -2]:
		if not is_area_solid(position.x + step, position.y + i):
			return i
	return null

# jump corner correction
func wiggle_y(step):
	# wiggle around and look for an open space
	for i in [1, -1, 2, -2, 3, -3]:
		if not is_area_solid(position.x + i, position.y + step):
			return i
	return null

# move on treadmill
func tread_move():
	is_on_tread = false
	for a in check_area_actors("treadmill", position.x, position.y + 1):
		is_on_tread = true
		remainder_x += a.tread_speed
		break

# check area for solid tiles
func is_area_solid_tile(x1, y1, width, height):
	var w2m = Shared.node_map_solid.world_to_map(Vector2(x1, y1))
	var cell = Shared.node_map_solid.cell_size.x
	
	# check more than four points if hitbox is longer than 8 pixels
	for ix in range((width / cell) + 1):
		for iy in range((height / cell) + 1):
			var check = Vector2(w2m.x + ix, w2m.y + iy)
			if Shared.node_map_solid.get_cellv(check) != -1:
				check *= cell
				if aabb(x1, y1, width, height, check.x, check.y, cell, cell):
					return true
	return false

# check area for solid actors
func is_area_solid_actor(x, y, width = hitbox_x, height = hitbox_y, ignore = null) -> bool:
	for a in get_tree().get_nodes_in_group("actor"):
		if a != self and a.is_solid and a != ignore:
			if aabb(x, y, width, height, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y):
				return true
	return false

# check if area is solid
func is_area_solid(x, y, width = hitbox_x, height = hitbox_y, ignore = null) -> bool:
	if is_area_solid_tile(x, y, width, height):
		return true
	return is_area_solid_actor(x, y, width, height, ignore)

# return array of actors
func check_area_actors(group_name = "actor", x = position.x, y = position.y, width = hitbox_x, height = hitbox_y, ignore = null):
	if not group_name:
		group_name = "actor"
	var act = []
	for a in get_tree().get_nodes_in_group(group_name):
		if a != self and a != ignore:
			if aabb(x, y, width, height, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y):
				act.append(a)
	return act
