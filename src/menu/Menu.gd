extends Node
class_name Menu

export var is_open = false
export var is_sub := false

export var parent_path : NodePath = ""
onready var parent_node = get_node_or_null(parent_path)

export var list_path : NodePath = ""
onready var list_node : Control = get_node_or_null(list_path)
onready var list := []

export var cursor_path : NodePath = ""
onready var cursor_node : Control = get_node_or_null(cursor_path)
export var cursor := 0 setget set_cursor
export var cursor_expand := Vector2.ZERO
export var cursor_lerp := 0.2
export var is_audio_scroll = false
export var is_sub_visible := false
export var is_audio_back := false
export var is_audio_yes := false

export var scroll_path : NodePath = ""
onready var scroll_node : Control = get_node_or_null(scroll_path)

var last_menu = null

var open_clock := 0.0
var open_time := 0.1
var key_time := 0.1

export var is_close_btn_no := false
export var is_color := false
export var color_on := Color.white
export var color_off := Color(0.8,0.8,0.8,1.0)

export var ui_expand := true
export var ui_top := false
export var ui_arrows := true
export var ui_x := true
export var ui_c := true
export var ui_stack := false
export var ui_v := false

func _ready():
	make_list(list_node)
	
	open(false)

func _input(event):
	menu_input(event)

func make_list(arg):
	if is_instance_valid(arg):
		list_node = arg
		list = arg.get_children()

func menu_input(event):
	if !is_open or is_sub or open_clock > 0 or Wipe.is_wipe: return
	
	var b_del : bool = event.is_action_pressed("ui_del")
	var b_pause : bool = event.is_action_pressed("ui_pause")
	var b_no : bool = event.is_action_pressed("ui_no")
	var b_yes : bool = event.is_action_pressed("ui_yes")
	var b_x = btn.p("ui_right") - btn.p("ui_left")
	var b_y = btn.p("ui_down") - btn.p("ui_up")
	
	if b_del: btn_del()
	elif b_no: btn_no()
	elif b_yes: btn_yes()
	elif b_y != 0: btn_y(b_y)
	elif b_x != 0: btn_x(b_x)
	
	if b_del or b_no or b_yes or b_y or b_x:
		open_clock = key_time

func btn_del():
	pass

func btn_no():
	if is_audio_back:
		Audio.play("menu_exit", 0.8, 1.2)
	if is_close_btn_no:
		open(false)

func btn_yes():
	if is_audio_yes:
		Audio.play("menu_yes", 0.8, 1.2)
	if list.size() > cursor and list[cursor].has_method("act"):
		list[cursor].act()

func btn_y(arg := 0):
	if arg != 0:
		self.cursor += arg
		if is_audio_scroll:
			 Audio.play("menu_scroll", 0.8, 1.2)

func btn_x(arg):
	if list[cursor].has_method("scroll"):
		list[cursor].scroll(arg)

func _physics_process(delta):
	menu_process(delta)

func menu_process(delta):
	open_clock = max(0, open_clock - delta)
	
	if is_instance_valid(cursor_node) and list.size() > cursor:
		cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(list[cursor].rect_size + cursor_expand, cursor_lerp)
		cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(list[cursor].rect_global_position - (cursor_expand * 0.5), cursor_lerp)
		
		if is_instance_valid(scroll_node):
			scroll_node.rect_position.y = 64 - cursor_node.rect_position.y - (cursor_node.rect_size.y * 0.5)

func set_cursor(arg := cursor):
	if list.size() > cursor and list[cursor].has_method("deselect"): list[cursor].deselect()
	cursor = clamp(arg, 0, list.size() - 1)
	if list.size() > cursor and list[cursor].has_method("select"): list[cursor].select()
	
	if is_color:
		for i in list.size():
			list[i].modulate = color_on if i == cursor else color_off

func open(arg := false, _last = null):
	is_open = arg
	if is_instance_valid(_last):
		last_menu = _last
	
	if parent_node and parent_node.get("visible") != null:
		parent_node.visible = is_open
	
	if is_open:
		set_cursor(0)
		UI.keys(ui_expand, ui_top, ui_arrows, ui_x, ui_c, ui_stack, ui_v)
	else:
		if list.size() > cursor and list[cursor].has_method("deselect"): list[cursor].deselect()
		if is_instance_valid(last_menu):
			last_menu.close_sub()
			last_menu = null
	
	open_clock = open_time
	
	on_open()

func on_open():
	pass

func open_sub(arg : Menu):
	if is_instance_valid(arg):
		is_sub = true
		arg.open(true, self)
		parent_node.visible = is_sub_visible
		on_open_sub()

func on_open_sub():
	pass

func close_sub():
	is_sub = false
	parent_node.visible = true
	open_clock = open_time
	on_close_sub()

func on_close_sub():
	pass
