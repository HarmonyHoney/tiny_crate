extends Menu

var is_paused := false

var timer := 0.1 # prevent input overlap
var clock := 0.0

signal pause
signal unpause
onready var ghost_label := $Center/Control/Center/VBox/List/Label5
var ghost_cursor := 0

func _input(event):
	if !is_sub and clock == 0 and Shared.is_in_game and !Wipe.is_wipe:
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
	TouchScreen.set_game(!is_paused)
	clock = timer
	
	if is_paused:
		scroll_ghost()
		get_tree().paused = is_paused
		emit_signal("pause")
		Audio.play("menu_pause", 0.9, 1.1)
	else:
		Shared.setup_ghosts()
		emit_signal("unpause")
		Audio.play("menu_pick", 0.9, 1.1)

func btn_no():
	toggle_pause()

func btn_yes():
	.btn_yes()
	match cursor:
		0:
			toggle_pause()
		1:
			Shared.wipe_scene()
			toggle_pause()
			Audio.play("menu_reset", 0.9, 1.1)
		2:
			scroll_ghost(1)
		3:
			open_sub(OptionsMenu)
		4:
			Shared.wipe_scene(Shared.level_select_path)
			toggle_pause()
			Audio.play("menu_exit", 0.9, 1.1)

func btn_x(arg := 0):
	if cursor == 2:
		scroll_ghost(arg)

func scroll_ghost(arg := 0):
	ghost_cursor = 2 if Shared.is_replay_note else 1 if Shared.is_replay else 0
	ghost_cursor = wrapi(ghost_cursor + arg, 0, 3)
	Shared.is_replay = [false, true, false][ghost_cursor]
	Shared.is_replay_note = [false, false, true][ghost_cursor]
	ghost_label.text = "ghost: " + ["off", "run", "note"][ghost_cursor]
	Audio.play("menu_yes", 0.8, 1.2)
