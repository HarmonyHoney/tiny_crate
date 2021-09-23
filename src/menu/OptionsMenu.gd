extends Node2D

var menu_items := []
var cursor := 0

var node_cursor : ColorRect
var node_audio : AudioStreamPlayer2D

var is_input = true

func _ready():
	node_cursor = $Cursor
	menu_items = $MenuItems.get_children()
	
	node_audio = $AudioStreamPlayer2D
	
	select_item(0)

func _process(delta):
	pass

func _input(event):
	if !is_input:
		return
	if event.is_action_pressed("jump"):
		if menu_items[cursor].has_method("act"):
			menu_items[cursor].act()
	elif event.is_action_pressed("left") or event.is_action_pressed("right"):
		var btnx = btn.p("right") - btn.p("left")
		if menu_items[cursor].has_method("scroll"):
			menu_items[cursor].scroll(btnx)
	elif event.is_action_pressed("down") or event.is_action_pressed("up"):
		var btny = btn.p("down") - btn.p("up")
		if btny:
			select_item(cursor + btny)

func select_item(arg := 0):
	if menu_items[cursor].has_method("deselect"):
		menu_items[cursor].deselect()
		
	cursor = clamp(arg, 0, menu_items.size() - 1)
	node_cursor.rect_position.y = menu_items[cursor].position.y - 2
	
	if menu_items[cursor].has_method("select"):
		menu_items[cursor].select()




