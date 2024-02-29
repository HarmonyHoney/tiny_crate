extends Menu

var default_keys := {}

export var is_gamepad := false

export var popup_path : NodePath = ""
onready var popup := get_node_or_null(popup_path)
var is_rebind := false

export var row_path : NodePath = ""
onready var row_dupe := get_node_or_null(row_path).duplicate()
export var label_path : NodePath = ""
onready var label_dupe := get_node_or_null(label_path).duplicate()
export var header_path : NodePath = ""
onready var header_node := get_node_or_null(header_path)

var actions := []

export var keys_action := {
"h_game" : "gameplay",
"jump" : "jump",
"action" : "lift",
"up" : "up",
"down" : "down",
"left" : "left",
"right": "right",

"h_menu" : "menu",
"ui_pause": "pause",
"ui_yes" : "yes",
"ui_no" : "no",
"ui_up" : "up",
"ui_down" : "down",
"ui_left" : "left",
"ui_right" : "right",
"ui_del" : "unbind key",

"b_reset" : "reset to defaults",
}

signal refresh

func _ready():
	for i in [row_path, label_path]:
		get_node(i).queue_free()
	
	popup.visible = false
	
	# setup list
	list = []
	for i in keys_action.keys():
		var h = i.begins_with("h_")
		var b = i.begins_with("b_")
		if h or b:
			var d = label_dupe.duplicate()
			d.text = keys_action[i]
			list_node.add_child(d)
			if b:
				list.append(d)
		elif InputMap.has_action(i):
			var r = row_dupe.duplicate()
			r.get_node("Label").text = keys_action[i]
			list_node.add_child(r)
			list.append(r)
			actions.append(i)
			
			fill_row(r, i)
	
	set_cursor()

func menu_input(event):
	if !is_open or Wipe.is_wipe: return
	
	var is_del : bool = event.is_action_pressed("ui_del")
	var is_no : bool = event.is_action_pressed("ui_no")
	var is_yes : bool = event.is_action_pressed("ui_yes")
	var btny = btn.p("ui_down") - btn.p("ui_up")
	
	
	if is_rebind:
		if is_del:
			is_rebind = false
			popup.visible = false
			ui_keys()
		elif event.is_pressed() and !event.is_echo() and Key.is_type(event, is_gamepad) and !is_del:
			assign_key(actions[cursor], event)
			is_rebind = false
			ui_keys()
			popup.visible = false
			get_tree().set_input_as_handled()
	else:
		var is_action = cursor < actions.size()
		
		if is_del:
			if is_action:
				clear_action()
			Audio.play("menu_scroll", 0.8, 1.2)
		elif is_no:
			open(false)
			btn_no()
		elif is_yes:
			if is_action:
				popup.visible = true
				is_rebind = true
				ui_keys()
			else:
				reset_to_defaults()
		elif btny != 0:
			self.cursor += btny
			Audio.play("menu_scroll", 0.8, 1.2)


func ui_keys():
	UI.keys(true, false, !is_rebind, !is_rebind, !is_rebind, false, true)

func on_open():
	if is_open:
		ui_keys()
		UI.labels()
		if is_instance_valid(header_node):
			header_node.text = "gamepad" if is_gamepad else "keyboard"
		for i in actions.size():
			fill_row(list[i], actions[i])
	else:
		Shared.save_keys()

func fill_row(row, action):
	var a = get_action_list_is_type(action)
	
	var keys = row.get_node("Keys").get_children()
	for x in keys.size():
		var less = x < a.size()
		keys[x].visible = less
		if less:
			keys[x].parse_event(a[x])

func get_action_list_is_type(_action, _gamepad := is_gamepad):
	var e = []
	for i in InputMap.get_action_list(_action):
		if Key.is_type(i, _gamepad):
			e.append(i)
	return e

func assign_key(action : String, event):
	var is_ui = action.begins_with("ui_")
	
	# remove event if present anywhere
	for i in InputMap.get_actions():
		if InputMap.action_has_event(i, event) and i.begins_with("ui_") == is_ui:
			InputMap.action_erase_event(i, event)
	
	# add event to action, will bring to front of list if present
	InputMap.action_add_event(action, event)
	
	# keep action size to 4 events of type
	var e = get_action_list_is_type(action)
	if e.size() > 4:
		InputMap.action_erase_event(action, e[0])
	
	emit_signal("refresh")
	for i in actions.size():
		fill_row(list[i], actions[i])

func clear_action(_cursor := cursor):
	var action : String = actions[_cursor]
	var is_ui := action.begins_with("ui_")
	
	var e = get_action_list_is_type(action)
	if is_ui:
		e.pop_back()
	for i in e:
		InputMap.action_erase_event(action, i)
	
	fill_row(list[_cursor], actions[_cursor])

func default_keys():
	# get default key binds
	for i in InputMap.get_actions():
		default_keys[i] = InputMap.get_action_list(i)

func reset_to_defaults():
	for action in InputMap.get_actions():
		for event in InputMap.get_action_list(action):
			if Key.is_type(event, is_gamepad):
				InputMap.action_erase_event(action, event)
	
	for action in default_keys.keys():
		for event in default_keys[action]:
			if Key.is_type(event, is_gamepad):
				InputMap.action_add_event(action, event)
	
	for i in actions.size():
		fill_row(list[i], actions[i])
	
	emit_signal("refresh")
