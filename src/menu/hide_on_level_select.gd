extends Sprite2D

func _ready():
	if Shared.is_level_select or TouchScreen.visible:
		visible = false
	
	Pause.connect("pause",Callable(self,"pause"))
	Pause.connect("unpause",Callable(self,"unpause"))

func pause():
	visible = false

func unpause():
	visible = true
