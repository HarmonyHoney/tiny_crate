extends Node

var node_map_solid : TileMap
var node_camera_game : Camera2D

var is_quit := false
var is_reset := false
var reset_clock := 0.0
var reset_time := 1.0
var is_clear := false

var map_path := "res://src/map/"
var current_map := 0
var scene_path := "res://src/menu/select.tscn"
var main_menu_path := "res://src/menu/StartMenu.tscn"
var options_menu_path := "res://src/menu/OptionsMenu.tscn"
var level_select_path := "res://src/menu/select.tscn"
var win_screen_path := "res://src/menu/WinScreen.tscn"
var credits_path := "res://src/menu/credits.tscn"
var splash_path := "res://src/menu/splash.tscn"

var window_scale := 1

var save_data := {}
var save_filename := "box.save"

var view_size := Vector2(228, 128)

var maps = []

var is_level_select := false
var is_in_game := false

var sfx_volume = 10
var music_volume = 10

var actors := []


func _ready():	
	print("Shared._ready(): ")
	
	# get world maps
	maps = dir_list(map_path)
	print("maps: ", maps)
	
	# scale window
	window_scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	window_scale = max(1, floor(window_scale * 0.9))
	set_window_scale()
	
	# load save data
	if load_file(save_filename):
		save_data = JSON.parse(load_file(save_filename)).result
		print("save_data: " + JSON.print(save_data, "\t"))
		if !save_data.has("map"):
			create_save()
	else:
		print(save_filename + " not found")
		create_save()
	
	Wipe.connect("finish", self, "wipe_finish")

func _physics_process(delta):
	# reset timer
	if is_reset:
		reset_clock -= delta
		if reset_clock < 0:
			do_reset()

func create_save():
	save_data = {}
	save_data["map"] = 0
	save_file(save_filename, JSON.print(save_data, "\t"))

# look into a folder and return a list of filenames without file extension
func dir_list(path : String):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name:
			array.append(file_name.split(".")[0])
			file_name = dir.get_next()
		dir.list_dir_end()
	array.sort()
	return array

func set_window_scale(arg := window_scale):
	window_scale = max(1, arg if arg else window_scale)
	if OS.get_name() != "HTML5":
		OS.window_size = Vector2(view_size.x * window_scale, view_size.y * window_scale)
		# center window
		OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)
	return "window_scale: " + str(window_scale) + " - resolution: " + str(OS.get_window_size())

func start_reset():
	if !is_reset:
		is_reset = true
		reset_clock = reset_time

func do_reset():
	is_reset = false
	Wipe.start()
	Pause.set_process_input(false)

func quit_wipe():
	is_quit = true
	Wipe.start()

func wipe_scene(arg := ""):
	scene_path = arg
	do_reset()

func wipe_finish():
	if is_quit:
		get_tree().quit()
	else:
		change_map()

func change_map():
	get_tree().change_scene(scene_path)
	is_level_select = scene_path == level_select_path
	is_in_game = scene_path.begins_with(map_path) or scene_path.begins_with(win_screen_path)
	TouchScreen.pause.visible = is_in_game
	Pause.set_process_input(true)
	
	UI.keys(false, false)

func set_map(arg):
	current_map = clamp(arg, 0, Shared.maps.size() - 1)
	if arg > Shared.maps.size() - 1:
		scene_path = win_screen_path
	else:
		scene_path = map_path + maps[current_map] + ".tscn"

func win():
	win_save()
	set_map(current_map + 1)
	start_reset()
	print("map complete")

func win_save():
	if save_data["map"] < current_map + 1:
		save_data["map"]  = current_map + 1
	
	save_file(save_filename, JSON.print(save_data, "\t"))
	print("save_data: ", save_data)

func save_file(fname, arg):
	var file = File.new()
	file.open("user://" + str(fname), File.WRITE)
	file.store_string(arg)
	file.close()

func load_file(fname = "box.save"):
	var file = File.new()
	file.open("user://" + str(fname), File.READ)
	var content = file.get_as_text()
	file.close()
	return content

func delete_save():
	print("delete save")
	create_save()

func unlock():
	save_data["map"] = 99
	save_file(save_filename, JSON.print(save_data, "\t"))

func set_volume_sfx(arg = 0):
	sfx_volume = clamp(arg, 0, 10)
	AudioServer.set_bus_volume_db(1, linear2db(sfx_volume / 10.0))

func set_volume_music(arg = 0):
	music_volume = clamp(arg, 0, 10)
	AudioServer.set_bus_volume_db(2, linear2db(music_volume / 10.0))

