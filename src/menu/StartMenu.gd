extends Node2D

var menu_list : Label
var menu_items := []

onready var menu_stuff := $Control/Menu.get_children()
var main_items := ["play", "options", "credits"]

onready var quit_menu : Control = $Menu/Quit
var quit_items := ["yes", "no"]

var cursor := 0

var timer := 0.1
var clock := 0.0

onready var node_audio_scroll : AudioStreamPlayer = $AudioScroll
onready var node_audio_play : AudioStreamPlayer = $AudioPlay
onready var node_audio_options : AudioStreamPlayer = $AudioOptions
onready var node_audio_credits : AudioStreamPlayer = $AudioCredits
onready var node_audio_quit : AudioStreamPlayer = $AudioQuit
onready var node_audio_yes : AudioStreamPlayer = $AudioYes
onready var node_audio_no : AudioStreamPlayer = $AudioNo

var is_input = true

func _ready():
	switch_menu("main")
	UI.keys(true, true, false)

func _input(event):
	if !is_input:
		return
	if event.is_action_pressed("action"):
		if menu_items == quit_items:
			cursor = 1
			menu_select()
		else:
			cursor = 0
			write_menu()
			switch_menu("quit")
			node_audio_quit.play()
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
	for i in 3:
		menu_stuff[i].modulate = Color("ff004d") if i == cursor else Color("83769c")

func menu_select():
	match menu_items[clamp(cursor, 0, menu_items.size() - 1)].to_lower():
		"play":
			Shared.wipe_scene(Shared.level_select_path)
			is_input = false
			node_audio_play.play()
		"options":
			Shared.wipe_scene(Shared.options_menu_path)
			is_input = false
			node_audio_options.play()
		"credits":
			Shared.wipe_scene(Shared.credits_path)
			is_input = false
			node_audio_credits.play()
		"yes":
			is_input = false
			node_audio_yes.play()
			if OS.get_name() == "HTML5":
				Shared.wipe_scene(Shared.splash_path)
			else:
				Shared.wipe_quit()
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
			menu_items = main_items
		"quit":
			quit_menu.visible = true
			menu_items = quit_items
			cursor = 1
	write_menu()
