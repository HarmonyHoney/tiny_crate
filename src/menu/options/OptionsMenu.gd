extends Menu

func on_open():
	if !is_open:
		Shared.save_options()
