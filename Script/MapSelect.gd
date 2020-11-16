
extends Node2D


var label_list : RichTextLabel
var label_info : RichTextLabel

var map_list : String
var maps : PoolStringArray = []
var cursor := 0
var line_height = 9


func _ready():
	label_list = $Control/List
	label_info = $Control/Info
	
	map_list = ""
	var dir = Directory.new()
	if dir.open("res://Map") == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name:
			print(file_name.split(".")[0])
			map_list += file_name.split(".")[0] + "\n"
			file_name = dir.get_next()
		dir.list_dir_end()
	
	
	maps.append_array(map_list.split("\n", false))
	label_list.text = map_list
	
	info()

func _process(delta):
	var btny = btn.p("down") - btn.p("up")
	if btny:
		scroll(btny)
	
	if btn.p("action"):
		Shared.map_name = maps[cursor]
		get_tree().change_scene("res://Map/" + maps[cursor] + ".tscn")


func scroll(arg = 0):
	cursor = clamp(cursor + arg, 0, maps.size() - 1)
	label_list.rect_position.y = 90 - (cursor * line_height)
	info()

func info():
	label_info.text = str(cursor) + " / " + maps[cursor] + "\n"
	for i in Shared.stage_data:
		if i.has("file") and i.file == "res://Map/" + maps[cursor] + ".tscn":
			for j in i.size():
				label_info.text += str(i.keys()[j]) + ": " + str(i.values()[j]) + "\n"
			break






