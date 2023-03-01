extends Node2D

@onready var fill = $Box/Fill
@onready var audio = $AudioStreamPlayer

var is_selected = false

func _ready():
	fill.visible = ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))

func select():
	is_selected = true

func deselect():
	is_selected = false

# HTML5 fullscreen fix
func _input(event):
	if is_selected and event.is_action_pressed("jump"):
		var is_full = ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!is_full) else Window.MODE_WINDOWED
		Shared.set_window_scale()
		audio.play()
		fill.visible = !is_full
		if !is_full:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
