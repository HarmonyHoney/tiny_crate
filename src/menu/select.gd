extends Node2D
var map_path := "res://src/menu/worlds/"
#var map = "world-2"


var screen : Control
var screens : Control
var cam : Camera2D
var label : Label

var maps = []

var cursor = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screens = $Control/Screens
	cam = $Camera2D
	
	screen = $Control/Screens/Screen.duplicate()
	$Control/Screens/Screen.queue_free()
	
	label = $Control/Label
	
	maps = []
	var dir = Directory.new()
	if dir.open(map_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name:
			print(file_name.split(".")[0])
			maps.append(file_name.split(".")[0])
			file_name = dir.get_next()
		dir.list_dir_end()
	
	for i in maps.size():
		var new = screen.duplicate()
		new.rect_position.x += i * 120
		new.get_node("Label").text = maps[i]
		screens.add_child(new)
		view_map(new.get_node("ViewportContainer/Viewport"), maps[i])

func _process(delta):
	var btnx = btn.p("right") - btn.p("left")
	if btnx:
		cursor = clamp(cursor + btnx, 0, maps.size() - 1)
		cam.position.x = 160 + cursor * 120
		#label.text = maps[cursor]
		#label.rect_position.x = 140 + cursor * 120

func view_map(port, map):
	for i in port.get_children():
		i.queue_free()
	
	if ResourceLoader.exists(map_path + map + ".tscn"):
		var m = load(map_path + map + ".tscn").instance()
		port.add_child(m)
		for i in get_tree().get_nodes_in_group("player"):
			i.set_process(false) # dont process player




