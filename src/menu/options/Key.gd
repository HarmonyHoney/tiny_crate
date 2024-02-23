tool
extends Control
class_name Key

export var action := "" setget set_action
export var text := "key" setget set_text
export var font_width := 6
export var is_refresh := true
export var is_gamepad := false
export var is_connect := false setget set_is_connect

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
"joy 4" : "lb",
"joy 5" : "rb",
"joy 6" : "lt",
"axis 6+" : "lt",
"joy 7" : "rt",
"axis 7+" : "rt",
}

var images := {"up" : 0,
"down" : 1,
"left" : 2,
"right" : 3,
"," : 4,
"joy 0" : 8,
"joy 1" : 9,
"joy 2" : 10,
"joy 3" : 11,
"joy 12" : 12,
"joy 13" : 13,
"joy 14" : 14,
"joy 15" : 15,
"axis 1-" : 16,
"axis 1+" : 17,
"axis 0-" : 18,
"axis 0+" : 19,
"axis 3-" : 20,
"axis 3+" : 21,
"axis 2-" : 22,
"axis 2+" : 23,
"joy 10" : 24,
"joy 11" : 25,
"joy 8" : 26,
"joy 9" : 27,
}


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
	#print(text)
	var frame = -1
	
	
	if swap.has(text):
		text = swap[text]
	
	if images.has(text):
		frame = images[text]
	var is_joy = frame > 7
	
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
		white.visible = !is_joy
		white.rect_size = in_size
	if is_instance_valid(black):
		black.visible = !is_joy
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

func set_is_connect(arg := is_connect):
	is_connect = arg
	var s = "signal_gamepad"
	if is_connect:
		Shared.connect(s, self, s)
		signal_gamepad()
	elif Shared.is_connected(s, self, s):
		Shared.disconnect(s, self, s)

static func is_type(event, _is_gamepad := is_gamepad):
	var test = !_is_gamepad and event is InputEventKey
	if !test:
		test = _is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion)
	
	return test

func parse_event(event : InputEvent):
	var s = " "
	if event is InputEventJoypadButton:
		s = "JOY " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		var sgn = "+" if event.axis_value > 0 else "-"
		s = "AXIS " + str(event.axis) + sgn
	elif event is InputEvent:
			s = str(event.as_text().to_lower())
	
	self.text = s
	update()

func signal_gamepad():
	is_gamepad = Shared.is_gamepad
	set_action()
