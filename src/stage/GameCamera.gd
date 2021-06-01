extends Camera2D

var node_target : Node2D
export var pos_offset := Vector2.ZERO
export var pos_start := Vector2.ZERO
export var pos_target := Vector2.ZERO
export var lerp_step := 0.1

export var is_focal_point := false
# between 0.0 and 1.0, distance of lerp between focal point and target
export var target_influence := 0.5

func _ready():
	Shared.node_camera_game = self
	
	# set vars
	pos_start = position
	
	# looks kinda ugly when using focal point
	if is_focal_point:
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false

func _process(delta):
	if is_instance_valid(node_target):
		if is_focal_point:
			pos_target = pos_start.linear_interpolate(node_target.position + pos_offset, target_influence)
		else:
			pos_target = node_target.position + pos_offset
	# smoothing
	position = position.linear_interpolate(pos_target, lerp_step)

# super simple screen shake
func shake(dist : int):
	position.x +=  dist if randf() < 0.5 else -dist
	position.y +=  dist if randf() < 0.5 else -dist
	
