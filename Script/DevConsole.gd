extends CanvasLayer

var node_control : Control
var node_log : RichTextLabel
var node_input : LineEdit
var node_hint : RichTextLabel

var is_open := false
var last_text = ""

var is_draw_collider := false

func _ready():
	node_control= $Control
	node_log = $Control/Log
	node_log.clear()
	node_input = $Control/Input
	node_hint = $Control/Hint
	
	node_control.visible = is_open
	out("untitled project by Harmony Monroe")
	out("developer console initialized")

func _process(delta):
	if btn.p("dev_console"):
		close() if is_open else open()
	
	if btn.p("ui_cancel"):
		close()


func _input(event):
	if is_open:
		if event is InputEventKey and event.pressed:
			if node_input.has_focus():
				# press up
				if event.scancode == KEY_UP:
					node_input.text = last_text
			else:
				# always grab focus when typing
				node_input.grab_focus()
				node_input.caret_position = 999

# signal when pressing enter
# solve input string and call method
func _on_Input_text_entered(new_text):
	if new_text == "":
		return
	node_input.clear()
	last_text = new_text
	if not is_open:
		return
	
	var method = new_text.split(" ")[0].to_lower()
	var arg = new_text.substr(method.length() + 1)
	if not _call(method, arg):
		out("can't find: " + method)

func _on_Input_text_changed(new_text):
	if new_text == "":
		node_hint.text = ""
	else:
		var l = []
		node_hint.text = ""
		for c in _get_cmd_list():
			if c.begins_with(new_text.to_lower()):
				l.append(c)
		l = str(l)
		l.erase(0, 1)
		l.erase(l.length() - 1, 1)
		node_hint.text = l

func _call(method := "", arg := ""):
	if _get_cmd_list().has(method):
		call(method, arg)
		return true
	else:
		return false

func _set(_var := "", _val := ""):
	if _get_var_list().has(_var):
		set(_var, str2var(_val))
		return true
	else:
		return false

func _get_cmd_list():
	var s = []
	for m in get_script().get_script_method_list():
		if not m.name.begins_with("_"):
			s.append(m.name)
	s.sort()
	return s

func _get_var_list():
	var s = []
	for m in get_script().get_script_property_list():
		if not m.name.begins_with("_"):
			s.append(m.name)
	return s

# show help text
func help(arg = null):
	out("(help)")
	out(" - methods: " + str(_get_cmd_list()))
	out(" - properties: " + str(_get_var_list()))

# set a local var
func cset(arg := ""):
	var split = arg.split(" ")
	if split.size() > 1:
		var _var = split[0]
		var _val = split[1]
		if _set(_var, _val):
			out("(cset) " + _var + " = " + str(get(_var)))
		else:
			out("(cset) '" + str(_var) + "' not found.")
		
	else:
		out("(cset) '" + arg + "' invalid syntax. use 'cset <var> <val>'")

# get a local var
func cget(arg := ""):
	if _get_var_list().has(arg):
		out("(cget) " + arg + " = " + str(get(arg)))
	else:
		out("(cget) '" + arg + "' not found")

# open console
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

# list nodes in group, actor by default
func list(arg = null):
	arg = arg if arg else "actor"
	var l = []
	for a in get_tree().get_nodes_in_group(arg):
		l.append(a.name)
	out("(list) " + str(l.size()) + " " + str(arg) + " nodes: " + str(l))

# set an actor variable by actor_name, variable_name and value
func aset(arg := ""):
	var split = arg.split(" ")
	if split.size() > 2:
		var _name = split[0]
		var _var = split[1]
		var _val = split[2]
		
		for a in get_tree().get_nodes_in_group("actor"):
			if a.name.to_lower() == _name.to_lower():
				a.set(_var, str2var(_val))
				out("(aset) " + str(a.name) + "." + str(_var) + " = " + str(a.get(_var)))
				return
		
		out("(aset) " + str(_name) + " not found")
	else:
		out("(aset) '" + arg + "' invalid syntax. use 'aset <name> <var> <val>'")

# get an actor variable by actor_name and variable_name
func aget(arg := ""):
	var split = arg.split(" ")
	if split.size() > 1:
		var _name = split[0]
		var _var = split[1]
		
		for a in get_tree().get_nodes_in_group("actor"):
			if a.name.to_lower() == _name.to_lower():
				out("(aget) " + str(a.name) + "." + str(_var) + " = " + str(a.get(_var)))
				return
		
		out("(aget) " + str(_name) + " not found")
	else:
		out("(aget) '" + arg + "' invalid syntax. use 'aget <name> <var>'")

# set an actor position by actor_name, x and y
func apos(arg := ""):
	var split = arg.split(" ")
	if split.size() > 2:
		var _name = split[0]
		var _x = split[1]
		var _y = split[2]
		
		for a in get_tree().get_nodes_in_group("actor"):
			if a.name.to_lower() == _name.to_lower():
				a.position = Vector2(_x, _y)
				out("(apos) " + str(a.name) + ".position = " + str(a.position))
				return
		
		out("(apos) " + str(_name) + " not found")
	else:
		out("(apos) '" + arg + "' invalid syntax. use 'apos <name> <x> <y>'")



