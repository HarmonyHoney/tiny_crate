
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
	
	scroll()

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
	label_info.text = str(cursor) + " / " + maps[cursor] + "\n"
	
	for i in Shared.stage_data:
		if i.has("file") and i.file == "res://Map/" + maps[cursor] + ".tscn":
			label_info.text += "file: " + str(i.file) + "\n"
			if i.has("complete"):
				label_info.text += "complete: " + str(i.complete) + "\n"
			label_info.text += "name: " + str(i.name) + "\n"
			label_info.text += "time: " + str(i.time) + "\n"
			label_info.text += "deaths: " + str(i.death) + "\n"
			if i.has("pickup") and i.has("jump"):
				label_info.text += "boxes picked up: " + str(i.pickup) + "\n"
				label_info.text += "jumps: " + str(i.jump) + "\n"
			break


