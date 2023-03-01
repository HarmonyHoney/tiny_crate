extends TileMap

func _ready():
	Shared.node_map_solid = self
	tile_set.tile_set_modulate(1, Color.TRANSPARENT)
