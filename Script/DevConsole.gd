extends CanvasLayer

var node_control : Control
var node_log : RichTextLabel
var node_input : LineEdit

var is_open := false
var last_text = ""

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

# always grab focus when typing
func _input(event):
	if is_open:
		if event is InputEventKey and event.pressed:
			node_input.grab_focus()
			# press up
			if event.scancode == KEY_UP:
				node_input.text = last_text

# signal when pressing enter
# solve input string and call method
func _on_Input_text_entered(new_text):
	node_input.clear()
	last_text = new_text
	if not is_open:
		return
	if new_text.begins_with("_"):
		out("error: '_' in '" + new_text + "' - private methods disabled")
		return
	
	var method = new_text.split(" ")[0]
	var arg = new_text.substr(method.length() + 1)
	if has_method(method):
			call(method, arg)
	else:
		out("can't find: " + method)

#open console
func open(arg = null):
	is_open = true
	node_control.visible = true
	node_input.grab_focus()

# close console
func close(arg = null):
	is_open = false
	node_control.visible = false
	node_input.clear()

# print to console
func out(arg = "", newline = true):
	node_log.text += str(arg) + ("\n" if newline else "")
	print("dev.out: ", arg)

# clear console
func clear(arg = null):
	node_log.clear()

# quit game
func quit(arg = null):
	out("(quit) bye bye")
	get_tree().quit()

# reset scene
func reset(arg = null):
	get_tree().reload_current_scene()
	out("(reset) '" + str(get_tree().current_scene.filename) + "' loaded")

# load map scene by name
func map(arg = "map0"):
	if get_tree().change_scene("res://Map/" + arg + ".tscn"):
		out("(map) error loading '" + arg + "' from " + "res://Map/" + arg + ".tscn")
	else:
		out("(map) loaded '" + arg + "' from: " + "res://Map/" + arg + ".tscn")

# spawn box at Vector2 coordinates
func box(arg := ""):
	var pos = null
	if arg.split(" ").size() > 1:
		pos = Vector2(int(arg.split(" ")[0]), int(arg.split(" ")[1]))
	for i in get_tree().get_nodes_in_group("player"):
		i.debug_box(pos)

# set window scale
func winscale(arg = 0):
	out("(winscale) " +  str(Shared.set_window_scale(int(arg))))

# kill player
func kill(arg = null):
	out("(kill) ", false)
	for i in get_tree().get_nodes_in_group("player"):
		i.death()

# show help text
func help(arg = null):
	var s = []
	for m in get_script().get_script_method_list():
		if not m.name.begins_with("_"):
			s.append(m.name)
	s.sort()
	out("(help) methods: " + str(s))

# list nodes in group, actor by default
func list(arg = null):
	arg = arg if arg else "actor"
	var l = []
	for a in get_tree().get_nodes_in_group(arg):
		l.append(a.name)
	out("(list) " + str(l.size()) + " " + str(arg) + " nodes: " + str(l))

# set a variable from an actor by actor_name variable_name and value
func setvar(arg := ""):
	var split = arg.split(" ")
	if split.size() > 2:
		var _name = split[0]
		var _var = split[1]
		var _val = split[2]
		
		for a in get_tree().get_nodes_in_group("actor"):
			if a.name.to_lower() == _name.to_lower():
				a.set(_var, str2var(_val))
				out("(setvar) " + str(a.name) + "." + str(_var) + " = " + str(a.get(_var)))
				return
		
		out("(setvar) " + str(_name) + " not found")
	else:
		out("(setvar) '" + arg + "' invalid syntax. use 'setvar <name> <var> <val>'")

# get a variable from an actor by actor_name and variable_name
func getvar(arg := ""):
	var split = arg.split(" ")
	if split.size() > 1:
		var _name = split[0]
		var _var = split[1]
		
		for a in get_tree().get_nodes_in_group("actor"):
			if a.name.to_lower() == _name.to_lower():
				out("(getvar) " + str(a.name) + "." + str(_var) + " = " + str(a.get(_var)))
				return
		
		out("(getvar) " + str(_name) + " not found")
	else:
		out("(getvar) '" + arg + "' invalid syntax. use 'getvar <name> <var>'")

