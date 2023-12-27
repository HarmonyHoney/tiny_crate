extends Node2D

onready var keyboard := $Menu/Keyboard
var rows : Array = []#keyboard.get_children()

onready var cursor_node := $Menu/Cursor
var cursor_x := 0
var cursor_y := 0
onready var arrows := $Menu/Arrows

onready var name_label := $Menu/Name
onready var done_node := $Menu/Done

var colors = [0, 0, 0, 0]
var swatches = []

onready var player_mat : ShaderMaterial = $Player/Sprite.material
var is_input := true

func _ready():
	# setup rows & columns
	rows = []
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
	colors = Shared.player_colors
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
		if (cursor_y == 3 and btny == 1) or (cursor_y == 8 and btny == -1): cursor_x = 4
		move_cursor(cursor_x, cursor_y + btny)
	
	elif cursor_y < 4:
		if btnx != 0 or is_jump or is_action:
			var c = btnx
			if btnx == 0:
				c = 1 if is_action else -1
			set_color(cursor_y, colors[cursor_y] + c)
			fill_swatches()
	elif cursor_y > 3 and cursor_y < 8:
		if btnx != 0:
			move_cursor(cursor_x + btnx)
		# erase letter
		if is_action:
			var s = name_label.text
			s.erase(s.length() - 1, 1)
			name_label.text = s
		
		# write letter
		elif is_jump:
			var s = rows[cursor_y][cursor_x].get_child(0).text
			var l = name_label.text
			name_label.text = (l + s).substr(0, 16)
	elif cursor_y == rows.size() - 1:
		if is_jump:
			Shared.wipe_scene(Shared.main_menu_path)
			is_input = false
			Shared.username = name_label.text
			Shared.player_colors = colors
			Shared.save_data["username"] = Shared.username
			Shared.save_data["player_colors"] = Shared.player_colors

func move_cursor(_x := cursor_x, _y = cursor_y):
	cursor_y = clamp(_y, 0, rows.size() - 1)
	cursor_x = wrapi(_x, 0, rows[cursor_y].size())
	
	cursor_node.rect_global_position = rows[cursor_y][cursor_x].rect_global_position
	cursor_node.rect_size = rows[cursor_y][cursor_x].rect_size
	
	arrows.rect_global_position = cursor_node.rect_global_position
	arrows.visible = cursor_y < 4


func set_color(_row := cursor_y, _col = colors[cursor_y]):
	colors[_row] = wrapi(_col, 0, Shared.palette.size())
	
	var params = [["hat"], ["skin"], ["suit"], ["eye", "shoe"]]
	for i in params[_row]:
		player_mat.set_shader_param(i + "_swap", Shared.palette[colors[_row]])

func fill_swatches(_row := cursor_y):
	var offset = [-2, -1, 0, 1, 2]
	for i in 5:
		swatches[_row][i].color = Shared.palette[wrapi(colors[_row] + offset[i], 0, Shared.palette.size())]
	
	

func _physics_process(delta):
	pass
