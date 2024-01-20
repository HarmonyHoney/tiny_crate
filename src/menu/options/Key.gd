tool
extends Control

export var action := "" setget set_action
export var text := "key" setget set_text

onready var white := $White
onready var black := $Black
onready var label := $Label

var is_gamepad := false

var swap := {"control" : "ctrl",
"quoteleft" : "~",
"capslock" : "caps",
"escape" : "esc",
"equal" : "=",
"minus" : "-",
"bracketleft" : "[",
"bracketright" : "]",
"apostrophe" : "'",
"semicolon" : ";",
"comma" : ",",
"period" : ".",
"slash" : "/",
"backslash" : "\\",
"insert" : "ins",
"delete" : "del",
"pageup" : "pgup",
"pagedown" : "pgdn",
}


func _ready():
	set_action()
	if Engine.editor_hint: return

func set_text(arg := text):
	text = arg
	var l = text.length() * 6.0
	
	rect_min_size = Vector2(l + 3, 9)
	
	if is_instance_valid(label):
		label.text = text
		label.rect_size = Vector2.ONE
		
	if is_instance_valid(white):
		white.rect_size = rect_min_size
	if is_instance_valid(black):
		black.rect_size = Vector2(l + 1, 7)
	
	update()

func set_action(arg := action):
	action = arg
	print("set_action = ", action, " ", InputMap.get_action_list(action))
	
	
	if action != "" and InputMap.has_action(action):
		var l = InputMap.get_action_list(action)
		print("l")
		var e = null
		
		for i in l:
			if is_type(i):
				e = i
		
		if e:
			parse_event(e)

func is_type(event):
	var test = !is_gamepad and event is InputEventKey
	if !test:
		test = is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion)
	
	return test

func parse_event(event : InputEvent):
	var s = str(event.as_text().to_lower())
	
	if swap.has(s):
		s = swap[s]
	
	self.text = s
	update()
