extends Node2D

@onready var cam : Camera2D = $Camera2D

var cursor = 0

@onready var screens : Control = $Control/Screens
var screen : Control
var screen_dist = 105
var columns = 4

var is_input := true

@onready var node_audio_scroll : AudioStreamPlayer = $AudioScroll
@onready var node_audio_select : AudioStreamPlayer = $AudioSelect
@onready var node_audio_back : AudioStreamPlayer = $AudioBack

# Called when the node enters the scene tree for the first time.
func _ready():
	Shared.is_level_select = true
	UI.keys()
	
	# make screens
	screen = $Control/Screen.duplicate()
	$Control/Screen.queue_free()
	
	for i in Shared.maps.size():
		if i <= Shared.map_save:
			var new = screen.duplicate()
			var sy = i / columns
			var sx = i % columns
			new.position += Vector2(sx + (sy % 2) * 0.5, sy) * screen_dist
			new.get_node("Label").text = Shared.maps[i]
			new.get_node("Note").visible = Shared.notes.has(i)
			screens.add_child(new)
			view_scene(new.get_node("SubViewportContainer/SubViewport"), Shared.map_path + Shared.maps[i])
	
	scroll(Shared.current_map)

func _input(event):
	if !is_input:
		return
	
	if event.is_action_pressed("action"):
		Shared.wipe_scene(Shared.main_menu_path)
		is_input = false
		node_audio_back.play()
	elif event.is_action_pressed("jump"):
		open_map()
		node_audio_select.play()
		is_input = false
	else:
		var btnx = btn.p("right") - btn.p("left")
		var btny = btn.p("down") - btn.p("up")
		if btnx or btny:
			scroll(btnx + (btny * columns))
			node_audio_scroll.pitch_scale = 1 + randf_range(-0.1, 0.5)
			node_audio_scroll.play()

# view a scene inside the viewport by path
func view_scene(port, path):
	for i in port.get_children():
		i.queue_free()
	
	if ResourceLoader.exists(path + ".tscn"):
		var m = load(path + ".tscn").instantiate()
		port.add_child(m)
		for i in Shared.actors:
			if !i.tag == "exit":
				i.set_physics_process(false) # dont process actors

func scroll(arg = 0):
	cursor = clamp(cursor + arg, 0, screens.get_child_count() - 1)
	cam.position = screens.get_children()[cursor].position + Vector2(50, 50)

func open_map():
	if cursor <= Shared.map_save:
		Shared.set_map(cursor)
		Shared.do_reset()
