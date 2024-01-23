extends Node2D

onready var control := $Control
onready var main_menu := $Control/Main
onready var quit_menu := $Control/Quit
onready var slot_menu := $Control/Slot
onready var open_menu := $Control/Open
onready var erase_menu := $Control/Erase
onready var menu_stuff := main_menu.get_children()
onready var cursor_node := $Control/Cursor
export var open_player_path : NodePath = ""
onready var open_player_mat : ShaderMaterial = get_node(open_player_path).material

export var demo_player_path : NodePath = ""
onready var demo_player_mat : ShaderMaterial = get_node(demo_player_path).sprite_mat

var cursor := 0 setget set_cursor
var menu_items := []
var main_items := ["play", "options", "credits"]
var quit_items := ["yes", "no"]
var slot_items := ["slot", "slot", "slot"]
var open_items := ["load", "creator", "erase"]
var erase_items := ["really erase", "no erase"]

var menu_name := "main"
var menu_last := menu_name

var is_input = true

export var cursor_offset := Vector2.ZERO
export var cursor_expand := Vector2.ZERO

export var color_select := Color.white
export var color_deselect := Color(1,1,1, 0.7)

var switch_clock := 0.0
export var switch_cooldown := 0.1

func _ready():
	randomize()
	Player.set_palette(demo_player_mat, Shared.pick_player_colors())
	Shared.load_slots()
	
	setup_slots()
	
	switch_menu(Shared.last_menu, true)
	self.cursor = Shared.last_cursor
	

func setup_slots():
	var slot_items := slot_menu.get_children()
	for i in 3:
		var si = slot_items[i]
		var sd = Shared.save_data[i]
		var gem_label = si.get_node("Label0")
		var note_label = si.get_node("Label1")
		var note_image = si.get_node("Image1")
		var player_mat = si.get_node("Player/Sprite").material
		
		if sd.empty():
			for y in si.get_children():
				var is_name : bool = y.name == "Label0"
				y.visible = is_name
				if is_name: y.text = "new run"
		else:
			if sd.has("gems"):
				gem_label.text = str(sd["gems"])
			
			if sd.has("notes") and int(sd["notes"]) > 0:
				note_label.text = str(sd["notes"])
			else:
				note_label.visible = false
				note_image.visible = false
			
			if sd.has("player_colors"):
				Player.set_palette(player_mat, sd["player_colors"])

func _input(event):
	if !is_input or Wipe.is_wipe or switch_clock > 0.0: return
	
	if event.is_action_pressed("ui_no"):
		if menu_items == open_items:
			Player.set_palette(demo_player_mat, Shared.pick_player_colors())
		var s = "main"
		match menu_items:
			main_items: s = "quit"
			open_items: s = "slot"
			erase_items: s = "open"
		switch_menu(s)
	elif event.is_action_pressed("ui_yes"):
		menu_select()
	else:
		var up = event.is_action_pressed("ui_up")# or event.is_action_pressed("ui_left")
		var down = event.is_action_pressed("ui_down")# or event.is_action_pressed("ui_right")
		if up or down:
			self.cursor += -1 if up else 1
			Audio.play("menu_scroll", 0.8, 1.2)

func _physics_process(delta):
	switch_clock = max(0, switch_clock - delta)

func write_menu():
	yield(get_tree(), "idle_frame")
	cursor_node.rect_global_position = menu_stuff[cursor].rect_global_position + cursor_offset
	cursor_node.rect_size = menu_stuff[cursor].rect_size + cursor_expand
	
	for i in menu_items.size():
		menu_stuff[i].modulate = color_select if i == cursor else color_deselect

func menu_select(tag : String = menu_items[cursor].to_lower()):
	Shared.last_cursor = cursor
	match tag:
		"play":
			switch_menu("slot")
		"creator":
			Shared.wipe_scene(Shared.creator_path)
			Audio.play("menu_play", 0.9, 1.1)
		"options":
			OptionsMenu.open(true, self)
			is_input = false
			Audio.play("menu_options", 0.9, 1.1)
			Shared.cam.pos_target += Vector2(24, -4)
			control.visible = false
		"credits":
			Shared.wipe_scene(Shared.credits_path)
			Audio.play("menu_pick", 0.9, 1.1)
		"yes":
			Audio.play("menu_yes", 0.9, 1.1)
			if OS.get_name() == "HTML5":
				Shared.wipe_scene(Shared.splash_path)
			else:
				menu_stuff[cursor].text = "quit!!"
				Shared.wipe_quit()
		"no":
			switch_menu("main")
		"slot":
			Audio.play("menu_play", 0.9, 1.1)
			Shared.last_slot = cursor
			
			if Shared.save_data[cursor].empty():
				Shared.load_save(cursor)
				Shared.wipe_scene(Shared.creator_path)
			else:
				switch_menu("open")
			
		"load":
			Shared.wipe_scene(Shared.level_select_path)
		"erase":
			switch_menu("erase")
		"really erase":
			Shared.delete_slot(Shared.last_slot)
			Shared.load_save(Shared.last_slot)
			setup_slots()
			switch_menu("slot")
		"no erase":
			switch_menu("open")
			

func resume():
	is_input = true
	Shared.cam.pos_target = Vector2(90, 76)
	UI.keys(false)
	control.visible = true

func switch_menu(arg, silent := false, _cursor := 0):
	var s = ["quit", "main", "slot", "open", "erase"]
	var items = [quit_items, main_items, slot_items, open_items, erase_items]
	var node = [quit_menu, main_menu, slot_menu, open_menu, erase_menu]
	var audio = ["pick", "exit", "pick", "pick", "pick"]
	var x = -1
	for i in s.size():
		node[i].visible = arg == s[i]
		if arg == s[i]:
			x = i
	
	if x > -1:
		switch_clock = switch_cooldown
		menu_items = items[x]
		menu_stuff = node[x].get_children()
		
		menu_last = menu_name
		menu_name = arg
		
		if !silent:
			Audio.play("menu_" + audio[x], 0.9, 1.1)
		
		match menu_name:
			"quit":
				_cursor = 1
			"erase":
				_cursor = 1
			"slot":
				_cursor = Shared.last_slot
				Shared.map_select = 0
			"open":
				Shared.load_save(Shared.last_slot)
				Player.set_palette(open_player_mat, Shared.player_colors)
				Player.set_palette(demo_player_mat, Shared.player_colors)
				if menu_last == "erase":
					_cursor = 2
			"main":
				Shared.last_slot = -1
		
		self.cursor = _cursor
		Shared.last_menu = arg

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, menu_items.size() - 1)
	write_menu()
