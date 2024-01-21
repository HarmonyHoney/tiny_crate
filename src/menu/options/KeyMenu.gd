extends CanvasLayer

var is_open = false
onready var default_keys := {}

export var is_gamepad := false

onready var control := $Control

onready var list_node := $Control/VBox
onready var row_node := $Control/VBox/Row

export var keys_action := {
"up" : "up",
"down" : "down",
"left" : "left",
"right": "right",
"jump" : "jump",
"action" : "lift",
"pause": "menu",
}

func _ready():
	open(false)
	
	# get default key binds
	for i in InputMap.get_actions():
		default_keys[i] = InputMap.get_action_list(i)
	
	# setup list
	for i in keys_action.keys():
		if InputMap.has_action(i):
			var r = row_node.duplicate()
			r.get_node("Label").text = keys_action[i]
			list_node.add_child(r)
			
			var a = InputMap.get_action_list(i)
			var k := []
			
			for y in a:
				if Key.is_type(y, is_gamepad):
					k.append(y.as_text())
			
			var keys = r.get_node("Keys").get_children()
			for x in keys.size():
				var less = x < k.size()
				keys[x].visible = less
				if less:
					keys[x].text = k[x]
		
	
	row_node.queue_free()

func _input(event):
	if !is_open or Wipe.is_wipe: return
	
	if event.is_action_pressed("action"):
		open(false)
		OptionsMenu.open(true)

func open(arg := false):
	is_open = arg
	control.visible = is_open


