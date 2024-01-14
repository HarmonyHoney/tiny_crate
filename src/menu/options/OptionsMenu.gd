extends Node2D

onready var node_cursor : ColorRect = $Cursor
onready var menu_items : Array = $MenuItems.get_children()
var cursor := 0

func _ready():
	select_item(0)

func _input(event):
	if Wipe.is_wipe: return
	
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	var left = event.is_action_pressed("left")
	var right = event.is_action_pressed("right")
	
	var yes = event.is_action_pressed("jump")
	var no = event.is_action_pressed("action")
	
	if TouchScreen.visible:
		if left or right:
			select_item(cursor + (-1 if left else 1))
			Audio.play("menu_scroll", 0.8, 1.2)
		elif yes or no:
			var btnx = -1 if no else 1
			if menu_items[cursor].has_method("scroll"):
				menu_items[cursor].scroll(btnx)
				
			if menu_items[cursor].has_method("act"):
				menu_items[cursor].act()
	else:
		if up or down:
			select_item(cursor + (-1 if up else 1))
			Audio.play("menu_scroll", 0.8, 1.2)
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




