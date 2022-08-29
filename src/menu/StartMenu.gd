extends Node2D

var menu_list : Label
var menu_items := []

onready var main_list : Label = $Menu/List
var main_items := ["play", "options", "credits", "quit"]

onready var quit_menu : Control = $Menu/Quit
onready var quit_list : Label = $Menu/Quit/List
var quit_items := ["yes", "no"]

var cursor := 0

var timer := 0.1
var clock := 0.0

onready var node_cursor : ColorRect = $Menu/Cursor
onready var node_audio_scroll : AudioStreamPlayer = $AudioScroll
onready var node_audio_play : AudioStreamPlayer = $AudioPlay
onready var node_audio_options : AudioStreamPlayer = $AudioOptions
onready var node_audio_credits : AudioStreamPlayer = $AudioCredits
onready var node_audio_quit : AudioStreamPlayer = $AudioQuit
onready var node_audio_yes : AudioStreamPlayer = $AudioYes
onready var node_audio_no : AudioStreamPlayer = $AudioNo

var is_input = true

func _ready():
	menu_list = main_list
	switch_menu("main")
	UI.keys()

func _input(event):
	if !is_input:
		return
	if event.is_action_pressed("action"):
		if menu_list == quit_list:
			cursor = 1
			menu_select()
	elif event.is_action_pressed("jump"):
		menu_select()
	else:
		var up = event.is_action_pressed("up") or event.is_action_pressed("left")
		var down = event.is_action_pressed("down") or event.is_action_pressed("right")
		if up or down:
			cursor = clamp(cursor + (-1 if up else 1), 0, menu_items.size() - 1)
			write_menu()
			node_audio_scroll.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_scroll.play()

func write_menu():
	menu_list.text = ""
	for i in menu_items.size():
		if cursor == i:
			menu_list.text += "-" + menu_items[i] + "-" + "\n"
			node_cursor.rect_position.y = -1 +  i * 11
			node_cursor.rect_position.x = 0
			node_cursor.rect_size.x = menu_list.rect_size.x - 1
		else:
			menu_list.text += menu_items[i] + "\n"

func menu_select():
	match menu_items[cursor].to_lower():
		"play":
			Shared.scene_path = Shared.level_select_path
			Shared.do_reset()
			is_input = false
			node_audio_play.play()
		"options":
			Shared.scene_path = Shared.options_menu_path
			Shared.do_reset()
			is_input = false
			node_audio_options.play()
		"credits":
			Shared.scene_path = Shared.credits_path
			Shared.do_reset()
			is_input = false
			node_audio_credits.play()
		"quit":
			cursor = -1
			write_menu()
			switch_menu("quit")
			node_audio_quit.play()
		"yes":
			is_input = false
			node_audio_yes.play()
			if OS.get_name() == "HTML5":
				Shared.scene_path = Shared.splash_path
				Shared.do_reset()
			else:
				Shared.quit_wipe()
		"no":
			switch_menu("main")
			cursor = 3
			write_menu()
			node_audio_no.play()

func switch_menu(arg):
	cursor = 0
	match arg:
		"main":
			quit_menu.visible = false
			menu_list = main_list
			menu_items = main_items
			
			node_cursor.get_parent().remove_child(node_cursor)
			main_list.add_child(node_cursor)
		"quit":
			quit_menu.visible = true
			menu_list = quit_list
			menu_items = quit_items
			cursor = 1
			
			node_cursor.get_parent().remove_child(node_cursor)
			quit_list.add_child(node_cursor)
	write_menu()
