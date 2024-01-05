extends Node

onready var node_ghost := $Ghost
onready var node_ghosts := $Ghosts
var ghosts := []
var ghost_count := 3

var node_map_solid : TileMap
var node_camera_game : Camera2D
var obscure_map

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
var creator_path := "res://src/menu/Creator.tscn"

var save_data := {}
var save_filename := "box.save"

var replay_filename := "replay.save"

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
var replaying := []
var is_win := false
var replay_name := ""

var actors := []
var player

var is_note := false
var notes := {}
var is_replay_note := false
var is_replay := false

var username := "crate_kid"
export (Array, Color) var palette := []
var player_colors = [8, 0, 11, 13]
var preset_palettes = [[7, 13, 6, 3], [8, 0, 11, 13], [11, 7, 9, 0], [12, 1, 7, 5], [9, 8, 12, 3]]

func _ready():
	print("Shared._ready(): ")
	randomize()
	
	# create player
	player_colors = preset_palettes[randi() % preset_palettes.size()]
	username = generate_username()
	
	# ghosts
	for i in ghost_count:
		var g = node_ghost.duplicate()
		node_ghosts.add_child(g)
		ghosts.append(g)
	node_ghost.visible = false
	
	# scale window
	window_scale = floor(OS.get_screen_size().x / get_viewport().size.x)
	window_scale = max(1, floor(window_scale * 0.9))
	set_window_scale()
	
	# lower volume
	for i in [1, 2]:
		set_bus_volume(i, 7)
	
	# get world maps
	maps = dir_list(map_path)
	print("maps: ", maps, " ", maps.size())
	
	# load save data
	load_save()
	load_replays()
	
	Wipe.connect("finish", self, "wipe_finish")

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
			
			for i in ghosts.size():
				var g = ghosts[i]
				if i < replaying.size():
					var r = replaying[i]
					if r.has_all(["frames", "x", "y", "sprite"]) and map_frame < r["frames"]:
						var px = g.position.x
						var new_pos = Vector2(r["x"][map_frame], r["y"][map_frame])
						g.position = new_pos
						g.frame = r["sprite"][map_frame]
						
						if px != new_pos.x:
							g.flip_h = new_pos.x < px
					else:
						g.visible = false
			
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
	save()
	if is_win:
		save_replays()
	
	get_tree().change_scene(scene_path)
	is_level_select = scene_path == level_select_path
	is_in_game = scene_path.begins_with(map_path) or scene_path.begins_with(win_screen_path)
	map_name = "" if !is_in_game else scene_path.split("/")[-1].trim_suffix(".tscn")
	is_win = false
	map_frame = 0
	replay = {"frames" : 0, "x" : [], "y" : [], "sprite" : []}
	replaying = []
	for i in ghosts:
		i.visible = false
	
	Pause.set_process_input(true)
	is_note = false
	UI.notes.visible = is_level_select
	UI.notes_label.text = str(notes.size())
	UI.keys(false, false)
	UI.labels("pick", "erase" if scene_path == creator_path else "back", "score" if is_level_select else "menu")
	
	if is_in_game:
		TouchScreen.turn_arrows(false)
		TouchScreen.show_keys(true, true, true, true, true)
		
		if is_replay or is_replay_note:
			var m = map_name + ("-note" if is_replay_note else "")
			is_replay_note = false
			is_replay = false
		
			if replays.has(m):
				replays[m].sort_custom(self, "sort_replays")
				
				for i in min(3, replays[m].size()):
					var r = replays[m][i].duplicate()
					if r.has_all(["frames", "x", "y", "sprite"]):
						replaying.append(r)
						ghosts[i].visible = true
		
	elif is_level_select:
		UI.keys(true, true, true, true)
		TouchScreen.turn_arrows(false)
		TouchScreen.show_keys(true, true, true, true)
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
	elif scene_path == creator_path:
		UI.keys(true, true, false)

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

func save_replays():
	save_file(replay_filename, JSON.print(replays, "\t"))

func create_save():
	save_data = {}
	save_data["map"] = 0
	save_data["notes"] = {}
	save_data["times"] = {}
	save_data["username"] = username
	save_data["player_colors"] = player_colors
	save()

func generate_username():
	var u = ""
	var prefix = "crate box block square rect pack cube stack throw jump jumpin climb thinky brain spike skull pixel puzzle pico"
	var middle = [" ", "_", "-", "."]
	var suffix = "kid dude dood pal friend bud buddy guy gal boy girl homie person human robot cyborg man woman cousin cuz head face butt fart arms legs body hands feet mind"
	var pf : Array = prefix.split(" ", false)
	var sf : Array = suffix.split(" ", false)
	pf.shuffle()
	sf.shuffle()
	var end = middle.duplicate()
	end.append("")
	middle.shuffle()
	end.shuffle()
	var _name = pf[0] + middle[0] + sf[0] + end[0] + str(randi() % 100)
	return _name

func load_save():
	var l = load_file(save_filename)
	if l:
		save_data = JSON.parse(l).result
		
		# remove replays
		if save_data.has("replays"):
			save_data.erase("replays")
			
		#print("save_data: " + JSON.print(save_data, "\t"))
		if save_data.has("map"):
			map_save = int(save_data["map"])
			if save_data.has("notes"):
				var n = save_data["notes"]
				if n is Dictionary:
					notes = n
				# convert old saves
				elif n is Array:
					notes = {}
					for i in n:
						var key = i if (i is String) and ("-" in i) else maps[int(i)]
						notes[key] = 45260
			if save_data.has("times"):
				var d = save_data["times"]
				if d is Dictionary:
					map_times = d
			if save_data.has("deaths"):
				var d = save_data["deaths"]
				if d is Dictionary:
					deaths = d
			if save_data.has("username"):
				username = save_data["username"]
			if save_data.has("player_colors"):
				player_colors = save_data["player_colors"]
		else:
			create_save()
	else:
		print(save_filename + " not found")
		create_save()

func load_replays():
	var l = load_file(replay_filename)
	if l:
		replays = JSON.parse(l).result
	else:
		print(replay_filename + " not found")

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
	
	if is_note and (!notes.has(map_name) or (notes.has(map_name) and map_frame < notes[map_name])):
		notes[map_name] = map_frame
	
	if !map_times.has(map_name) or (map_times.has(map_name) and (map_frame < map_times[map_name])):
		map_times[map_name] = map_frame
	
	save_data["map"] = map_save
	save_data["notes"] = notes
	save_data["times"] = map_times
	save_data["username"] = username
	
	var m = map_name + ("-note" if is_note else "")
	
	if !replays.has(m):
		replays[m] = []
	replays[m].append(replay)
	replays[m].sort_custom(self, "sort_replays")
	if replays[m].size() > 10:
		replays[m].resize(10)
	
	#save()
	print("map complete")#, save_data: ", save_data)
	
	Leaderboard.submit_score(m, -map_frame)
	
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
	#save()
	Leaderboard.submit_score("death", 1)
	Leaderboard.submit_score("death", 1, map_name)
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

func get_all_children(n, a := []):
	if is_instance_valid(n):
		a.append(n)
		for i in n.get_children():
			a = get_all_children(i, a)
	return a
