extends Node

onready var node_ghost := $Ghost
onready var node_ghosts := $Ghosts
onready var cam := $Cam

var ghosts := []
var ghost_count := 10

var map_solid : TileMap
var map_obscure : TileMap

var is_quit := false
var is_level_select := false
var is_in_game := false
var is_creator := false
var is_gamepad := false
signal signal_gamepad

var map_dir := "res://src/map/"
var main_menu_path := "res://src/menu/StartMenu.tscn"
var level_select_path := "res://src/menu/select.tscn"
var credits_path := "res://src/menu/credits.tscn"
var splash_path := "res://src/menu/splash.tscn"
var creator_path := "res://src/menu/Creator.tscn"
var scene_path := level_select_path
var scene_last := scene_path

var save_limit = 6
var save_data := {0: {}, 1: {}, 2: {}, 3: {}, 4: {}, 5: {}}
var save_slot := 0
var last_slot = -1
var save_maps := {}
var save_path := "user://save/"
var save_filename := "box.save"
var keys_path := "keys.tres"
var options_path := "options.tres"
var replays := [{}, {}, {}, {}, {}, {}, {}]
var is_save := false
var last_menu := "main"
var last_cursor := 0

var view_size := Vector2(228, 128)
var bus_volume = [10, 10, 10]

var actors := []
var player

var map_dict : Dictionary = load("res://src/stage/sheet.tres").dict

var map_select := 0
var maps := []
var map_name := ""
var map_frame := 0
var replay := {"frames" : 0, "x" : [], "y": [], "sprite" : []}
var replaying := []
var replay_map := ""
var count_gems := 0
var count_notes := 0
var count_die := 0
var count_percent := 0.0
var count_gems_time := 0.0
var count_notes_time := 0.0
var save_clock := 0.0

var is_win := false
var is_note := false
var is_replay := false
var is_replay_note := false
var is_faster := false
var is_faster_note := false

var username := "crate_kid"
export (Array, Color) var palette := []
var player_colors = [8, 0, 11, 13]
var preset_palettes = [[7, 13, 6, 3], [8, 0, 11, 13], [11, 7, 9, 0], [12, 1, 7, 5], [9, 8, 12, 3]]
var last_palette = -1

var time_elapsed := 0
var auto_save_clock := 0
var auto_save_time := 1800
var window_option := 0 setget set_window_option
var background_option := 10 setget set_background_option
signal background_signal

func _ready():
	print("Shared._ready(): ")
	
	# ghosts
	for i in ghost_count:
		var g = node_ghost.duplicate()
		node_ghosts.add_child(g)
		ghosts.append(g)
	node_ghost.visible = false
	
	# lower volume
	for i in [1, 2]:
		set_bus_volume(i, 7)
	
	# make save folders
	var dir = Directory.new()
	if !dir.open(save_path) == OK:
		dir.make_dir(save_path)
	
	for i in save_limit:
		var s = save_path + str(i)
		if !dir.open(s) == OK:
			dir.make_dir(s)
	
	# get all maps
	for i in dir_list(map_dir):
		maps.append(i.split(".")[0])
	
	
	load_options()
	load_slots()
	KeyMenu.default_keys()
	load_keys()
	
	Wipe.connect("finish", self, "wipe_finish")

func _input(event):
	var joy = event is InputEventJoypadButton or event is InputEventJoypadMotion
	if is_gamepad != joy:
		is_gamepad = joy
		emit_signal("signal_gamepad")

func _physics_process(delta):
	time_elapsed += 1
	
	auto_save_clock += 1
	if auto_save_clock > auto_save_time:
		save_options()
		auto_save_clock = 0
	
	
	if is_level_select or is_in_game or is_creator:
		save_clock += 1
	
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

func wipe_scene(arg := scene_path, timer := 0.0):
	if Wipe.is_wipe: return
	if timer > 0.0:
		yield(get_tree().create_timer(timer), "timeout")
		if Wipe.is_wipe: return
	scene_last = scene_path
	scene_path = arg.replace(" ", "")
	Wipe.start()

