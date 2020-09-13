tool
extends Actor
class_name Exit

var node_dust : Node2D
export var dust_count := 5
export var dust_speed := 0.13

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	
	node_dust = $Dust
	
	# create dust
	for i in dust_count - 1:
		node_dust.add_child($Dust/dust.duplicate())
	var j = 0
	for i in node_dust.get_children():
		i.position.x = floor(rand_range(-4, 4))
		i.position.y = j - 4
		j += 2
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		return
	
	for i in node_dust.get_children():
		i.position.y -= dust_speed
		if i.position.y < -11:
			i.position.y = 0
			i.position.x = floor(rand_range(-4, 4))
	
	
	
