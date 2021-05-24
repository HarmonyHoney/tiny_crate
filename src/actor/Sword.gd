extends Node2D

var sprite : Sprite

var player
var speed = 10

var target := Vector2.ZERO

export var lerp_step := 0.1

var is_slash = false
var slash_count = 0

var audio : AudioStreamPlayer2D
var audio2

var dir = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprite
	audio = $Audio1
	audio2 = $Audio2
	
	
	for i in get_tree().get_nodes_in_group("player"):
		player = i
		break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_slash:
		slash_count += 25
		if slash_count > 359:
			slash_count = 0
			is_slash = false
		rotation_degrees = slash_count * dir
	else:
		if is_instance_valid(player):
			dir = player.dir
			target = player.center() - Vector2(dir * 9, 2)
			sprite.flip_h = player.center().x < position.x
	
	position = position.linear_interpolate(target, lerp_step)

func slash():
	if is_slash:
		return
	is_slash = true
	
	if btn.d("up"):
		target = player.center() + Vector2(rand_range(-2, 2) + (player.speed_x * 12), -15)
	elif btn.d("down"):
		target = player.center() + Vector2(rand_range(-2, 2) + (player.speed_x * 12), 15)
	else:
		target = player.center() + Vector2(dir * 15 + (player.speed_x * 12), -2 + rand_range(-2, 2) + (player.speed_y * 2))
	
	var a = audio if randf() > 0.5 else audio2
	a.pitch_scale = 1 + rand_range(-0.2, 0.2)
	a.play()
	
	slash_count = 0

