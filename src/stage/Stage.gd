tool
extends Node2D

export var palette := -1 setget set_palette
var palettes := [["c2c3c7", "5f574f", "008751", "ad0028"],
["c46874", "3d1c2f", "bd9400", "ad0028"],
["b2b2db", "39394f", "838700", "ab378a"],
["c2a782", "382e1f", "ab2c59", "4b6e2e"],
["66bd6a", "153d17", "0a69f0", "a82d2d"],]

export var color_solid := Color("c2c3c7") setget set_solid
export var color_back := Color("5f574f") setget set_back
export var color_grass := Color("008751") setget set_grass
export var color_wood := Color("ad0028") setget set_wood

onready var map_solid := $SolidTileMap
onready var map_spike := $SpikeTileMap
onready var map_detail := $DetailTileMap
onready var map_obscure := $ObscureMap

func _ready():
	set_palette()
	set_solid()
	set_back()
	set_grass()
	set_wood()

func set_palette(arg := palette):
	palette = arg
	if palette > -1 and palette < palettes.size():
		var p = PoolColorArray(palettes[palette])
		set_solid(p[0])
		set_back(p[1])
		set_grass(p[2])
		set_wood(p[3])
		update()

func set_solid(arg := color_solid):
	color_solid = arg
	if map_solid:
		map_solid.tile_color = color_solid
	if map_obscure:
		map_obscure.tile_color = color_solid

func set_back(arg := color_back):
	color_back = arg
	if map_detail:
		map_detail.brick_color = color_back
	
func set_grass(arg := color_grass):
	color_grass = arg
	if map_detail:
		map_detail.grass_color = color_grass
	
func set_wood(arg := color_wood):
	color_wood = arg
	if map_detail:
		map_detail.wood_color = color_wood
