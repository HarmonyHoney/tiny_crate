extends Node2D

onready var cam : Camera2D = Shared.cam
onready var cursor_node := $Cursor
onready var player := $"%Player"
onready var exit := $"%Exit"

var cursor = 0
var current_map := "1-1"

onready var screens_node : Control = $Control/Screens
onready var screen : Control = $Control/Screen
export var screen_dist = Vector2(5, 5)
export var screen_size = Vector2(136, 96)
var screen_pos := []
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
onready var score_row := $Control/Scores/Row

var is_screening := false
var screen_list := []
export var timeout_mod := 1.0
var screen_time := 0.0

export var color_gem := Color("ffec27")
export var color_new := Color("83769c")

var map_lock := {}
var map_list := []
var map_rows := []
var map_unlocked := []
var map_vector = {}
var is_faster = false
var is_faster_note = false

var blink_label

export var blink_on := 0.3
export var blink_off := 0.2
var blink_clock := 0.0
var blink_count = 10

var lockdict= {0:["1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8"],
6 : ['2-1', '2-2', '2-3', '2-4', '2-5', '2-6', '2-7', '2-8'],
12: ['3-1', '3-2', '3-3', '3-4', '3-5', '3-6', '3-7', '3-8'],
18: ['4-1', '4-2', '4-3', '4-4', '4-5', '4-6', '4-7', '4-8'],
24: ['5-1', '5-2', '5-3', '5-4'],
30: ['win']}

func _ready():
	#Leaderboard.connect("new_score", self, "new_score")
	#SilentWolf.Scores.connect("sw_scores_received", self, "new_score")
	
	is_faster_note = Shared.is_faster_note
	is_faster = is_faster_note or Shared.is_faster
	print("is_faster: ", is_faster, ", is_faster_note: ", is_faster_note)
#	if is_faster:
#		Audio.play("menu_bell", 0.8, 1.2)
	
	# setup maps & locks
	for i in lockdict.keys():
		var s = lockdict[i]
		map_rows.append(s)
		for x in s:
			map_lock[x] = i
			map_list.append(x)
			if i - 1 < Shared.count_gems:
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
			var v = Vector2(x, y)
			map_vector[v] = sum
			map_vector[sum] = v
	screen_max = max(0, screen_pos.size() - 1)
	overlays.resize(screen_pos.size())
	
	scroll(Shared.map_select)
	cam.set_pos(cam.pos_target)
	
	screen_list.sort_custom(self, "sort_list")
	is_screening = true
	
	show_scoreboard()

func sort_list(a, b):
	if abs(a - cursor) < abs(b - cursor):
		return true
	return false

func _input(event):
	if !is_input or Wipe.is_wipe:
		return
	
	if event.is_action_pressed("ui_no"):
		Shared.wipe_scene(Shared.main_menu_path)
		is_input = false
		Shared.is_save = true
		Audio.play("menu_back", 0.9, 1.1)
	elif event.is_action_pressed("ui_yes"):
		if open_map():
			Audio.play("menu_pick", 0.9, 1.1)
			is_input = false
		else:
			Audio.play("menu_random", 0.8, 1.2)
	elif event.is_action_pressed("ui_pause"):
		show_score = posmod(show_score + 1, 3)
		print("show_score: ", show_score)
		show_scoreboard()
		Audio.play("menu_options", 0.7, 1.3)
	else:
		var btnx = btn.p("ui_right") - btn.p("ui_left")
		var btny = btn.p("ui_down") - btn.p("ui_up")
		if input_count == 0 and (btnx or btny):
			input_count = input_wait
			if btnx:
				scroll(cursor + btnx)
			else:
				var v = map_vector[cursor]
				v.y = clamp(v.y + btny, 0, map_rows.size() - 1)
				v.x = clamp(v.x, 0, map_rows[v.y].size() - 1)
				scroll(map_vector[v])
			
			Audio.play("menu_scroll3", 0.9, 1.5)

func _physics_process(delta):
	input_count = max(0, input_count - 1)
	for i in last_refresh.keys():
		last_refresh[i] = max(0, last_refresh[i] - delta)
	
	if is_instance_valid(blink_label) and blink_count > 0:
		blink_clock -= delta
		if blink_clock < -blink_off:
			blink_clock = blink_on
			blink_count -= 1
		blink_label.modulate = [Color.transparent, Color.white][int(blink_clock > 0.0)]
	
	var ticks : float = OS.get_ticks_msec()
	
	if is_screening:
		screen_time += delta
		
		while OS.get_ticks_msec() < ticks + (delta * timeout_mod):
			if screen_list.size() > 0:
				make_screen(screen_list.pop_front())
			else:
				is_screening = false
				print(screen_time, " screeening time")
				break

