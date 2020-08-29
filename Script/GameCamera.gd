extends Camera2D

var node_target : Node2D
export var pos_offset := Vector2()
export var start_pos : Vector2

export var is_focal_point := false
# between 0.0 and 1.0, distance of lerp between focal point and target
export var target_influence := 0.5

func _ready():
	Shared.node_camera_game = self
	start_pos = position
	
	# looks kinda ugly when using focal point
	if is_focal_point:
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false

func _process(delta):
	if node_target:
		if is_focal_point:
			position = start_pos.linear_interpolate(node_target.position + pos_offset, target_influence)
			pass
		else:
			position = node_target.position + pos_offset
	position.x = round(position.x)
	position.y = round(position.y)
