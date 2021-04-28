extends CanvasLayer

var is_paused := false
var menu_list : Label
var menu : Control
var paused_menu : NinePatchRect
var paused_list : Label
var options_menu: NinePatchRect
var options_list : Label

var cursor := 0
var menu_items := []
var selection := ""
var paused_items := ["resume", "reset", "level select", "options", "quit game"]
var options_items := ["back", "fullscreen", "window size", "volume"]

var timer := 0.1
var clock := 0.0

func _ready():
	paused_menu = $Menu/Paused
	paused_list = $Menu/Paused/List
	options_menu = $Menu/Options
	options_list = $Menu/Options/List
	
	menu = $Menu
	menu.visible = false
	menu_list = paused_list

func _process(delta):
	if clock != 0:
		clock = max(0, clock - delta)
		if clock == 0:
			if is_paused:
				pass
			else:
				get_tree().paused = false

func _input(event):
	if clock == 0 and not dev.is_open:
		if event.is_action_pressed("pause"):
			toggle_pause()
		if is_paused:
			if event.is_action_pressed("jump"):
				menu_select()
			elif event.is_action_pressed("down") or event.is_action_pressed("up"):
				var btny = btn.p("down") - btn.p("up")
				if btny:
					cursor = clamp(cursor + btny, 0, menu_items.size() - 1)
					selection = menu_items[cursor]
					write_menu()
					

func toggle_pause():
	is_paused = !is_paused
	menu.visible = is_paused
	clock = timer
	
	if is_paused:
		get_tree().paused = is_paused
		switch_menu("paused")
	else:
		options_menu.visible = false


func write_menu():
	menu_list.text = ""
	for i in menu_items.size():
		if cursor == i:
			menu_list.text += "> "
		menu_list.text += menu_items[i] + "\n"

func menu_select():
	match menu_items[cursor]:
		"resume":
			toggle_pause()
		"reset":
			Shared.do_reset()
			toggle_pause()
		"options":
			switch_menu("options")
		"level select":
			get_tree().change_scene("res://src/menu/select.tscn")
			toggle_pause()
		"quit game":
			get_tree().quit()
		"back":
			switch_menu("paused")
		"fullscreen":
			OS.window_fullscreen = !OS.window_fullscreen
		"volume":
			pass

func switch_menu(arg):
	cursor = 0
	match arg:
		"paused":
			paused_menu.visible = true
			options_menu.visible = false
			menu_list = paused_list
			menu_items = paused_items
		"options":
			paused_menu.visible = false
			options_menu.visible = true
			menu_list = options_list
			menu_items = options_items
	write_menu()
