extends Node2D

@onready var audio := $AudioStreamPlayer
@onready var label_scale := $Scale
@onready var label_res := $Resolution

func _ready():
	set_text()

func scroll(arg = 1):
	Shared.set_window_scale(clamp(Shared.window_scale + arg, 1, 12))
	set_text()
	audio.pitch_scale = 1 + randf_range(-0.3, 0.4)
	audio.play()

func set_text():
	label_scale.text = str(Shared.window_scale) + "x"
	label_res.text = str(Shared.view_size.x * Shared.window_scale) + " x " + str(Shared.view_size.y * Shared.window_scale)
