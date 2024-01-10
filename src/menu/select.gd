extends Node2D

onready var cam : Camera2D = $Camera2D
onready var cursor_node := $Cursor

var cursor = 0
var current_map := "1-1"

onready var screens_node : Control = $Control/Screens
onready var screen : Control = $Control/Screen
var screens := []
export var screen_dist = Vector2(5, 5)
export var screen_size = Vector2(136, 104)
export var columns = 8
var screen_pos := []
var screen_static := []
var screen_max := 1

var overlays := []

var is_input := true
var input_count := 0
var input_wait := 3
var show_score := 0
var last_refresh := {}
var refresh_wait := 5.0

onready var score_node := $Control/Scores
onready var score_title := $Control/Scores/HBoxContainer/Title
onready var score_list := $Control/Scores/List
onready var score_note := $Control/Scores/HBoxContainer/Note
onready var score_clock := $Control/Scores/HBoxContainer/Clock
onready var score_map := $Control/Scores/HBoxContainer/Map

var load_list := []
var loader : ResourceInteractiveLoader
var port_count = 0
var is_load := false
var is_screening := false
var map_limit := 0
var screen_list := []
export var timeout_mod := 1.0

var screen_time := 0.0
var loading_time := 0.0

export var color_gem := Color("ffec27")
export var color_new := Color("83769c")

var map_lock := {}
var map_list := []
var map_rows := []
var map_unlocked := []
export(String, MULTILINE) var lock_string := ""


func _ready():
	Leaderboard.connect("new_score", self, "new_score")
	SilentWolf.Scores.connect("sw_scores_received", self, "new_score")
	
	# setup maps & locks
	for i in lock_string.split("\n"):
		var s : Array = i.split(" ")
		var c = int(s.pop_front())
		map_rows.append(s)
		for x in s:
			map_lock[x] = c
			map_list.append(x)
			if c - 1 < Shared.count_gems:
				map_unlocked.append(x)
	print("map_lock: ", map_lock)
	print("map_rows: ", map_rows)
	
	screen.rect_position -= Vector2.ONE * 500
	
	# make screens
	screen_pos = []
	var sum = -1
	for y in map_rows.size():
		for x in map_rows[y].size():
			screen_pos.append((Vector2(x + (y % 2) * 0.5, y) * (screen_size + screen_dist)))
			sum += 1
			screen_list.append(sum)
	screen_max = max(0, screen_pos.size() - 1)
	
	scroll(Shared.map_select)
	cam.reset_smoothing()
	
	screen_list.sort_custom(self, "sort_list")
	is_screening = true
	
	show_scoreboard()

func sort_list(a, b):
	if abs(a - cursor) < abs(b - cursor):
		return true
	return false

func _input(event):
	if !is_input:
		return
	
	if event.is_action_pressed("action"):
		Shared.wipe_scene(Shared.main_menu_path)
		is_input = false
		Audio.play("menu_back", 0.9, 1.1)
	elif event.is_action_pressed("jump"):
		if open_map():
			Audio.play("menu_pick", 0.9, 1.1)
			is_input = false
			is_load = false
		else:
			Audio.play("menu_random", 0.8, 1.2)
	elif event.is_action_pressed("pause"):
		show_score = posmod(show_score + 1, 3)
		print("show_score: ", show_score)
		show_scoreboard()
	else:
		var btnx = btn.p("right") - btn.p("left")
		var btny = btn.p("down") - btn.p("up")
		if input_count == 0 and (btnx or btny):
			input_count = input_wait
			scroll(btnx + (btny * columns))
			Audio.play("menu_scroll3", 0.9, 1.5)

func _physics_process(delta):
	input_count = max(0, input_count - 1)
	for i in last_refresh.keys():
		last_refresh[i] = max(0, last_refresh[i] - delta)
	
	var ticks : float = OS.get_ticks_msec()
	
	if is_screening:
		screen_time += delta
		
		while OS.get_ticks_msec() < ticks + (delta * timeout_mod):
			if screen_list.size() > 0:
				make_screen(screen_list.pop_front())
			else:
				is_screening = false
				is_load = true
				print(screen_time, " screeening time")
				break
	
	# load stages
	elif is_load:
		loading_time += delta
		
		while OS.get_ticks_msec() < ticks + (delta * timeout_mod):
			if load_list.size() > 0:
				var pop = load_list.pop_front()
				pop[2].add_child(Shared.scene_dict[pop[1]].instance())
				screen_static[pop[0]].visible = false
			else:
				is_load = false
				print(loading_time, " loading time")
				break

