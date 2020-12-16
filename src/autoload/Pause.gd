extends CanvasLayer

var is_paused := false
var menu_list : Label
var menu : Control

var cursor := 0
var menu_items := ["resume", "options", "level select", "quit game"]
var selection := ""

var timer := 0.1
var clock := 0.0

func _ready():
	menu = $Menu
	menu.visible = false
	menu_list = $Menu/NinePatchRect/List


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
		cursor = 0
		write_menu()
	else:
		pass


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
		"options":
			pass
		"level select":
			get_tree().change_scene("res://src/menu/MapSelect.tscn")
			toggle_pause()
		"quit game":
			get_tree().quit()

