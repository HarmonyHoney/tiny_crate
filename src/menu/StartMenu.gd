extends Node2D

var menu_list : Label
var menu_items := []

var main_menu : Control
var main_list : Label
var main_items := ["play", "options", "quit"]

var quit_menu : Control
var quit_list : Label
var quit_items := ["yes", "no"]

var cursor := 0

var timer := 0.1
var clock := 0.0

var node_cursor : ColorRect
var node_audio : AudioStreamPlayer2D

var is_input = true

func _ready():
	main_menu = $Menu/Main
	main_list = $Menu/Main/List
	
	quit_menu = $Menu/Quit
	quit_list = $Menu/Quit/List
	
	menu_list = main_list
	
	node_cursor = $Menu/Cursor
	node_audio = $AudioStreamPlayer2D
	
	switch_menu("main")

func _process(delta):
	pass

func _input(event):
	if !is_input:
		return
	if event.is_action_pressed("action"):
		if menu_list == quit_list:
			switch_menu("paused")
	elif event.is_action_pressed("jump"):
		menu_select()
	elif event.is_action_pressed("down") or event.is_action_pressed("up"):
		var btny = btn.p("down") - btn.p("up")
		if btny:
			cursor = clamp(cursor + btny, 0, menu_items.size() - 1)
			write_menu()

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
		"options":
			Shared.scene_path = Shared.options_menu_path
			Shared.do_reset()
			is_input = false
		"quit":
			switch_menu("quit")
		"yes":
			get_tree().quit()
		"no":
			switch_menu("main")
			cursor = 2
			write_menu()
		

func switch_menu(arg):
	cursor = 0
	match arg:
		"main":
			main_menu.visible = true
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
