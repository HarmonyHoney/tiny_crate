@tool
extends Actor
class_name Box

var is_push = false

@onready var node_audio : AudioStreamPlayer2D = $AudioHit
@onready var node_anim : AnimationPlayer = $AnimationPlayer
@onready var node_sprite : Sprite2D = $Sprite2D
var spr_pos := Vector2.ZERO

var push_clock := 0.0
@export var push_dur := 0.3
var push_dir = -1

var shake_dist = 0

var scene_slam = preload("res://src/fx/Slam.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint or Shared.is_level_select:
		set_physics_process(false)
		return
	
	spr_pos = node_sprite.position
	
	if is_area_solid(position.x, position.y + 1):
		is_on_floor = true
		shake_dist = 1

func hit_floor():
	speed.x = 0
	node_audio.pitch_scale = 1 + randf_range(-0.2, 0.2)
	node_audio.play()
	Shared.node_camera_game.shake(shake_dist)
	node_anim.play("hit")
	node_anim.advance(0)
	shake_dist = 1
	
	# slam
	var inst = scene_slam.instantiate()
	inst.position = center()
	get_parent().add_child(inst)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	is_push = false

# push box
func push(dir : int):
	if is_push:
		return
	is_push = true
	push_clock = 0
	
	# check for box at destination
	if is_area_solid(position.x + dir, position.y):
		for a in check_area_actors("box", position.x + dir):
			a.push(dir)
	
	# check for box above
	if not is_area_solid(position.x + dir, position.y):
		for a in check_area_actors("box", position.x, position.y - 1):
			a.push(dir)
		move_x(dir)
		push_dir = dir
