extends TileMap

var scene_spike = preload("res://src/actor/Spike.tscn")

func _ready():
	if !Shared.is_level_select:
		for pos in get_used_cells():
			var cell = cell_size.x
			var inst = scene_spike.instance()
			inst.position = Vector2(pos.x * cell, pos.y * cell + 5)
			add_child(inst)
		clear()
