extends Node

var node_map_solid : TileMap
var node_map_spike : TileMap
var node_camera_game : Camera2D

var stage : Stage

var is_reset = false
var reset_clock := 0.0
var reset_time := 1.0
var is_clear = false

var map_path := "res://src/map/"
var _window_scale := 1.0
var map_name := "hub"
var hub_pos := Vector2(-16, -16)
#var death_count := 0

var stage_data := []
var save_file := "box.save"

var last_pick = 0

var view_size := Vector2(240, 180)

func _ready():	
	dev.out("Shared._ready(): ", false)
	
	# _window_scale window
	_window_scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	_window_scale = max(1, floor(_window_scale * 0.8))
	set_window_scale()
	
	# load stage save data
	if load_data(save_file):
		stage_data = JSON.parse(load_data(save_file)).result
		dev.out(JSON.print(stage_data, "\t"))
	else:
		dev.out(save_file + " not found")

func _process(delta):
	# reset timer
	if is_reset:
		reset_clock -= delta
		if reset_clock < 0:
			do_reset()

func set_window_scale(arg := _window_scale):
	_window_scale = arg if arg else _window_scale
	_window_scale = max(1, _window_scale)
	OS.window_size = Vector2(view_size.x * _window_scale, view_size.y * _window_scale)
	# center window
	OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)
	return "_window_scale: " + str(_window_scale) + " - resolution: " + str(OS.get_window_size())

func start_reset():
	if !is_reset:
		is_reset = true
		reset_clock = reset_time

func do_reset():
	is_reset = false
	HUD.wipe.connect("finish", self, "change_map")
	HUD.wipe.start()

func change_map():
	if is_clear:
		is_clear = false
		get_tree().change_scene("res://src/menu/select.tscn")
	else:
		get_tree().change_scene(map_path + map_name + ".tscn")
	HUD.wipe.start(true)


func win():
	win_save()
	
	is_clear = true
	last_pick += 1
	start_reset()
	dev.out("map complete")

func win_save():
	# save data
	if stage:
		stage.stop_timer()
		var new_data = {
			"file": stage.filename,
			"name": stage.stage_name,
			"complete": stage.is_complete,
			"time": stage.timer,
			"death": stage.metric_death,
			"jump": stage.metric_jump,
			"pickup": stage.metric_pickup,
		}
		for i in stage_data:
			if i.has("file") and i["file"] == new_data["file"]:
				stage_data.erase(i)
				break
		stage_data.append(new_data)
	
	stage_data.sort()
	save_data(save_file, JSON.print(stage_data, "\t"))


func save_data(save_file,  arg):
	var file = File.new()
	file.open("user://" + str(save_file), File.WRITE)
	file.store_string(arg)
	file.close()

func load_data(fname = "box.save"):
	var file = File.new()
	file.open("user://" + str(fname), File.READ)
	var content = file.get_as_text()
	file.close()
	return content
	



