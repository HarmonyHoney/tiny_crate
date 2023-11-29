extends Node

onready var node_ghost := $Ghost

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
var map_name := ""
var map_frame := 0
var map_times := {}
var deaths := {}
var replays := {}
var replay := {"frames" : 0, "x" : [], "y": [], "sprite" : []}
var replaying := {}
var is_win := false


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
	load_save()
	
	Wipe.connect("finish", self, "wipe_finish")
	
	# silent wolf
	var api_key = load("silent_wolf_api_key.gd").source_code.strip_edges().replace('"', "")
	SilentWolf.configure({
		"api_key": api_key,
		"game_id": "TinyCrate",
		"game_version": "1.0.0",
		"log_level": 1})

	SilentWolf.configure_scores({"open_scene_on_close": "res://scenes/MainPage.tscn"})
	
	yield(get_tree(), "idle_frame")
#	SilentWolf.Players.post_player_data("player_name", {"1-1" : 23}, false)
	SilentWolf.Scores.persist_score("player_name", 1)

func _physics_process(delta):
	# reset timer
	if is_reset:
		reset_clock -= delta
		if reset_clock < 0:
			do_reset()
	
	if is_in_game:
		# map time
		if !Pause.is_paused:
			map_frame += 1
			
			if replaying.has_all(["frames", "x", "y", "sprite"]) and map_frame < replaying["frames"]:
				var px = node_ghost.position.x
				node_ghost.position.x = replaying["x"][map_frame]
				node_ghost.position.y = replaying["y"][map_frame]
				var nx = node_ghost.position.x
				node_ghost.frame = replaying["sprite"][map_frame]
				
				if px != nx:
					node_ghost.flip_h = nx < px
			else:
				node_ghost.visible = false
			
			if is_instance_valid(player) and !is_win:
				replay["frames"] += 1
				replay["x"].append(player.position.x)
				replay["y"].append(player.position.y)
				replay["sprite"].append(player.node_sprite.frame)

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
	map_name = "" if !is_in_game else scene_path.split("/")[-1].trim_suffix(".tscn")
	is_win = false
	map_frame = 0
	replay = {"frames" : 0, "x" : [], "y" : [], "sprite" : []}
	replaying = {}
	node_ghost.visible = false
	
	Pause.set_process_input(true)
	is_note = false
	UI.notes.visible = is_level_select
	UI.notes_label.text = str(notes.size())
	UI.keys(false, false)
	
	if is_in_game:
		TouchScreen.turn_arrows(false)
		TouchScreen.show_keys(true, true, true, true, true)
		if replays.has(map_name):
			var r = {"frames" : INF}
			for i in replays[map_name]:
				if i.has("frames") and i["frames"] < r["frames"]:
					r = i.duplicate()
			replaying = r
			node_ghost.visible = true
		
	elif is_level_select:
		UI.keys()
		TouchScreen.turn_arrows(false)
		TouchScreen.show_keys()
	elif scene_path == main_menu_path:
		UI.keys(true, true, false)
		TouchScreen.turn_arrows(true)
		TouchScreen.show_keys(true, false, true)
	elif scene_path == options_menu_path:
		UI.keys()
		TouchScreen.turn_arrows(true)
		TouchScreen.show_keys()
	elif scene_path == credits_path:
		UI.keys(false, true)
		TouchScreen.show_keys(false, true, false)

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

func save():
	save_file(save_filename, JSON.print(save_data, "\t"))

func create_save():
	save_data = {}
	save_data["map"] = 0
	save_data["notes"] = []
	save_data["times"] = {}
	save_data["replays"] = {}
	save()

func load_save():
	var l = load_file(save_filename)
	if l:
		save_data = JSON.parse(l).result
		#print("save_data: " + JSON.print(save_data, "\t"))
		if save_data.has("map"):
			map_save = int(save_data["map"])
			if save_data.has("notes"):
				var n = PoolStringArray(save_data["notes"])
				# convert old saves
				for i in n:
					if i.find("-") == -1:
						var m = maps[int(i)]
						if !notes.has(m):
							notes.append(m)
					elif !notes.has(i):
						notes.append(i)
				notes.sort()
				
			if save_data.has("times"):
				map_times = Dictionary(save_data["times"])
			if save_data.has("deaths"):
				deaths = Dictionary(save_data["deaths"])
			if save_data.has("replays"):
				replays = Dictionary(save_data["replays"])
		else:
			create_save()
	else:
		print(save_filename + " not found")
		create_save()

func delete_save():
	print("delete save")
	create_save()

func unlock():
	map_save = 99
	save_data["map"] = map_save
	save()

func win():
	is_win = true
	var ms = map_save
	if map_save < current_map + 1:
		map_save = current_map + 1
	
	if is_note and !notes.has(map_name):
		notes.append(map_name)
		notes.sort()
	
	if !map_times.has(map_name) or (map_times.has(map_name) and (map_frame < map_times[map_name])):
		map_times[map_name] = map_frame
	
	save_data["map"] = map_save
	save_data["notes"] = notes
	save_data["times"] = map_times
	
	if !replays.has(map_name):
		replays[map_name] = []
	replays[map_name].append(replay)
	replays[map_name].sort_custom(self, "sort_replays")
	if replays[map_name].size() > 3:
		replays[map_name].resize(3)
	save_data["replays"] = replays
	
	save()
	print("map complete")#, save_data: ", save_data)
	
	if map_save > ms:
		set_map(current_map + 1)
	else:
		scene_path = level_select_path
	start_reset()

func sort_replays(a, b):
	if a["frames"] < b["frames"]:
		return true
	return false

func die():
	deaths[map_name] = 1 if !deaths.has(map_name) else (deaths[map_name] + 1)
	save_data["deaths"] = deaths
	save()
	print("you died")#, save_data: ", save_data)

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
