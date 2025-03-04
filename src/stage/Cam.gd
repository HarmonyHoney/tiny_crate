extends Camera2D

var node_target : Node2D
var pos_target := Vector2.ZERO
var pos_target_offset := Vector2.ZERO
export var lerp_step := 0.1
export var lerp_jump := 0.5
var lerp_pos := Vector2.ZERO

var bounds_upper := Vector2.ZERO
var bounds_lower := Vector2.ZERO


func set_pos(arg : Vector2 = position):
	position = arg
	lerp_pos = position
	pos_target = position

func _ready():
	set_pos()
	
	Wipe.connect("finish", self, "wipe_finish")

func wipe_finish():
	node_target = null
	pos_target_offset = Vector2.ZERO

func _physics_process(delta):
	if is_instance_valid(node_target):
		pos_target = node_target.position + pos_target_offset
	pos_target.x = clamp(pos_target.x, bounds_upper.x, bounds_lower.x)
	pos_target.y = clamp(pos_target.y, bounds_upper.y, bounds_lower.y)
	
	# smoothing
	lerp_pos = lerp_pos.linear_interpolate(pos_target, clamp(lerp_step, 0, 1))
	if lerp_pos.distance_to(pos_target) < lerp_jump:
		lerp_pos = pos_target
	position = lerp_pos.round()

# super simple screen shake
func shake(dist : int):
	position.x += dist if randf() < 0.5 else -dist
	position.y += dist if randf() < 0.5 else -dist
	lerp_pos = position
