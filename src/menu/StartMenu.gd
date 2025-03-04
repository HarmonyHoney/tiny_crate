extends Menu

onready var main_menu := $Control/Main
onready var quit_menu := $Control/Quit
onready var slot_menu := $Control/Slot
onready var open_menu := $Control/Open
onready var erase_menu := $Control/Erase
onready var user_label := $Username/Label
onready var menu_stuff := main_menu.get_children()
onready var credits_node := $Credits
onready var stage := $Stage
onready var cam := Shared.cam

export var open_player_path : NodePath = ""
onready var open_player_mat : ShaderMaterial = get_node(open_player_path).material

export var demo_player_path : NodePath = ""
onready var demo_player_mat : ShaderMaterial = get_node(demo_player_path).sprite_mat

var menu_items := []
var main_items := ["play", "options", "credits"]
var quit_items := ["yes", "no"]
var slot_items := ["slot", "slot", "slot"]
var open_items := ["load", "creator", "erase"]
var erase_items := ["really erase", "no erase"]

var menu_name := "main"
var menu_last := menu_name
var name_offset := 0

export var is_credits := false

func _ready():
	randomize()
	Player.set_palette(demo_player_mat, Shared.pick_player_colors())
	
	setup_slots()
	
	user_label.text = Shared.username
	switch_menu(Shared.last_menu, true)
	self.cursor = Shared.last_cursor
	credits_node.visible = false
	
	open(true)

func menu_process(delta):
	.menu_process(delta)
	
	if menu_name == "slot":
		user_label.rect_global_position = cursor_node.rect_global_position + cursor_node.rect_size + Vector2(2, -8)
	
	if menu_name == "open":
		user_label.rect_global_position = user_label.rect_global_position.linear_interpolate(list[0].rect_global_position + Vector2((name_offset * 3) - 12, -8), 0.15)

func on_cursor():
	if menu_name == "slot":
		var s = ""
		var dat = Shared.save_data
		if dat[cursor].has("username"):
			s = dat[cursor]["username"]
		
		user_label.text = s

func btn_no():
	if is_credits:
		is_credits = false
		credits_node.visible = false
		close_sub()
		Audio.play("menu_back", 0.3, 2.0)
		stage.rnd()
		Player.set_palette(demo_player_mat, Shared.pick_player_colors())
	else:
		if menu_items == open_items:
			Player.set_palette(demo_player_mat, Shared.pick_player_colors())
		var s = "main"
		match menu_items:
			main_items: s = "quit"
			open_items: s = "slot"
			erase_items: s = "open"
		switch_menu(s)

func btn_yes():
	if !is_credits:
		menu_select()

func btn_y(arg := 1):
	if !is_credits:
		.btn_y(arg)

func setup_slots():
	var slot_items := slot_menu.get_children()
	for i in Shared.save_limit:
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

func menu_select(tag : String = menu_items[clamp(cursor, 0, menu_items.size() - 1)].to_lower()):
	Shared.last_cursor = cursor
	match tag:
		"play":
			switch_menu("slot")
		"creator":
			Shared.wipe_scene(Shared.creator_path)
			Audio.play("menu_play", 0.9, 1.1)
		"options":
			open_sub(OptionsMenu)
			Audio.play("menu_options", 0.9, 1.1)
			cam.pos_target += Vector2(24, -4)
		"credits":
			is_credits = true
			credits_node.visible = true
			if parent_node:
				parent_node.visible = false
			cam.pos_target += Vector2(104, 0)
			Audio.play("menu_options", 0.9, 1.1)
			UI.keys(false, false, false, false)
			TouchScreen.show_keys()
		"yes":
			Audio.play("menu_yes", 0.9, 1.1)
			menu_stuff[cursor].text = "quit!!"
			if OS.get_name() == "HTML5":
				Shared.wipe_scene(Shared.splash_path)
			else:
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
			setup_slots()
			switch_menu("slot")
		"no erase":
			switch_menu("open")
			

func on_close_sub():
	cam.pos_target = Vector2(90, 76)
	UI.keys(false)

func switch_menu(arg, silent := false, _cursor := 0):
	user_label.visible = arg == "slot" or arg == "open"
	
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
		open_clock = open_time
		menu_items = items[x]
		menu_stuff = node[x].get_children()
		make_list(node[x])
		
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
				user_label.visible = true
			"open":
				Shared.load_save(Shared.last_slot)
				Player.set_palette(open_player_mat, Shared.player_colors)
				Player.set_palette(demo_player_mat, Shared.player_colors)
				if menu_last == "erase":
					_cursor = 2
				name_offset = abs(min(user_label.text.length() - 10 , 0))
			"main":
				Shared.last_slot = -1
		
		self.cursor = _cursor
		Shared.last_menu = arg
