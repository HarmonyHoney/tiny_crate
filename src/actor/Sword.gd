tool
extends Actor

var sprite : Sprite

var player
var speed = 10

var target := Vector2.ZERO

export var lerp_step := 0.1

var is_slash = false
export var slash_margin = 1

var audio : AudioStreamPlayer2D
var audio2

var dir = 1

var lerp_pos := Vector2.ZERO

export var slash_dist = 15
export var speed_mod = 12

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	sprite = $Sprite
	audio = $Audio1
	audio2 = $Audio2
	
	for i in get_parent().get_children():
		if i.is_in_group("player"):
			player = i
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	if is_slash:
		sprite.rotate(deg2rad(delta * dir * 1650))
		if lerp_pos.distance_to(target) < slash_margin:
			is_slash = false
			sprite.rotation_degrees = 0
		for i in check_area_actors():
			i.hit()
		
	else:
		if is_instance_valid(player):
			dir = player.dir
			target = player.center() - Vector2(dir * 9, 2)
			sprite.flip_h = player.center().x < position.x
	
	lerp_pos = lerp_pos.linear_interpolate(target, lerp_step)
	center(lerp_pos.round())

func slash():
	if is_slash:
		return
	is_slash = true
	
	var wiggle = 3
	
	if btn.d("up"):
		target = player.center() + Vector2(rand_range(-wiggle, wiggle) + (player.speed_x * speed_mod), -slash_dist)
	elif btn.d("down"):
		target = player.center() + Vector2(rand_range(-wiggle, wiggle) + (player.speed_x * speed_mod), slash_dist)
	else:
		target = player.center() + Vector2(dir * slash_dist + (player.speed_x * speed_mod), -2 + rand_range(-wiggle, wiggle) + (player.speed_y * 2))
	var a = audio if randf() > 0.5 else audio2
	a.pitch_scale = 1 + rand_range(-0.2, 0.2)
	a.play()

