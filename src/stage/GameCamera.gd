tool
extends Camera2D

export var is_moving := true

var node_target : Node2D
var pos_target := Vector2.ZERO
var pos_target_offset := Vector2.ZERO
export var lerp_step := 0.1
var lerp_pos := Vector2.ZERO

export var is_focal_point := false
# between 0.0 and 1.0, distance of lerp between focal point and target
export var target_influence := 0.5

var node_bounds : ColorRect
var bounds_upper := Vector2.ZERO
var bounds_lower := Vector2.ZERO

export var bounds := Rect2(0, 0, 0, 0) setget _set_bounds

func _ready():
	if Engine.editor_hint or Shared.is_level_select:
		set_physics_process(false)
		return
	
	Shared.cam = self
	
	# set limits
	bounds_upper.x = -bounds.position.x + position.x
	bounds_upper.y = -bounds.position.y + position.y
	bounds_lower.x = bounds.size.x + position.x
	bounds_lower.y = bounds.size.y + position.y
	print("GameCamera - bounds upper: ", bounds_upper, " lower: ", bounds_lower)
	
	# set vars
	lerp_pos = position
	pos_target = position

func _physics_process(delta):
	if !is_moving or Engine.editor_hint:
		return
	
	if is_instance_valid(node_target):
		pos_target = node_target.position + pos_target_offset
	pos_target.x = clamp(pos_target.x, bounds_upper.x, bounds_lower.x)
	pos_target.y = clamp(pos_target.y, bounds_upper.y, bounds_lower.y)
	
	# smoothing
	lerp_pos = lerp_pos.linear_interpolate(pos_target, lerp_step)
	position = lerp_pos.round()

func _set_bounds(arg):
	bounds.position.x = abs(arg.position.x)
	bounds.position.y = abs(arg.position.y)
	bounds.size.x = abs(arg.size.x)
	bounds.size.y = abs(arg.size.y)
	update()

func _draw():
	if Engine.editor_hint:
		draw_rect(Rect2(-bounds.position.x - 228/2, -bounds.position.y - 128/2, 228 + bounds.size.x + bounds.position.x, 128 + bounds.size.y + bounds.position.y), Color.red, false)

# super simple screen shake
func shake(dist : int):
	position.x += dist if randf() < 0.5 else -dist
	position.y += dist if randf() < 0.5 else -dist
	lerp_pos = position