func wipe_quit():
	is_quit = true
	Wipe.start()

func wipe_finish():
	if is_quit:
		get_tree().quit()
	else:
		change_map()

func change_map():
	count_score()
	if is_save:
		save()
	if is_win:
		save_replays()
	
	get_tree().change_scene_to(load(scene_path))
	
	is_win = false
	is_save = false
	is_level_select = scene_path == level_select_path
	is_creator = scene_path == creator_path
	is_in_game = scene_path.begins_with(map_dir)
	map_name = "" if !is_in_game else scene_path.split("/")[-1].trim_suffix(".tscn")
	map_frame = 0
	replay = {"frames" : 0, "x" : [], "y" : [], "sprite" : []}
	
	setup_ghosts()
	
	is_note = false
	UI.map.visible = is_level_select
	UI.keys(false, false, false, false, false)
	UI.labels("pick", "erase" if scene_path == creator_path else "back", "score" if is_level_select else "pause")
	TouchScreen.set_game(is_in_game)
	
	if !is_level_select:
		is_faster = false
		is_faster_note = false
	
	if is_in_game:
		TouchScreen.show_keys(true, true, true, true)
		UI.show_stats()
		
	elif is_level_select:
		is_replay = false
		is_replay_note = false
		UI.keys(true, true)
		TouchScreen.show_keys(true, true, true, true)
		
		last_menu = "open"
		last_cursor = 0
		
		UI.notes.visible = count_notes > 0
		UI.notes_label.text = str(count_notes)
		UI.gems_label.text = str(count_gems)
		
	elif scene_path == main_menu_path:
		UI.keys(false, false)
		TouchScreen.show_keys()
	elif scene_path == creator_path:
		UI.keys(false, false, true, true, true, true)

func setup_ghosts():
	replaying = []
	for i in ghosts:
		i.visible = false
	
	if  is_in_game and (is_replay or is_replay_note):
		var m = map_name + ("-note" if is_replay_note else "")
	
		if replays[save_slot].has(m):
			replays[save_slot][m].sort_custom(self, "sort_replays")
			
			for i in min(ghost_count, replays[save_slot][m].size()):
				var r = replays[save_slot][m][i].duplicate()
				if r.has_all(["frames", "x", "y", "sprite"]):
					replaying.append(r)
					ghosts[i].visible = true

func time_to_string(arg := 0.0, mod := 60.0):
	var time = arg * (1.0 / max(1.0, mod))
	if time < 60.0:
		return str(time).pad_decimals(2)
	elif time < 3600.0:
		return str(time / 60.0).pad_zeros(2).pad_decimals(0) + ":" + str(fposmod(time, 60.0)).pad_zeros(2).pad_decimals(0)
	else:
		return str(time / 3600.0).pad_decimals(0) + ":" + str(fmod(time / 60.0, 60.0)).pad_zeros(2).pad_decimals(0) + ":" + str(fposmod(time, 60.0)).pad_zeros(2).pad_decimals(0)

### Saving and Loading

func save_file(fname, arg):
	var file = File.new()
	if OK == file.open(str(fname), File.WRITE):
		file.store_string(arg)
		file.close()

func load_file(fname = ""):
	var file = File.new()
	if OK == file.open(str(fname), File.READ):
		var content = file.get_as_text()
		file.close()
		return content

func save():
	var data = {}
	data["clock"] = save_clock
	data["username"] = username
	data["player_colors"] = player_colors
	data["maps"] = save_maps
	
	save_data[save_slot]["username"] = username
	
	save_file(save_path + str(save_slot) + "/" + save_filename, JSON.print(data, "\t"))

func load_slots():
	for i in save_limit:
		load_save(i)
		load_replays(i)

