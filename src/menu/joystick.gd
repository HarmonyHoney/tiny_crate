tool
extends Control

export var radius := 20.0
export var max_range := 40.0

onready var base := $Base
onready var tip := $Tip

export var action_up := "ui_up"
export var action_down := "ui_down"
export var action_left := "ui_left"
export var action_right := "ui_right"

var joy = Vector2.ZERO

func _input(event):
	if Engine.editor_hint: return
	
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var vec = event.position - rect_global_position
		var r = vec.length() < max_range
		vec = vec.limit_length(radius)
		joy = vec.normalized() if r else Vector2.ZERO
		
		if event is InputEventScreenTouch:
			r = event.pressed
		
		tip.modulate = Color.red if r else Color.white
		tip.rect_position = vec if r else Vector2.ZERO
		
		if r:
			send_input()
		else:
			for i in 4:
				Input.action_release([action_down, action_left, action_up, action_right][i])
	


func send_input():
	var ja = rad2deg(joy.angle())
	var is_right = abs(ja) < 45
	var is_left = abs(ja) > 135
	var is_up = !is_right and !is_left and ja < 0
	var is_down = !is_up
	
	var u = InputEventAction.new()
	u.action = action_right if is_right else action_left if is_left else action_up if is_up else action_down
	u.pressed = true
	Input.parse_input_event(u)
	print(u.action)
	
