extends Control

var is_paused := false
var menu_list : Label

var cursor := 0
var menu_items := ["resume", "options", "exit"]


func _ready():
	visible = false
	menu_list = $List
	
	menu_list.text = ""
	for i in menu_items:
		menu_list.text += i + "\n"


func _process(delta):
	if is_paused:
		var btny = btn.p("down") - btn.p("up")
		if btny:
			cursor = clamp(cursor + btny, 0, menu_items.size() - 1)
			menu_list.text = ""
			for i in menu_items.size():
				if cursor == i:
					menu_list.text += "> "
				menu_list.text += menu_items[i] + "\n"
	

func _input(event):
	if dev.is_open:
		return
	
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if Input.is_action_just_pressed("jump"):
		toggle_pause()


func toggle_pause():
	is_paused = !is_paused
	visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		 pass
	else:
		pass
	
