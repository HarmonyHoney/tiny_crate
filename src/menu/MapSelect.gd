extends Node2D


var label_list : RichTextLabel
var label_info : RichTextLabel

var map_path := "res://src/map/"
var map_list : String
var maps : PoolStringArray = []
var cursor := 0
var line_height = 9

var viewport : Viewport


func _ready():
	label_list = $Control/List
	label_info = $Control/Info
	viewport = $Control/ViewportContainer/Viewport
	
	map_list = ""
	var dir = Directory.new()
	if dir.open(map_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name:
			print(file_name.split(".")[0])
			map_list += file_name.split(".")[0] + "\n"
			file_name = dir.get_next()
		dir.list_dir_end()
	
	
	maps.append_array(map_list.split("\n", false))
	label_list.text = map_list
	
	scroll()
	
	HUD.hide()

func _process(delta):
	var btny = btn.p("down") - btn.p("up")
	if btny:
		scroll(btny)
	
	if btn.p("jump"):
		select()

func select():
	Shared.map_name = maps[cursor]
	get_tree().change_scene(map_path + maps[cursor] + ".tscn")
	HUD.show()


func scroll(arg = 0):
	cursor = clamp(cursor + arg, 0, maps.size() - 1)
	label_list.rect_position.y = 90 - (cursor * line_height)
	info()
	view_map()

func info():
	label_info.text = str(cursor) + " / " + maps[cursor] + "\n"
	for i in Shared.stage_data:
		if i.has("file") and i.file == map_path + maps[cursor] + ".tscn":
			for j in i.size():
				label_info.text += str(i.keys()[j]) + ": " + str(i.values()[j]) + "\n"
			break

func view_map():
	for i in viewport.get_children():
		i.queue_free()
	
	if ResourceLoader.exists(map_path + maps[cursor] + ".tscn"):
		var m = load(map_path + maps[cursor] + ".tscn").instance()
		viewport.add_child(m)
		for i in get_tree().get_nodes_in_group("player"):
			i.set_process(false) # dont process player




