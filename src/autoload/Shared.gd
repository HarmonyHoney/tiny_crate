extends Node

var node_map_solid : TileMap
var node_camera_game : Camera2D

var is_quit := false
var is_reset := false
var reset_clock := 0.0
var reset_time := 1.0
var is_level_select := false
var is_in_game := false

var map_path := "res://src/map/"
var scene_path := "res://src/menu/select.tscn"
var main_menu_path := "res://src/menu/StartMenu.tscn"
var options_menu_path := "res://src/menu/options/OptionsMenu.tscn"
var level_select_path := "res://src/menu/select.tscn"
var win_screen_path := "res://src/menu/WinScreen.tscn"
var credits_path := "res://src/menu/credits.tscn"
var splash_path := "res://src/menu/splash.tscn"

var save_data := {}
var save_filename := "box.save"

var window_scale := 1
var view_size := Vector2(228, 128)
var bus_volume = [10, 10, 10]

var current_map := 0
var maps := []
var map_save := 0

var actors := []
var player

var is_note := false
var notes := []

func _ready():
	print("Shared._ready(): ")
	
	# scale window
	window_scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	window_scale = max(1, floor(window_scale * 0.9))
	set_window_scale()
	
	# lower volume
	for i in [1, 2]:
		set_bus_volume(i, 7)
	
	# get world maps
	maps = dir_list(map_path)
	print("maps: ", maps)
	
	# load save data
	var l = load_file(save_filename)
	if l:
		save_data = JSON.parse(l).result
		print("save_data: " + JSON.print(save_data, "\t"))
		if save_data.has("map"):
			map_save = save_data["map"]
			if save_data.has("notes"):
				notes = save_data["notes"]
		else:
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

### Changing Maps

func start_reset():
	if !is_reset:
		is_reset = true
		reset_clock = reset_time

func do_reset():
	is_reset = false
	Wipe.start()
	Pause.set_process_input(false)

func wipe_quit():
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

func set_map(arg):
	current_map = clamp(arg, 0, Shared.maps.size() - 1)
	if arg > Shared.maps.size() - 1:
		scene_path = win_screen_path
	else:
		scene_path = map_path + maps[current_map] + ".tscn"

func change_map():
	get_tree().change_scene(scene_path)
	is_level_select = scene_path == level_select_path
	is_in_game = scene_path.begins_with(map_path) or scene_path.begins_with(win_screen_path)
	TouchScreen.pause.visible = is_in_game
	Pause.set_process_input(true)
	is_note = false
	UI.notes.visible = is_level_select
	UI.notes_label.text = str(notes.size())
	UI.keys(false, false)

### Saving and Loading

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

func create_save():
	save_data = {}
	save_data["map"] = 0
	save_data["notes"] = []
	save_file(save_filename, JSON.print(save_data, "\t"))

func delete_save():
	print("delete save")
	create_save()

func unlock():
	map_save = 99
	save_data["map"] = map_save
	save_file(save_filename, JSON.print(save_data, "\t"))

func win():
	if map_save < current_map + 1:
		map_save = current_map + 1
	
	if is_note and !notes.has(current_map):
		notes.append(current_map)
		notes.sort()
	
	save_data["map"] = map_save
	save_data["notes"] = notes
	
	save_file(save_filename, JSON.print(save_data, "\t"))
	print("map complete, save_data: ", save_data)
	
	set_map(current_map + 1)
	start_reset()

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

### Options

func set_bus_volume(_bus := 1, _vol := 5):
	bus_volume[_bus] = clamp(_vol, 0, 10)
	AudioServer.set_bus_volume_db(_bus, linear2db(bus_volume[_bus] / 10.0))

func set_window_scale(arg := window_scale):
	window_scale = max(1, arg if arg else window_scale)
	if OS.get_name() != "HTML5":
		OS.window_size = Vector2(view_size.x * window_scale, view_size.y * window_scale)
		# center window
		OS.set_window_position(OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5)
	return "window_scale: " + str(window_scale) + " - resolution: " + str(OS.get_window_size())
