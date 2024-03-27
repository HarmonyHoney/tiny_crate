tool
extends Control

export var radius := 20.0
export var max_range := 60.0

onready var base := $Base
onready var tip := $Tip
onready var buttons := $Buttons.get_children()

var vec := Vector2.ZERO
var vl := 0.0
var joy = Vector2.ZERO
var is_joy := false
var last_val = -1
var is_input = true

func _input(event):
	if Engine.editor_hint or !is_input: return
	
	var is_touch = event is InputEventScreenTouch
	var is_drag = event is InputEventScreenDrag
	
	if (is_drag or is_touch):
		vec = event.position - rect_global_position
		vl = vec.length()
		joy = vec.normalized()
		
		is_joy = vl < max_range
		if is_touch and !event.pressed:
			is_joy = false
		
		vec = vec.limit_length(radius)
		
		tip.modulate = Color.red if is_joy else Color.white
		tip.rect_position = vec if is_joy else Vector2.ZERO

func _physics_process(delta):
	if Engine.editor_hint: return

func set_actions(_up, _down, _left, _right):
	is_joy = false
	for i in 4:
		buttons[i].action = [_right, _down, _left, _up][i]
		buttons[i].passby_press = !("ui_" in _up)
