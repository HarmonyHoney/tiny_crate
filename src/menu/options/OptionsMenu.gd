extends Menu

func on_open():
	if !is_open:
		Shared.save_options()

func _physics_process(delta):
	$"%TimeLabel".text = Shared.time_to_string(Shared.time_elapsed)
