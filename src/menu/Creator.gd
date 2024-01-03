extends Node2D

onready var keyboard := $Menu/Keyboard
var rows : Array = []#keyboard.get_children()

onready var cursor_node := $Menu/Cursors/Cursor
var cursor_x := 0
var cursor_y := 0
onready var arrows := $Menu/Cursors/Arrows
onready var cursors_parent := $Menu/Cursors

onready var name_label := $Menu/Name
onready var done_node := $Menu/Done
onready var random_node := $Menu/Random

var colors = [0, 0, 0, 0]
var swatches = []

onready var player_mat : ShaderMaterial = $Player/Sprite.material
var is_input := true

export var blink_on := 0.3
export var blink_off := 0.2
var blink_clock := 0.0

func _ready():
	# setup rows & columns
	rows = []
	rows.append([random_node])
	for i in $Menu/ColorPick.get_children():
		rows.append([i])
	
	for i in keyboard.get_children():
		rows.append(i.get_children())
	rows.append([done_node])
	
	move_cursor()
	
	# setup swatches
	swatches = []
	for i in $Menu/Colors.get_children():
		swatches.append(i.get_children())
		
	for i in 4:
		fill_swatches(i)
	
	name_label.text = Shared.username
	colors = Shared.player_colors.duplicate()
	for i in 4:
		set_color(i, colors[i])
		fill_swatches(i)

func _input(event):
	if !is_input: return
	
	var btnx = btn.p("right") - btn.p("left")
	var btny = btn.p("down") - btn.p("up")
	var is_jump = event.is_action_pressed("jump")
	var is_action = event.is_action_pressed("action")
	
	if btny != 0:
		if (cursor_y == 4 and btny == 1) or (cursor_y == 9 and btny == -1): cursor_x = 4
		move_cursor(cursor_x, cursor_y + btny)
	elif cursor_y == 0:
		if is_jump:
			name_label.text = Shared.generate_username()
			Audio.play("menu_random", 0.8, 1.2)
			for i in 4:
				set_color(i, randi() % 14)
				fill_swatches(i)
		elif is_action:
			is_input = false
			Shared.wipe_scene(Shared.main_menu_path)
			Audio.play("menu_scroll2", 0.8, 1.2)
	elif cursor_y == clamp(cursor_y, 1, 4):
		if btnx != 0 or is_jump or is_action:
			var c = btnx
			if btnx == 0:
				c = 1 if is_action else -1
			set_color(cursor_y - 1, colors[cursor_y - 1] + c)
			fill_swatches()
			Audio.play("menu_scroll3", 0.8, 1.2)
	elif cursor_y == clamp(cursor_y, 5, 8):
		if btnx != 0:
			move_cursor(cursor_x + btnx)
		# erase letter
		if is_action:
			var s = name_label.text
			s.erase(s.length() - 1, 1)
			name_label.text = s
			Audio.play("menu_exit", 0.8, 1.2)
		
		# write letter
		elif is_jump:
			var s = rows[cursor_y][cursor_x].get_child(0).text
			var l = name_label.text
			name_label.text = (l + s).substr(0, 16)
			Audio.play("menu_yes", 0.8, 1.2)
	elif cursor_y == rows.size() - 1:
		if is_jump:
			is_input = false
			Shared.wipe_scene(Shared.main_menu_path)
			Shared.username = name_label.text.to_lower()
			Shared.player_colors = colors.duplicate()
			Shared.save_data["username"] = Shared.username
			Shared.save_data["player_colors"] = Shared.player_colors.duplicate()
			Audio.play("menu_bell", 0.8, 1.2)
		elif is_action:
			Audio.play("menu_scroll2", 0.8, 1.2)

func move_cursor(_x := cursor_x, _y = cursor_y):
	cursor_y = clamp(_y, 0, rows.size() - 1)
	cursor_x = wrapi(_x, 0, rows[cursor_y].size())
	
	cursor_node.rect_global_position = rows[cursor_y][cursor_x].rect_global_position
	cursor_node.rect_size = rows[cursor_y][cursor_x].rect_size
	
	arrows.rect_global_position = cursor_node.rect_global_position
	arrows.visible = cursor_y == clamp(cursor_y, 1, 4)
	Audio.play("menu_scroll", 0.8, 1.2)
	
	if cursor_y == 0:
		UI.labels("pick", "back")
	elif cursor_y == clamp(cursor_y, 1, 4):
		UI.labels("left", "right")
	else:
		UI.labels("pick", "erase" if cursor_y < 9 else "nope")

func set_color(_row := cursor_y - 1, _col = colors[cursor_y - 1]):
	colors[_row] = wrapi(_col, 0, Shared.palette.size())
	
	var params = [["hat"], ["skin"], ["suit"], ["eye", "shoe"]]
	for i in params[_row]:
		player_mat.set_shader_param(i + "_swap", Shared.palette[colors[_row]])

func fill_swatches(_row := cursor_y -1):
	var offset = [-2, -1, 0, 1, 2]
	for i in 5:
		swatches[_row][i].color = Shared.palette[wrapi(colors[_row] + offset[i], 0, Shared.palette.size())]

func _physics_process(delta):
	# blink
	blink_clock -= delta
	if blink_clock < -blink_off:
		blink_clock = blink_on
	cursors_parent.modulate = Color("ff004d" if blink_clock > 0.0 else "ff77a8")
