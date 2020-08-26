extends TileMap


var scene_spike = preload("res://Scene/Spike.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Shared.node_map_spike = self
	
	for pos in get_used_cells():
		print("creating spike from tile: ", pos)
		var cell = cell_size.x
		var inst = scene_spike.instance()
		inst.position = Vector2(pos.x * cell, pos.y * cell + 5)
		add_child(inst)
	clear()
	
	
