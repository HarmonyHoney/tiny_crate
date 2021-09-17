extends Node2D

var menu_list : Label

var main_menu : Control
var main_list : Label
var main_items := ["play", "options", "quit"]

var options_menu : Control
var options_list : Label
var options_items := ["back", "fullscreen", "window size", "volume", "delete save data", "unlock all"]

var cursor := 0
var menu_items := []

var timer := 0.1
var clock := 0.0

var node_cursor : Node2D
var node_audio : AudioStreamPlayer2D

func _ready():
	main_menu = $Menu/Main
	main_list = $Menu/Main/List
	print(main_menu)
	
	options_menu = $Menu/Options
	options_list = $Menu/Options/List
	
	menu_list = main_list
	
	node_cursor = $Menu/Cursor
	node_audio = $AudioStreamPlayer2D
	
	switch_menu("paused")
	write_menu()

func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("jump"):
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
			node_cursor.position.y = 40 + i * 11
			node_cursor.scale.x = menu_items[i].length() * 0.6
		else:
			menu_list.text += menu_items[i] + "\n"

func menu_select():
	match menu_items[cursor]:
		"play":
			Shared.scene_path = Shared.level_select_path
			Shared.do_reset()
		"options":
			switch_menu("options")
		"quit game":
			get_tree().quit()
		"back":
			switch_menu("paused")
		"fullscreen":
			OS.window_fullscreen = !OS.window_fullscreen
		"volume":
			pass
		"delete save data":
			Shared.delete_save()
			node_audio.play()
		"unlock all":
			Shared.unlock()

func switch_menu(arg):
	cursor = 0
	match arg:
		"paused":
			main_menu.visible = true
			options_menu.visible = false
			menu_list = main_list
			menu_items = main_items
		"options":
			main_menu.visible = false
			options_menu.visible = true
			menu_list = options_list
			menu_items = options_items
	write_menu()
