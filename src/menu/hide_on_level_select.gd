extends Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	if Shared.is_level_select:
		visible = false