func make_screen(i := 0):
	var new = screen.duplicate()
	var map_name = map_list[i]
	var is_locked = Shared.count_gems < map_lock[map_name]
	
	new.rect_position = screen_pos[i]
	new.get_node("Vis/Overlay/HBox/Label").text = (str(map_lock[map_name]) + " to unlock") if is_locked else map_name
	new.get_node("Vis/Overlay/HBox/Gem").visible = is_locked
	
	var s = {}
	if Shared.save_maps.has(map_name):
		s = Shared.save_maps[map_name]
	
	var has_note = s.has("note")
	new.get_node("Vis/Overlay/Notes").visible = has_note
	var note_label = new.get_node("Vis/Overlay/Notes/Label")
	if has_note:
		note_label.text = Shared.time_to_string(s["note"])
	
	var gem = new.get_node("Vis/Overlay/Gem")
	gem.visible = !is_locked
	var has_time = s.has("time")
	
	gem.get_node("Sprite").modulate = color_gem if has_time else color_new
	var gem_label = gem.get_node("Label")
	gem_label.visible = has_time
	if has_time:
		gem_label.text = Shared.time_to_string(s["time"])
	
	var has_die = s.has("die")
	new.get_node("Vis/Overlay/Death").visible = has_die
	if has_die:
		new.get_node("Vis/Overlay/Death/Label").text = str(s["die"])
	
	if is_faster and i == Shared.map_select:
		blink_label = note_label if is_faster_note else gem_label
		print("faster ", i, ", blink_label ", blink_label)
		Audio.play("menu_bell", 0.5, 1.0)
	
	var sprite = new.get_node("Vis/Sprite")
	var dict = Shared.map_dict[map_name]
	sprite.region_rect = Rect2(screen_size * Vector2(dict[0], dict[1]), screen_size)
	
	screens_node.add_child(new)
	overlays[i] = new.get_node("Vis/Overlay")

func scroll(arg := cursor):
	if overlays[cursor]: overlays[cursor].visible = true
	
	cursor = clamp(arg, 0, screen_max)
	current_map = map_list[cursor]
	
	if overlays[cursor]: overlays[cursor].visible = !score_node.visible
	
	var sp = screen_pos[cursor]
	cursor_node.rect_position = sp
	score_node.rect_position = sp + Vector2(1, 1)
	var half = sp + (screen_size * 0.5)
	cam.pos_target = half
	refresh_score()
	
	var dict = Shared.map_dict[str(map_list[cursor])]
	
	player.position = Vector2(dict[2], dict[3])
	player.node_sprite.flip_h = randf() > 0.5
	exit.position = Vector2(dict[4], dict[5])
	

func show_scoreboard(arg := show_score):
	var n = arg == 2
	score_title.text = "fastest " + ("note" if n else "run")
	score_note.visible = n
	score_clock.visible = !n
	Shared.is_replay_note = n
	Shared.is_replay = arg == 1
	
	score_node.visible = show_score > 0
	if overlays[cursor]: overlays[cursor].visible = !score_node.visible
	refresh_score()

func refresh_score(var map_name : String = current_map):
	if show_score == 0: return
	if show_score == 2: map_name += "-note"
	
	score_map.text = current_map
	write_score()
	
	if !last_refresh.has(map_name) or last_refresh[map_name] == 0:
		#Leaderboard.refresh_score(map_name)
		print("   -   ", map_name, " REFRESH SCORE ")
		last_refresh[map_name] = refresh_wait

func new_score(arg1 = null, arg2 = null, arg3 = null):
	write_score()

func write_score():
	var key = "note" if show_score == 2 else "time"
	var dat = Shared.save_data
	var dict = {}
	
	for i in dat.keys():
		if dat[i].has_all(["username", "maps"]) and dat[i]["maps"].has(current_map) and dat[i]["maps"][current_map].has(key):
			dict[int(dat[i]["maps"][current_map][key])] = dat[i]["username"]
	
	var t = ""
	var keys = dict.keys()
	var row = 0
	var my_row = -1
	
	keys.sort()
	for i in keys:
		t += Shared.time_to_string(i) + " " + dict[i] + "\n"
		
		if dict[i] == Shared.username:
			my_row = row
		
		row += 1
	
	score_row.visible = my_row > -1
	score_row.rect_position.y = (score_list.rect_position.y - 2) + (my_row * 8)
	
	if t == "":
		t = "NO DATA !"
	
	score_list.text = t

func open_map():
	if current_map in map_unlocked:
		Shared.map_select = cursor
		Shared.wipe_scene(Shared.map_dir + current_map + ".tscn")
		return true
	return false
