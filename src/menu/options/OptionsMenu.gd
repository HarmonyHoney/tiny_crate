extends Node

onready var center := $Center
onready var node_cursor : ColorRect = $Center/Control/Cursor
onready var menu_items : Array = $Center/Control/MenuItems.get_children()
var cursor := 0
export var is_open := false
var input_clock := 0.0
export var input_cooldown := 0.1
var last_menu = null

func _ready():
	center.visible = false
	select_item(0)

func _input(event):
	if !is_open or Wipe.is_wipe or input_clock > 0: return
	
	var up = event.is_action_pressed("ui_up")
	var down = event.is_action_pressed("ui_down")
	var left = event.is_action_pressed("ui_left")
	var right = event.is_action_pressed("ui_right")
	
	var yes = event.is_action_pressed("ui_yes")
	var no = event.is_action_pressed("ui_no")
	
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
		open(false)

func _physics_process(delta):
	input_clock = max(0, input_clock - delta)

func select_item(arg := 0):
	if menu_items[cursor].has_method("deselect"):
		menu_items[cursor].deselect()
		
	cursor = clamp(arg, 0, menu_items.size() - 1)
	node_cursor.rect_global_position = menu_items[cursor].rect_global_position - Vector2(2, 2)
	node_cursor.rect_size = menu_items[cursor].rect_size + Vector2(4, 4)
	
	if menu_items[cursor].has_method("select"):
		menu_items[cursor].select()

func open(arg := is_open, _last = null):
	is_open = arg
	if is_instance_valid(_last):
		last_menu = _last
	
	center.visible = is_open
	input_clock = input_cooldown
	
	select_item()
	if !is_open and is_instance_valid(last_menu) and last_menu.has_method("resume"):
		last_menu.resume()



