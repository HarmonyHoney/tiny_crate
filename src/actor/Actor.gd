tool
extends Node2D
class_name Actor

# hitbox
export var hitbox_x := 8 setget _set_hit_x
export var hitbox_y := 8 setget _set_hit_y

# speed
var speed := Vector2.ZERO
export var gravity := 0.2
var term_vel := 16
var remainder := Vector2.ZERO

# movement and collision
export var tag := "actor"
export var is_solid := false
export var is_moving := false
export var is_colliding := false
export var is_using_gravity := false

# has moved
var has_moved_x := false
var has_moved_y := false
var last_move := Vector2.ZERO

# has hit
var has_hit_up := false
var has_hit_down := false
var has_hit_left := false
var has_hit_right := false

# air time
var is_on_floor := false
var is_on_floor_last := false
var time_since_floor := 0

# ignore this actor's solidity
var ignore_actor : Actor

export var is_select_process := false
export var is_obscure := false

func _enter_tree():
	if Engine.editor_hint: return
	Shared.actors.append(self)

func _exit_tree():
	if Engine.editor_hint: return
	Shared.actors.erase(self)

func _ready():
	position = position.floor()
	
	if Engine.editor_hint or (Shared.is_level_select and !is_select_process):
		set_physics_process(false)

func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	if is_moving:
		move()
		
		if is_using_gravity:
			speed.y = min(speed.y + gravity, term_vel)
		if not is_on_floor:
			time_since_floor += 1
	
	if is_obscure and is_instance_valid(Shared.map_obscure):
		modulate.a = lerp(1.0, 0.0, Shared.map_obscure.frac)

# update() the _draw() when hitbox values are changed (in the editor)
func _set_hit_x(value):
	hitbox_x = value
	update()

func _set_hit_y(value):
	hitbox_y = value
	update()

# draw hitbox in editor
func _draw():
	if Engine.editor_hint:
		draw_rect(Rect2(0, 0, hitbox_x, hitbox_y), Color(1, 0, 0.75, 0.5))

# axis aligned bounding box
func aabb(x1 : int, y1 : int, w1 : int, h1 : int, x2 : int, y2 : int, w2 : int, h2 : int):
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1

func is_overlapping(a : Actor):
	return aabb(position.x, position.y, hitbox_x, hitbox_y, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y)

func center():
	return position + Vector2(hitbox_x / 2, hitbox_y / 2)

# move actor
func move(override = Vector2.ZERO):
	# clear vars
	has_moved_x = false
	has_moved_y = false
	has_hit_up = false
	has_hit_down = false
	has_hit_left = false
	has_hit_right = false
	last_move = position
	
	if override != Vector2.ZERO:
		move_y(override.y)
		move_x(override.x)
	else:
		remainder.y += speed.y
		var dy = floor(remainder.y + 0.5) # distance y
		remainder.y -= dy
		if dy != 0:
			move_y(dy)
		
		remainder.x += speed.x
		var dx = floor(remainder.x + 0.5) # distance x
		remainder.x -= dx
		if dx != 0:
			move_x(dx)
	
	last_move = position - last_move
	just_moved()

func just_moved():
	pass

# return distance of upcoming move
func move_get_dist():
	return Vector2(floor(remainder.x + speed.x + 0.5), floor(remainder.y + speed.y + 0.5))

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
				speed.x = 0
				remainder.x = 0
				
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
	is_on_floor_last = is_on_floor
	is_on_floor = false
	
	if is_colliding:
		var step = sign(dist)
		for i in range(abs(dist)):
			if is_area_solid(position.x, position.y + step):
				if step == -1 and wiggle_y(step):
					position.x += wiggle_y(step)
					position.y += step
					continue
				speed.y = 0
				remainder.y = 0
				
				has_hit_up = (step == -1)
				has_hit_down = (step == 1)
				is_on_floor = has_hit_down
				if is_on_floor:
					time_since_floor = 0
					if !is_on_floor_last:
						hit_floor()
				return true
			else:
				position.y += step
	else:
		position.y += dist
	return false

func hit_floor():
	pass

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

# check area for solid tiles
func is_area_solid_tile(x1, y1, width, height):
	var w2m = Shared.map_solid.world_to_map(Vector2(x1, y1))
	var cell = Shared.map_solid.cell_size.x
	
	# check more than four points if hitbox is longer than 8 pixels
	var points = max(2, (width / cell) + 1)
	for ix in points:
		for iy in points:
			var check = Vector2(w2m.x + ix, w2m.y + iy)
			if Shared.map_solid.get_cellv(check) != -1:
				check *= cell
				if aabb(x1, y1, width, height, check.x, check.y, cell, cell):
					return true
	return false

# check area for solid actors
func is_area_solid_actor(x, y, width = hitbox_x, height = hitbox_y, ignore = null) -> bool:
	for a in Shared.actors:
		if a.is_solid and a != self and a != ignore and a != ignore_actor:
			if aabb(x, y, width, height, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y):
				return true
	return false

# check if area is solid
func is_area_solid(x = position.x, y = position.y, width = hitbox_x, height = hitbox_y, ignore = null) -> bool:
	if is_area_solid_tile(x, y, width, height):
		return true
	return is_area_solid_actor(x, y, width, height, ignore)

# is overlapping any actor?
func is_area_actor(_tag = "", x = position.x, y = position.y, width = hitbox_x, height = hitbox_y, ignore = null):
	for a in Shared.actors:
		if a != self and a != ignore and (_tag != "" and a.tag == _tag) and aabb(x, y, width, height, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y):
			return true
	return false

# return array of actors
func check_area_actors(_tag = "", x = position.x, y = position.y, width = hitbox_x, height = hitbox_y, ignore = null):
	var act = []
	for a in Shared.actors:
		if a != self and a != ignore and (_tag != "" and a.tag == _tag) and aabb(x, y, width, height, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y):
			act.append(a)
	return act

func check_area_first_actor(_tag = "", x = position.x, y = position.y, width = hitbox_x, height = hitbox_y, ignore = null):
	for a in Shared.actors:
		if a != self and a != ignore and (_tag != "" and a.tag == _tag) and aabb(x, y, width, height, a.position.x, a.position.y, a.hitbox_x, a.hitbox_y):
			return a
