extends Node


var node_map_solid : TileMap
var node_map_spike : TileMap
var node_camera_game : Camera2D

var is_reset = false
var reset_clock := 0.0
var reset_time := 1.0

func _ready():
	
	# scale window
	var scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	scale = max(1, scale - 1)
	OS.window_size = Vector2(320 * scale, 180 * scale)
	
	# center window
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)

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
