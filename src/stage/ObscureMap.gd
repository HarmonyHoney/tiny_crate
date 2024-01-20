tool
extends TileMap

export var tile_color := Color("c2c3c7") setget set_tile_color
export var speed := 10.0
var frac = 1.0

func _ready():
	tile_set = tile_set.duplicate()
	if Engine.is_editor_hint(): return
	
	set_tile_color()
	tile_set.tile_set_modulate(0, Color.transparent)
	
	if Shared.is_level_select: return
	
	Shared.map_obscure = self

func _physics_process(delta):
	if Engine.is_editor_hint() or Shared.is_level_select: return
	
	frac = lerp(frac, 0.0 if is_instance_valid(Shared.player) and get_cellv(world_to_map(Shared.player.center())) != -1 else 1.0, delta * speed)
	modulate.a = lerp(0.5, 1.0, frac)

func set_tile_color(arg := tile_color):
	tile_color = arg
	tile_set.tile_set_modulate(2, tile_color)
	
