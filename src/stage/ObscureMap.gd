extends TileMap

func _ready():
	tile_set.get_source(0).get_tile_data(Vector2i(0, 0), 0).modulate = Color.BLACK
	tile_set.get_source(1).get_tile_data(Vector2i(0, 0), 0).modulate = Color.TRANSPARENT

func _physics_process(delta):
	if is_instance_valid(Shared.player):
		modulate.a = lerp(modulate.a, 0.0 if get_cell_source_id(0, local_to_map(Shared.player.center())) != -1 else 1.0, delta * 10.0)
