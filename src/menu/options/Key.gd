tool
extends Control

export var text := "key" setget set_text

onready var white := $White
onready var black := $Black
onready var label := $Label

func _ready():
	set_text()
	if Engine.editor_hint: return

func set_text(arg := text):
	text = arg
	var l = text.length() * 6.0
	
	rect_min_size = Vector2(l + 3, 9)
	
	if is_instance_valid(label):
		label.text = text
		label.rect_size = Vector2.ONE
		
	if is_instance_valid(white):
		white.rect_size = rect_min_size
	if is_instance_valid(black):
		black.rect_size = Vector2(l + 1, 7)
	
	update()
