extends Node2D

onready var menu_items : Array = $MenuItems.get_children()
var cursor := 0

onready var node_cursor : ColorRect = $Cursor
onready var node_audio_scroll : AudioStreamPlayer = $AudioScroll

func _ready():
	select_item(0)

func _input(event):
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	var left = event.is_action_pressed("left")
	var right = event.is_action_pressed("right")
	
	var yes = event.is_action_pressed("jump")
	var no = event.is_action_pressed("action")
	
	if TouchScreen.visible:
		if left or right:
			select_item(cursor + (-1 if left else 1))
			node_audio_scroll.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_scroll.play()
		elif yes or no:
			var btnx = -1 if no else 1
			if menu_items[cursor].has_method("scroll"):
				menu_items[cursor].scroll(btnx)
				
			if menu_items[cursor].has_method("act"):
				menu_items[cursor].act()
	else:
		if up or down:
			select_item(cursor + (-1 if up else 1))
			node_audio_scroll.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_scroll.play()
		elif yes:
			if menu_items[cursor].has_method("act"):
				menu_items[cursor].act()
		elif left or right:
			var btnx = -1 if left else 1
			if menu_items[cursor].has_method("scroll"):
				menu_items[cursor].scroll(btnx)
		elif no:
			if menu_items[0].has_method("act"):
				menu_items[0].act()

func select_item(arg := 0):
	if menu_items[cursor].has_method("deselect"):
		menu_items[cursor].deselect()
		
	cursor = clamp(arg, 0, menu_items.size() - 1)
	node_cursor.rect_position.y = menu_items[cursor].position.y - 2
	
	if menu_items[cursor].has_method("select"):
		menu_items[cursor].select()




