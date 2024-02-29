tool
extends Control

export var radius := 20.0
export var max_range := 40.0
export var dead_zone := 2.0

onready var base := $Base
onready var tip := $Tip

export var action_up := "ui_up"
export var action_down := "ui_down"
export var action_left := "ui_left"
export var action_right := "ui_right"

var vec := Vector2.ZERO
var vl := 0.0
var joy = Vector2.ZERO
var is_joy := false
var last_val = -1
var index := -1

func _input(event):
	if Engine.editor_hint: return
	
	var is_touch = event is InputEventScreenTouch
	var is_drag = event is InputEventScreenDrag
	
	if (is_drag or is_touch) and (event.index == index or index == -1):
		vec = event.position - rect_global_position
		vl = vec.length()
		joy = vec.normalized()
		
		if is_touch:
			is_joy = vl < max_range if event.pressed else false
			index = event.index if is_joy else -1
		
		vec = vec.limit_length(radius)
		
		tip.modulate = Color.red if is_joy else Color.white
		tip.rect_position = vec if is_joy else Vector2.ZERO
		
		send_input()

func send_input():
	var ja = wrapf(rad2deg(joy.angle()) + 45.0, 0.0, 360.0)
	var val = int(ja / 90.0) if is_joy and vl > dead_zone else -1
	
	var a = [action_right , action_down, action_left, action_up]
	for i in 4:
		if i != val: Input.action_release(a[i])
	
	if val > -1:
		var u = InputEventAction.new()
		u.action = a[val]
		u.pressed = true
		Input.parse_input_event(u)
		print(val, " ", u.action, " ", vec, " index: ", index)

func _physics_process(delta):
	if Engine.editor_hint: return

func set_actions(_up, _down, _left, _right):
	is_joy = false
	index = -1
	send_input()
	
	action_up = _up
	action_down = _down
	action_left = _left
	action_right = _right
