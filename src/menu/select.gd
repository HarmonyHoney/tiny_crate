extends Node2D

var cam : Camera2D

var cursor = 0

var screens : Control
var screen : Control
var screen_dist = 105
var columns = 4

var wait = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Shared.is_level_select = true
	
	cam = $Camera2D
	
	screens = $Control/Screens
	screen = $Control/Screen.duplicate()
	$Control/Screen.queue_free()
	
	# make screens
	for i in Shared.maps.size():
		if i <= Shared.save_data["map"]:
			var new = screen.duplicate()
			var sy = i / columns
			var sx = i % columns
			new.rect_position += Vector2(sx + (sy % 2) * 0.5, sy) * screen_dist
			#new.rect_position += Vector2(i, 0) * screen_dist
			new.get_node("Label").text = Shared.maps[i]
			screens.add_child(new)
			view_scene(new.get_node("ViewportContainer/Viewport"), Shared.map_path + Shared.maps[i])
	
	scroll(Shared.current_map)

func _process(delta):
	if wait > 0:
		wait -= delta
		if wait < 0:
			HUD.wipe.connect("finish", self, "load_level")
			HUD.wipe.start()
		return
	
	var btnx = btn.p("right") - btn.p("left")
	var btny = btn.p("down") - btn.p("up")
	if btn.p("jump"):
		open_map()
	if btnx or btny:
		scroll(btnx + (btny * columns))

# view a scene inside the viewport by path
func view_scene(port, path):
	for i in port.get_children():
		i.queue_free()
	
	if ResourceLoader.exists(path + ".tscn"):
		var m = load(path + ".tscn").instance()
		port.add_child(m)
		for i in get_tree().get_nodes_in_group("actor"):
			if !i.is_in_group("exit"):
				i.set_process(false) # dont process actors

func scroll(arg = 0):
	cursor = clamp(cursor + arg, 0, screens.get_child_count() - 1)
	cam.position = screens.get_children()[cursor].rect_position + Vector2(50, 50)

func open_map():
	if cursor <= Shared.save_data["map"]:
		Shared.set_map(cursor)
		Shared.do_reset()
