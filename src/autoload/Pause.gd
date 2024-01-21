extends CanvasLayer

var is_paused := false

export var  path_parent : NodePath = ""
onready var node_parent : CanvasItem = get_node(path_parent)

export var path_cursor : NodePath = ""
onready var node_cursor : Control = get_node(path_cursor)

export var path_list : NodePath = ""
onready var node_list := get_node(path_list)
onready var menu_list : Array = node_list.get_children()

export var color_on := Color.white
export var color_off := Color(0.8,0.8,0.8,1.0)
export var cursor_offset := Vector2.ZERO
export var cursor_expand := Vector2.ZERO

var cursor := 0

var timer := 0.1 # prevent input overlap
var clock := 0.0

signal pause
signal unpause

func _ready():
	node_parent.visible = false
	
	set_cursor()

func _physics_process(delta):
	if clock != 0:
		clock = max(0, clock - delta)
		if clock == 0:
			if is_paused:
				pass
			else:
				get_tree().paused = false

func _input(event):
	if clock == 0 and Shared.is_in_game and !Wipe.is_wipe:
		if event.is_action_pressed("ui_pause"):
			toggle_pause()
		if is_paused:
			
			if event.is_action_pressed("ui_no"):
				toggle_pause()
			elif event.is_action_pressed("ui_yes"):
				select()
			else:
				var up = event.is_action_pressed("ui_up")# or event.is_action_pressed("left")
				var down = event.is_action_pressed("ui_down")# or event.is_action_pressed("right")
				if up or down:
					set_cursor(cursor + (-1 if up else 1))
					Audio.play("menu_scroll", 0.8, 1.2)

func toggle_pause():
	is_paused = !is_paused
	node_parent.visible = is_paused
	UI.keys(true, is_paused, is_paused, is_paused, is_paused)
	UI.stats.visible = is_paused
	TouchScreen.turn_arrows(is_paused)
	clock = timer
	
	if is_paused:
		get_tree().paused = is_paused
		set_cursor()
		emit_signal("pause")
		Audio.play("menu_pause", 0.9, 1.1)
	else:
		emit_signal("unpause")
		Audio.play("menu_pick", 0.9, 1.1)


func set_cursor(arg = 0):
	cursor = clamp(arg, 0, menu_list.size() - 1)
	node_cursor.rect_global_position = cursor_offset + menu_list[cursor].rect_global_position - (cursor_expand * 0.5)
	node_cursor.rect_size = menu_list[cursor].rect_size + cursor_expand
	
	for i in menu_list.size():
		menu_list[i].modulate = color_on if cursor == i else color_off

func select():
	match cursor:
		0:
			toggle_pause()
		1:
			Shared.wipe_scene()
			toggle_pause()
			Audio.play("menu_reset", 0.9, 1.1)
		2:
			Shared.wipe_scene(Shared.level_select_path)
			toggle_pause()
			Audio.play("menu_exit", 0.9, 1.1)
