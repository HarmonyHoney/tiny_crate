extends Node


var node_map_solid : TileMap
var node_map_spike : TileMap

var is_reset = false
var reset_clock := 0.0
var reset_time := 1.0

func _process(delta):
	if is_reset:
		reset_clock -= delta
		if reset_clock < 0:
			is_reset = false
			get_tree().reload_current_scene()

func start_reset():
	if !is_reset:
		is_reset = true
		reset_clock = reset_time
