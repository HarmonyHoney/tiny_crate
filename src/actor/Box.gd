tool
extends Actor
class_name Box

var is_push = false

var node_audio : AudioStreamPlayer2D
var node_anim : AnimationPlayer
var node_sprite : Sprite
var spr_pos := Vector2.ZERO

var push_clock := 0.0
export var push_dur := 0.3
var push_dir = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	
	node_audio = $AudioHit
	node_anim = $AnimationPlayer
	node_sprite = $Sprite
	spr_pos = node_sprite.position
	
	if is_area_solid(tile.x, tile.y + 1):
		is_on_floor = true

func just_moved():
	if !is_push:
		node_sprite.position = spr_pos + (Vector2.ZERO if is_on_floor else remainder * tile_size)

func hit_floor():
	speed.x = 0
	node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	node_audio.play()
	Shared.node_camera_game.shake(2)
	node_anim.play("hit")
	node_anim.advance(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	
	if is_push:
		push_clock = min(push_clock + delta, push_dur)
		node_sprite.position = spr_pos - Vector2(lerp(push_dir, 0, push_clock / push_dur) * tile_size, 0)
		if push_clock == push_dur:
			is_push = false

# push box
func push(dir : int):
	if is_push:
		return
	is_push = true
	push_clock = 0
	
	# check for box at destination
	if is_area_solid(tile.x + dir, tile.y):
		for a in check_area_actors("box", tile.x + dir):
			a.push(dir)
	
	# check for box above
	if not is_area_solid(tile.x + dir, tile.y):
		for a in check_area_actors("box", tile.x, tile.y - 1):
			a.push(dir)
		move_x(dir)
		push_dir = dir
