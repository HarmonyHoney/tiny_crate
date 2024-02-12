tool
extends Actor
class_name Box

var is_push = false

onready var node_audio : AudioStreamPlayer2D = $AudioHit
onready var node_anim : AnimationPlayer = $AnimationPlayer
onready var node_sprite : Sprite = $Sprite
onready var sprite_mat : ShaderMaterial = node_sprite.material
var spr_pos := Vector2.ZERO

var push_clock := 0.0
export var push_dur := 0.3
var push_dir = -1

var shake_dist = 0

var scene_slam = preload("res://src/fx/Slam.tscn")

var images = [1, 4, 5, 6, 7]
export var is_refresh_frame := 0 setget pick_frame

func _ready():
	if Engine.editor_hint: return
	pick_frame()
	if Shared.is_level_select: return
	
	spr_pos = node_sprite.position
	
	if is_area_solid(position.x, position.y + 1):
		is_on_floor = true
		shake_dist = 1

func _physics_process(delta):
	if Engine.editor_hint: return
	
	is_push = false

func hit_floor():
	speed.x = 0
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()
	Shared.cam.shake(shake_dist)
	node_anim.play("hit")
	node_anim.advance(0)
	shake_dist = 1
	
	# slam
	var inst = scene_slam.instance()
	inst.position = center()
	get_parent().add_child(inst)

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

func pick_frame(arg = null):
	#randomize()
	node_sprite.frame = images[randi() % images.size()]
	node_sprite.flip_h = randf() > 0.5
	sprite_mat.set_shader_param("flip", float(randf() > 0.5))
	