func save_keys(path := keys_path):
	var s_keys = SaveDict.new()
	for a in InputMap.get_actions():
		s_keys.dict[a] = InputMap.get_action_list(a)
	
	ResourceSaver.save(save_path + path, s_keys)

func load_keys(path := keys_path):
	if !ResourceLoader.exists(save_path + path): return
	var r = load(save_path + path)
	
	if r is SaveDict:
		for a in r.dict.keys():
			if InputMap.has_action(a):
				InputMap.action_erase_events(a)
				
				for e in r.dict[a]:
					InputMap.action_add_event(a, e)

func set_window_option(arg := window_option):
	window_option = clamp(arg, 0, 4)
	OS.window_borderless = window_option == 1 or window_option == 2
	OS.window_fullscreen = window_option == 3
	if window_option == 2:
		OS.window_size = OS.get_screen_size()
	
	OS.set_window_position(Vector2.ZERO if window_option == 2 else (OS.get_screen_size() * 0.5 - OS.get_window_size() * 0.5))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if window_option < 3 else Input.MOUSE_MODE_HIDDEN

func set_background_option(arg := background_option):
	background_option = clamp(arg, 0, 10)
	emit_signal("background_signal")

func save_options(path := options_path):
	var data = {}
	data["sfx"] = bus_volume[1]
	data["ost"] = bus_volume[2]
	data["touch"] = int(TouchScreen.is_stay)
	data["full"] = int(OS.window_fullscreen)
	data["view"] = int(window_option)
	var ws = OS.window_size
	data["size"] = str(ws.x) + "," + str(ws.y)
	data["back"] = int(background_option)
	data["time"] = time_elapsed
	
	print("save_options, path: ", path, " time: ", time_elapsed)
	save_file(save_path + options_path, JSON.print(data, "\t"))

func load_options(path := options_path):
	var dict = {}
	var l = load_file(save_path + path)
	if l: dict = JSON.parse(l).result
	
	if !dict.empty():
		if dict.has("sfx"):
			var v = int(dict["sfx"])
			bus_volume[1] = v
			set_bus_volume(1, v)
		if dict.has("ost"):
			var v = int(dict["ost"])
			bus_volume[2] = v
			set_bus_volume(2, v)
		if dict.has("full"):
			set_fullscreen(bool(dict["full"]))
		if dict.has("touch"):
			TouchScreen.is_stay = bool(dict["touch"])
		if dict.has("view"):
			self.window_option = int(dict["view"])
		if dict.has("size"):
			var ws = str(dict["size"]).split_floats(",", false)
			if ws.size() == 2:
				OS.window_size = Vector2(float(ws[0]), float(ws[1]))
				set_window_option()
		if dict.has("back"):
			self.background_option = int(dict["back"])
		if dict.has("time"):
			time_elapsed = abs(int(dict["time"]))

func delete_slot(_slot := save_slot):
	var dir = Directory.new()
	if dir.open(save_path + str(_slot)) == 0:
		dir.list_dir_begin(true, true)
		var fname = dir.get_next()
		while fname != "":
			dir.remove(fname)
			fname = dir.get_next()
		
		replays[_slot] = {}	
		load_save(_slot)

func save_replays(arg := replay_map, _slot := save_slot):
	save_file(save_path + str(_slot) + "/" + arg + ".save", JSON.print(replays[save_slot][arg], "\t"))

func load_save(_slot = save_slot):
	save_slot = clamp(_slot, 0, save_limit - 1)
	var save_string = save_path + str(save_slot) + "/" + save_filename
	
	save_data[save_slot] = {}
	var s = save_data[save_slot]
	
	username = generate_username()
	player_colors = pick_player_colors()
	save_maps = {}
	save_clock = 0.0
	
	var dict := {}
	
	if dict.empty():
		var l = load_file(save_string)
		if l: dict = JSON.parse(l).result
		else: print(save_string + " not found")
	
	print(save_slot, " / ", dict)
	if !dict.empty():
		if dict.has("clock"):
			save_clock = dict["clock"]
		
		if dict.has("username"):
			username = dict["username"]
			s["username"] = username
			
		if dict.has("player_colors"):
			player_colors = dict["player_colors"].duplicate()
			s["player_colors"] = player_colors
		
		if dict.has("maps"):
			save_maps = dict["maps"].duplicate()
			s["maps"] = save_maps
			
			count_score()
			s["gems"] = count_gems
			s["notes"] = count_notes

