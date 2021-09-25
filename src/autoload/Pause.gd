extends CanvasLayer

var is_paused := false
onready var menu : Control = $Menu
onready var menu_list : Label = $Menu/List

var cursor := 0
var menu_items := ["resume", "reset", "exit"]

var timer := 0.1 # prevent input overlap
var clock := 0.0

onready var node_cursor : ColorRect = $Menu/Cursor
onready var node_audio_pause : AudioStreamPlayer = $AudioPause
onready var node_audio_scroll : AudioStreamPlayer = $AudioScroll
onready var node_audio_resume : AudioStreamPlayer = $AudioResume
onready var node_audio_reset : AudioStreamPlayer = $AudioReset
onready var node_audio_exit : AudioStreamPlayer = $AudioExit

signal pause
signal unpause

func _ready():
	menu.visible = false
	
	set_cursor()
	write_menu()

func _process(delta):
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
			elif event.is_action_pressed("down") or event.is_action_pressed("up"):
				var btny = btn.p("down") - btn.p("up")
				if btny:
					set_cursor(cursor + btny)
					write_menu()
					node_audio_scroll.pitch_scale = 1 + rand_range(-0.2, 0.2)
					node_audio_scroll.play()

func toggle_pause():
	is_paused = !is_paused
	menu.visible = is_paused
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
	node_cursor.rect_position.y = menu_list.rect_position.y - 2 + cursor * 11

func select():
	match menu_items[cursor]:
		"resume":
			toggle_pause()
		"reset":
			Shared.do_reset()
			toggle_pause()
			node_audio_reset.play()
		"exit":
			Shared.scene_path = Shared.level_select_path
			Shared.do_reset()
			toggle_pause()
			node_audio_exit.play()
