extends Node2D

onready var main_menu := $Control/Menu/List
onready var menu_stuff := main_menu.get_children()
onready var quit_menu := $Control/Quit

var cursor := 0 setget set_cursor
var menu_items := []
var main_items := ["play", "creator", "options", "credits"]
var quit_items := ["yes", "no"]
var is_input = true

export var blink_on := 0.3
export var blink_off := 0.2
var blink_clock := 0.0

func _ready():
	switch_menu("main", true)

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
			self.cursor += -1 if up else 1
			Audio.play("menu_scroll", 0.8, 1.2)

func _physics_process(delta):
# blink
	blink_clock -= delta
	if blink_clock < -blink_off:
		blink_clock = blink_on
	menu_stuff[cursor].modulate = Color("ff004d" if blink_clock > 0.0 else "ff77a8")

func write_menu():
	for i in menu_items.size():
		menu_stuff[i].modulate = Color("ff004d") if i == cursor else Color("83769c")

func menu_select(tag : String = menu_items[cursor].to_lower()):
	match tag:
		"play":
			Shared.wipe_scene(Shared.level_select_path)
			is_input = false
			Audio.play("menu_play", 0.9, 1.1)
		"creator":
			Shared.wipe_scene(Shared.creator_path)
			is_input = false
			Audio.play("menu_play", 0.9, 1.1)
		"options":
			Shared.wipe_scene(Shared.options_menu_path)
			is_input = false
			Audio.play("menu_options", 0.9, 1.1)
		"credits":
			Shared.wipe_scene(Shared.credits_path)
			is_input = false
			Audio.play("menu_pick", 0.9, 1.1)
		"yes":
			is_input = false
			Audio.play("menu_yes", 0.9, 1.1)
			if OS.get_name() == "HTML5":
				Shared.wipe_scene(Shared.splash_path)
			else:
				menu_stuff[cursor].text = "quit!!"
				Shared.wipe_quit()
		"no":
			switch_menu("main")

func switch_menu(arg, silent := false):
	var is_main : bool = arg == "main"
	quit_menu.visible = !is_main
	main_menu.visible = is_main
	menu_items = main_items if is_main else quit_items
	menu_stuff = (main_menu if is_main else quit_menu).get_children()
	
	if !silent:
		Audio.play("menu_" + ("exit" if is_main else "pick"), 0.9, 1.1)
	
	self.cursor = 0 if is_main else 1

func find_cursor(arg := ""):
	if is_input and menu_items.has(arg):
		self.cursor = menu_items.find(arg)
		menu_select()

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, menu_items.size() - 1)
	write_menu()
