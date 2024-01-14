extends CanvasItem

export var blink_on := 0.3
export var blink_off := 0.2
var blink_clock := 0.0
export var color_blink : PoolColorArray = ["ff004d", "ff77a8"]
export var node_path : NodePath = "."
onready var node := get_node_or_null(node_path)

func _physics_process(delta):
	blink_clock -= delta
	if blink_clock < -blink_off:
		blink_clock = blink_on
	if node:
		node.modulate = color_blink[int(blink_clock > 0.0)]
