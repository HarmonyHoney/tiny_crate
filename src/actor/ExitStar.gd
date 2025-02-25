extends Sprite

export var speed := 6.0
export var speed_diff := 3.0

export var orbit := 10.0
export var orbit_diff := 5.0

var rot := 0.0
export var rot_speed := 30.0
export var rot_speed_diff := 15.0

var counter := 0.0

func _ready():
	frame = floor(rand_range(0, 5))
	rot = deg2rad(randf() * 360)
	z_index = 1
	
	speed += rand_range(-speed_diff, speed_diff)
	if randf() > 0.5:
		speed = -speed
	
	orbit += rand_range(-orbit_diff, orbit_diff)
	
	rot_speed += rand_range(-rot_speed_diff, rot_speed_diff)
	if randf() > 0.5:
		rot_speed = -rot_speed

func _physics_process(delta):
	counter += delta
	var sx = sin(counter * speed) * orbit
	var vec := Vector2(sx, 0)
	rot += deg2rad(delta * rot_speed)
	position = vec.rotated(rot)
	if z_index > 0:
		if sx > orbit * 0.9:
			z_index = -z_index
	else:
		if sx < orbit * -0.9:
			z_index = -z_index
