extends CanvasItem

func act():
	OptionsMenu.is_open = false
	OptionsMenu.visible = false
	KeyMenu.open(true)
	Audio.play("menu_pause", 0.9, 1.1)
