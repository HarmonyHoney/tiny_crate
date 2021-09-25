extends Node2D

onready var menu_items : Array = $MenuItems.get_children()
var cursor := 0

onready var node_cursor : ColorRect = $Cursor
onready var node_audio_scroll : AudioStreamPlayer = $AudioScroll

func _ready():
	select_item(0)

func _input(event):
	if event.is_action_pressed("action"):
		if menu_items[0].has_method("act"):
			menu_items[0].act()
	elif event.is_action_pressed("jump"):
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
			node_audio_scroll.pitch_scale = 1 + rand_range(-0.2, 0.2)
			node_audio_scroll.play()

func select_item(arg := 0):
	if menu_items[cursor].has_method("deselect"):
		menu_items[cursor].deselect()
		
	cursor = clamp(arg, 0, menu_items.size() - 1)
	node_cursor.rect_position.y = menu_items[cursor].position.y - 2
	
	if menu_items[cursor].has_method("select"):
		menu_items[cursor].select()




