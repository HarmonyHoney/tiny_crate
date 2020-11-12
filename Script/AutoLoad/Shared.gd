extends Node

var node_map_solid : TileMap
var node_map_spike : TileMap
var node_camera_game : Camera2D

var stage : Stage

var is_reset = false
var reset_clock := 0.0
var reset_time := 1.0

var _window_scale := 1.0
var map_name := "hub"
var hub_pos := Vector2(-16, -16)
var death_count := 0

var stage_data := []
var save_file := "box.save"

func _ready():	
	dev.out("Shared._ready(): ", false)
	
	# _window_scale window
	_window_scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	_window_scale = max(1, _window_scale - 2)
	set_window_scale()
	
	# load stage save data
	if load_data(save_file):
		stage_data = JSON.parse(load_data(save_file)).result
		dev.out(JSON.print(stage_data, "\t"))
	else:
		dev.out(save_file + " not found")

func set_window_scale(arg := _window_scale):
	_window_scale = arg if arg else _window_scale
	_window_scale = max(1, _window_scale)
	OS.window_size = Vector2(320 * _window_scale, 180 * _window_scale)
	# center window
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)
	return "_window_scale: " + str(_window_scale) + " - resolution: " + str(OS.get_window_size())

func _process(delta):
	# reset timer
	if is_reset:
		reset_clock -= delta
		if reset_clock < 0:
			do_reset()

func start_reset(arg = ""):
	if !is_reset:
		is_reset = true
		reset_clock = reset_time
		if arg:
			map_name = arg

func do_reset():
	is_reset = false
	dev.out("loading scene: " + "res://Map/" + map_name + ".tscn")
	get_tree().change_scene("res://Map/" + map_name + ".tscn")

func death():
	death_count += 1
	HUD.node_death.text = "deaths: " + str(death_count)

func win():
	if stage:
		stage.stop_timer()
		
		var new_data = {
			"name": stage.stage_name,
			"time": stage.timer,
			"death": death_count,
		}
		
		for i in stage_data:
			if i["name"] == new_data["name"]:
				stage_data.erase(i)
		stage_data.append(new_data)
	
	save_data(save_file, JSON.print(stage_data, "\t"))
	dev.out("(box.save)")
	dev.out(load_data(save_file))
	
	death_count = 0

func save_data(save_file,  arg):
	var file = File.new()
	file.open("user://" + str(save_file), File.WRITE)
	file.store_string(arg)
	file.close()
	#dev.out("(Shared.save) user://box.save")
	#dev.out("[\n" + str(arg) + "\n]")

func load_data(fname):
	var file = File.new()
	file.open("user://" + str(fname), File.READ)
	var content = file.get_as_text()
	file.close()
	return content
	



