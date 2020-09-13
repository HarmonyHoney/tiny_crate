extends Node


var node_map_solid : TileMap
var node_map_spike : TileMap
var node_camera_game : Camera2D

var is_reset = false
var reset_clock := 0.0
var reset_time := 1.0

var _window_scale := 1.0

func _ready():
	
	# _window_scale window
	_window_scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	_window_scale = max(1, _window_scale- 2)
	set_window_scale()

func set_window_scale(arg := _window_scale):
	_window_scale = arg
	_window_scale = max(1, _window_scale)
	OS.window_size = Vector2(320 * _window_scale, 180 * _window_scale)
	# center window
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)
	
	print("_window_scale: ", _window_scale)

func _process(delta):
	if is_reset:
		reset_clock -= delta
		if reset_clock < 0:
			is_reset = false
			get_tree().reload_current_scene()
	
	
	
	if Input.is_action_just_pressed("window_shrink"):
		set_window_scale(_window_scale - 1)
	elif Input.is_action_just_pressed("window_expand"):
		set_window_scale(_window_scale + 1)

func start_reset():
	if !is_reset:
		is_reset = true
		reset_clock = reset_time