func make_screen(i := 0):
	var new = screen.duplicate()
	var map_name = map_list[i]
	var is_locked = Shared.count_gems < map_lock[map_name]
	
	new.rect_position = screen_pos[i]
	new.get_node("Overlay/HBox/Label").text = (str(map_lock[map_name]) + " to unlock") if is_locked else map_name
	new.get_node("Overlay/HBox/Gem").visible = is_locked
	
	var s = {}
	if Shared.save_maps.has(map_name):
		s = Shared.save_maps[map_name]
	
	var has_note = s.has("note")
	new.get_node("Overlay/Notes").visible = has_note
	if has_note:
		new.get_node("Overlay/Notes/Label").text = time_to_string(s["note"])
	
	var has_time = s.has("time")
	new.get_node("Overlay/Time").visible = has_time
	var gem = new.get_node("Overlay/Gem")
	gem.modulate = color_gem if has_time else color_new
	gem.visible = !is_locked
	if has_time:
		new.get_node("Overlay/Time/Label").text = time_to_string(s["time"])
	
	var has_die = s.has("die")
	new.get_node("Overlay/Death").visible = has_die
	if has_die:
		new.get_node("Overlay/Death/Label").text = str(s["die"])
	
	screens_node.add_child(new)
	screens.append(new)
	overlays.append(new.get_node("Overlay"))
	screen_static.append(new.get_node("Vis/Static"))
	view_scene(new.get_node("Vis/ViewportContainer/Viewport"), Shared.map_dir + map_list[i] + ".tscn", i)

# view a scene inside the viewport by path
func view_scene(port, path, arg):
	for i in port.get_children():
		i.queue_free()
	
	load_list.append([port_count, path, port])
	port_count += 1

func scroll(arg = 0):
	var o = cursor < overlays.size()
	if o: overlays[cursor].visible = true
	
	cursor = clamp(cursor + arg, 0, screen_max)
	current_map = map_list[cursor]
	
	if o: overlays[cursor].visible = !score_node.visible
	
	var sp = screen_pos[cursor]
	cursor_node.rect_position = sp
	score_node.rect_position = sp + Vector2(1, 1)
	cam.position = sp + (screen_size * 0.5)
	refresh_score()

func show_scoreboard(arg := show_score):
	var n = arg == 2
	score_title.text = "fastest " + ("note" if n else "run")
	score_note.visible = n
	score_clock.visible = !n
	Shared.is_replay_note = n
	Shared.is_replay = arg == 1
	
	score_node.visible = show_score > 0
	if cursor < overlays.size():
		overlays[cursor].visible = !score_node.visible
	refresh_score()

func refresh_score(var map_name : String = current_map):
	if show_score == 0: return
	if show_score == 2: map_name += "-note"
	
	score_map.text = current_map
	write_score()
	
	if !last_refresh.has(map_name) or last_refresh[map_name] == 0:
		Leaderboard.refresh_score(map_name)
		print(map_name, " FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH FRESH ")
		last_refresh[map_name] = refresh_wait

func new_score(arg1 = null, arg2 = null, arg3 = null):
	write_score()

func write_score():
	var map_name = current_map + ("-note" if show_score == 2 else "")
	var t = ""
	var count = 0
	if Leaderboard.is_online:
		if Leaderboard.scores.has(map_name):
			var s = Leaderboard.scores[map_name]
			if s.empty():
				t = "no data!"
			else:
				for i in s:
					t += time_to_string(-int(i["score"])) + " " + str(i["player_name"]) + "\n"
					count += 1
					if count > 9 : break
		else:
			t = "loading..."
	else:
		if Shared.replays.has(map_name):
			for i in Shared.replays[map_name]:
				if i.has("frames"):
					t += time_to_string(int(i["frames"])) + "\n"
					count += 1
					if count > 9 : break
		else:
			t = "NO DATA!"
	
	score_list.text = t

func time_to_string(arg := 0.0):
	var time = arg * (1.0/60.0)
	if time < 60.0:
		return str(time).pad_decimals(2)
	else:
		return str(time / 60.0).pad_zeros(2).pad_decimals(0) + ":" + str(fposmod(time, 60.0)).pad_zeros(2).pad_decimals(0)

func open_map():
	if current_map in map_unlocked:
		Shared.map_select = cursor
		Shared.wipe_scene(Shared.map_dir + current_map + ".tscn")
		return true
	return false
