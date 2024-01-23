tool
extends Control
class_name Key

export var action := "" setget set_action
export var text := "key" setget set_text
export var font_width := 6
export var is_refresh := true
export var is_gamepad := false

onready var white := $White
onready var black := $Black
onready var label := $Label
onready var sprite := $Sprite


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
"scrolllock" : "scrlk",
"backspace" : "back",
}

var images := {"up" : 0,
"down" : 1,
"left" : 2,
"right" : 3,
"," : 4}


func _ready():
	KeyMenu.connect("refresh", self, "refresh")
	set_action()
	set_text()
	if Engine.editor_hint: return

func refresh():
	if is_refresh:
		set_action()

func set_text(arg := text):
	text = arg.to_lower()
	var frame = -1
	
	if swap.has(text):
		text = swap[text]
	
	if images.has(text):
		frame = images[text]
	
	var l = (text.length() if frame < 0 else 1) * font_width
	
	var out_size = Vector2(l + 3, 9)
	var in_size = Vector2(l + 1, 7)
	rect_min_size = in_size
	rect_size = in_size
	
	if is_instance_valid(sprite):
		sprite.visible = frame > -1
		sprite.frame = max(0, frame)
	
	if is_instance_valid(label):
		label.visible = frame < 0
		label.text = text if frame < 0 else ""
		label.rect_size = Vector2.ONE
	if is_instance_valid(white):
		white.rect_size = in_size
	if is_instance_valid(black):
		black.rect_size = out_size
	
	update()

func set_action(arg := action):
	action = arg
	if Engine.editor_hint: return
	
	if action != "" and InputMap.has_action(action):
		var l = InputMap.get_action_list(action)
		var e = null
		
		for i in l:
			if is_type(i, is_gamepad):
				e = i
		
		if e:
			parse_event(e)

static func is_type(event, _is_gamepad := is_gamepad):
	var test = !_is_gamepad and event is InputEventKey
	if !test:
		test = _is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion)
	
	return test

func parse_event(event : InputEvent):
	self.text = str(event.as_text())
	update()
