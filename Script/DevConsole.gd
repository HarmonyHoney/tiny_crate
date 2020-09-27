extends CanvasLayer

var node_control : Control
var node_log : RichTextLabel
var node_input : LineEdit

var is_open := false

func _ready():
	node_control= $Control
	node_log = $Control/Log
	node_log.clear()
	node_input = $Control/Input
	
	node_control.visible = is_open
	out("untitled project by Harmony Monroe")
	out("developer console initialized")

func _process(delta):
	if btn.p("dev_console"):
		close() if is_open else open()
	
	if btn.p("ui_cancel"):
		close()

func open():
	is_open = true
	node_control.visible = true
	node_input.grab_focus()
	
func close():
	is_open = false
	node_control.visible = false
	node_input.clear()

# always grab focus when typing
func _input(event):
	if event is InputEventKey and event.pressed:
		node_input.grab_focus()

# signal when pressing enter
func _on_Input_text_entered(new_text):
	if not is_open:
		return
	
	var method = new_text.split(" ")[0]
	var args = new_text.substr(method.length() + 1)
	if has_method(method):
		if args:
			call(method, args)
		else:
			call(method)
	else:
		out("can't find: " + method)
	
	node_input.clear()

func out(arg = ""):
	node_log.text += arg + "\n"
	print("dev.out: ", arg)

func clear():
	node_log.clear()

func quit():
	out("bye bye")
	get_tree().quit()

func reset():
	out("reset scene")
	get_tree().reload_current_scene()

func map(arg = "map0"):
	if get_tree().change_scene("res://Map/" + arg + ".tscn"):
		out("error loading map: " + "res://Map/" + arg + ".tscn")
	else:
		out("loading map: " + "res://Map/" + arg + ".tscn")

func box():
	for i in get_tree().get_nodes_in_group("player"):
		i.debug_box()

func winscale(arg = 0):
	if int(arg) == 0:
		Shared.set_window_scale()
	else:
		Shared.set_window_scale(int(arg))

func kill():
	for i in get_tree().get_nodes_in_group("player"):
		i.death()
