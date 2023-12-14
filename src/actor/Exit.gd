tool
extends Actor
class_name Exit

onready var node_dust : Node2D = $Dust
export var dust_count := 5
export var dust_speed := 0.13

onready var node_stars : Node2D = $Stars
export var star_count := 5
export var star_speed := 6
export var star_orbit := 10
var star_rot = 0

func _ready():
	if Engine.editor_hint: return
	
	# create dust
	for i in dust_count - 1:
		node_dust.add_child($Dust/dust.duplicate())
	var j = 0
	for i in node_dust.get_children():
		i.position.x = floor(rand_range(-4, 4))
		i.position.y = j - 4
		j += 2
	
	# create stars
	for i in star_count - 1:
		node_stars.add_child($Stars/Star.duplicate())

func _physics_process(delta):
	if Engine.editor_hint: return
	
	# move dust
	for i in node_dust.get_children():
		i.position.y -= dust_speed
		if i.position.y < -11:
			i.position.y = 0
			i.position.x = floor(rand_range(-4, 4))
