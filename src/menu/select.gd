extends Node2D

onready var cam : Camera2D = $Camera2D
onready var cursor_node := $Cursor

var cursor = 0
var current_map := "1-1"

onready var screens : Control = $Control/Screens
var screen : Control
var screen_dist = 105
var columns = 4

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

var load_list := []
var loader : ResourceInteractiveLoader
var port_count = 0

func _ready():
	# make screens
	screen = $Control/Screen.duplicate()
	$Control/Screen.queue_free()
	
	for i in Shared.maps.size():
		if i <= Shared.map_save:
			var new = screen.duplicate()
			var sy = i / columns
			var sx = i % columns
			var map_name = Shared.maps[i]
			
			new.rect_position += Vector2(sx + (sy % 2) * 0.5, sy) * screen_dist
			new.get_node("Overlay/Label").text = map_name
			
			var is_note := Shared.notes.has(map_name)
			new.get_node("Overlay/Notes").visible = is_note
			if is_note:
				new.get_node("Overlay/Notes/Label").text = time_to_string(Shared.notes[map_name])
			
			var is_time := Shared.map_times.has(map_name)
			new.get_node("Overlay/Time").visible = is_time
			if is_time:
				new.get_node("Overlay/Time/Label").text = time_to_string(Shared.map_times[map_name])
			
			var is_death : bool = Shared.deaths.has(map_name) and Shared.deaths[map_name] > 0
			new.get_node("Overlay/Death").visible = is_death
			if is_death:
				new.get_node("Overlay/Death/Label").text = str(Shared.deaths[map_name])
			
			screens.add_child(new)
			overlays.append(new.get_node("Overlay"))
			view_scene(new.get_node("Vis/ViewportContainer/Viewport"), Shared.map_path + Shared.maps[i] + ".tscn")
	
	Leaderboard.connect("new_score", self, "new_score")
	SilentWolf.Scores.connect("sw_scores_received", self, "new_score")
	scroll(Shared.current_map)
	show_scoreboard()
	
	load_list.sort_custom(self, "sort_load_list")

func sort_load_list(a, b):
	if abs(a[0] - cursor) < abs(b[0] - cursor):
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
		open_map()
		Audio.play("menu_pick", 0.9, 1.1)
		is_input = false
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
	
	# load stages
	if loader == null and load_list.size() > 0:
		loader = ResourceLoader.load_interactive(load_list[0][1])
	
	if loader != null:
		var ticks = OS.get_ticks_msec()
		var tick_limit = delta * 77
		
		while OS.get_ticks_msec() < ticks + tick_limit:
			var error = loader.poll()
			if error == ERR_FILE_EOF:
				var map = loader.get_resource().instance()
				loader = null
				load_list.pop_front()[2].add_child(map)
				break
			elif error != OK:
				# failed
				loader = null
				break

# view a scene inside the viewport by path
func view_scene(port, path):
	for i in port.get_children():
		i.queue_free()
		
	load_list.append([port_count, path, port])
	port_count += 1

func scroll(arg = 0):
	overlays[cursor].visible = true
	cursor = clamp(cursor + arg, 0, screens.get_child_count() - 1)
	current_map = Shared.maps[cursor]
	overlays[cursor].visible = !score_node.visible
	var screen_pos = screens.get_children()[cursor].rect_position
	var pos = screen_pos + Vector2(50, 50)
	cam.position = pos
	score_node.rect_position = screen_pos + Vector2(1, 1)
	cursor_node.position = pos
	refresh_score()

func show_scoreboard(arg := show_score):
	var n = arg == 2
	score_title.text = "fastest " + ("note" if n else "run")
	score_note.visible = n
	score_clock.visible = !n
	Shared.is_replay_note = n
	Shared.is_replay = arg == 1
	
	score_node.visible = show_score > 0
	overlays[cursor].visible = !score_node.visible
	refresh_score()

func refresh_score(var map_name : String = current_map):
	if show_score == 0: return
	if show_score == 2: map_name += "-note"
	
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
			t = "LOADING..."
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
	if cursor <= Shared.map_save:
		Shared.set_map(cursor)
		Shared.do_reset()
