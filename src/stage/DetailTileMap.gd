tool
extends TileMap

export var brick_color := Color("5f574f") setget set_brick_color
export var grass_color := Color("008751") setget set_grass_color
export var wood_color := Color("ad0028") setget set_wood_color

func _ready():
	tile_set = tile_set.duplicate()
	if Engine.is_editor_hint(): return
	
	set_brick_color()
	set_grass_color()
	set_wood_color()

func set_brick_color(arg := brick_color):
	brick_color = arg
	tile_set.tile_set_modulate(4, brick_color)
	
func set_grass_color(arg := grass_color):
	grass_color = arg
	tile_set.tile_set_modulate(5, grass_color)

func set_wood_color(arg := wood_color):
	wood_color = arg
	tile_set.tile_set_modulate(6, wood_color)
