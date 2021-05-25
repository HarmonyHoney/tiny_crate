tool
extends Actor
class_name Box

var is_pushed = false

var last_floor := false

var node_audio : AudioStreamPlayer2D
var node_anim : AnimationPlayer

var scene_explosion = preload("res://src/fx/Explosion.tscn")
var scene_explosion2 = preload("res://src/fx/Explosion2.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	
	node_audio = $AudioHit
	node_anim = $AnimationPlayer
	
	if is_area_solid(position.x, position.y + 1):
		is_on_floor = true
		last_floor = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	is_pushed = false

func _on_hit_floor():
	._on_hit_floor()
	if !is_on_floor_last:
		node_audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
		node_audio.play()
		Shared.node_camera_game.shake(2)
		node_anim.play("hit")
		node_anim.advance(0)

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

func hit(arg = 0):
	var inst = scene_explosion.instance()
	inst.position = position + (Vector2(4, 8) if is_holding else Vector2(4, 4))
	get_parent().add_child(inst)
	Shared.node_camera_game.shake(2)
	queue_free()

