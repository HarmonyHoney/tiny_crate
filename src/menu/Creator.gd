extends Node2D

onready var keyboard := $Keyboard
var rows : Array = []#keyboard.get_children()

onready var cursor_node := $Cursor
var cursor_x := 0
var cursor_y := 0

onready var name_label := $Name
onready var done_node := $Done

export (Array, Color) var palette := []
var colors = [7, 0, 10, 13]
var swatches = []

onready var player_mat : ShaderMaterial = $Player/Sprite.material


func _ready():
	# setup rows & columns
	rows = []
	for i in $ColorPick.get_children():
		rows.append([i])
	
	for i in keyboard.get_children():
		rows.append(i.get_children())
	rows.append([done_node])
	
	move_cursor()
	
	# setup swatches
	swatches = []
	for i in $Colors.get_children():
		swatches.append(i.get_children())
		
	for i in 4:
		fill_swatches(i)

func _input(event):
	if event.is_action_pressed("jump"):
		# write letter
		if cursor_y > 3 and cursor_y < 8:
			var s = rows[cursor_y][cursor_x].get_child(0).text
			var l = name_label.text
			name_label.text = (l + s).substr(0, 16)
	elif event.is_action_pressed("action"):
		# erase letter
		if cursor_y > 3 and cursor_y < 8:
			var s = name_label.text
			s.erase(s.length() - 1, 1)
			name_label.text = s
	else:
		var btnx = btn.p("right") - btn.p("left")
		var btny = btn.p("down") - btn.p("up")
		
		if btnx != 0:
			move_cursor(cursor_x + btnx)
			
			if cursor_y < 4:
				set_color(cursor_y, colors[cursor_y] + btnx)
				fill_swatches()
		elif btny != 0:
			if cursor_y == 4 and btny == -1: cursor_x = 4
			move_cursor(cursor_x, cursor_y + btny)


func move_cursor(_x := cursor_x, _y = cursor_y):
	cursor_y = clamp(_y, 0, rows.size() - 1)
	cursor_x = wrapi(_x, 0, rows[cursor_y].size() - 1)
	
	cursor_node.rect_global_position = rows[cursor_y][cursor_x].rect_global_position
	cursor_node.rect_size = rows[cursor_y][cursor_x].rect_size


func set_color(_row := cursor_y, _col = colors[cursor_y]):
	colors[_row] = wrapi(_col, 0, palette.size())
	
	var params = [["hat"], ["skin"], ["suit"], ["eye", "shoe"]]
	for i in params[_row]:
		player_mat.set_shader_param(i + "_swap", palette[colors[_row]])

func fill_swatches(_row := cursor_y):
	var offset = [-2, -1, 0, 1, 2]
	for i in 5:
		swatches[_row][i].color = palette[wrapi(colors[_row] + offset[i], 0, palette.size())]
	
	

func _physics_process(delta):
	pass
