extends CanvasLayer

var node_timer : Label
var node_death : Label

var pause : Control
var is_paused := false
var pause_list : Label

var cursor := 0
var menu_items := ["resume", "options", "exit"]


func _ready():
	node_timer = $Timer
	node_death = $Death
	
	pause = $Pause
	pause.visible = false
	pause_list = $Pause/List
	
	pause_list.text = ""
	for i in menu_items:
		pause_list.text += i + "\n"


func _process(delta):
	
	
	if is_paused:
		var btny = btn.p("down") - btn.p("up")
		if btny:
			cursor = clamp(cursor + btny, 0, menu_items.size() - 1)
			pause_list.text = ""
			for i in menu_items.size():
				if cursor == i:
					pause_list.text += "> "
				pause_list.text += menu_items[i] + "\n"
	

func _input(event):
	if Input.is_action_just_pressed("pause") and not dev.is_open:
		toggle_pause()


func toggle_pause():
	is_paused = !is_paused
	pause.visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		 pass
	else:
		pass
	
