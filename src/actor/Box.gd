tool
extends Actor
class_name Box

var is_pushed = false

var node_audio : AudioStreamPlayer2D
var node_anim : AnimationPlayer
var node_sprite : Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	
	node_audio = $AudioHit
	node_anim = $AnimationPlayer
	node_sprite = $Sprite
	
	if is_area_solid(position.x, position.y + 1):
		is_on_floor = true

func just_moved():
	node_sprite.position = Vector2(4,4) + (Vector2.ZERO if is_on_floor else remainder)

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
	is_pushed = false

# push box
func push(dir : int):
	if is_pushed:
		return
	is_pushed = true
	
	# check for box at destination
	if is_area_solid(position.x + dir, position.y):
		for a in check_area_actors("box", position.x + dir):
			a.push(dir)
	
	# check for box above
	if not is_area_solid(position.x + dir, position.y):
		for a in check_area_actors("box", position.x, position.y - 1):
			a.push(dir)
		move_x(dir)
