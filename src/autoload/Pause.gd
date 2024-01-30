extends Menu

var is_paused := false

var timer := 0.1 # prevent input overlap
var clock := 0.0

signal pause
signal unpause

func _input(event):
	if clock == 0 and Shared.is_in_game and !Wipe.is_wipe:
		if event.is_action_pressed("ui_pause"):
			toggle_pause()

func _physics_process(delta):
	if clock != 0:
		clock = max(0, clock - delta)
		if clock == 0 and !is_paused:
			get_tree().paused = false

func toggle_pause():
	is_paused = !is_paused
	open(is_paused)
	
	UI.keys(true, is_paused, is_paused, is_paused, is_paused)
	UI.stats.visible = is_paused
	TouchScreen.turn_arrows(is_paused)
	clock = timer
	
	if is_paused:
		get_tree().paused = is_paused
		emit_signal("pause")
		Audio.play("menu_pause", 0.9, 1.1)
	else:
		emit_signal("unpause")
		Audio.play("menu_pick", 0.9, 1.1)

func btn_no():
	toggle_pause()

func btn_yes():
	match cursor:
		0:
			toggle_pause()
		1:
			Shared.wipe_scene()
			toggle_pause()
			Audio.play("menu_reset", 0.9, 1.1)
		2:
			open_sub(OptionsMenu)
		3:
			Shared.wipe_scene(Shared.level_select_path)
			toggle_pause()
			Audio.play("menu_exit", 0.9, 1.1)
