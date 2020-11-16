
extends Node2D


var label_list : RichTextLabel
var label_info : RichTextLabel

export(String, MULTILINE) var map_list : String

var maps : PoolStringArray = []
var cursor := 0
var line_height = 9


func _ready():
	label_list = $Control/List
	label_info = $Control/Info
	
	maps.append_array(map_list.split("\n", false))
	label_list.text = map_list
	

func _process(delta):
	var btny = btn.p("down") - btn.p("up")
	if btny:
		cursor = clamp(cursor + btny, 0, maps.size() - 1)
		label_list.rect_position.y = 90 - (cursor * line_height)
		label_info.text = str(cursor) + " / " + maps[cursor] + "\n"
		
		for i in Shared.stage_data:
			if i.has("file") and i.file == "res://Map/" + maps[cursor] + ".tscn":
				label_info.text += "name: " + str(i.name) + "\n"
				label_info.text += "file: " + str(i.file) + "\n"
				label_info.text += "time: " + str(i.time) + "\n"
				label_info.text += "deaths: " + str(i.death) + "\n"
				break
	
	if btn.p("action"):
		get_tree().change_scene("res://Map/" + maps[cursor] + ".tscn")
	
	
