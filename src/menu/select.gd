extends Node2D

var cam : Camera2D

var is_select := false
var cursor = 0
var pick = 0
var picker : Control

var worlds = []
var world_path := "res://src/menu/worlds/"
var screens : Control
var screen : Control
var screen_dist = 150

var levels = []
var level_path := "res://src/map/"
var level_grid : Control
var level : Label


# Called when the node enters the scene tree for the first time.
func _ready():
	cam = $Camera2D
	
	screens = $Control/Screens
	screen = $Control/Screens/Screen.duplicate()
	$Control/Screens/Screen.queue_free()
	
	level_grid = $Control/Levels
	level = $Control/Levels/Level.duplicate()
	$Control/Levels/Level.queue_free()
	
	picker = $Control/Picker
	
	# get world maps
	worlds = dir_list(world_path)
	print("worlds: ", worlds)
	
	# make screens
	for i in worlds.size():
		var new = screen.duplicate()
		new.rect_position.x += i * screen_dist
		new.get_node("Label").text = worlds[i]
		screens.add_child(new)
		view_scene(new.get_node("ViewportContainer/Viewport"), world_path + worlds[i])

func _process(delta):
	var btnx = btn.p("right") - btn.p("left")
	
	if is_select:
		if btn.p("action"):
			close_world()
		if btn.p("jump"):
			Shared.map_name = levels[pick]
			get_tree().change_scene(level_path + levels[pick] + ".tscn")
		if btnx:
			pick_level(btnx)
	else:
		if btn.p("jump"):
			open_world()
		if btnx:
			cursor = clamp(cursor + btnx, 0, worlds.size() - 1)
			cam.position.x = screens.get_children()[cursor].rect_position.x + 50

# view a scene inside the viewport by path
func view_scene(port, path):
	for i in port.get_children():
		i.queue_free()
	
	if ResourceLoader.exists(path + ".tscn"):
		var m = load(path + ".tscn").instance()
		port.add_child(m)
		for i in get_tree().get_nodes_in_group("player"):
			i.set_process(false) # dont process player

func open_world():
	is_select = true
	screens.get_children()[cursor].move_down()
	cam.position.y += 180
	
	# get levels
	levels = dir_list(level_path)
	print("levels: ", levels)
	
	# level grid
	var lvl_pos = Vector2(cam.position.x - 100, cam.position.y - 30)
	for i in levels.size():
		var new = level.duplicate()
		var w = 4
		var py = i / w
		var px = i % w
		new.rect_position.y = lvl_pos.y + py * 20
		new.rect_position.x = lvl_pos.x + px * 20
		new.text = str(i)
		level_grid.add_child(new)
	
	pick = 0
	pick_level()

func close_world():
	is_select = false
	cam.position.y -= 180
	screens.get_children()[cursor].move_back()
	
	for i in level_grid.get_children():
		i.queue_free()
	
	view_scene(screens.get_children()[cursor].get_node("ViewportContainer/Viewport"), world_path + worlds[cursor])

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

func pick_level(arg = 0):
	pick = clamp(pick + arg, 0, levels.size() - 1)
	picker.rect_position = level_grid.get_children()[pick].rect_position
	view_scene(screens.get_children()[cursor].get_node("ViewportContainer/Viewport"), level_path + levels[pick])
