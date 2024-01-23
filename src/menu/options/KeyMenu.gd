extends CanvasLayer

var is_open = false
onready var default_keys := {}

export var is_gamepad := false

onready var control := $Control
onready var popup := $PopUp
var is_rebind := false

onready var list_node := $Control/VBox
onready var row_node := $Control/VBox/Row

var cursor := 0 setget set_cursor
onready var cursor_node := $Control/Cursor
export var cursor_expand := Vector2.ZERO
var list := []
var actions := []

export var keys_action := {
"up" : "up",
"down" : "down",
"left" : "left",
"right": "right",
"jump" : "jump",
"action" : "lift",

"ui_pause": "pause",
"ui_up" : "menu up",
"ui_down" : "menu down",
"ui_left" : "menu left",
"ui_right" : "menu right",
"ui_yes" : "menu yes",
"ui_no" : "menu no",
}

func _ready():
	open(false)
	popup.visible = false
	
	# get default key binds
	for i in InputMap.get_actions():
		default_keys[i] = InputMap.get_action_list(i)
	
	# setup list
	for i in keys_action.keys():
		if InputMap.has_action(i):
			var r = row_node.duplicate()
			r.get_node("Label").text = keys_action[i]
			list_node.add_child(r)
			list.append(r)
			actions.append(i)
			
			fill_row(r, i)
	
	row_node.queue_free()
	
	
	set_cursor()

func fill_row(row, action):
	var a = InputMap.get_action_list(action)
	var k := []
	
	for y in a:
		if Key.is_type(y, is_gamepad):
			k.append(y.as_text())
	
	var keys = row.get_node("Keys").get_children()
	for x in keys.size():
		var less = x < k.size()
		keys[x].visible = less
		if less:
			keys[x].text = k[x]

func _input(event):
	if !is_open or Wipe.is_wipe: return
	
	if is_rebind:
		if event.is_action_pressed("ui_end"):
			is_rebind = false
			popup.visible = false
		elif event.is_pressed() and !event.is_echo() and Key.is_type(event):
			assign_key(actions[cursor], event)
			is_rebind = false
			popup.visible = false
			get_tree().set_input_as_handled()
	else:
		var btny = btn.p("ui_down") - btn.p("ui_up")
		
		if event.is_action_pressed("ui_no"):
			open(false)
			OptionsMenu.open(true)
		elif event.is_action_pressed("ui_yes"):
			popup.visible = true
			is_rebind = true
		elif btny != 0:
			self.cursor += btny

func open(arg := false):
	is_open = arg
	visible = is_open

func set_cursor(arg := cursor):
	cursor = clamp(arg, 0, list.size() - 1)
	
	cursor_node.rect_size = list[cursor].rect_size + cursor_expand
	cursor_node.rect_global_position = list[cursor].rect_global_position - (cursor_expand * 0.5)
	
	control.rect_position.y = 64 - cursor_node.rect_position.y

func assign_key(action : String, event):
	var is_ui = action.begins_with("ui_")
	
	# remove event if present anywhere
	for i in InputMap.get_actions():
		if InputMap.action_has_event(i, event) and i.begins_with("ui_") == is_ui:
			InputMap.action_erase_event(i, event)
	
	# add event to action, will bring to front of list if present
	InputMap.action_add_event(action, event)
	
	# keep action size to 4 events of type
	var e = []
	for i in InputMap.get_action_list(action):
		if Key.is_type(i):
			e.append(i)
	
	if e.size() > 4:
		InputMap.action_erase_event(action, e[0])
	
	for i in list.size():
		fill_row(list[i], actions[i])
	
