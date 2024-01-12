extends Node2D

onready var main_menu := $Control/Main
onready var quit_menu := $Control/Quit
onready var slot_menu := $Control/Slot
onready var menu_stuff := main_menu.get_children()
onready var cursor_node := $Control/Cursor

var cursor := 0 setget set_cursor
var menu_items := []
var main_items := ["play", "creator", "options", "credits"]
var quit_items := ["yes", "no"]
var slot_items := ["slot", "slot", "slot"]
var is_input = true

export var blink_on := 0.3
export var blink_off := 0.2
var blink_clock := 0.0
export var cursor_offset := Vector2.ZERO
export var cursor_expand := Vector2.ZERO

export var color_select := Color.white
export var color_deselect := Color(1,1,1, 0.7)
export var color_blink : PoolColorArray = ["ff004d", "ff77a8"]

func _enter_tree():
	randomize()
	Shared.player_colors = Shared.preset_palettes[randi() % Shared.preset_palettes.size()]

func _ready():
	switch_menu("main", true)
	
	Shared.load_slots()
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
	if !is_input:
		return
	if event.is_action_pressed("action"):
		switch_menu("quit" if menu_items == main_items else "main")
	elif event.is_action_pressed("jump"):
		menu_select()
	else:
		var up = event.is_action_pressed("up") or event.is_action_pressed("left")
		var down = event.is_action_pressed("down") or event.is_action_pressed("right")
		if up or down:
			self.cursor += -1 if up else 1
			Audio.play("menu_scroll", 0.8, 1.2)

func _physics_process(delta):
	# blink
	blink_clock -= delta
	if blink_clock < -blink_off:
		blink_clock = blink_on
	cursor_node.modulate = color_blink[int(blink_clock > 0.0)]

func write_menu():
	cursor_node.rect_global_position = menu_stuff[cursor].rect_global_position + cursor_offset
	cursor_node.rect_size = menu_stuff[cursor].rect_size + cursor_expand
	
	for i in menu_items.size():
		menu_stuff[i].modulate = color_select if i == cursor else color_deselect

func menu_select(tag : String = menu_items[cursor].to_lower()):
	match tag:
		"play":
			switch_menu("slot")
		"creator":
			Shared.wipe_scene(Shared.creator_path)
			is_input = false
			Audio.play("menu_play", 0.9, 1.1)
		"options":
			Shared.wipe_scene(Shared.options_menu_path)
			is_input = false
			Audio.play("menu_options", 0.9, 1.1)
		"credits":
			Shared.wipe_scene(Shared.credits_path)
			is_input = false
			Audio.play("menu_pick", 0.9, 1.1)
		"yes":
			is_input = false
			Audio.play("menu_yes", 0.9, 1.1)
			if OS.get_name() == "HTML5":
				Shared.wipe_scene(Shared.splash_path)
			else:
				menu_stuff[cursor].text = "quit!!"
				Shared.wipe_quit()
		"no":
			switch_menu("main")
		"slot":
			is_input = false
			if Shared.save_data[cursor].empty():
				Shared.wipe_scene(Shared.creator_path)
			else:
				Shared.load_slot(cursor)
				Shared.wipe_scene(Shared.level_select_path)
			Audio.play("menu_play", 0.9, 1.1)

func switch_menu(arg, silent := false):
	var s = ["quit", "main", "slot"]
	var items = [quit_items, main_items, slot_items]
	var node = [quit_menu, main_menu, slot_menu]
	var audio = ["pick", "exit", "pick"]
	for i in 3:
		node[i].visible = arg == s[i]
		if arg == s[i]:
			menu_items = items[i]
			menu_stuff = node[i].get_children()
			if !silent:
				Audio.play("menu_" + audio[i], 0.9, 1.1)
	
	self.cursor = 1 if arg == "quit" else 0

func find_cursor(arg := ""):
	if is_input and menu_items.has(arg):
		self.cursor = menu_items.find(arg)
		menu_select()

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, menu_items.size() - 1)
	write_menu()
