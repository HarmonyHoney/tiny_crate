extends CanvasItem

func _ready():
	if Shared.is_level_select:
		visible = false
	
	Pause.connect("pause", self, "pause")
	Pause.connect("unpause", self, "unpause")

func pause():
	visible = false

func unpause():
	visible = true
