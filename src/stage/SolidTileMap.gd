tool
extends TileMap

export var tile_color := Color("c2c3c7") setget set_tile_color

func _ready():
	if Engine.is_editor_hint(): return
	tile_set = tile_set.duplicate()
	
	Shared.map_solid = self
	
	set_tile_color()
	tile_set.tile_set_modulate(1, Color.transparent)

func set_tile_color(arg := tile_color):
	tile_color = arg
	tile_set.tile_set_modulate(0, tile_color)
	
