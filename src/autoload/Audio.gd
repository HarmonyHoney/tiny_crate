extends Node

export var is_refresh := false setget set_refresh

var dict = {}

func _ready():
	refresh()

func play(arg = "menu_scroll", from := 1.0, to := -1.0, pos := 0.0):
	if arg is String and dict.has(arg):
		arg = dict[arg]
	
	if is_instance_valid(arg) and (arg is AudioStreamPlayer or arg is AudioStreamPlayer2D):
		arg.pitch_scale = from if to < 0 else rand_range(from, to)
		arg.play(pos)


func refresh():
	dict = {}
	for i in Shared.get_all_children(self):
		if i is AudioStreamPlayer or i is AudioStreamPlayer2D:
			dict[str(get_path_to(i)).to_lower().replace("/", "_")] = i
	
	print("Audio.dict refresh: ", dict.keys())

func set_refresh(arg := is_refresh):
	is_refresh = false
	refresh()
