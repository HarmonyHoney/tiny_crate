extends Node2D
class_name Actor


export var tag = "actor"
var px : int = 0
var py : int = 0

export var hitbox_x : int = 8
export var hitbox_y : int = 8

var speed_x = 0
var speed_y = 0
export var gravity = 0.2

var remainder_x = 0
var remainder_y = 0

export var is_moving = true
export var is_solid = true
export var is_colliding = true
export var is_using_gravity = true
export var is_on_treadmill = false

var has_moved_x = false
var has_moved_y = false

var has_hit_up = false
var has_hit_down = false
var has_hit_left = false
var has_hit_right = false

var is_on_floor = false
var is_on_floor_2 = false
var is_on_floor_3 = false



# Called when the node enters the scene tree for the first time.
func _ready():
	px = floor(position.x)
	py = floor(position.y)
	position.x = px
	position.y = py
	apply_pos()

func _process(delta):
	move()
	
	if is_using_gravity:
		speed_y += gravity
	

# update the node's position
func apply_pos():
	position.x = px
	position.y = py

# axis aligned bounding box
func aabb(x1 : int, y1 : int, w1 : int, h1 : int, x2 : int, y2 : int, w2 : int, h2 : int):
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1

# check solid tilemap (on x axis)
func check_solid_tile_x(dist : int):
	# left / dist == -1
	var x = px - 1
	# right
	if dist == 1:
		x = px + hitbox_x
	
	var y1 = py
	var y2 = py + hitbox_y - 1
	var w2m1 = Shared.node_map.world_to_map(Vector2(x, y1))
	var w2m2 = Shared.node_map.world_to_map(Vector2(x, y2))
	
	var check_up = Shared.node_map.get_cellv(w2m1) != -1
	var check_down = Shared.node_map.get_cellv(w2m2) != -1
	
	return check_up or check_down

# check solid tilemap (on y axis)
func check_solid_tile_y(dist : int):
	# up / dist == -1
	var y = py - 1
	# down
	if dist == 1:
		y = py + hitbox_y
	
	var x1 = px
	var x2 = px + hitbox_x - 1
	var w2m1 = Shared.node_map.world_to_map(Vector2(x1, y))
	var w2m2 = Shared.node_map.world_to_map(Vector2(x2, y))
	
	var check_left = Shared.node_map.get_cellv(w2m1) != -1
	var check_right = Shared.node_map.get_cellv(w2m2) != -1
	
	return check_left or check_right

# check tilemap, and then check actors (on x axis)
func check_solid_x(dist : int):
	var hit = check_solid_tile_x(dist)
	if not hit:
		hit = check_solid_actor(dist, 0, null)
	return hit

# check tilemap, and then check actors (on y axis)
func check_solid_y(dist : int):
	var hit = check_solid_tile_y(dist)
	if not hit:
		hit = check_solid_actor(0, dist, null)
	return hit

# check for solid actors, dx, dy = distance x and y
func check_solid_actor(dx : int, dy : int, ignore : Actor):
	var hit = false
	for a in get_tree().get_nodes_in_group("actor"):
		if a != self and a.is_solid and a != ignore:
			if aabb(px + dx, py + dy, hitbox_x, hitbox_y, a.px, a.py, a.hitbox_x, a.hitbox_y):
				hit = true
				break
	return hit

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
	var hit = false
	has_moved_x = true
	
	if is_colliding:
		var step = sign(dist)
		
		for i in range(abs(dist)):
			if check_solid_x(step):
				speed_x = 0
				remainder_x = 0
				
				has_hit_left = (step == -1)
				has_hit_right = (step == 1)
				hit = true
				break
			else:
				px += step
		
	else:
		px += dist
	
	position.x = px
	return hit

# move y axis
func move_y(dist : int):
	var hit = false
	has_moved_y = true
	is_on_floor_3 = is_on_floor_2
	is_on_floor_2 = is_on_floor
	is_on_floor = false
	
	if is_colliding:
		var step = sign(dist)
		
		for i in range(abs(dist)):
			if check_solid_y(step):
				speed_y = 0
				remainder_y = 0
				
				has_hit_up = (step == -1)
				has_hit_down = (step == 1)
				is_on_floor = has_hit_down
				hit = true
				break
			else:
				py += step
		
	else:
		py += dist
	
	position.y = py
	return hit

# return array of overlapping actors
func overlapping_actors(dx : int, dy : int, ignore : Actor):
	var act = []
	for a in get_tree().get_nodes_in_group("actor"):
		if a != self and a != ignore:
			if aabb(px + dx, py + dy, hitbox_x, hitbox_y, a.px, a.py, a.hitbox_x, a.hitbox_y):
				act.append(a)
	return act

func check_area_solid_tile(x1, y1, width, height):
	var x2 = x1 + width - 1
	var y2 = y1 + height - 1
	
	var pos = [Vector2(x1, y1), Vector2(x2, y1), Vector2(x1, y2), Vector2(x2, y2)]
	for i in pos:
		var w2m = Shared.node_map.world_to_map(i)
		if Shared.node_map.get_cellv(w2m) != -1:
			return true
	return false

func check_area_solid_actor(x, y, width, height, ignore):
	for a in get_tree().get_nodes_in_group("actor"):
		if a != self and a.is_solid and a != ignore:
			if aabb(x, y, width, height, a.px, a.py, a.hitbox_x, a.hitbox_y):
				return true
	return false

func check_area_solid(x, y, width, height, ignore):
	if check_area_solid_tile(x, y, width, height):
		return true
	if check_area_solid_actor(x, y, width, height, ignore):
		return true
	return false


