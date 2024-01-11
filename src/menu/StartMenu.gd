extends Node2D

onready var main_menu := $Control/Main
onready var quit_menu := $Control/Quit
onready var slot_menu := $Control/Slot
onready var menu_stuff := main_menu.get_children()

var cursor := 0 setget set_cursor
var menu_items := []
var main_items := ["play", "creator", "options", "credits"]
var quit_items := ["yes", "no"]
var slot_items := ["slot", "slot", "slot"]
var is_input = true

export var blink_on := 0.3
export var blink_off := 0.2
var blink_clock := 0.0

func _ready():
	switch_menu("main", true)
	
	Shared.load_slots()
	var smc = slot_menu.get_children()
	for i in smc.size():
		smc[i].text = str(Shared.save_data[i]["gems"]) + " win"

func _input(event):
	if !is_input:
		return
	if event.is_action_pressed("action"):
		switch_menu("quit" if menu_items == main_items else "main")
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
			switch_menu("slot")
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
		"slot":
			Shared.load_slot(cursor)
			Shared.wipe_scene(Shared.level_select_path)
			is_input = false
			Audio.play("menu_play", 0.9, 1.1)

func switch_menu(arg, silent := false):
	var s = ["quit", "main", "slot"]
	var items = [quit_items, main_items, slot_items]
	var node = [quit_menu, main_menu, slot_menu]
	var audio = ["pick", "exit", "pick"]
	for i in 3:
		node[i].visible = arg == s[i]
		if arg == s[i]:
			menu_items = items[i]
			menu_stuff = node[i].get_children()
			if !silent:
				Audio.play("menu_" + audio[i], 0.9, 1.1)
	
	self.cursor = 1 if arg == "quit" else 0

func find_cursor(arg := ""):
	if is_input and menu_items.has(arg):
		self.cursor = menu_items.find(arg)
		menu_select()

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, menu_items.size() - 1)
	write_menu()
