extends CanvasLayer

var is_paused := false
onready var menu : Control = $Center/Paused
onready var menu_list : Label = $Center/Paused/List
onready var node_cursor : ColorRect = $Center/Paused/Cursor

var cursor := 0
var menu_items := ["go", "redo", "stages"]

var timer := 0.1 # prevent input overlap
var clock := 0.0

onready var node_audio_pause : AudioStreamPlayer = $Audio/Pause
onready var node_audio_scroll : AudioStreamPlayer = $Audio/Scroll
onready var node_audio_resume : AudioStreamPlayer = $Audio/Resume
onready var node_audio_reset : AudioStreamPlayer = $Audio/Reset
onready var node_audio_exit : AudioStreamPlayer = $Audio/Exit

signal pause
signal unpause

func _ready():
	menu.visible = false
	
	set_cursor()
	write_menu()

func _physics_process(delta):
	if clock != 0:
		clock = max(0, clock - delta)
		if clock == 0:
			if is_paused:
				pass
			else:
				get_tree().paused = false

func _input(event):
	if clock == 0 and Shared.is_in_game:
		if event.is_action_pressed("pause"):
			toggle_pause()
		if is_paused:
			
			if event.is_action_pressed("action"):
				toggle_pause()
			elif event.is_action_pressed("jump"):
				select()
			else:
				var up = event.is_action_pressed("up") or event.is_action_pressed("left")
				var down = event.is_action_pressed("down") or event.is_action_pressed("right")
				if up or down:
					set_cursor(cursor + (-1 if up else 1))
					write_menu()
					Audio.play("pause_scroll", 0.8, 1.2)

func toggle_pause():
	is_paused = !is_paused
	menu.visible = is_paused
	UI.keys(is_paused, is_paused, true, is_paused)
	TouchScreen.turn_arrows(is_paused)
	clock = timer
	
	if is_paused:
		get_tree().paused = is_paused
		set_cursor()
		write_menu()
		emit_signal("pause")
		node_audio_pause.play()
	else:
		emit_signal("unpause")
		node_audio_resume.play()

func write_menu():
	menu_list.text = ""
	for i in menu_items.size():
		if cursor == i:
			menu_list.text += "-" + menu_items[i] + "-" + "\n"
		else:
			menu_list.text += menu_items[i] + "\n"

func set_cursor(arg = 0):
	cursor = clamp(arg, 0, menu_items.size() - 1)
	node_cursor.rect_position.y = menu_list.rect_position.y - 1 + (cursor * 8)

func select():
	match menu_items[cursor]:
		"go":
			toggle_pause()
		"redo":
			Shared.do_reset()
			toggle_pause()
			node_audio_reset.play()
		"stages":
			Shared.wipe_scene(Shared.level_select_path)
			toggle_pause()
			node_audio_exit.play()
