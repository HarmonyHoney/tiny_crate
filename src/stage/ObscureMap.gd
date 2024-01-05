extends TileMap

var frac = 0.0
export var speed := 10.0

func _ready():
	for i in 2:
		tile_set.tile_set_modulate(i, Color.transparent)
	
	if Shared.is_level_select: return
	
	Shared.obscure_map = self

func _physics_process(delta):
	if Shared.is_level_select: return
	
	frac = lerp(frac, 0.0 if is_instance_valid(Shared.player) and get_cellv(world_to_map(Shared.player.center())) != -1 else 1.0, delta * speed)
	modulate.a = lerp(0.5, 1.0, frac)
