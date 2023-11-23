extends Node2D

onready var main_menu := $Control/Menu
onready var menu_stuff := main_menu.get_children()
onready var quit_menu := $Control/Quit

var cursor := 0
var menu_items := []
var main_items := ["play", "options", "credits"]
var quit_items := ["yes", "no"]
var is_input = true

onready var node_audio_scroll : AudioStreamPlayer = $Audio/Scroll
onready var node_audio_play : AudioStreamPlayer = $Audio/Play
onready var node_audio_options : AudioStreamPlayer = $Audio/Options
onready var node_audio_credits : AudioStreamPlayer = $Audio/Credits
onready var node_audio_quit : AudioStreamPlayer = $Audio/Quit
onready var node_audio_yes : AudioStreamPlayer = $Audio/Yes
onready var node_audio_no : AudioStreamPlayer = $Audio/No

func _ready():
	switch_menu("main", true)
	UI.keys(true, true, false)

func _input(event):
	if !is_input:
		return
	if event.is_action_pressed("action"):
		if menu_items == quit_items:
			switch_menu("main")
		else:
			switch_menu("quit")
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
	for i in menu_items.size():
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
				menu_stuff[cursor].text = "quit!!"
				Shared.wipe_quit()
		"no":
			switch_menu("main")

func switch_menu(arg, silent := false):
	var is_main : bool = arg == "main"
	cursor = 0 if is_main else 1
	quit_menu.visible = !is_main
	main_menu.visible = is_main
	menu_items = main_items if is_main else quit_items
	menu_stuff = (main_menu if is_main else quit_menu).get_children()
	
	if !silent:
		(node_audio_no if is_main else node_audio_quit).play()
	
	write_menu()
