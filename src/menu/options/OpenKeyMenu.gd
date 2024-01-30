extends CanvasItem

export var is_gamepad := false

func act():
	KeyMenu.is_gamepad = is_gamepad
	OptionsMenu.open_sub(KeyMenu)
	Audio.play("menu_pause", 0.9, 1.1)