func load_replays(_slot := save_slot):
	replays[_slot] = {}
	var s = save_path + str(_slot) + "/"
	for i in dir_list(s):
		var l = load_file(s + i)
		if l:
			var p = JSON.parse(l).result
			if p is Array and p[0] is Dictionary and p[0].has("frames"):
				replays[_slot][i.split(".")[0]] = p
		else:
			print(s + i + " not found")

func generate_username():
	var u = ""
	var prefix = "crate box block square rect pack cube stack throw jump jumpin climb thinky brain spike skull pixel puzzle pico"
	var middle = ["!", "_", "-", "."]
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

func unlock():
	print("unlock")

func win():
	is_win = true
	is_save = true
	
	# map
	if !save_maps.has(map_name):
		save_maps[map_name] = {}
	var s = save_maps[map_name]
	
	var hn = s.has("note")
	if is_note and (!hn or(hn and map_frame < s["note"])):
		s["note"] = map_frame
		is_faster_note = true
	
	var ht = s.has("time")
	if !ht or (ht and map_frame < s["time"]):
		s["time"] = map_frame
		is_faster = true
	
	# replays
	var m = map_name + ("-note" if is_note else "")
	replay_map = m
	
	if !replays[save_slot].has(m):
		replays[save_slot][m] = []
	replays[save_slot][m].append(replay)
	replays[save_slot][m].sort_custom(self, "sort_replays")
	if replays[save_slot][m].size() > ghost_count:
		replays[save_slot][m].resize(ghost_count)
	
	print("map complete")
	
	#Leaderboard.submit_score(m, -map_frame)
	
	wipe_scene(level_select_path)

func count_score():
	count_gems = 0
	count_notes = 0
	count_die = 0
	count_notes_time = 0.0
	count_gems_time = 0.0
	
	for i in save_maps.values():
		if i.has("time"):
			count_gems += 1
			count_gems_time += i["time"]
		if i.has("note"):
			count_notes += 1
			count_notes_time += i["note"]
		if i.has("die"): count_die += i["die"]
	
	var f = 36.0
	count_percent = ((count_gems * 0.5) / f) + ((count_notes * 0.5) / f)
	

func sort_replays(a, b):
	if a["frames"] < b["frames"]:
		return true
	return false

func die():
	if !save_maps.has(map_name):
		save_maps[map_name] = {}
	var s = save_maps[map_name]
	if !s.has("die"):
		s["die"] = 1
	else:
		s["die"] += 1
	
	#Leaderboard.submit_score("death", 1)
	#Leaderboard.submit_score("death", 1, map_name)
	print("you died")

func pick_player_colors():
	var s = preset_palettes.size()
	var r = randi() % s
	if r == last_palette:
		r = (r + 1) % s
	
	last_palette = r
	return preset_palettes[r]

# look into a folder and return a list of filenames without file extension
func dir_list(path : String):
	var array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name:
			array.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	array.sort()
	return array

### Options

func set_bus_volume(_bus := 1, _vol := 5):
	bus_volume[_bus] = clamp(_vol, 0, 10)
	AudioServer.set_bus_volume_db(_bus, linear2db(bus_volume[_bus] / 10.0))

func get_all_children(n, a := []):
	if is_instance_valid(n):
		a.append(n)
		for i in n.get_children():
			a = get_all_children(i, a)
	return a

func set_fullscreen(arg := false):
	OS.window_fullscreen = arg
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if arg else Input.MOUSE_MODE_VISIBLE
